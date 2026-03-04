using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Edugate_Project.Models; // Your Models namespace (Subject, UploadedFile, StudentSubmission)

namespace Edugate_Project
{
    public partial class StudentActivities : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        // Cached per request
        private bool _isPremiumSchool = false;
        private string _studentSchoolCode = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check
            if (Session["IsStudentLoggedIn"] == null || !(bool)Session["IsStudentLoggedIn"] || Session["StudentID"] == null)
            {
                Response.Redirect("StudentLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int studentId = (int)Session["StudentID"];

                // Sidebar student name
                if (Session["StudentFullName"] != null)
                {
                    litStudentFullName.Text = Session["StudentFullName"].ToString();
                }

                // Premium state
                _studentSchoolCode = GetStudentSchoolCode(studentId);
                _isPremiumSchool = GetIsPremiumBySchoolCode(_studentSchoolCode);
                ViewState["IsPremiumSchool"] = _isPremiumSchool;

                SetPlanBadge();
                SetPremiumVisualState();

                string studentFullName = Session["StudentFullName"]?.ToString() ?? "Student";
                litStudentInfo.Text = $"<p class='text-center'>Logged in as: <strong>{studentFullName}</strong></p>";

                // Initial data
                BindSubjectsToDropdown(studentId);

                // Guard: if no subjects, dropdown will be disabled
                if (ddlSubjects.Enabled && ddlSubjects.Items.Count > 0)
                {
                    BindTeacherActivities(studentId, ddlSubjects.SelectedValue);
                    BindStudentSubmissions(studentId, ddlSubjects.SelectedValue);
                }
            }
            else
            {
                _isPremiumSchool = ViewState["IsPremiumSchool"] != null && (bool)ViewState["IsPremiumSchool"];
            }
        }

