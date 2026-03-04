using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using BCrypt.Net;

namespace Edugate_Project
{
    public partial class StudentRegistration : System.Web.UI.Page
    {
        private readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = "";
                cblSubjects.Items.Clear();
                pnlSubjectSelection.Visible = false;
            }
        }

        /* ======================
           Reactive subject list
           ====================== */
        protected void txtSchoolCode_TextChanged(object sender, EventArgs e) => CheckAndLoadSubjects();
        protected void ddlGradeLevel_SelectedIndexChanged(object sender, EventArgs e) => CheckAndLoadSubjects();

        private void CheckAndLoadSubjects()
        {
            if (!int.TryParse(txtSchoolCode.Text.Trim(), out int schoolCode))
            {
                cblSubjects.Items.Clear();
                pnlSubjectSelection.Visible = false;
                return;
            }
            if (!int.TryParse(ddlGradeLevel.SelectedValue, out int gradeLevel) || gradeLevel <= 0)
            {
                cblSubjects.Items.Clear();
                pnlSubjectSelection.Visible = false;
                return;
            }

            pnlSubjectSelection.Visible = true;
            BindSubjects(schoolCode, gradeLevel);
        }

        private void BindSubjects(int schoolCode, int gradeLevel)
        {
            if (string.IsNullOrWhiteSpace(ConnectionString))
            {
                ShowStatusMessage("Database connection string is not configured.", "error");
                pnlSubjectSelection.Visible = false;
                return;
            }

            cblSubjects.Items.Clear();

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(
                @"SELECT SubjectCode, SubjectName
                  FROM Subjects
                  WHERE SchoolCode=@SchoolCode AND GradeLevel=@GradeLevel
                  ORDER BY SubjectName;", con))
            {
                cmd.Parameters.Add("@SchoolCode", SqlDbType.Int).Value = schoolCode;
                cmd.Parameters.Add("@GradeLevel", SqlDbType.Int).Value = gradeLevel;

                try
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.HasRows)
                        {
                            while (r.Read())
                            {
                                cblSubjects.Items.Add(
                                    new ListItem(
                                        r["SubjectName"].ToString(),
                                        r["SubjectCode"].ToString()
                                    ));
                            }
                            lblMessage.Text = "";
                            pnlSubjectSelection.Visible = true;
                        }
                        else
                        {
                            pnlSubjectSelection.Visible = false;
                            ShowStatusMessage("No subjects found for this School Code and Grade Level.", "info");
                        }
                    }
                }
                catch (Exception ex)
                {
                    pnlSubjectSelection.Visible = false;
                    ShowStatusMessage($"Error loading subjects: {ex.Message}", "error");
                }
            }
        }

        /* ======================
           Register
           ====================== */
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Let validators show messages if invalid
            if (!Page.IsValid)
            {
                if (!int.TryParse(txtSchoolCode.Text.Trim(), out _) ||
                    !int.TryParse(ddlGradeLevel.SelectedValue, out int g) || g <= 0)
                {
                    pnlSubjectSelection.Visible = false;
                }
                return;
            }

            if (string.IsNullOrWhiteSpace(ConnectionString))
            {
                ShowStatusMessage("Database connection string is not configured.", "error");
                return;
            }

            // Build FullName from First + Last (DB has only FullName)
            string firstName = (txtFullName.Text ?? "").Trim();
            string lastName = (txtLastName.Text ?? "").Trim();
            string fullName = string.IsNullOrEmpty(lastName) ? firstName : (firstName + " " + lastName).Trim();

            string email = (txtEmail.Text ?? "").Trim();
            string address = (txtAddress.Text ?? "").Trim();
            string gender = (ddlGender.SelectedValue ?? "").Trim();

            // Parse numeric columns to match DB types
            if (!int.TryParse(txtSchoolCode.Text.Trim(), out int schoolCode))
            {
                ShowStatusMessage("School Code must be a valid number.", "error");
                pnlSubjectSelection.Visible = false;
                return;
            }
            if (!int.TryParse(ddlGradeLevel.SelectedValue, out int gradeLevel) || gradeLevel <= 0)
            {
                ShowStatusMessage("Grade Level is required.", "error");
                pnlSubjectSelection.Visible = false;
                return;
            }

            // Hash password
            string rawPassword = (txtPassword.Text ?? "").Trim();
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(rawPassword);

            using (var con = new SqlConnection(ConnectionString))
            {
                con.Open();
                var tx = con.BeginTransaction();

                try
                {
                    // Unique email check
                    using (var check = new SqlCommand("SELECT COUNT(*) FROM Students WHERE Email=@Email;", con, tx))
                    {
                        check.Parameters.Add("@Email", SqlDbType.NVarChar, 256).Value = email;
                        int exists = Convert.ToInt32(check.ExecuteScalar());
                        if (exists > 0)
                        {
                            ShowStatusMessage("An account with this email already exists.", "error");
                            tx.Rollback();
                            return;
                        }
                    }

                    // Insert student — match table columns exactly
                    int newStudentId;
                    using (var cmd = new SqlCommand(@"
                        INSERT INTO Students
                            (FullName, Address, Gender, Email, PasswordHash, RegistrationDate, SchoolCode, Grade, GradeLevel, IsActive, LastLogin)
                        VALUES
                            (@FullName, @Address, @Gender, @Email, @PasswordHash, GETDATE(), @SchoolCode, @Grade, @GradeLevel, @IsActive, @LastLogin);
                        SELECT CAST(SCOPE_IDENTITY() AS int);", con, tx))
                    {
                        cmd.Parameters.Add("@FullName", SqlDbType.NVarChar, 200).Value =
                            string.IsNullOrWhiteSpace(fullName) ? (object)DBNull.Value : fullName;
                        cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value =
                            string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address;
                        cmd.Parameters.Add("@Gender", SqlDbType.NVarChar, 50).Value =
                            string.IsNullOrWhiteSpace(gender) ? (object)DBNull.Value : gender;
                        cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 256).Value = email;
                        cmd.Parameters.Add("@PasswordHash", SqlDbType.NVarChar, 200).Value = hashedPassword;
                        cmd.Parameters.Add("@SchoolCode", SqlDbType.Int).Value = schoolCode;

                        // If you don’t use Grade separately, you can store same as GradeLevel or NULL
                        cmd.Parameters.Add("@Grade", SqlDbType.Int).Value = gradeLevel;
                        cmd.Parameters.Add("@GradeLevel", SqlDbType.Int).Value = gradeLevel;

                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = true;
                        cmd.Parameters.Add("@LastLogin", SqlDbType.DateTime).Value = DBNull.Value;

                        newStudentId = (int)cmd.ExecuteScalar();
                    }

                    // Optional: StudentSubjects
                    try
                    {
                        using (var cmdSub = new SqlCommand(
                            "INSERT INTO StudentSubjects (StudentID, SubjectCode) VALUES (@StudentID, @SubjectCode);", con, tx))
                        {
                            cmdSub.Parameters.Add("@StudentID", SqlDbType.Int).Value = newStudentId;
                            var pCode = cmdSub.Parameters.Add("@SubjectCode", SqlDbType.NVarChar, 50);

                            foreach (ListItem item in cblSubjects.Items)
                            {
                                if (item.Selected)
                                {
                                    pCode.Value = item.Value;
                                    cmdSub.ExecuteNonQuery();
                                }
                            }
                        }
                    }
                    catch
                    {
                        // ignore if table not present
                    }

                    tx.Commit();

                    // Reset UI
                    ClearFormFields();
                    pnlSubjectSelection.Visible = false;

                    // === Defer success popup until page scripts are ready ===
                    var js = @"
(function(){
  var fire = function(){
    if (typeof showSuccessAndRedirect === 'function') {
      showSuccessAndRedirect();
    } else if (typeof showSuccessCard === 'function') {
      showSuccessCard({
        title:'SUCCESS',
        message:'Registration successful!',
        buttonText:'CONTINUE',
        redirectUrl:'Default.aspx',
        autoCloseMs:2200
      });
    } else {
      window.location.href = 'Default.aspx';
    }
  };
  if (window.Sys && Sys.Application && typeof Sys.Application.add_load === 'function') {
    Sys.Application.add_load(fire);
  } else {
    window.addEventListener('load', fire);
  }
})();";
                    ScriptManager.RegisterStartupScript(this, GetType(), "regSuccess", js, true);
                }
                catch (SqlException ex)
                {
                    tx.Rollback();
                    ShowStatusMessage($"Database error: {ex.Message} (#{ex.Number})", "error");
                }
                catch (Exception ex)
                {
                    tx.Rollback();
                    ShowStatusMessage($"Unexpected error: {ex.Message}", "error");
                }
            }
        }

        private void ClearFormFields()
        {
            txtFullName.Text = "";
            txtLastName.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            txtEmail.Text = "";
            txtAddress.Text = "";
            ddlGender.SelectedIndex = 0;
            txtSchoolCode.Text = "";
            ddlGradeLevel.SelectedIndex = 0;
            cblSubjects.Items.Clear();
        }

        private void ShowStatusMessage(string message, string type)
        {
            string color = type == "error" ? "red" :
                           type == "success" ? "green" :
                           type == "info" ? "deepskyblue" : "white";
            lblMessage.Text = $"<span style='color:{color};'>{message}</span>";
        }
    }
}
