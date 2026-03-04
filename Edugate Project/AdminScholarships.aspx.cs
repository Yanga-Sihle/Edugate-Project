using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class AdminScholarships : System.Web.UI.Page
    {
        private string ConnectionString => ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null) Response.Redirect("~/Default.aspx");
            if (!IsPostBack)
            {
                BindScholarshipGrid();
                BindApplicationsGrid();
            }
        }

        /* ---------------------- Create scholarship ---------------------- */

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                decimal? amount = null;
                if (decimal.TryParse(txtAmount.Text, out var amt)) amount = amt;

                DateTime? deadline = null;
                if (DateTime.TryParse(txtDeadline.Text, out var d)) deadline = d;

                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.Scholarships
    (Name, Amount, Deadline, Field, [Type], [Description],
     ApplicationUrl, RequiresDocuments, RequiredDocuments, IsActive, CreatedBy)
VALUES
    (@name, @amount, @deadline, @field, @type, @desc,
     @url, @reqDocs, @reqList, 1, @createdBy);", cn))
                {
                    cmd.Parameters.AddWithValue("@name", (txtName.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@amount", (object)amount ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@deadline", (object)deadline ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@field", (txtField.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@type", (txtType.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@desc", (txtDescription.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@url", (txtUrl.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@reqDocs", chkRequiresDocs.Checked);
                    cmd.Parameters.AddWithValue("@reqList", (txtRequiredDocs.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@createdBy", Convert.ToString(Session["AdminId"] ?? "Admin"));

                    cn.Open();
                    cmd.ExecuteNonQuery();
                }

                ClearForm();
                BindScholarshipGrid();
            }
            catch
            {
                throw;
            }
        }

        private void ClearForm()
        {
            txtName.Text = txtAmount.Text = txtField.Text = txtType.Text = txtDescription.Text = txtUrl.Text = txtRequiredDocs.Text = string.Empty;
            chkRequiresDocs.Checked = true;
            txtDeadline.Text = string.Empty;
        }

        /* ---------------------- Existing scholarships grid ---------------------- */

        private void BindScholarshipGrid()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT ScholarshipId, Name, Amount, Deadline, Field, [Type], ApplicationUrl, RequiresDocuments, IsActive
FROM dbo.Scholarships
ORDER BY ISNULL(Deadline, '9999-12-31'), Name;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvScholarships.DataSource = dt;
                gvScholarships.DataBind();
            }
        }

        protected void gvScholarships_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvScholarships.PageIndex = e.NewPageIndex;
            BindScholarshipGrid();
        }

        /* ---------------------- Assisted Applications grid (NEW) ---------------------- */

        private void BindApplicationsGrid()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT 
    a.ApplicationId,
    a.ScholarshipId,
    s.Name AS ScholarshipName,
    s.ApplicationUrl,
    a.StudentFullName,
    a.StudentEmail,
    a.SubmittedOn,
    a.Status,
    a.UploadedZipPath
FROM dbo.ScholarshipApplications a
JOIN dbo.Scholarships s ON s.ScholarshipId = a.ScholarshipId
ORDER BY a.SubmittedOn DESC, a.ApplicationId DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvApplications.DataSource = dt;
                gvApplications.DataBind();
            }
        }

        protected void gvApplications_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvApplications.PageIndex = e.NewPageIndex;
            BindApplicationsGrid();
        }

        protected void gvApplications_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            // Bind per-application files to inner Repeater
            var rpt = (Repeater)e.Row.FindControl("rptFiles");
            if (rpt == null) return;

            var dataItem = (DataRowView)e.Row.DataItem;
            int appId = Convert.ToInt32(dataItem["ApplicationId"]);

            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT FileId, ApplicationId, DocType, FilePath, OriginalFileName
FROM dbo.ScholarshipApplicationFiles
WHERE ApplicationId = @app
ORDER BY FileId;", cn))
            {
                cmd.Parameters.AddWithValue("@app", appId);
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                rpt.DataSource = dt;
                rpt.DataBind();
            }
        }
    }
}
