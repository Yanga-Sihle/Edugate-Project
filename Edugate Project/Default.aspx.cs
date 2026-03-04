using BCrypt.Net;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Edugate_Project
{
    public partial class Default : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // You can add any initialization logic here if needed
        }
        protected void btnSchoolLogin_Click(object sender, EventArgs e)
        {
            string schoolCode = txtSchoolCode.Text.Trim();
            string password = txtSchoolPassword.Text;

            if (string.IsNullOrEmpty(schoolCode) || string.IsNullOrEmpty(password))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "alert('Please enter both school code and password');", true);
                return;
            }

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = @"SELECT SchoolCode, SchoolName, PasswordHash, IsPremium 
                                FROM Schools 
                                WHERE SchoolCode = @SchoolCode";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedHash = reader["PasswordHash"].ToString();

                                if (BCrypt.Net.BCrypt.Verify(password, storedHash))
                                {
                                    // Successful login
                                    Session["IsSchoolLoggedIn"] = true;
                                    Session["SchoolCode"] = reader["SchoolCode"];
                                    Session["SchoolName"] = reader["SchoolName"];
                                    Session["IsPremium"] = reader["IsPremium"];
                                    Response.Redirect("SchoolDashboard.aspx");
                                }
                                else
                                {
                                    // Invalid password
                                    ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                                        "alert('Invalid school code or password');", true);
                                }
                            }
                            else
                            {
                                // School not found
                                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                                    "alert('Invalid school code or password');", true);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Handle error
                        ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                            $"alert('An error occurred: {ex.Message}');", true);
                    }
                }
            }
        }


        protected void btnStudentLogin_Click(object sender, EventArgs e)
        {
            string email = txtStudentEmail.Text.Trim();
            string password = txtStudentPassword.Text;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError", "alert('Please enter both email and password');", true);
                return;
            }

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = @"SELECT StudentID, PasswordHash, FullName FROM Students 
                                WHERE Email = @Email";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedHash = reader["PasswordHash"].ToString();

                                if (BCrypt.Net.BCrypt.Verify(password, storedHash))
                                {
                                    // Successful login
                                    Session["IsStudentLoggedIn"] = true;
                                    Session["StudentID"] = reader["StudentID"];
                                    Session["StudentFullName"] = reader["FullName"];
                                    Response.Redirect("StudentDashboard.aspx");
                                }
                                else
                                {
                                    // Invalid password
                                    ScriptManager.RegisterStartupScript(this, GetType(), "showError", "alert('Invalid email or password');", true);
                                }
                            }
                            else
                            {
                                // Email not found
                                ScriptManager.RegisterStartupScript(this, GetType(), "showError", "alert('Invalid email or password');", true);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Handle error
                        ScriptManager.RegisterStartupScript(this, GetType(), "showError", $"alert('An error occurred: {ex.Message}');", true);
                    }
                }
            }
        }

        protected void btnAdminLogin_Click(object sender, EventArgs e)
        {
            string username = txtAdminUsername.Text.Trim();
            string password = txtAdminPassword.Text;

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "alert('Please enter both username and password');", true);
                return;
            }

            // First try admin login (plain text password)
            try
            {
                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    string adminQuery = @"SELECT AdminId, Username FROM [Admin] 
                           WHERE Username = @Username AND Password = @Password";

                    using (SqlCommand cmd = new SqlCommand(adminQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Password", password);

                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                Session["IsAdminLoggedIn"] = true;
                                Session["AdminUsername"] = username;
                                Session["AdminId"] = reader["AdminId"];
                                Response.Redirect("AdminDashboard.aspx");
                                return;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"alert('Error during admin login: {ex.Message}');", true);
                return;
            }

            // If admin login failed, try teacher login (hashed password)
            try
            {
                using (SqlConnection con = new SqlConnection(ConnectionString))
                {
                    string teacherQuery = @"SELECT TeacherId, Username, PasswordHash, FullName, SchoolCode, SubjectCode 
                              FROM Teachers 
                              WHERE Username = @Username";

                    using (SqlCommand cmd = new SqlCommand(teacherQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);

                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedHash = reader["PasswordHash"].ToString();

                                if (BCrypt.Net.BCrypt.Verify(password, storedHash))
                                {
                                    // Store all teacher information in session
                                    Session["IsTeacherLoggedIn"] = true;
                                    Session["TeacherUsername"] = username;
                                    Session["TeacherId"] = reader["TeacherId"];
                                    Session["TeacherFullName"] = reader["FullName"].ToString();
                                    Session["SchoolCode"] = reader["SchoolCode"].ToString();
                                    Session["SubjectCode"] = reader["SubjectCode"].ToString();

                                    // Get the subject name
                                    GetTeacherSubjectName(reader["SubjectCode"].ToString(), reader["SchoolCode"].ToString());

                                    Response.Redirect("TeacherDashboard.aspx");
                                    return;
                                }
                            }
                        }
                    }
                }

                // If we get here, credentials were invalid for both
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "alert('Invalid username or password');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"alert('Error during teacher login: {ex.Message}');", true);
            }

        }
        private void GetTeacherSubjectName(string subjectCode, string schoolCode)
        {
            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                string query = @"SELECT SubjectName FROM Subjects 
                        WHERE SubjectCode = @SubjectCode 
                        AND SchoolCode = @SchoolCode";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);

                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        Session["SubjectName"] = result.ToString();
                    }
                    else
                    {
                        Session["SubjectName"] = "Unknown Subject";
                    }
                }
            }
        }
    }
}