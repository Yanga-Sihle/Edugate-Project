using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class StudentDashboard : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        // Cached per request
        private bool _isPremiumSchool = false;
        private string _studentSchoolCode = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsStudentLoggedIn"] == null || !(bool)Session["IsStudentLoggedIn"] || Session["StudentID"] == null)
            {
                Response.Redirect("Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Session["StudentFullName"] != null)
                {
                    litStudentFullName.Text = Session["StudentFullName"].ToString();
                    litStudentFullName2.Text = Session["StudentFullName"].ToString();
                }
                else
                {
                    litStudentFullName.Text = "Student";
                    litStudentFullName2.Text = "Student";
                }

                // Load student data (also captures SchoolCode)
                LoadStudentData();

                // Check premium once and persist
                _isPremiumSchool = GetIsPremiumBySchoolCode(_studentSchoolCode);
                ViewState["IsPremiumSchool"] = _isPremiumSchool;

                // Visual cues (safe if controls missing)
                SetPlanBadge();
                SetPremiumVisualState();

                // Load the rest
                LoadStudentSubjects();
                LoadStudentGrades();
                LoadQuizResults();
            }
            else
            {
                // Recover premium flag on postback for click handler
                _isPremiumSchool = ViewState["IsPremiumSchool"] != null && (bool)ViewState["IsPremiumSchool"];
            }
        }

        /// <summary>
        /// Reads student profile, captures SchoolCode into _studentSchoolCode, and binds UI.
        /// </summary>
        private void LoadStudentData()
        {
            int studentId = (int)Session["StudentID"];

            string query = @"SELECT [StudentId], [FullName], [Address], [Gender], [Email], 
                                    [RegistrationDate], [SchoolCode], [Grade], [GradeLevel], 
                                    [IsActive], [LastLogin] 
                             FROM [Edugate].[dbo].[Students] 
                             WHERE StudentId = @StudentId";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Display student information
                            litStudentId.Text = reader["StudentId"].ToString();
                            litFullName.Text = reader["FullName"].ToString();
                            litEmail.Text = reader["Email"].ToString();
                            litGender.Text = reader["Gender"].ToString();
                            litAddress.Text = reader["Address"].ToString();

                            _studentSchoolCode = reader["SchoolCode"].ToString();
                            litSchoolCode.Text = _studentSchoolCode;

                            litGrade.Text = reader["Grade"].ToString();
                            litGradeLevel.Text = reader["GradeLevel"].ToString();
                            litRegistrationDate.Text = Convert.ToDateTime(reader["RegistrationDate"]).ToString("dd MMM yyyy");
                            litLastLogin.Text = reader["LastLogin"] != DBNull.Value
                                ? Convert.ToDateTime(reader["LastLogin"]).ToString("dd MMM yyyy HH:mm")
                                : "Never";
                            litStatus.Text = Convert.ToBoolean(reader["IsActive"]) ? "Active" : "Inactive";

                            // Pre-fill edit form
                            txtFullName.Text = reader["FullName"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            if (!string.IsNullOrEmpty(reader["Gender"].ToString()))
                            {
                                ListItem item = ddlGender.Items.FindByValue(reader["Gender"].ToString());
                                if (item != null) ddlGender.SelectedValue = item.Value;
                            }
                            txtAddress.Text = reader["Address"].ToString();
                            txtGrade.Text = reader["Grade"].ToString();
                            txtGradeLevel.Text = reader["GradeLevel"].ToString();
                        }
                        else
                        {
                            Response.Redirect("Login.aspx");
                        }
                    }
                }
                catch (Exception ex)
                {
                    // Log as needed
                    System.Diagnostics.Debug.WriteLine($"Error fetching student data: {ex.Message}");
                    Response.Redirect("ErrorPage.aspx");
                }
            }
        }

        /// <summary>
        /// Returns true if the school for the given SchoolCode is Premium.
        /// </summary>
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
                con.Open();
                object scalar = cmd.ExecuteScalar();
                return scalar != null && Convert.ToBoolean(scalar);
            }
        }

        /// <summary>
        /// One handler to gate all Premium-only sidebar actions.
        /// Attach to LinkButtons with CommandArgument = target url.
        /// </summary>
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

        /// <summary>
        /// Sets a simple "Premium" or "Free" badge under the avatar (if the literal exists).
        /// </summary>
        private void SetPlanBadge()
        {
            try
            {
                if (litPlanBadge != null)
                    litPlanBadge.Text = _isPremiumSchool ? "Premium" : "Free";
            }
            catch
            {
                // ignore if control not on page
            }
        }

        /// <summary>
        /// Optional: visually gray-out gated items when on Free. Safe if controls are absent.
        /// </summary>
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

        private void LoadStudentSubjects()
        {
            int studentId = (int)Session["StudentID"];

            string query = @"SELECT DISTINCT s.SubjectCode, s.SubjectName
                             FROM Subjects s
                             INNER JOIN StudentSubjects ss ON s.SubjectCode = ss.SubjectCode
                             WHERE ss.StudentID = @StudentID
                             ORDER BY s.SubjectName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                try
                {
                    con.Open();
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    if (dt.Rows.Count > 0)
                    {
                        rptSubjects.DataSource = dt;
                        rptSubjects.DataBind();
                        litNoSubjects.Visible = false;
                    }
                    else
                    {
                        rptSubjects.DataSource = null;
                        rptSubjects.DataBind();
                        litNoSubjects.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error fetching student subjects: {ex.Message}");
                    litNoSubjects.Visible = true;
                }
            }
        }

        private void LoadStudentGrades()
        {
            int studentId = (int)Session["StudentID"];

            string query = @"SELECT s.SubjectName AS Subject, g.Mark, g.Grade, g.Status, g.SubmissionDate
                             FROM Grades g
                             INNER JOIN Subjects s ON g.SubjectCode = s.SubjectCode
                             WHERE g.StudentID = @StudentID
                             ORDER BY s.SubjectName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                try
                {
                    con.Open();
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    if (dt.Rows.Count > 0)
                    {
                        rptGrades.DataSource = dt;
                        rptGrades.DataBind();
                        litNoGrades.Visible = false;
                    }
                    else
                    {
                        rptGrades.DataSource = null;
                        rptGrades.DataBind();
                        litNoGrades.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error fetching student grades: {ex.Message}");
                    litNoGrades.Visible = true;
                }
            }
        }

        private void LoadQuizResults()
        {
            int studentId = (int)Session["StudentID"];

            // latest (most recent CompletionDate) result per QuizId for this student
            string query = @"
        WITH Ranked AS
        (
            SELECT
                qr.ResultId,
                qr.QuizId,
                q.QuizTitle,
                s.SubjectName,
                qr.Score,
                qr.CompletionDate,
                ROW_NUMBER() OVER (
                    PARTITION BY qr.QuizId
                    ORDER BY qr.CompletionDate DESC, qr.ResultId DESC
                ) AS rn
            FROM QuizResults qr
            INNER JOIN Quizzes   q ON qr.QuizId    = q.QuizId
            INNER JOIN Subjects  s ON q.SubjectCode = s.SubjectCode
            WHERE qr.StudentID = @StudentID
        )
        SELECT ResultId, QuizTitle, SubjectName, Score, CompletionDate
        FROM Ranked
        WHERE rn = 1
        ORDER BY CompletionDate DESC;";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                try
                {
                    con.Open();
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());

                    if (dt.Rows.Count > 0)
                    {
                        rptQuizResults.DataSource = dt;
                        rptQuizResults.DataBind();
                        litNoQuizResults.Visible = false;
                    }
                    else
                    {
                        rptQuizResults.DataSource = null;
                        rptQuizResults.DataBind();
                        litNoQuizResults.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error fetching quiz results: {ex.Message}");
                    litNoQuizResults.Visible = true;
                }
            }
        }


        protected void btnSave_Click(object sender, EventArgs e)
        {
            int studentId = (int)Session["StudentID"];

            string query = @"UPDATE [Edugate].[dbo].[Students] 
                             SET FullName = @FullName, Email = @Email, Gender = @Gender, 
                                 Address = @Address, Grade = @Grade, GradeLevel = @GradeLevel
                             WHERE StudentId = @StudentId";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Gender", ddlGender.SelectedValue);
                cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                cmd.Parameters.AddWithValue("@Grade", txtGrade.Text.Trim());
                cmd.Parameters.AddWithValue("@GradeLevel", txtGradeLevel.Text.Trim());
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                try
                {
                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Update session and display values
                        Session["StudentFullName"] = txtFullName.Text.Trim();
                        litStudentFullName.Text = txtFullName.Text.Trim();
                        litStudentFullName2.Text = txtFullName.Text.Trim();
                        litFullName.Text = txtFullName.Text.Trim();
                        litEmail.Text = txtEmail.Text.Trim();
                        litGender.Text = ddlGender.SelectedValue;
                        litAddress.Text = txtAddress.Text.Trim();
                        litGrade.Text = txtGrade.Text.Trim();
                        litGradeLevel.Text = txtGradeLevel.Text.Trim();

                        // Hide the edit form
                        editProfileForm.Style["display"] = "none";

                        // Notify
                        ScriptManager.RegisterStartupScript(this, GetType(), "UpdateSuccess",
                            "alert('Profile updated successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, GetType(), "UpdateError",
                            "alert('Failed to update profile. Please try again.');", true);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error updating student data: {ex.Message}");
                    ScriptManager.RegisterStartupScript(this, GetType(), "UpdateError",
                        $"alert('Error updating profile: {ex.Message.Replace("'", "\\'")}');", true);
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }

        // Helper for grades CSS
        public string GetGradeCssClass(int mark)
        {
            if (mark >= 80) return "grade-excellent";
            if (mark >= 70) return "grade-good";
            if (mark >= 60) return "grade-average";
            if (mark >= 50) return "grade-pass";
            return "grade-fail";
        }
    }
}
