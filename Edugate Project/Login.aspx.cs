using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;
using BCrypt.Net; // Ensure this NuGet package is installed in your project

namespace Edugate_Project
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblMessage.Text = "";
            }
        }

        protected void btnLOGIN_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                // CHANGE: Use txtEmail.Text instead of txtFullName.Text
                string emailInput = txtEmail.Text.Trim(); // Now using Email for login
                string password = txtPassword.Text.Trim();

                string connectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    try
                    {
                        con.Open();

                        // CHANGE: Query by Email instead of FullName
                        string query = @"SELECT StudentID, PasswordHash, FullName FROM Students
                                         WHERE Email = @Email"; // Changed WHERE clause and parameter name

                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            // CHANGE: Add parameter for @Email
                            cmd.Parameters.AddWithValue("@Email", emailInput); // Changed parameter name

                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    // Student found by Email, now verify password
                                    int studentID = (int)reader["StudentID"];
                                    string storedPasswordHash = reader["PasswordHash"].ToString();
                                    string retrievedFullName = reader["FullName"].ToString();

                                    // --- Password Verification using BCrypt.Net-Core ---
                                    bool isPasswordValid = BCrypt.Net.BCrypt.Verify(password, storedPasswordHash);

                                    if (isPasswordValid)
                                    {
                                        // Successful login:
                                        Session["IsStudentLoggedIn"] = true;
                                        Session["StudentID"] = studentID;
                                        Session["StudentFullName"] = retrievedFullName;
                                        // Optional: Store the email as well if needed in other pages
                                        Session["StudentEmail"] = emailInput;

                                        reader.Close(); // Close the current reader before redirecting

                                        Response.Redirect("StudentDashboard.aspx");
                                    }
                                    else
                                    {
                                        // Failed login: Password does not match
                                        lblMessage.Text = "<span style='color:red;'>Invalid email or password.</span>"; // Updated message
                                    }
                                }
                                else
                                {
                                    // Failed login: Email not found
                                    lblMessage.Text = "<span style='color:red;'>Invalid email or password.</span>"; // Updated message
                                }
                            }
                        }
                    }
                    catch (SqlException sqlEx)
                    {
                        lblMessage.Text = "<span style='color:red;'>A database error occurred. Please try again later.<br/>";
                        lblMessage.Text += $"SQL Error Details: {sqlEx.Message}</span>";
                        // In a production environment, log this to a file or monitoring system,
                        // do NOT display raw error details to the user.
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "<span style='color:red;'>An unexpected error occurred. Please try again.<br/>";
                        lblMessage.Text += $"Error Details: {ex.Message}</span>";
                        // In a production environment, log this to a file or monitoring system.
                    }
                }
            }
            else
            {
                // If Page.IsValid is false, validators will display their messages.
            }
        }
    }
}