        private string GetStudentSchoolCode(int studentId)
        {
            string code = null;
            const string sql = @"SELECT SchoolCode FROM [Edugate].[dbo].[Students] WHERE StudentId = @StudentId";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                try
                {
                    con.Open();
                    object scalar = cmd.ExecuteScalar();
                    code = scalar?.ToString();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error getting SchoolCode: {ex.Message}");
                }
            }
            return code;
        }

        private bool GetIsPremiumBySchoolCode(string schoolCode)
        {
            if (string.IsNullOrWhiteSpace(schoolCode)) return false;

            const string sql = @"SELECT ISNULL(IsPremium, 0)
                                 FROM [Edugate].[dbo].[Schools]
                                 WHERE SchoolCode = @SchoolCode";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode.Trim());
                try
                {
                    con.Open();
                    object scalar = cmd.ExecuteScalar();
                    return scalar != null && Convert.ToBoolean(scalar);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error checking premium: {ex.Message}");
                    return false;
                }
            }
        }

        protected void RestrictedNav_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string targetUrl = btn?.CommandArgument;

            if (_isPremiumSchool)
            {
                if (!string.IsNullOrWhiteSpace(targetUrl))
                {
                    Response.Redirect(targetUrl, false);
                }
                return;
            }

            string msg = "Your school is on the Free plan. Please ask your school administrator to upgrade to Premium to access Scholarships, Career Guidance, Study Materials, and Upload School Report.";
            ScriptManager.RegisterStartupScript(this, GetType(), "UpgradeNotice",
                $"alert('{msg.Replace("'", "\\'")}');", true);
        }

        private void SetPlanBadge()
        {
            try
            {
                var lit = FindControl("litPlanBadge") as Literal;
                if (lit != null) lit.Text = _isPremiumSchool ? "<span class='status-message success'>Premium</span>"
                                                             : "<span class='status-message info'>Free</span>";
            }
            catch { /* ignore */ }
        }

        private void SetPremiumVisualState()
        {
            if (_isPremiumSchool) return;

            TryAppendDisabledClass(FindControl("lnkUploadReport") as WebControl);
            TryAppendDisabledClass(FindControl("lnkScholarships") as WebControl);
            TryAppendDisabledClass(FindControl("lnkCareer") as WebControl);
            TryAppendDisabledClass(FindControl("lnkMaterials") as WebControl);
        }

        private void TryAppendDisabledClass(WebControl ctrl)
        {
            if (ctrl == null) return;
            if (string.IsNullOrWhiteSpace(ctrl.CssClass))
                ctrl.CssClass = "disabled";
            else if (!ctrl.CssClass.Contains("disabled"))
                ctrl.CssClass += " disabled";
        }

        private void BindSubjectsToDropdown(int studentId)
        {
            string query = @"SELECT DISTINCT s.SubjectCode, s.SubjectName
                             FROM StudentSubjects ss
                             INNER JOIN Subjects s ON ss.SubjectCode = s.SubjectCode
                             WHERE ss.StudentID = @StudentID
                             ORDER BY s.SubjectName";

            var subjects = new List<Subject>();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            subjects.Add(new Subject
                            {
                                SubjectCode = reader["SubjectCode"].ToString(),
                                SubjectName = reader["SubjectName"].ToString()
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error binding subjects: {ex.Message}");
                    ShowStatusMessage("Error loading your subjects.", "error", litSubmissionStatus);
                }
            }

            if (subjects.Any())
            {
                ddlSubjects.DataSource = subjects;
                ddlSubjects.DataTextField = "SubjectName";
                ddlSubjects.DataValueField = "SubjectCode";
                ddlSubjects.DataBind();
            }
            else
            {
                ddlSubjects.Items.Clear();
                ddlSubjects.Items.Add(new ListItem("No Subjects Available", ""));
                ddlSubjects.Enabled = false;
                ShowStatusMessage("You are not currently enrolled in any subjects. Please contact administration.", "info", litSubmissionStatus);
            }
        }

        /// <summary>
        /// Binds files uploaded by teachers for the selected subject.
        /// </summary>
        protected void BindTeacherActivities(int studentId, string subjectCode)
        {
            if (string.IsNullOrEmpty(subjectCode))
            {
                BindEmpty(rptTeacherActivities, pnlNoTeacherActivities);
                return;
            }

            string query = @"
SELECT DISTINCT
    uf.FileID, uf.FileName, uf.FilePath, uf.Message, uf.UploadDate, uf.SubjectCode,
    s.SubjectName, t.Username AS TeacherUsername, t.FullName AS TeacherFullName
FROM UploadedFiles uf
INNER JOIN Subjects s ON uf.SubjectCode = s.SubjectCode
INNER JOIN Teachers t ON uf.TeacherID = t.TeacherID
WHERE uf.SubjectCode = @SubjectCode
ORDER BY uf.UploadDate DESC";

            var teacherActivities = new List<UploadedFile>();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            teacherActivities.Add(new UploadedFile
                            {
                                FileID = (int)reader["FileID"],
                                FileName = reader["FileName"].ToString(),

                                FilePath = reader["FilePath"].ToString(),
                                Message = reader["Message"] == DBNull.Value ? "" : reader["Message"].ToString(),
                                UploadDate = (DateTime)reader["UploadDate"],
                                SubjectCode = reader["SubjectCode"].ToString(),
                                SubjectName = reader["SubjectName"].ToString(),
                                TeacherUsername = reader["TeacherUsername"].ToString(),
                                TeacherFullName = reader["TeacherFullName"].ToString()
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error binding teacher activities: {ex.Message}");
                    ShowStatusMessage("Error loading teacher activities.", "error", litSubmissionStatus);
                }
            }

            // De-dupe in memory (safety)
            teacherActivities = teacherActivities
                .GroupBy(a => a.FileID)
                .Select(g => g.First())
                .ToList();

            if (teacherActivities.Any())
            {
                RebindList(rptTeacherActivities, teacherActivities, pnlNoTeacherActivities, false);
            }
            else
            {
                BindEmpty(rptTeacherActivities, pnlNoTeacherActivities);
            }
        }

        /// <summary>
        /// Binds the student's past submissions for the selected subject.
        /// </summary>
        protected void BindStudentSubmissions(int studentId, string subjectCode)
        {
            if (string.IsNullOrEmpty(subjectCode))
            {
                BindEmpty(rptStudentSubmissions, pnlNoStudentSubmissions);
                return;
            }

            string query = @"
SELECT DISTINCT
    ss.SubmissionID, ss.OriginalFileName, ss.SubmittedFilePath, ss.SubmissionMessage, ss.SubmissionDate,
    s.SubjectName, s.SubjectCode
FROM StudentSubmissions ss
INNER JOIN Subjects s ON ss.SubjectCode = s.SubjectCode
WHERE ss.StudentID = @StudentID AND ss.SubjectCode = @SubjectCode
ORDER BY ss.SubmissionDate DESC";

            var studentSubmissions = new List<StudentSubmission>();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            studentSubmissions.Add(new StudentSubmission
                            {
                                SubmissionID = (int)reader["SubmissionID"],
                                OriginalFileName = reader["OriginalFileName"].ToString(),
                                SubmittedFilePath = reader["SubmittedFilePath"].ToString(),
                                SubmissionMessage = reader["SubmissionMessage"] == DBNull.Value ? "" : reader["SubmissionMessage"].ToString(),
                                SubmissionDate = (DateTime)reader["SubmissionDate"],
                                SubjectName = reader["SubjectName"].ToString(),
                                SubjectCode = reader["SubjectCode"].ToString()
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error binding student submissions: {ex.Message}");
                    ShowStatusMessage("Error loading your past submissions.", "error", litSubmissionStatus);
                }
            }

            // De-dupe in memory (safety)
            studentSubmissions = studentSubmissions
                .GroupBy(su => su.SubmissionID)
                .Select(g => g.First())
                .ToList();

            if (studentSubmissions.Any())
            {
                RebindList(rptStudentSubmissions, studentSubmissions, pnlNoStudentSubmissions, false);
            }
            else
            {
                BindEmpty(rptStudentSubmissions, pnlNoStudentSubmissions);
            }
        }

        protected void ddlSubjects_SelectedIndexChanged(object sender, EventArgs e)
        {
            int studentId = (int)Session["StudentID"];
            string selectedSubjectCode = ddlSubjects.SelectedValue;

            if (string.IsNullOrEmpty(selectedSubjectCode))
            {
                BindEmpty(rptTeacherActivities, pnlNoTeacherActivities);
                BindEmpty(rptStudentSubmissions, pnlNoStudentSubmissions);
                litSubmissionStatus.Text = "";
                updActivities.Update();
                return;
            }

            BindTeacherActivities(studentId, selectedSubjectCode);
            BindStudentSubmissions(studentId, selectedSubjectCode);
            litSubmissionStatus.Text = "";
            updActivities.Update();
        }

        protected void btnSubmitWork_Click(object sender, EventArgs e)
        {
            int studentId = (int)Session["StudentID"];
            string selectedSubjectCode = ddlSubjects.SelectedValue;
            string submissionMessage = txtSubmissionMessage.Text.Trim();

            if (string.IsNullOrEmpty(selectedSubjectCode))
            {
                ShowStatusMessage("Please select a subject before submitting.", "error", litSubmissionStatus);
                return;
            }

            if (!FileUploadControl.HasFile)
            {
                ShowStatusMessage("Please select a file to submit.", "error", litSubmissionStatus);
                return;
            }

            string fileName = "";
            string filePath = "";
            bool fileUploaded = false;

            try
            {
                string submissionDir = Server.MapPath($"~/Submissions/{selectedSubjectCode}/StudentID_{studentId}/");
                if (!Directory.Exists(submissionDir))
                {
                    Directory.CreateDirectory(submissionDir);
                }

                fileName = Path.GetFileName(FileUploadControl.FileName);
                filePath = Path.Combine(submissionDir, fileName);

                int count = 1;
                string tempFileName = fileName;
                while (File.Exists(filePath))
                {
                    tempFileName = $"{Path.GetFileNameWithoutExtension(fileName)} ({count++}){Path.GetExtension(fileName)}";
                    filePath = Path.Combine(submissionDir, tempFileName);
                }
                fileName = tempFileName;

                FileUploadControl.SaveAs(filePath);
                fileUploaded = true;
            }
            catch (Exception ex)
            {
                ShowStatusMessage($"File upload failed: {ex.Message}", "error", litSubmissionStatus);
                return;
            }

            int teacherId = GetTeacherIdForSubject(selectedSubjectCode);
            if (teacherId == 0)
            {
                ShowStatusMessage("Could not determine the teacher for this subject. Submission failed.", "error", litSubmissionStatus);
                if (fileUploaded && File.Exists(filePath))
                {
                    File.Delete(filePath);
                }
                return;
            }

            string relativePath = filePath.Replace(Server.MapPath("~/"), "").Replace("\\", "/");
            bool saved = SaveStudentSubmissionToDatabase(studentId, teacherId, selectedSubjectCode, fileName, relativePath, submissionMessage);

            if (saved)
            {
                ShowStatusMessage("Your work has been submitted successfully!", "success", litSubmissionStatus);
                txtSubmissionMessage.Text = string.Empty;
                BindStudentSubmissions(studentId, selectedSubjectCode);
                updActivities.Update();
            }
            else
            {
                ShowStatusMessage("Failed to save submission information to the database.", "error", litSubmissionStatus);
                if (fileUploaded && File.Exists(filePath))
                {
                    File.Delete(filePath);
                }
            }
        }

        private int GetTeacherIdForSubject(string subjectCode)
        {
            int teacherId = 0;
            const string query = "SELECT TOP 1 TeacherID FROM Teachers WHERE SubjectCode = @SubjectCode";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                try
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        teacherId = Convert.ToInt32(result);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error getting teacher ID for subject {subjectCode}: {ex.Message}");
                }
            }
            return teacherId;
        }

        private bool SaveStudentSubmissionToDatabase(int studentId, int teacherId, string subjectCode, string fileName, string relativeFilePath, string message)
        {
            string query = @"INSERT INTO StudentSubmissions (StudentID, TeacherID, SubjectCode, OriginalFileName, SubmittedFilePath, SubmissionMessage, SubmissionDate)
                             VALUES (@StudentID, @TeacherID, @SubjectCode, @OriginalFileName, @SubmittedFilePath, @SubmissionMessage, GETDATE())";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                cmd.Parameters.AddWithValue("@OriginalFileName", fileName);
                cmd.Parameters.AddWithValue("@SubmittedFilePath", relativeFilePath);
                cmd.Parameters.AddWithValue("@SubmissionMessage", string.IsNullOrEmpty(message) ? (object)DBNull.Value : message);

                try
                {
                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error saving student submission info to DB: {ex.Message}");
                    return false;
                }
            }
        }

        private void ShowStatusMessage(string message, string type, Literal literalControl)
        {
            literalControl.Text = $"<div class='status-message {type}'>{message}</div>";
        }

        /* -------- helper binding patterns to avoid duplicates -------- */

        private void RebindList<T>(Repeater repeater, List<T> data, Panel emptyPanel, bool updatePanel = true)
        {
            repeater.DataSource = null;   // clear previous (defensive)
            repeater.DataBind();

            repeater.DataSource = data;
            repeater.DataBind();

            emptyPanel.Visible = false;
            if (updatePanel) updActivities.Update();
        }

        private void BindEmpty(Repeater repeater, Panel emptyPanel, bool updatePanel = true)
        {
            repeater.DataSource = null;
            repeater.DataBind();
            emptyPanel.Visible = true;
            if (updatePanel) updActivities.Update();
        }
    }
}
