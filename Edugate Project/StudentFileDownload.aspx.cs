using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO; // Required for file operations
using System.Configuration; // Required for ConfigurationManager

namespace Edugate_Project
{
    public partial class StudentFileDownload : System.Web.UI.Page
    {
        // IMPORTANT: Update "YourDbConnection" with the actual name of your connection string from web.config
        private string connectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // CORRECTED: Check for "StudentID" from the login session
                // Ensure the user is logged in before proceeding
                if (Session["StudentID"] == null)
                {
                    Response.Redirect("Login.aspx"); // Redirect to your login page
                    return; // Stop further execution
                }

                // Call the new method to load student's personal information
                LoadStudentInfo();

                // Bind the rest of the page data (subjects and activities)
                BindSubjectFilter();
                LoadActivities();
            }
        }

        /// <summary>
        /// Retrieves and displays the logged-in student's personal information.
        /// Assumes StudentID is stored in Session["StudentID"] after login.
        /// </summary>
        private void LoadStudentInfo()
        {
            // CORRECTED: Use the correct Session key for StudentID
            int studentID = Convert.ToInt32(Session["StudentID"]);

            // SQL Query to get student details
            string query = "SELECT FullName, Email, SchoolCode FROM Students WHERE StudentId = @StudentID";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentID);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Populate the Literal controls with student data
                                litStudentFullName.Text = reader["FullName"].ToString();
                                litStudentEmail.Text = reader["Email"].ToString();
                                litStudentSchoolCode.Text = reader["SchoolCode"].ToString();
                            }
                            else
                            {
                                // Handle case where student ID is in session but no matching record found
                                litStatusMessage.Text = "<div class='status-message-global error'>Student information not found.</div>";
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log the exception for debugging in a real application (e.g., using a logging framework)
                        // For demonstration, displaying it on the page:
                        litStatusMessage.Text = $"<div class='status-message-global error'>Error loading student information: {ex.Message}</div>";
                        System.Diagnostics.Debug.WriteLine($"Error in LoadStudentInfo: {ex.Message}");
                    }
                }
            }
        }

        private void BindSubjectFilter()
        {
            DataTable dtSubjects = new DataTable();
            // CORRECTED: Filter subjects based on the student's enrollment
            string query = @"
                SELECT DISTINCT S.SubjectCode, S.SubjectName 
                FROM Subjects S
                INNER JOIN StudentEnrollments SE ON S.SubjectCode = SE.SubjectCode
                WHERE SE.StudentID = @StudentID
                ORDER BY S.SubjectName";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    // CORRECTED: Use the correct Session key
                    cmd.Parameters.AddWithValue("@StudentID", Convert.ToInt32(Session["StudentID"]));
                    con.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtSubjects);
                }
            }

            ddlSubjectFilter.DataSource = dtSubjects;
            ddlSubjectFilter.DataTextField = "SubjectName";
            ddlSubjectFilter.DataValueField = "SubjectCode";
            ddlSubjectFilter.DataBind();
            ddlSubjectFilter.Items.Insert(0, new ListItem("All Subjects", "")); // Add "All Subjects" option
        }

        protected void ddlSubjectFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadActivities();
        }

        private void LoadActivities()
        {
            // CORRECTED: Use the correct Session key
            int studentID = Convert.ToInt32(Session["StudentID"]);
            string selectedSubjectCode = ddlSubjectFilter.SelectedValue;

            DataTable dtActivities = new DataTable();

            // SQL Query to get activities (from UploadedFiles) for the student's enrolled subjects
            // and include teacher username and submission status.
            string query = @"
                SELECT
                    UF.FileID AS ActivityID,           -- Map FileID to ActivityID
                    UF.FileName AS ActivityTitle,      -- Use FileName as ActivityTitle
                    UF.Message AS Description,         -- Use Message as Description
                    UF.FilePath AS ActivityFilePath,   -- Map FilePath to ActivityFilePath
                    UF.FileName AS ActivityFileName,   -- Map FileName to ActivityFileName
                    UF.SubjectCode,
                    S.SubjectName,
                    T.Username AS TeacherUsername,
                    UF.UploadDate,                     -- Use UploadDate for display
                    (SELECT TOP 1 1 FROM ActivitySubmissions AS ASUB WHERE ASUB.ActivityID = UF.FileID AND ASUB.StudentID = @StudentID) AS HasSubmitted
                FROM UploadedFiles AS UF               -- Changed from Activities to UploadedFiles
                INNER JOIN StudentEnrollments AS SE ON UF.SubjectCode = SE.SubjectCode
                INNER JOIN Subjects AS S ON UF.SubjectCode = S.SubjectCode
                INNER JOIN Teachers AS T ON UF.TeacherID = T.TeacherID -- Assumes Teachers table exists for Username
                WHERE SE.StudentID = @StudentID";

            if (!string.IsNullOrEmpty(selectedSubjectCode))
            {
                query += " AND UF.SubjectCode = @SubjectCode";
            }
            query += " ORDER BY UF.UploadDate DESC";


            using (SqlConnection con = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentID);
                    if (!string.IsNullOrEmpty(selectedSubjectCode))
                    {
                        cmd.Parameters.AddWithValue("@SubjectCode", selectedSubjectCode);
                    }

                    con.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtActivities);
                }
            }

            if (dtActivities.Rows.Count > 0)
            {
                rptActivities.DataSource = dtActivities;
                rptActivities.DataBind();
                ActivityListPanel.Visible = true;
                litStatusMessage.Text = ""; // Clear any previous global messages
            }
            else
            {
                rptActivities.DataSource = null;
                rptActivities.DataBind();
                ActivityListPanel.Visible = false;
                litStatusMessage.Text = "<div class='status-message-global info'>No activities found for your enrolled subjects.</div>";
            }
        }

        protected void rptActivities_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SubmitActivity")
            {
                int activityID = Convert.ToInt32(e.CommandArgument);
                // CORRECTED: Use the correct Session key
                int studentID = Convert.ToInt32(Session["StudentID"]);

                // Find controls within the current Repeater item
                FileUpload fileUploadControl = (FileUpload)e.Item.FindControl("FileUploadSubmission");
                TextBox txtComments = (TextBox)e.Item.FindControl("txtSubmissionComments");
                Literal litSubmissionStatus = (Literal)e.Item.FindControl("litSubmissionStatus"); // This is the individual status message per activity

                if (fileUploadControl != null && fileUploadControl.HasFile)
                {
                    try
                    {
                        // 1. Define save path and filename
                        string submissionFolder = Server.MapPath("~/Submissions/");
                        if (!Directory.Exists(submissionFolder))
                        {
                            Directory.CreateDirectory(submissionFolder);
                        }

                        // Create a unique file name to avoid overwrites
                        // Format: ActivityID_StudentID_Timestamp_OriginalFileName
                        string originalFileName = Path.GetFileName(fileUploadControl.FileName);
                        string fileExtension = Path.GetExtension(originalFileName);
                        string uniqueFileName = $"{activityID}_{studentID}_{DateTime.Now.ToString("yyyyMMddHHmmss")}{fileExtension}";
                        string filePath = Path.Combine(submissionFolder, uniqueFileName);

                        // Save the file
                        fileUploadControl.SaveAs(filePath);

                        // 2. Record submission in the database
                        string comments = txtComments.Text;
                        string dbFilePath = "~/Submissions/" + uniqueFileName; // Path to store in DB

                        // Check if a submission already exists for this activity and student
                        // If so, update it. Otherwise, insert a new one.
                        string checkExistingQuery = "SELECT COUNT(*) FROM ActivitySubmissions WHERE ActivityID = @ActivityID AND StudentID = @StudentID";
                        string insertOrUpdateQuery = "";

                        using (SqlConnection con = new SqlConnection(connectionString))
                        {
                            con.Open();
                            using (SqlCommand checkCmd = new SqlCommand(checkExistingQuery, con))
                            {
                                checkCmd.Parameters.AddWithValue("@ActivityID", activityID);
                                checkCmd.Parameters.AddWithValue("@StudentID", studentID);
                                int existingSubmissions = (int)checkCmd.ExecuteScalar();

                                if (existingSubmissions > 0)
                                {
                                    // Update existing submission
                                    insertOrUpdateQuery = @"
                                        UPDATE ActivitySubmissions
                                        SET SubmissionDate = GETDATE(),
                                            Comments = @Comments,
                                            FilePath = @FilePath,
                                            FileName = @FileName
                                        WHERE ActivityID = @ActivityID AND StudentID = @StudentID";
                                    litSubmissionStatus.Text = "<div class='status-message-individual success'>Your submission has been updated successfully! ✔️</div>";
                                }
                                else
                                {
                                    // Insert new submission
                                    insertOrUpdateQuery = @"
                                        INSERT INTO ActivitySubmissions (ActivityID, StudentID, SubmissionDate, Comments, FilePath, FileName)
                                        VALUES (@ActivityID, @StudentID, GETDATE(), @Comments, @FilePath, @FileName)";
                                    litSubmissionStatus.Text = "<div class='status-message-individual success'>Activity submitted successfully! 🎉</div>";
                                }
                            }

                            using (SqlCommand cmd = new SqlCommand(insertOrUpdateQuery, con))
                            {
                                cmd.Parameters.AddWithValue("@ActivityID", activityID);
                                cmd.Parameters.AddWithValue("@StudentID", studentID);
                                cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(comments) ? (object)DBNull.Value : comments);
                                cmd.Parameters.AddWithValue("@FilePath", dbFilePath);
                                cmd.Parameters.AddWithValue("@FileName", originalFileName);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        // Re-load activities to reflect submission status immediately
                        // This might cause the entire page to refresh, but ensures the "HasSubmitted" indicator updates.
                        LoadActivities();
                    }
                    catch (Exception ex)
                    {
                        litSubmissionStatus.Text = $"<div class='status-message-individual error'>Error submitting activity: {ex.Message} ❌</div>";
                        // Log the exception for debugging in a real application
                        System.Diagnostics.Debug.WriteLine($"Error in rptActivities_ItemCommand: {ex.ToString()}");
                    }
                }
                else
                {
                    litSubmissionStatus.Text = "<div class='status-message-individual error'>Please select a file to submit. ⚠️</div>";
                }
            }
        }
    }
}