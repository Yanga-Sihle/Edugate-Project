using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Security;
using BCrypt.Net;
using Edugate_Project.Models;

namespace Edugate_Project
{
    // IMPORTANT: The 'Teacher' class should be defined ONCE
    // in a separate, shared file (e.g., Models.cs) in your project.
    // Ensure you have a file like Models.cs with this definition, INCLUDING SchoolCode:
    /*
    // Example Models.cs content:
    namespace Edugate_Project.Models
    {
        public class Teacher
        {
            public int TeacherID { get; set; }
            public string Username { get; set; }
            public string PasswordHash { get; set; } // This will store the BCrypt hash
            public string Email { get; set; }
            public string FullName { get; set; }
            public string SubjectCode { get; set; }
            public int SchoolCode { get; set; } // Added SchoolCode property
            public DateTime RegistrationDate { get; set; }
        }
    }
    */
    // Add this using directive if your Teacher class is in Edugate_Project.Models
    using Edugate_Project.Models;


    public partial class TeacherLogin : System.Web.UI.Page
    {
        // Connection string to your SQL Server database
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                     "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";
        // Replace "YourServerName" and "EdugateDB" with your actual server and database names.

        protected void Page_Load(object sender, EventArgs e)
        {
            // No specific logic needed on page load for a simple login form
        }

        /// <summary>
        /// Event handler for the Login button click.
        /// Authenticates the teacher using provided credentials against the database.
        /// </summary>
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string plainTextPassword = txtPassword.Text; // Get plain text password for BCrypt.Verify

            if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(plainTextPassword))
            {
                ShowStatusMessage("Username and password are required.", "error");
                return;
            }

            // Attempt to authenticate the teacher using the plain text password
            Teacher authenticatedTeacher = AuthenticateTeacher(username, plainTextPassword); // Pass plain text password

            if (authenticatedTeacher != null)
            {
                // Login successful
                ShowStatusMessage("Login successful! Redirecting...", "success");

                // FormsAuthentication Ticket
                FormsAuthentication.SetAuthCookie(authenticatedTeacher.Username, false);

                // Store teacher information in session
                Session["TeacherID"] = authenticatedTeacher.TeacherID;
                Session["TeacherUsername"] = authenticatedTeacher.Username;
                Session["FullName"] = authenticatedTeacher.FullName;
                Session["SubjectCode"] = authenticatedTeacher.SubjectCode;
                Session["SchoolCode"] = authenticatedTeacher.SchoolCode;
                Session["IsTeacherLoggedIn"] = true;

                // Redirect to dashboard
                Response.Redirect("TeacherDashboard.aspx");
            }
            else
            {
                // Login failed
                ShowStatusMessage("Invalid username or password.", "error");
            }
        }

        /// <summary>
        /// Authenticates a teacher by checking credentials against the database.
        /// </summary>
        /// <param name="username">The username provided by the teacher.</param>
        /// <param name="plainTextPassword">The plain text password provided by the teacher.</param>
        /// <returns>A Teacher object if authentication is successful, otherwise null.</returns>
        private Teacher AuthenticateTeacher(string username, string plainTextPassword)
        {
            Teacher teacher = null;
            // Modified query to fetch PasswordHash and SchoolCode
            string query = "SELECT TeacherID, Username, PasswordHash, Email, FullName, SubjectCode, SchoolCode FROM Teachers WHERE Username = @Username";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Username", username);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedPasswordHash = reader["PasswordHash"].ToString();

                                // --- IMPORTANT: Use BCrypt.Net.BCrypt.Verify to check the password ---
                                if (BCrypt.Net.BCrypt.Verify(plainTextPassword, storedPasswordHash))
                                {
                                    teacher = new Teacher
                                    {
                                        TeacherID = (int)reader["TeacherID"],
                                        Username = reader["Username"].ToString(),
                                        Email = reader["Email"].ToString(),
                                        FullName = reader["FullName"].ToString(),
                                        SubjectCode = reader["SubjectCode"].ToString(),
                                        SchoolCode = (int)reader["SchoolCode"] // Retrieve SchoolCode
                                    };
                                }
                                // If Verify returns false, 'teacher' remains null, leading to login failure message
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error during teacher authentication: {ex.Message}");
                        // In a real application, log this error more robustly (e.g., to a file, not just console).
                    }
                }
            }
            return teacher;
        }

        // --- REMOVED THE OLD SHA256 HashPassword method ---
        // It is no longer needed here as BCrypt.Net.BCrypt.Verify handles the comparison.

        /// <summary>
        /// Displays a status message to the user.
        /// </summary>
        /// <param name="message">The message text.</param>
        /// <param name="type">The type of message (e.g., "success", "error", "info").</param>
        private void ShowStatusMessage(string message, string type)
        {
            litStatusMessage.Text = $"<div class='status-message {type}'>{message}</div>";
        }
    }
}