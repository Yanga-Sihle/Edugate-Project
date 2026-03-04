using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class SchoolDashboard : System.Web.UI.Page
    {
        private readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["SchoolCode"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                string schoolCode = Session["SchoolCode"].ToString();
                LoadSchoolProfile(schoolCode);
                LoadDashboardStats(schoolCode);
                BindLearnersGrid(schoolCode);
                BindRecentActivity(schoolCode);
                CheckSubscriptionStatus(schoolCode);
                BindPaymentHistory(schoolCode);
                UpdatePaymentStatusBadge(schoolCode);
            }

            // keep selected tab on refresh / postback
            ScriptManager.RegisterStartupScript(this, GetType(), "tabPersistence",
                "if(sessionStorage.getItem('activeTab')){setTimeout(function(){var t=sessionStorage.getItem('activeTab');var b=[...document.querySelectorAll('.tab-btn')].find(x=>x.getAttribute('onclick')?.includes(t));if(b) b.click();},100);}", true);
        }

        /* =========================
           Subscription buttons
        ==========================*/
        protected void btnUpgrade_Click(object sender, EventArgs e)
        {
            if (Session["SchoolCode"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string schoolCode = Session["SchoolCode"].ToString();
            CreateSubscriptionChangeRequest(schoolCode, true);
        }

        protected void btnDowngrade_Click(object sender, EventArgs e)
        {
            if (Session["SchoolCode"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            string schoolCode = Session["SchoolCode"].ToString();
            CreateSubscriptionChangeRequest(schoolCode, false);
        }

        private void CreateSubscriptionChangeRequest(string schoolCode, bool isPremium)
        {
            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
            INSERT INTO SubscriptionChangeRequests (SchoolCode, IsPremium, RequestDate, Status)
            VALUES (@SchoolCode, @IsPremium, @RequestDate, 'Pending')", cn))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                    cmd.Parameters.AddWithValue("@IsPremium", isPremium);
                    cmd.Parameters.AddWithValue("@RequestDate", DateTime.Now);

                    cn.Open();
                    cmd.ExecuteNonQuery();
                    ShowAlert("Your request has been submitted for approval.", "success");
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                ShowAlert("An error occurred while submitting your request. Please try again.", "error");
            }
        }

        private void UpdateSubscriptionStatus(string schoolCode, bool isPremium)
        {
            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand("UPDATE Schools SET IsPremium=@p WHERE SchoolCode=@c", cn))
                {
                    cmd.Parameters.AddWithValue("@p", isPremium);
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    cn.Open();
                    int n = cmd.ExecuteNonQuery();
                    if (n > 0)
                    {
                        LoadSchoolProfile(schoolCode);
                        string action = isPremium ? "upgraded" : "downgraded";
                        ShowAlert($"Subscription successfully {action}!", "success");
                        LogSchoolActivity(schoolCode, "Subscription", $"Subscription {action} to {(isPremium ? "Premium" : "Standard")}", "School Admin");
                    }
                    else
                    {
                        ShowAlert("Failed to update subscription. Please try again.", "error");
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                ShowAlert("An error occurred while updating subscription. Please try again.", "error");
            }
        }

        /* =========================
           Sidebar profile (School)
        ==========================*/
        private void LoadSchoolProfile(string schoolCode)
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
                SELECT SchoolName, Email, Phone, Address, GradeLevel, LogoPath, IsPremium
                FROM Schools WHERE SchoolCode=@c", cn))
            {
                cmd.Parameters.AddWithValue("@c", schoolCode);
                cn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        lblSchoolName.Text = r["SchoolName"]?.ToString() ?? "School";
                        txtSchoolName.Text = r["SchoolName"]?.ToString() ?? "";
                        txtEmail.Text = r["Email"]?.ToString() ?? "";
                        txtPhone.Text = r["Phone"] == DBNull.Value ? "" : r["Phone"].ToString();
                        txtAddress.Text = r["Address"] == DBNull.Value ? "" : r["Address"].ToString();

                        if (r["GradeLevel"] != DBNull.Value)
                            ddlGradeLevel.SelectedValue = r["GradeLevel"].ToString();

                        var logo = r["LogoPath"] == DBNull.Value ? null : r["LogoPath"].ToString();
                        if (!string.IsNullOrWhiteSpace(logo))
                        {
                            imgLogoPreview.ImageUrl = logo;
                            imgLogoPreview.Visible = true;
                            if (imgLogoPreview.CssClass.Contains("hidden"))
                                imgLogoPreview.CssClass = imgLogoPreview.CssClass.Replace("hidden", "");
                            imgSchoolLogo.ImageUrl = logo;
                        }

                        bool isPremium = r["IsPremium"] != DBNull.Value && Convert.ToBoolean(r["IsPremium"]);
                        lblSubscriptionStatus.Text = isPremium ? "Premium" : "Standard";
                        lblCurrentSubscription.Text = isPremium ? "Premium Subscription" : "Standard Subscription";
                        subscriptionStatus.Attributes["class"] = isPremium
                            ? "inline-flex items-center px-4 py-2 rounded-full bg-[rgba(69,223,177,.2)] text-[var(--accent-green)] font-bold mb-4"
                            : "inline-flex items-center px-4 py-2 rounded-full bg-white/10 text-white font-bold mb-4";
                    }
                }
            }
        }

        /* =========================
           Overview cards (labels)
        ==========================*/
        private void LoadDashboardStats(string schoolCode)
        {
            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
                    SELECT
                        (SELECT COUNT(*) FROM Students  WHERE SchoolCode=@c) AS TotalLearners,
                        (SELECT COUNT(*) FROM Students  WHERE SchoolCode=@c AND IsActive=1) AS ActiveLearners,
                        (SELECT COUNT(*) FROM Teachers  WHERE SchoolCode=@c) AS TeachersCount,
                        (SELECT COUNT(*) FROM Subjects  WHERE SchoolCode=@c) AS SubjectsCount;", cn))
                {
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    cn.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            lblTotalLearners.Text = (r["TotalLearners"] ?? 0).ToString();
                            lblActiveLearners.Text = (r["ActiveLearners"] ?? 0).ToString();
                            lblTeachers.Text = (r["TeachersCount"] ?? 0).ToString();
                            lblSubjects.Text = (r["SubjectsCount"] ?? 0).ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                // don’t throw to UI; keep dashboard usable
                lblTotalLearners.Text = lblTotalLearners.Text.Length == 0 ? "0" : lblTotalLearners.Text;
                lblActiveLearners.Text = lblActiveLearners.Text.Length == 0 ? "0" : lblActiveLearners.Text;
                lblTeachers.Text = lblTeachers.Text.Length == 0 ? "0" : lblTeachers.Text;
                lblSubjects.Text = lblSubjects.Text.Length == 0 ? "0" : lblSubjects.Text;
            }
        }

        /* =========================
           Learners grid
        ==========================*/
        private void BindLearnersGrid(string schoolCode)
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
                SELECT StudentId, FullName, Email, Grade, IsActive,
                       LastLogin
                FROM Students
                WHERE SchoolCode=@c
                ORDER BY RegistrationDate DESC, StudentId DESC", cn))
            using (var da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@c", schoolCode);
                var dt = new DataTable();
                da.Fill(dt);
                gvLearners.DataSource = dt;
                gvLearners.DataBind();
            }
        }

        protected void gvLearners_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLearners.PageIndex = e.NewPageIndex;
            if (Session["SchoolCode"] != null)
            {
                BindLearnersGrid(Session["SchoolCode"].ToString());
            }
        }

        /* =========================
           Recent Activity grid
           (Builds a unified feed using data you already have:
            - New Students
            - New Teachers
            - Payment submissions)
        ==========================*/
        private void BindRecentActivity(string schoolCode)
        {
            var dt = new DataTable();
            dt.Columns.Add("ActivityDate", typeof(DateTime));
            dt.Columns.Add("ActivityType", typeof(string));
            dt.Columns.Add("Description", typeof(string));
            dt.Columns.Add("User", typeof(string));

            using (var cn = new SqlConnection(ConnectionString))
            {
                cn.Open();

                // New students
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10 RegistrationDate, FullName, Email
                    FROM Students
                    WHERE SchoolCode=@c
                    ORDER BY RegistrationDate DESC", cn))
                {
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            dt.Rows.Add(
                                r["RegistrationDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["RegistrationDate"]),
                                "New Student",
                                $"Registered: {r["FullName"]}",
                                r["Email"]?.ToString() ?? "Student");
                        }
                    }
                }

                // New teachers
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10 RegistrationDate, FullName, Email, SubjectCode, GradeLevel
                    FROM Teachers
                    WHERE SchoolCode=@c
                    ORDER BY RegistrationDate DESC", cn))
                {
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            var sub = r["SubjectCode"]?.ToString() ?? "";
                            var grade = r["GradeLevel"]?.ToString() ?? "";
                            dt.Rows.Add(
                                r["RegistrationDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["RegistrationDate"]),
                                "New Teacher",
                                $"Assigned {sub} (Grade {grade})",
                                r["FullName"]?.ToString() ?? "Teacher");
                        }
                    }
                }

                // Payment submissions
                using (var cmd = new SqlCommand(@"
                    SELECT TOP 10 SubmissionDate, InvoiceNumber, Status, PaymentMethod
                    FROM PaymentSubmissions
                    WHERE SchoolCode=@c
                    ORDER BY SubmissionDate DESC", cn))
                {
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            dt.Rows.Add(
                                r["SubmissionDate"] == DBNull.Value ? DateTime.Now : Convert.ToDateTime(r["SubmissionDate"]),
                                "Payment",
                                $"Invoice {r["InvoiceNumber"]} - {r["Status"]} ({r["PaymentMethod"]})",
                                "School Admin");
                        }
                    }
                }
            }

      
            var view = dt.DefaultView;
            view.Sort = "ActivityDate DESC";
            gvRecentActivity.DataSource = view.ToTable();
            gvRecentActivity.DataBind();
        }

        protected void gvRecentActivity_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvRecentActivity.PageIndex = e.NewPageIndex;
            if (Session["SchoolCode"] != null)
            {
                BindRecentActivity(Session["SchoolCode"].ToString());
            }
        }

      
        private void CheckSubscriptionStatus(string schoolCode)
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand("SELECT IsPremium FROM Schools WHERE SchoolCode=@c", cn))
            {
                cmd.Parameters.AddWithValue("@c", schoolCode);
                cn.Open();
                object o = cmd.ExecuteScalar();
                if (o != null && o != DBNull.Value)
                {
                    bool isPremium = Convert.ToBoolean(o);
                    btnUpgrade.Visible = !isPremium;
                    btnDowngrade.Visible = isPremium;
                    EnablePremiumFeatures(isPremium);
                }
            }
        }

        private void EnablePremiumFeatures(bool isPremium)
        {
            // Placeholder for feature toggles in UI (if needed later)
        }

        private void UpdatePaymentStatusBadge(string schoolCode)
        {
            // Show the latest payment status summary text
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 1 Status, SubmissionDate, VerificationDate
                FROM PaymentSubmissions
                WHERE SchoolCode=@c
                ORDER BY SubmissionDate DESC", cn))
            {
                cmd.Parameters.AddWithValue("@c", schoolCode);
                cn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        string status = r["Status"]?.ToString() ?? "N/A";
                        var sub = r["SubmissionDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(r["SubmissionDate"]);
                        var ver = r["VerificationDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(r["VerificationDate"]);
                        lblPaymentStatus.Text = status == "Verified"
                            ? $"Latest payment verified on {ver:dd MMM yyyy}"
                            : $"Latest submission {sub:dd MMM yyyy} — {status}";
                    }
                    else
                    {
                        lblPaymentStatus.Text = "No payments submitted yet.";
                    }
                }
            }
        }

        protected void btnUploadPayment_Click(object sender, EventArgs e)
        {
            if (Session["SchoolCode"] == null) { Response.Redirect("Login.aspx"); return; }

            if (!fileProofOfPayment.HasFile)
            {
                ShowUploadMessage("Please select a file to upload.", "error");
                return;
            }

            try
            {
                string schoolCode = Session["SchoolCode"].ToString();
                string invoiceNumber = GenerateInvoiceNumber();

                string ext = Path.GetExtension(fileProofOfPayment.FileName)?.ToLowerInvariant();
                string[] allowed = { ".pdf", ".jpg", ".jpeg", ".png" };
                if (!allowed.Contains(ext))
                {
                    ShowUploadMessage("Invalid file type. Please upload PDF, JPG, or PNG files only.", "error");
                    return;
                }

                if (fileProofOfPayment.PostedFile.ContentLength > 5 * 1024 * 1024)
                {
                    ShowUploadMessage("File size cannot exceed 5MB.", "error");
                    return;
                }

      
                var root = Server.MapPath("~/Uploads/Payments/");
                Directory.CreateDirectory(root);
                var safeName = $"payment_{schoolCode}_{DateTime.UtcNow:yyyyMMddHHmmssfff}{ext}";
                var physical = Path.Combine(root, safeName);
                fileProofOfPayment.SaveAs(physical);
                var relPath = "~/Uploads/Payments/" + safeName;

                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
INSERT INTO PaymentSubmissions 
    (SchoolCode, InvoiceNumber, FileName, OriginalFileName, SubmissionDate, PaymentMethod, Status)
VALUES
    (@SchoolCode, @InvoiceNumber, @FileName, @OriginalFileName, @SubmissionDate, @PaymentMethod, @Status)", cn))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                    cmd.Parameters.AddWithValue("@InvoiceNumber", invoiceNumber);
                    cmd.Parameters.AddWithValue("@FileName", relPath);
                    cmd.Parameters.AddWithValue("@OriginalFileName", Path.GetFileName(fileProofOfPayment.FileName));
                    cmd.Parameters.AddWithValue("@SubmissionDate", DateTime.Now);
                    cmd.Parameters.AddWithValue("@PaymentMethod", "Bank Transfer");
                    cmd.Parameters.AddWithValue("@Status", "Pending");

                    cn.Open();
                    var rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        ShowUploadMessage("Payment proof uploaded successfully! Invoice Number: " + invoiceNumber, "success");
                        LogSchoolActivity(schoolCode, "Payment", $"Uploaded payment proof - Invoice: {invoiceNumber}", "School Admin");
                        BindPaymentHistory(schoolCode);
                        UpdatePaymentStatusBadge(schoolCode);
                    }
                    else
                    {
                        ShowUploadMessage("Failed to save payment information. Please try again.", "error");
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                ShowUploadMessage("An error occurred while uploading the file. Please try again.", "error");
            }
        }

        private void BindPaymentHistory(string schoolCode)
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
                SELECT InvoiceNumber, OriginalFileName, SubmissionDate, PaymentMethod, Status, VerificationDate
                FROM PaymentSubmissions
                WHERE SchoolCode=@c
                ORDER BY SubmissionDate DESC", cn))
            using (var da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@c", schoolCode);
                var dt = new DataTable();
                da.Fill(dt);
                gvPaymentHistory.DataSource = dt;
                gvPaymentHistory.DataBind();
            }
        }

        private string GenerateInvoiceNumber()
        {
            var r = new Random();
            return $"INV{DateTime.Now:yy}{r.Next(10000000, 99999999)}";
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (Session["SchoolCode"] == null) { Response.Redirect("Login.aspx"); return; }
            if (!Page.IsValid) return;

            string schoolCode = Session["SchoolCode"].ToString();

            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                {
                    cn.Open();

                    string sql = @"UPDATE Schools SET SchoolName=@n, Email=@e, Phone=@p, Address=@a, GradeLevel=@g";
                    string logoPath = null;

                    if (fileSchoolLogo.HasFile)
                    {
                        logoPath = SaveUploadedLogo(fileSchoolLogo, schoolCode);
                        sql += ", LogoPath=@logo";
                    }
                    sql += " WHERE SchoolCode=@c";

                    using (var cmd = new SqlCommand(sql, cn))
                    {
                        cmd.Parameters.AddWithValue("@n", txtSchoolName.Text.Trim());
                        cmd.Parameters.AddWithValue("@e", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@p", string.IsNullOrWhiteSpace(txtPhone.Text) ? (object)DBNull.Value : txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@a", string.IsNullOrWhiteSpace(txtAddress.Text) ? (object)DBNull.Value : txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@g", string.IsNullOrWhiteSpace(ddlGradeLevel.SelectedValue) ? (object)DBNull.Value : ddlGradeLevel.SelectedValue);
                        cmd.Parameters.AddWithValue("@c", schoolCode);
                        if (logoPath != null) cmd.Parameters.AddWithValue("@logo", logoPath);

                        int n = cmd.ExecuteNonQuery();
                        if (n > 0)
                        {
                            // reflect sidebar immediately
                            lblSchoolName.Text = txtSchoolName.Text.Trim();
                            if (logoPath != null)
                            {
                                imgLogoPreview.ImageUrl = logoPath;
                                imgLogoPreview.Visible = true;
                                if (imgLogoPreview.CssClass.Contains("hidden"))
                                    imgLogoPreview.CssClass = imgLogoPreview.CssClass.Replace("hidden", "");
                                imgSchoolLogo.ImageUrl = logoPath;
                            }

                            ShowProfileMessage("Profile updated successfully!", "success");
                            LogSchoolActivity(schoolCode, "Profile", "Updated school profile information", "School Admin");
                        }
                        else
                        {
                            ShowProfileMessage("No changes were made to your profile.", "error");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                ShowProfileMessage("An error occurred while updating your profile. Please try again.", "error");
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            if (Session["SchoolCode"] == null) { Response.Redirect("Login.aspx"); return; }
            string schoolCode = Session["SchoolCode"].ToString();
            LoadSchoolProfile(schoolCode);

            fileSchoolLogo.Attributes.Clear();
            hfLogoChanged.Value = "false";

            ShowProfileMessage("Changes cancelled.", "success");
        }

        private string SaveUploadedLogo(FileUpload fileUpload, string schoolCode)
        {
            string ext = Path.GetExtension(fileUpload.FileName).ToLowerInvariant();
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
            if (!allowedExtensions.Contains(ext)) throw new Exception("Invalid file type. Please upload a JPG, PNG, or GIF image.");
            if (fileUpload.PostedFile.ContentLength > 2 * 1024 * 1024) throw new Exception("File size cannot exceed 2MB.");

            string folder = Server.MapPath("~/Uploads/SchoolLogos/");
            Directory.CreateDirectory(folder);

            string name = $"logo_{schoolCode}_{DateTime.Now:yyyyMMddHHmmss}{ext}";
            string path = Path.Combine(folder, name);
            fileUpload.SaveAs(path);

            return $"~/Uploads/SchoolLogos/{name}";
        }

        /* =========================
           UI helpers / logging
        ==========================*/
        private void ShowProfileMessage(string message, string type = "error")
        {
            lblProfileMessage.Text = message;
            lblProfileMessage.CssClass = type == "success" ? "status-message status-success" : "status-message status-error";
            lblProfileMessage.Visible = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollToProfileMsg",
                $"setTimeout(function(){{ document.getElementById('{lblProfileMessage.ClientID}').scrollIntoView({{ behavior: 'smooth', block: 'center' }}); }}, 100);", true);
        }

        private void ShowUploadMessage(string message, string type = "error")
        {
            lblUploadMessage.Text = message;
            lblUploadMessage.CssClass = type == "success" ? "status-message status-success" : "status-message status-error";
            lblUploadMessage.Visible = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "scrollToUploadMsg",
                $"setTimeout(function(){{ document.getElementById('{lblUploadMessage.ClientID}').scrollIntoView({{ behavior: 'smooth', block: 'center' }}); }}, 100);", true);
        }

        private void ShowAlert(string message, string type = "success")
        {
            // Minimal alert; you can replace with your nicer overlay if you want
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(),
                $"alert('{message.Replace("'", "\\'")}');", true);
        }

        private void LogSchoolActivity(string schoolCode, string activityType, string description, string userType)
        {
            // Optional: persist activity in a table if you have one (e.g., SchoolActivity)
            // If you don't maintain an activity table, the Recent Activity grid still works (it derives from Students/Teachers/Payments).
            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
                    IF OBJECT_ID('dbo.SchoolActivity','U') IS NOT NULL
                    INSERT INTO SchoolActivity (SchoolCode, ActivityDate, ActivityType, Description, [User])
                    VALUES (@c, GETDATE(), @t, @d, @u)", cn))
                {
                    cmd.Parameters.AddWithValue("@c", schoolCode);
                    cmd.Parameters.AddWithValue("@t", activityType ?? "");
                    cmd.Parameters.AddWithValue("@d", description ?? "");
                    cmd.Parameters.AddWithValue("@u", userType ?? "");
                    cn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex) { LogError(ex); }
        }

        private void LogError(Exception ex)
        {
            try
            {
                System.Diagnostics.Trace.TraceError(ex.ToString());
                // Optional: also write a plain line so it shows up in more listeners
                System.Diagnostics.Trace.WriteLine("ERROR: " + ex);
            }
            catch { /* ignore logging failures */ }
        }

    }
}
