using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Edugate_Project
{
    public partial class TeacherDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["TeacherID"] == null)
                {
                    Response.Redirect("TeacherLogin.aspx");
                }
                else
                {
                    LoadTeacherData();
                    LoadStudentCount();
                }
            }
        }

        private void LoadTeacherData()
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query = "SELECT FullName, Email, SubjectCode, SchoolCode FROM Teachers WHERE TeacherID = @TeacherID";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);

                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();

                    if (reader.Read())
                    {
                        lblTeacherName.Text = reader["FullName"].ToString();
                        lblSidebarTeacherName.Text = reader["FullName"].ToString();
                        lblEmail.Text = reader["Email"].ToString();
                        lblSubject.Text = reader["SubjectCode"].ToString();
                        lblSchoolName.Text = reader["SchoolCode"].ToString();

                        // Pre-populate the edit form
                        txtFullName.Text = reader["FullName"].ToString();
                        txtEmail.Text = reader["Email"].ToString();
                        txtSubject.Text = reader["SubjectCode"].ToString();
                    }

                    reader.Close();
                }
            }
        }

        private void LoadStudentCount()
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) AS StudentCount FROM Students WHERE SchoolCode = (SELECT SchoolCode FROM Teachers WHERE TeacherID = @TeacherID)";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);

                    connection.Open();
                    object result = command.ExecuteScalar();

                    if (result != null)
                    {
                        lblStudentCount.Text = result.ToString();
                    }
                }
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    // Check if password needs to be updated
                    if (!string.IsNullOrEmpty(txtPassword.Text))
                    {
                        if (txtPassword.Text != txtConfirmPassword.Text)
                        {
                            // Passwords don't match
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Passwords do not match.');", true);
                            return;
                        }

                        // Update with password
                        string query = "UPDATE Teachers SET FullName = @FullName, Email = @Email, SubjectCode = @SubjectCode, PasswordHash = @PasswordHash WHERE TeacherID = @TeacherID";

                        using (SqlCommand command = new SqlCommand(query, connection))
                        {
                            command.Parameters.AddWithValue("@FullName", txtFullName.Text);
                            command.Parameters.AddWithValue("@Email", txtEmail.Text);
                            command.Parameters.AddWithValue("@SubjectCode", txtSubject.Text);
                            command.Parameters.AddWithValue("@PasswordHash", HashPassword(txtPassword.Text));
                            command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);

                            connection.Open();
                            int rowsAffected = command.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Profile updated successfully.');", true);
                                LoadTeacherData(); // Refresh the displayed data
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error updating profile.');", true);
                            }
                        }
                    }
                    else
                    {
                        // Update without password
                        string query = "UPDATE Teachers SET FullName = @FullName, Email = @Email, SubjectCode = @SubjectCode WHERE TeacherID = @TeacherID";

                        using (SqlCommand command = new SqlCommand(query, connection))
                        {
                            command.Parameters.AddWithValue("@FullName", txtFullName.Text);
                            command.Parameters.AddWithValue("@Email", txtEmail.Text);
                            command.Parameters.AddWithValue("@SubjectCode", txtSubject.Text);
                            command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);

                            connection.Open();
                            int rowsAffected = command.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Profile updated successfully.');", true);
                                LoadTeacherData(); // Refresh the displayed data
                            }
                            else
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error updating profile.');", true);
                            }
                        }
                    }
                }
            }
        }

        // Simple password hashing function - you might want to use a more secure method
        private string HashPassword(string password)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                var hashedBytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(hashedBytes);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}