using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;

namespace Edugate_Project
{
    public partial class Scholarships : System.Web.UI.Page
    {
        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Student display
                litStudentFullName.Text = Convert.ToString(Session["StudentFullName"] ?? "Student");

                // List
                BindScholarships(null, null, null);

                // Pre-fill assist form (optional)
                txtFullName.Text = Convert.ToString(Session["StudentFullName"] ?? "");
                txtEmail.Text = Convert.ToString(Session["StudentEmail"] ?? "");
                txtStudentId.Text = Convert.ToString(Session["StudentId"] ?? "");
            }
        }

        private void BindScholarships(string field, decimal? minAmount, int? days)
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT ScholarshipId, [Name], Amount, [Deadline], [Field], [Type], [Description], ApplicationUrl
FROM dbo.Scholarships
WHERE IsActive = 1
  AND (@field IS NULL OR NULLIF(@field,'') IS NULL OR [Field] = @field)
  AND (@minAmt IS NULL OR Amount >= @minAmt)
  AND (@days IS NULL OR ([Deadline] IS NOT NULL AND [Deadline] <= DATEADD(DAY, CONVERT(int,@days), CAST(GETDATE() AS date))))
ORDER BY ISNULL([Deadline], '9999-12-31'), [Name];", cn))
            {
                cmd.Parameters.AddWithValue("@field", (object)field ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@minAmt", (object)minAmount ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@days", (object)days ?? DBNull.Value);

                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                rptScholarships.DataSource = dt;
                rptScholarships.DataBind();
            }
        }

        protected void FilterScholarships(object sender, EventArgs e)
        {
            string field = ddlField.SelectedValue;

            decimal? minAmount = null;
            if (decimal.TryParse(ddlAmount.SelectedValue, out var amt)) minAmount = amt;

            int? days = null;
            if (int.TryParse(ddlDeadline.SelectedValue, out var dd)) days = dd;

            BindScholarships(field, minAmount, days);
        }

        /* ========== APPLY: WEBSITE (client button uses JS goToWebsite()) ========== */
        protected void btnApplyWebsite_Click(object sender, EventArgs e)
        {
            // Keeping this as a backup if you wire a server button again.
            var raw = (hfApplyUrl.Value ?? "").Trim();
            if (string.IsNullOrWhiteSpace(raw))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "noUrl",
                    "showToast('No website link for this scholarship.');", true);
                return;
            }

            string url = raw;
            if (!(url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                  url.StartsWith("https://", StringComparison.OrdinalIgnoreCase)))
            {
                url = "https://" + url.TrimStart('/');
            }

            ScriptManager.RegisterStartupScript(
                this, GetType(), "goApply",
                $"window.location.href='{url.Replace("'", "\\'")}';", true
            );
        }

        /* ========== APPLY: SHOW ASSIST PANEL ========== */
        protected void btnShowAssist_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "showAssist", "showAssistPanel();", true);
        }

        /* ========== ASSIST: SUBMIT DOCUMENTS (ALWAYS INSERTS APPLICATION FIRST) ========== */
        protected void btnSubmitAssist_Click(object sender, EventArgs e)
        {
            try
            {
                var fullName = (txtFullName.Text ?? "").Trim();
                var email = (txtEmail.Text ?? "").Trim();
                var phone = (txtPhone.Text ?? "").Trim();
                var studentId = (txtStudentId.Text ?? "").Trim();
                var motivation = (txtMotivation.Text ?? "").Trim();

                if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
                {
                    Toast("Name and Email are required.");
                    ScriptManager.RegisterStartupScript(this, GetType(), "showAssist2", "showAssistPanel();", true);
                    return;
                }

                if (!int.TryParse((hfApplyScholarshipId.Value ?? "").Trim(), out int scholarshipId) || scholarshipId <= 0)
                {
                    Toast("Please click Apply on a specific scholarship first.");
                    return;
                }

                int newAppId;

                // 1) Insert the application row FIRST (no transaction),
                // so even if file writing fails, we keep the application.
                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.ScholarshipApplications
(
    ScholarshipId, StudentId, StudentFullName, StudentEmail, Notes, SubmittedOn, Status,
    FullName, Email, Phone, Motivation, CreatedOn
)
VALUES
(
    @sid, @studentId, @studentFullName, @studentEmail, @notes, GETDATE(), 'Pending',
    @fullName, @email, @phone, @motivation, GETDATE()
);
SELECT CAST(SCOPE_IDENTITY() AS int);", cn))
                {
                    cmd.Parameters.AddWithValue("@sid", scholarshipId);

                    if (int.TryParse(studentId, out int sidInt))
                        cmd.Parameters.AddWithValue("@studentId", sidInt);
                    else
                        cmd.Parameters.AddWithValue("@studentId", DBNull.Value);

                    cmd.Parameters.AddWithValue("@studentFullName", fullName);
                    cmd.Parameters.AddWithValue("@studentEmail", email);
                    cmd.Parameters.AddWithValue("@notes", string.IsNullOrWhiteSpace(motivation) ? (object)DBNull.Value : motivation);

                    cmd.Parameters.AddWithValue("@fullName", fullName);
                    cmd.Parameters.AddWithValue("@email", email);
                    cmd.Parameters.AddWithValue("@phone", string.IsNullOrWhiteSpace(phone) ? (object)DBNull.Value : phone);
                    cmd.Parameters.AddWithValue("@motivation", string.IsNullOrWhiteSpace(motivation) ? (object)DBNull.Value : motivation);

                    cn.Open();
                    newAppId = (int)cmd.ExecuteScalar();
                }

                // 2) Try to save files; errors here won't delete the application.
                string appFolder = Server.MapPath($"~/Uploads/Scholarships/{newAppId}");
                try
                {
                    if (!Directory.Exists(appFolder))
                        Directory.CreateDirectory(appFolder);
                }
                catch (Exception dirEx)
                {
                    // Still keep the application, just inform about files
                    Toast("Saved application, but could not create folder for files: " + Safe(dirEx.Message));
                    ScriptManager.RegisterStartupScript(this, GetType(), "hideAssist", "hideAssistPanel();", true);
                    return;
                }

                // Each file saved independently; failures reported but not fatal.
                TrySaveOneFile(newAppId, "ID", fuIdDoc, appFolder);
               
                Toast("Your documents were submitted for assistance.");
                ScriptManager.RegisterStartupScript(this, GetType(), "hideAssist", "hideAssistPanel();", true);

                // Optional clear
                txtMotivation.Text = string.Empty;
                txtPhone.Text = string.Empty;
            }
            catch (Exception ex)
            {
                Toast("Upload failed: " + Safe(ex.Message));
                ScriptManager.RegisterStartupScript(this, GetType(), "showAssist3", "showAssistPanel();", true);
            }
        }

        /* -------- helpers -------- */

        private void TrySaveOneFile(int appId, string docType, System.Web.UI.WebControls.FileUpload fu, string folder)
        {
            if (fu == null || !fu.HasFile) return;

            // Save to disk
            var safeName = Path.GetFileName(fu.FileName);
            var absPath = Path.Combine(folder, safeName);
            fu.SaveAs(absPath);

            // Save DB record
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
INSERT INTO dbo.ScholarshipApplicationFiles
    (ApplicationId, DocType, FilePath, OriginalFileName, ContentType, FileSizeBytes, UploadedOn)
VALUES
    (@app, @doc, @path, @orig, @ct, @size, GETDATE());", cn))
            {
                cmd.Parameters.AddWithValue("@app", appId);
                cmd.Parameters.AddWithValue("@doc", (object)docType ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@path", $"~/Uploads/Scholarships/{appId}/{safeName}");
                cmd.Parameters.AddWithValue("@orig", safeName);
                cmd.Parameters.AddWithValue("@ct", fu.PostedFile.ContentType ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@size", fu.PostedFile.ContentLength);
                cn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void Toast(string message)
        {
            var msg = Safe(message ?? "Done");
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"),
                $"showToast('{msg}');", true);
        }

        private string Safe(string s) => HttpUtility.JavaScriptStringEncode(s ?? string.Empty);
    }
}
