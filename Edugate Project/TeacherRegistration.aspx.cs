using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;
using System.Linq;

namespace Edugate_Project
{
    public partial class TeacherRegistration : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                TeacherForm.CssClass = "form-container active";
                SchoolForm.CssClass = "form-container";
                btnTeacherForm.CssClass = "type-btn active";
                btnSchoolForm.CssClass = "type-btn";

                subjectGroup.Visible = false;
                gradeGroup.Visible = false;
                debugSubjects.Visible = false;
                schoolCodeGroup.Visible = false;
            }
        }

        protected void ValidateSchoolCode(object source, ServerValidateEventArgs args)
        {
            string code = args.Value.Trim();
            args.IsValid = code.Length == 5 && code.All(char.IsDigit) && SchoolExists(code);
        }

        protected void ValidateSchoolEmail(object source, ServerValidateEventArgs args)
        {
            args.IsValid = !SchoolEmailExists(args.Value);
        }

        protected void txtSchoolCode_TextChanged(object sender, EventArgs e)
        {
            string schoolCode = txtSchoolCode.Text.Trim();
            debugSubjects.InnerText = $"School code changed to: {schoolCode}";
            debugSubjects.Visible = true;

            if (!string.IsNullOrEmpty(schoolCode))
            {
                ddlGrade.SelectedIndex = 0;
                ddlSubjects.Items.Clear();
                ddlSubjects.Items.Add(new ListItem("-- Select Subject --", ""));
                gradeGroup.Visible = true;
                subjectGroup.Visible = false;
                LoadAvailableGrades(schoolCode);
            }
            else
            {
                gradeGroup.Visible = false;
                subjectGroup.Visible = false;
            }
        }

        private void LoadAvailableGrades(string schoolCode)
        {
            try
            {
                ddlGrade.Items.Clear();
                ddlGrade.Items.Add(new ListItem("-- Select Grade --", ""));

                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    if (!SchoolExists(schoolCode))
                    {
                        debugSubjects.InnerText += "\nSchool not found";
                        return;
                    }

                    string query = @"SELECT DISTINCT GradeLevel
                             FROM Subjects
                             WHERE SchoolCode = @SchoolCode
                             ORDER BY GradeLevel";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);

                        if (con.State != ConnectionState.Open)
                            con.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                while (reader.Read())
                                {
                                    string gradeValue = reader["GradeLevel"].ToString();
                                    ddlGrade.Items.Add(new ListItem($"Grade {gradeValue}", gradeValue));
                                }
                                debugSubjects.InnerText += "\nGrades loaded successfully.";
                            }
                            else
                            {
                                debugSubjects.InnerText += "\nNo grades found for this school.";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                debugSubjects.InnerText += $"\nError loading grades: {ex.Message}";
            }
            finally
            {
                debugSubjects.Visible = true;
            }
        }

        protected void ddlGrade_SelectedIndexChanged(object sender, EventArgs e)
        {
            string schoolCode = txtSchoolCode.Text.Trim();
            string selectedGrade = ddlGrade.SelectedValue;
            debugSubjects.InnerText = $"Grade changed to: {selectedGrade} for school: {schoolCode}";
            debugSubjects.Visible = true;

            if (!string.IsNullOrEmpty(schoolCode) && !string.IsNullOrEmpty(selectedGrade))
            {
                LoadSchoolSubjects(schoolCode, selectedGrade);
                subjectGroup.Visible = true;
            }
            else
            {
                subjectGroup.Visible = false;
            }
        }

        private void LoadSchoolSubjects(string schoolCode, string gradeLevel)
        {
            try
            {
                ddlSubjects.Items.Clear();
                ddlSubjects.Items.Add(new ListItem("-- Select Subject --", ""));

                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    string query = @"
                SELECT SubjectCode
                FROM Subjects
                WHERE SchoolCode = @SchoolCode
                AND GradeLevel = @GradeLevel
                AND NOT EXISTS (
                    SELECT 1 FROM Teachers t
                    WHERE t.SchoolCode = Subjects.SchoolCode
                    AND t.SubjectCode = Subjects.SubjectCode
                    AND t.GradeLevel = Subjects.GradeLevel
                )
                ORDER BY SubjectCode";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                        cmd.Parameters.AddWithValue("@GradeLevel", gradeLevel);

                        if (con.State != ConnectionState.Open)
                            con.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                while (reader.Read())
                                {
                                    string subjectCode = reader["SubjectCode"].ToString();
                                    ddlSubjects.Items.Add(new ListItem(subjectCode, subjectCode));
                                }
                                debugSubjects.InnerText += "\nSubjects loaded successfully.";
                                return;
                            }
                            else
                            {
                                debugSubjects.InnerText += "\nNo subjects found for this grade.";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                debugSubjects.InnerText += $"\nError loading subjects: {ex.Message}";
            }
            finally
            {
                debugSubjects.Visible = true;
            }
        }

        protected void btnAddSubject_Click(object sender, EventArgs e)
        {
            if (ddlSystemSubjects.SelectedIndex <= 0 || string.IsNullOrEmpty(ddlSubjectGrade.SelectedValue))
            {
                litSchoolStatus.Text = "<div class='error-message'>Please select both a subject and grade</div>";
                return;
            }

            string subjectCode = ddlSystemSubjects.SelectedValue;
            string subjectName = ddlSystemSubjects.SelectedItem.Text;
            string gradeLevel = ddlSubjectGrade.SelectedValue;

            string newItemValue = $"{subjectCode}|{gradeLevel}";
            if (lstSchoolSubjects.Items.Cast<ListItem>().Any(item => item.Value == newItemValue))
            {
                litSchoolStatus.Text = "<div class='error-message'>This subject and grade combination is already added</div>";
                return;
            }

            lstSchoolSubjects.Items.Add(new ListItem($"{subjectName} (Grade {gradeLevel})", newItemValue));
        }

        protected void btnRemoveSubject_Click(object sender, EventArgs e)
        {
            if (lstSchoolSubjects.SelectedIndex >= 0)
            {
                lstSchoolSubjects.Items.RemoveAt(lstSchoolSubjects.SelectedIndex);
            }
            else
            {
                litSchoolStatus.Text = "<div class='error-message'>Please select a subject to remove</div>";
            }
        }

        protected void btnTeacherRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                string schoolCode = txtSchoolCode.Text.Trim();
                string selectedSubjectCode = ddlSubjects.SelectedValue;
                string selectedGrade = ddlGrade.SelectedValue;

                if (string.IsNullOrEmpty(schoolCode))
                {
                    ShowTeacherMessage("Please enter a school code", false);
                    return;
                }

                if (string.IsNullOrEmpty(selectedGrade))
                {
                    ShowTeacherMessage("Please select a grade", false);
                    return;
                }

                if (string.IsNullOrEmpty(selectedSubjectCode))
                {
                    ShowTeacherMessage("Please select a subject", false);
                    return;
                }

                if (!SubjectExists(schoolCode, selectedSubjectCode, selectedGrade))
                {
                    ShowTeacherMessage("Invalid subject/grade combination", false);
                    return;
                }

                if (SubjectHasTeacher(schoolCode, selectedSubjectCode, selectedGrade))
                {
                    ShowTeacherMessage("This subject already has a teacher assigned", false);
                    return;
                }

                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(txtPassword.Text);

                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    con.Open();
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                            string query = @"INSERT INTO Teachers
                                        (Username, PasswordHash, Email, FullName, SubjectCode,
                                         RegistrationDate, SchoolCode, GradeLevel)
                                         VALUES
                                         (@Username, @PasswordHash, @Email, @FullName, @SubjectCode,
                                         GETDATE(), @SchoolCode, @GradeLevel)";

                            using (SqlCommand cmd = new SqlCommand(query, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@Username", txtUsername.Text);
                                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                                cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                                cmd.Parameters.AddWithValue("@FullName", txtFullName.Text);
                                cmd.Parameters.AddWithValue("@SubjectCode", selectedSubjectCode);
                                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                                cmd.Parameters.AddWithValue("@GradeLevel", selectedGrade);

                                int rowsAffected = cmd.ExecuteNonQuery();

                                if (rowsAffected > 0)
                                {
                                    transaction.Commit();
                                    ShowTeacherMessage("Registration successful!", true);
                                    ClearTeacherForm();

                                    // 🔔 Fire the success popup (change redirect if you like)
                                    var js = @"
                                    (function(){
                                      var fire = function(){
                                        if (typeof showSuccessAndRedirect === 'function') {
                                          showSuccessAndRedirect('Teacher registered successfully!', 'Default.aspx');
                                        } else if (typeof showSuccessCard === 'function') {
                                          showSuccessCard({ title:'SUCCESS', message:'Teacher registered successfully!', redirectUrl:'Default.aspx', autoCloseMs:2200 });
                                        }
                                      };
                                      if (window.Sys && Sys.Application && typeof Sys.Application.add_load === 'function') {
                                        Sys.Application.add_load(fire);
                                      } else {
                                        window.addEventListener('load', fire);
                                      }
                                    })();";
                                    ScriptManager.RegisterStartupScript(this, GetType(), "TeacherRegisterSuccess", js, true);
                                }
                                else
                                {
                                    transaction.Rollback();
                                    ShowTeacherMessage("Registration failed", false);
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            ShowTeacherMessage("Error: " + ex.Message, false);
                            debugSubjects.InnerText += $"\nRegistration error: {ex.Message}";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowTeacherMessage("Error: " + ex.Message, false);
                debugSubjects.InnerText += $"\nError: {ex.Message}";
                debugSubjects.Visible = true;
            }
        }

        protected void btnSchoolRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                if (SchoolEmailExists(txtSchoolEmail.Text.Trim()))
                {
                    litSchoolStatus.Text = "<div class='error-message'>This email is already registered. Please use a different email address.</div>";
                    return;
                }

                if (lstSchoolSubjects.Items.Count == 0)
                {
                    litSchoolStatus.Text = "<div class='error-message'>Please add at least one subject</div>";
                    return;
                }

                string schoolCode = GenerateSchoolCode();
                txtGeneratedSchoolCode.Text = schoolCode;
                schoolCodeGroup.Visible = true;

                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(txtSchoolPassword.Text);

                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    con.Open();
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                            // Insert school
                            string schoolQuery = @"INSERT INTO Schools
                                        (SchoolCode, SchoolName, Address, Email, Phone, 
                                         IsPremium, RegistrationDate, PasswordHash)
                                         VALUES
                                         (@SchoolCode, @SchoolName, @Address, @Email, @Phone,
                                         @IsPremium, GETDATE(), @PasswordHash)";

                            using (SqlCommand cmd = new SqlCommand(schoolQuery, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                                cmd.Parameters.AddWithValue("@SchoolName", txtSchoolName.Text.Trim());
                                cmd.Parameters.AddWithValue("@Address", txtSchoolAddress.Text.Trim());
                                cmd.Parameters.AddWithValue("@Email", txtSchoolEmail.Text.Trim());
                                cmd.Parameters.AddWithValue("@Phone", txtSchoolPhone.Text.Trim());
                                cmd.Parameters.AddWithValue("@IsPremium", ddlSubscriptionPlan.SelectedValue == "Premium");
                                cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                                cmd.ExecuteNonQuery();
                            }

                            // Insert subjects
                            foreach (ListItem item in lstSchoolSubjects.Items)
                            {
                                string[] parts = item.Value.Split('|');
                                string subjectCode = parts[0];
                                string gradeLevel = parts[1];
                                string subjectName = GetSubjectName(subjectCode);

                                string subjectQuery = @"INSERT INTO Subjects
                                              (SubjectCode, SubjectName, SchoolCode, GradeLevel)
                                              VALUES
                                              (@SubjectCode, @SubjectName, @SchoolCode, @GradeLevel)";

                                using (SqlCommand cmd = new SqlCommand(subjectQuery, con, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                                    cmd.Parameters.AddWithValue("@SubjectName", subjectName);
                                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                                    cmd.Parameters.AddWithValue("@GradeLevel", gradeLevel);

                                    cmd.ExecuteNonQuery();
                                }
                            }

                            transaction.Commit();
                            litSchoolStatus.Text = "<div class='success-message'>School registered successfully! Your school code is: " + schoolCode + "</div>";
                            ClearSchoolFormExceptCode();
                            schoolCodeGroup.Visible = true;

                            // 🔔 Show popup with code and redirect
                            var js = $@"
                            (function(){{
                              var msg = 'School registered successfully! Your school code is: {schoolCode}';
                              var fire = function(){{
                                if (typeof showSuccessAndRedirect === 'function') {{
                                  showSuccessAndRedirect(msg, 'Default.aspx');
                                }} else if (typeof showSuccessCard === 'function') {{
                                  showSuccessCard({{ title:'SUCCESS', message: msg, redirectUrl:'Default.aspx', autoCloseMs:2800 }});
                                }}
                              }};
                              if (window.Sys && Sys.Application && typeof Sys.Application.add_load === 'function') {{
                                Sys.Application.add_load(fire);
                              }} else {{
                                window.addEventListener('load', fire);
                              }}
                            }})();";
                            ScriptManager.RegisterStartupScript(this, GetType(), "SchoolRegisterSuccess", js, true);
                        }
                        catch (SqlException sqlEx)
                        {
                            transaction.Rollback();
                            litSchoolStatus.Text = $"<div class='error-message'>Database error: {sqlEx.Message}</div>";
                            schoolCodeGroup.Visible = true;
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            litSchoolStatus.Text = $"<div class='error-message'>Error: {ex.Message}</div>";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                litSchoolStatus.Text = $"<div class='error-message'>Error: {ex.Message}</div>";
            }
        }

        private string GetSubjectName(string subjectCode)
        {
            switch (subjectCode)
            {
                case "PHYS": return "Physics";
                case "CAT": return "CAT/IT";
                case "EGD": return "EGD";
                case "MATH": return "Mathematics";
                case "GEOG": return "Geography";
                case "LIFE": return "Life Science";
                case "ACCT": return "Accounting";
                case "AGRI": return "Agriculture";
                case "ENGL": return "English";
                default: return subjectCode;
            }
        }

        private string GenerateSchoolCode()
        {
            Random rnd = new Random();
            string code;

            do
            {
                code = rnd.Next(10000, 99999).ToString();
            } while (SchoolExists(code));

            return code;
        }

        private bool SchoolExists(string schoolCode)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = "SELECT COUNT(*) FROM Schools WHERE SchoolCode = @SchoolCode";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                    con.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool SchoolEmailExists(string email)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = "SELECT COUNT(*) FROM Schools WHERE Email = @Email";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    con.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool SubjectExists(string schoolCode, string subjectCode, string gradeLevel)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = @"SELECT COUNT(*) FROM Subjects
                         WHERE SchoolCode = @SchoolCode
                         AND SubjectCode = @SubjectCode
                         AND GradeLevel = @GradeLevel";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    cmd.Parameters.AddWithValue("@GradeLevel", gradeLevel);

                    if (con.State != ConnectionState.Open)
                        con.Open();

                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool SubjectHasTeacher(string schoolCode, string subjectCode, string gradeLevel)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = @"SELECT COUNT(*) FROM Teachers
                                 WHERE SchoolCode = @SchoolCode
                                 AND SubjectCode = @SubjectCode
                                 AND GradeLevel = @GradeLevel";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    cmd.Parameters.AddWithValue("@GradeLevel", gradeLevel);
                    con.Open();
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private void ShowTeacherMessage(string message, bool isSuccess)
        {
            litTeacherStatus.Text = $"<div class='{(isSuccess ? "success" : "error")}-message'>{message}</div>";
        }

        private void ClearTeacherForm()
        {
            txtFullName.Text = "";
            txtEmail.Text = "";
            txtUsername.Text = "";
            txtPassword.Text = "";
            txtSchoolCode.Text = "";
            ddlGrade.SelectedIndex = 0;
            ddlSubjects.Items.Clear();
            subjectGroup.Visible = false;
            gradeGroup.Visible = false;
            debugSubjects.Visible = false;
        }

        private void ClearSchoolFormExceptCode()
        {
            txtSchoolName.Text = "";
            txtSchoolAddress.Text = "";
            txtSchoolEmail.Text = "";
            txtSchoolPhone.Text = "";
            txtSchoolPassword.Text = "";
            txtSchoolConfirmPassword.Text = "";
            lstSchoolSubjects.Items.Clear();
            ddlSystemSubjects.SelectedIndex = 0;
            ddlSubjectGrade.SelectedIndex = 0;
            schoolCodeGroup.Visible = true;
        }

        protected void btnTeacherForm_Click(object sender, EventArgs e)
        {
            TeacherForm.CssClass = "form-container active";
            SchoolForm.CssClass = "form-container";
            btnTeacherForm.CssClass = "type-btn active";
            btnSchoolForm.CssClass = "type-btn";
            schoolCodeGroup.Visible = false;
        }

        protected void btnSchoolForm_Click(object sender, EventArgs e)
        {
            TeacherForm.CssClass = "form-container";
            SchoolForm.CssClass = "form-container active";
            btnTeacherForm.CssClass = "type-btn";
            btnSchoolForm.CssClass = "type-btn active";
        }
    }
}
