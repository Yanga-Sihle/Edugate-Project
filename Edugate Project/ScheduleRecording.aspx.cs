using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class ScheduleRecording : System.Web.UI.Page
    {
        private const string SCHOOL_CODE_PREFIX = "EDG-";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtTime.Text = DateTime.Now.ToString("HH:mm");
                cmpDate.ValueToCompare = DateTime.Today.ToString("yyyy-MM-dd"); // FIX for CompareValidator

                if (Session["TeacherID"] == null || Session["SchoolCode"] == null || Session["SubjectCode"] == null)
                {
                    DisplayStyledMessage("Teacher session data not found. Please log in to schedule sessions.", "error");
                    btnScheduleSession.Enabled = false;
                }
            }
        }

        // *** START OF CORRECTED VALIDATION METHOD ***
        protected void cvSchoolCode_ServerValidate(object source, ServerValidateEventArgs args)
        {
            string subjectInput = txtSubject.Text.Trim(); // What the user typed, e.g., "EDG-PHY122"
            string teacherAssignedSubjectCode = Session["SubjectCode"]?.ToString(); // What's in the database/session, e.g., "PHY122"

            if (string.IsNullOrEmpty(teacherAssignedSubjectCode))
            {
                args.IsValid = false;
                cvSchoolCode.ErrorMessage = "Teacher subject code is not available in session. Please re-login.";
                return;
            }

            // First, ensure the input starts with the required school code prefix
            if (!subjectInput.StartsWith(SCHOOL_CODE_PREFIX, StringComparison.OrdinalIgnoreCase))
            {
                args.IsValid = false;
                cvSchoolCode.ErrorMessage = $"Subject must start with '{SCHOOL_CODE_PREFIX}' (e.g., {SCHOOL_CODE_PREFIX}Mathematics).";
            }
            else
            {
                // If it starts with the prefix, extract the actual subject code part
                // For "EDG-PHY122" with prefix "EDG-", this will be "PHY122"
                string subjectCodeWithoutPrefix = subjectInput.Substring(SCHOOL_CODE_PREFIX.Length);

                // Now compare this extracted part with the teacher's assigned subject code
                if (!string.Equals(subjectCodeWithoutPrefix, teacherAssignedSubjectCode, StringComparison.OrdinalIgnoreCase))
                {
                    args.IsValid = false;
                    // Provide a more specific error message if the subject part doesn't match
                    cvSchoolCode.ErrorMessage = $"The subject code part ('{subjectCodeWithoutPrefix}') must match your assigned subject: '{teacherAssignedSubjectCode}'.";
                }
                else
                {
                    args.IsValid = true; // All checks passed
                }
            }
        }
        // *** END OF CORRECTED VALIDATION METHOD ***

        protected void cvTargetAudience_ServerValidate(object source, ServerValidateEventArgs args)
        {
            bool anySelected = false;
            foreach (ListItem item in cblTargetAudience.Items)
            {
                if (item.Selected)
                {
                    anySelected = true;
                    break;
                }
            }
            args.IsValid = anySelected;
            cvTargetAudience.ErrorMessage = "Please select at least one target audience.";
        }

        protected void btnScheduleSession_Click(object sender, EventArgs e)
        {
            Page.Validate();

            if (Page.IsValid)
            {
                if (Session["TeacherID"] == null || Session["SchoolCode"] == null || Session["SubjectCode"] == null)
                {
                    DisplayStyledMessage("Error: Teacher session data is missing. Please re-login.", "error");
                    btnScheduleSession.Enabled = false;
                    return;
                }

                int teacherId = Convert.ToInt32(Session["TeacherID"]);
                string teacherSchoolCode = Session["SchoolCode"].ToString();
                // string teacherSubjectCode = Session["SubjectCode"].ToString(); // No longer directly used here for validation

                // IMPORTANT: The 'subject' variable below will store the full value from the textbox, e.g., "EDG-PHY122"
                // This is what will be inserted into the LiveRecordingSessions table.
                string subject = txtSubject.Text.Trim();
                string dateString = txtDate.Text;
                string timeString = txtTime.Text;
                int durationMinutes = int.Parse(ddlDuration.SelectedValue);
                string topic = txtTopic.Text.Trim();
                string description = txtDescription.Text.Trim();

                DateTime sessionDate;
                TimeSpan sessionTime;
                DateTime sessionDateTime;

                bool dateParsed = DateTime.TryParse(dateString, out sessionDate);
                bool timeParsed = TimeSpan.TryParse(timeString, out sessionTime);

                if (!dateParsed || !timeParsed)
                {
                    DisplayStyledMessage("Invalid Date or Time format. Please ensure correct format (YYYY-MM-DD for date, HH:MM for time).", "error");
                    return;
                }

                sessionDateTime = sessionDate.Date + sessionTime;

                if (sessionDateTime < DateTime.Now)
                {
                    DisplayStyledMessage("Cannot schedule a session in the past. Please select a future date and time.", "error");
                    return;
                }

                List<string> selectedAudiences = new List<string>();
                foreach (ListItem item in cblTargetAudience.Items)
                {
                    if (item.Selected)
                    {
                        selectedAudiences.Add(item.Text);
                    }
                }
                string targetAudiences = string.Join(", ", selectedAudiences);

                string connectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;
                string insertSql = @"INSERT INTO [Edugate].[dbo].[LiveRecordingSessions]
                                    (TeacherID, SubjectCode, SchoolCode, SessionDate, SessionTime, DurationMinutes, Topic, Description, TargetAudiences)
                                    VALUES (@TeacherID, @SubjectCode, @SchoolCode, @SessionDate, @SessionTime, @DurationMinutes, @Topic, @Description, @TargetAudiences)";

                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        using (SqlCommand cmd = new SqlCommand(insertSql, conn))
                        {
                            cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                            cmd.Parameters.AddWithValue("@SubjectCode", subject); // This will be "EDG-PHY122" if entered correctly
                            cmd.Parameters.AddWithValue("@SchoolCode", teacherSchoolCode);
                            cmd.Parameters.AddWithValue("@SessionDate", sessionDate.Date);
                            cmd.Parameters.AddWithValue("@SessionTime", sessionTime);
                            cmd.Parameters.AddWithValue("@DurationMinutes", durationMinutes);
                            cmd.Parameters.AddWithValue("@Topic", topic);
                            cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description);
                            cmd.Parameters.AddWithValue("@TargetAudiences", string.IsNullOrEmpty(targetAudiences) ? (object)DBNull.Value : targetAudiences);

                            conn.Open();
                            cmd.ExecuteNonQuery();

                            string successContent = $"<h2>Session Scheduled Successfully!</h2>" +
                                                    $"<p><strong>Subject:</strong> {subject}</p>" +
                                                    $"<p><strong>Date & Time:</strong> {sessionDateTime.ToString("dd MMMM yyyy HH:mm")}</p>" +
                                                    $"<p><strong>Duration:</strong> {durationMinutes} Minutes</p>" +
                                                    $"<p><strong>Topic:</strong> {topic}</p>" +
                                                    $"<p><strong>Description:</strong> {(string.IsNullOrEmpty(description) ? "N/A" : description)}</p>" +
                                                    $"<p><strong>Target Audience(s):</strong> {(selectedAudiences.Any() ? string.Join(", ", selectedAudiences) : "None specified")}</p>";

                            DisplayStyledMessage(successContent, "success");
                            ClearForm();
                        }
                    }
                }
                catch (SqlException ex)
                {
                    DisplayStyledMessage($"Database error scheduling session: {ex.Message}", "error");
                }
                catch (Exception ex)
                {
                    DisplayStyledMessage($"An unexpected error occurred: {ex.Message}", "error");
                }
            }
            else
            {
                DisplayStyledMessage("Please correct the errors highlighted in the form.", "error");
            }
        }

        private void DisplayStyledMessage(string msg, string type)
        {
            string styledHtml = "";
            if (type == "success")
            {
                styledHtml = $"<div class='success-message'>{msg}</div>";
            }
            else if (type == "error")
            {
                styledHtml = $"<div class='error-message'>{msg}</div>";
            }
            else
            {
                styledHtml = msg;
            }

            litMessage.Text = styledHtml;
            litMessage.Visible = true;
        }

        private void ClearForm()
        {
            txtSubject.Text = string.Empty;
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtTime.Text = DateTime.Now.ToString("HH:mm");
            ddlDuration.SelectedValue = "60";
            txtTopic.Text = string.Empty;
            txtDescription.Text = string.Empty;

            foreach (ListItem item in cblTargetAudience.Items)
            {
                item.Selected = false;
            }
        }
    }
}