using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Edugate_Project.Models;
using Newtonsoft.Json;

namespace Edugate_Project
{
    public partial class QuizManagement : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        private const string SessionQuizQuestionsKey = "CurrentQuizQuestions";
        private const string SessionQuizSubjectCodeKey = "CurrentQuizSubjectCode";
        private const string SessionQuizSubjectNameKey = "CurrentQuizSubjectName";
        private const string SessionQuizTitleKey = "CurrentQuizTitle";
        private const string SessionQuizDueDateKey = "CurrentQuizDueDate";
        private const string SessionQuizMaxAttemptsKey = "CurrentQuizMaxAttempts";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsTeacherLoggedIn"] == null || !(bool)Session["IsTeacherLoggedIn"] || Session["TeacherID"] == null)
            {
                Response.Redirect("TeacherLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadTeacherData();
                BindSubjectsToDropdown();

                if (Session[SessionQuizQuestionsKey] != null)
                {
                    LoadQuizCreationUIFromSession();
                }
                else
                {
                    SubjectSelectionPanel.Visible = true;
                    QuizCreationPanel.Visible = false;
                    CurrentQuestionsDisplayPanel.Visible = false;
                }
            }

            if (Session[SessionQuizQuestionsKey] != null && QuizCreationPanel.Visible)
            {
                BindCurrentQuestions();
            }
        }

        private void LoadTeacherData()
        {
            using (var connection = new SqlConnection(ConnectionString))
            using (var command = new SqlCommand("SELECT FullName FROM Teachers WHERE TeacherID = @TeacherID", connection))
            {
                command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                connection.Open();
                object result = command.ExecuteScalar();
                if (result != null) lblSidebarTeacherName.Text = result.ToString();
            }
        }

        private void BindSubjectsToDropdown()
        {
            int teacherId = (int)Session["TeacherID"];
            string query = @"SELECT s.SubjectCode, s.SubjectName
                             FROM Subjects s
                             INNER JOIN Teachers t ON s.SubjectCode = t.SubjectCode
                             WHERE t.TeacherID = @TeacherID
                             ORDER BY s.SubjectName";

            var subjects = new List<Subject>();

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                try
                {
                    con.Open();
                    using (var reader = cmd.ExecuteReader())
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
                    System.Diagnostics.Debug.WriteLine("Error binding subjects: " + ex.Message);
                    ShowStatusMessage("Error loading subjects.", "error");
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
                ddlSubjects.Items.Add(new ListItem("No Subjects Assigned", ""));
                ddlSubjects.Enabled = false;
                ShowStatusMessage("You are not assigned to any subjects. Please contact administration.", "info");
                btnLoadQuizCreation.Enabled = false;
            }
        }

        protected void btnLoadQuizCreation_Click(object sender, EventArgs e)
        {
            string selectedSubjectCode = ddlSubjects.SelectedValue;
            string selectedSubjectName = ddlSubjects.SelectedItem?.Text;
            string quizTitle = txtQuizTitle.Text.Trim();

            if (string.IsNullOrEmpty(selectedSubjectCode))
            {
                ShowStatusMessage("Please select a subject.", "error");
                return;
            }
            if (string.IsNullOrWhiteSpace(quizTitle))
            {
                ShowStatusMessage("Please enter a quiz title.", "error");
                return;
            }

            Session[SessionQuizSubjectCodeKey] = selectedSubjectCode;
            Session[SessionQuizSubjectNameKey] = selectedSubjectName;
            Session[SessionQuizTitleKey] = quizTitle;
            Session[SessionQuizQuestionsKey] = new List<Question>();

            // Initialize scheduling fields (so teacher can set them before adding questions)
            Session[SessionQuizDueDateKey] = null;   // or keep null until save
            Session[SessionQuizMaxAttemptsKey] = null;

            LoadQuizCreationUIFromSession();
            ShowStatusMessage($"Ready to create quiz: {quizTitle} for {selectedSubjectName}", "info");
        }

        private void LoadQuizCreationUIFromSession()
        {
            SubjectSelectionPanel.Visible = false;
            QuizCreationPanel.Visible = true;
            CurrentQuestionsDisplayPanel.Visible = true;

            lblSelectedSubject.Text = Session[SessionQuizSubjectNameKey]?.ToString();
            lblSelectedQuizTitle.Text = Session[SessionQuizTitleKey]?.ToString();

            // Pre-fill optional fields if we have them in session
            txtDueDate.Text = Session[SessionQuizDueDateKey]?.ToString() ?? string.Empty;
            txtMaxAttempts.Text = Session[SessionQuizMaxAttemptsKey]?.ToString() ?? string.Empty;

            BindCurrentQuestions();
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            string questionText = txtQuestionText.Text.Trim();
            if (string.IsNullOrWhiteSpace(questionText))
            {
                ShowStatusMessage("Question text cannot be empty.", "error");
                return;
            }

            var options = new List<string>();
            var boxes = new List<TextBox> { txtOption1, txtOption2, txtOption3, txtOption4 };
            string correctAnswer = string.Empty;

            for (int i = 0; i < boxes.Count; i++)
            {
                string opt = boxes[i].Text.Trim();
                if (!string.IsNullOrWhiteSpace(opt))
                {
                    options.Add(opt);
                    var rb = (RadioButton)optionsContainer.FindControl($"rbCorrect{i + 1}");
                    if (rb != null && rb.Checked) correctAnswer = opt;
                }
            }

            if (!options.Any())
            {
                ShowStatusMessage("Please provide at least one answer option.", "error");
                return;
            }
            if (string.IsNullOrWhiteSpace(correctAnswer))
            {
                ShowStatusMessage("Please select the correct answer.", "error");
                return;
            }

            var questions = GetQuestionsFromSession();

            questions.Add(new Question
            {
                QuestionText = questionText,
                Options = options,
                CorrectAnswer = correctAnswer,
                QuestionID = Guid.NewGuid().ToString()
            });

            SaveQuestionsToSession(questions);
            ShowStatusMessage("Question added successfully!", "success");
            ClearQuestionForm();
            BindCurrentQuestions();
        }

        protected void btnSaveQuiz_Click(object sender, EventArgs e)
        {
            var questions = GetQuestionsFromSession();
            if (!questions.Any())
            {
                ShowStatusMessage("Please add at least one question before saving the quiz.", "error");
                return;
            }

            string subjectCode = Session[SessionQuizSubjectCodeKey]?.ToString();
            string quizTitle = Session[SessionQuizTitleKey]?.ToString();

            if (string.IsNullOrEmpty(subjectCode) || string.IsNullOrWhiteSpace(quizTitle))
            {
                ShowStatusMessage("Quiz subject or title is missing from session. Please start a new quiz.", "error");
                ClearQuizSession();
                LoadQuizCreationUIFromSession();
                return;
            }

            // Parse optional DueDate & MaxAttempts (accepts “yyyy-MM-dd HH:mm” or anything DateTime.Parse can handle)
            DateTime? dueDate = null;
            if (!string.IsNullOrWhiteSpace(txtDueDate.Text))
            {
                if (DateTime.TryParse(txtDueDate.Text.Trim(), CultureInfo.CurrentCulture, DateTimeStyles.AssumeLocal, out var parsed))
                    dueDate = parsed;
                else if (DateTime.TryParseExact(txtDueDate.Text.Trim(), "yyyy-MM-dd HH:mm", CultureInfo.InvariantCulture, DateTimeStyles.None, out parsed))
                    dueDate = parsed;
                else
                {
                    ShowStatusMessage("Invalid Due Date format. Use 'yyyy-MM-dd HH:mm' or your local format.", "error");
                    return;
                }
            }

            int? maxAttempts = null;
            if (!string.IsNullOrWhiteSpace(txtMaxAttempts.Text))
            {
                if (int.TryParse(txtMaxAttempts.Text.Trim(), out int parsedInt))
                    maxAttempts = parsedInt;
                else
                {
                    ShowStatusMessage("Max Attempts must be a whole number.", "error");
                    return;
                }
            }

            var newQuiz = new Quiz
            {
                SubjectCode = subjectCode,
                QuizTitle = quizTitle,
                Questions = questions,
                CreatedDate = DateTime.Now
                // (Model can be extended to hold DueDate/MaxAttempts, not required for saving.)
            };

            if (SaveQuizToDatabase(newQuiz, dueDate, maxAttempts))
            {
                ShowStatusMessage("Quiz saved successfully!", "success");
                ClearQuizSession();
                SubjectSelectionPanel.Visible = true;
                QuizCreationPanel.Visible = false;
                CurrentQuestionsDisplayPanel.Visible = false;
                txtQuizTitle.Text = string.Empty;
                txtDueDate.Text = string.Empty;
                txtMaxAttempts.Text = string.Empty;
                BindSubjectsToDropdown();
            }
            else
            {
                ShowStatusMessage("Failed to save quiz. Please try again.", "error");
            }
        }

        protected void btnClearForm_Click(object sender, EventArgs e)
        {
            ClearQuestionForm();
            ShowStatusMessage("Question form cleared.", "info");
        }

        protected void btnCancelQuiz_Click(object sender, EventArgs e)
        {
            ClearQuizSession();
            ShowStatusMessage("Quiz creation cancelled.", "info");
            SubjectSelectionPanel.Visible = true;
            QuizCreationPanel.Visible = false;
            CurrentQuestionsDisplayPanel.Visible = false;
            txtQuizTitle.Text = string.Empty;
            txtDueDate.Text = string.Empty;
            txtMaxAttempts.Text = string.Empty;
            BindSubjectsToDropdown();
        }

        protected void btnDeleteQuestion_Command(object source, CommandEventArgs e)
        {
            if (int.TryParse(e.CommandArgument.ToString(), out int idx))
            {
                var q = GetQuestionsFromSession();
                if (idx >= 0 && idx < q.Count)
                {
                    q.RemoveAt(idx);
                    SaveQuestionsToSession(q);
                    BindCurrentQuestions();
                    ShowStatusMessage("Question deleted.", "info");
                }
                else
                {
                    ShowStatusMessage("Invalid question index.", "error");
                }
            }
        }

        private void ClearQuestionForm()
        {
            txtQuestionText.Text = "";
            txtOption1.Text = "";
            txtOption2.Text = "";
            txtOption3.Text = "";
            txtOption4.Text = "";
            rbCorrect1.Checked = rbCorrect2.Checked = rbCorrect3.Checked = rbCorrect4.Checked = false;

            // Persist the (possibly changed) scheduling inputs in session during drafting
            Session[SessionQuizDueDateKey] = txtDueDate.Text.Trim();
            Session[SessionQuizMaxAttemptsKey] = txtMaxAttempts.Text.Trim();
        }

        private List<Question> GetQuestionsFromSession()
            => Session[SessionQuizQuestionsKey] as List<Question> ?? new List<Question>();

        private void SaveQuestionsToSession(List<Question> questions)
            => Session[SessionQuizQuestionsKey] = questions;

        private void BindCurrentQuestions()
        {
            var current = GetQuestionsFromSession();
            if (current.Any())
            {
                rptCurrentQuestions.DataSource = current;
                CurrentQuestionsDisplayPanel.Visible = true;
            }
            else
            {
                rptCurrentQuestions.DataSource = null;
                CurrentQuestionsDisplayPanel.Visible = false;
            }
            rptCurrentQuestions.DataBind();
        }

        private void ClearQuizSession()
        {
            Session.Remove(SessionQuizQuestionsKey);
            Session.Remove(SessionQuizSubjectCodeKey);
            Session.Remove(SessionQuizSubjectNameKey);
            Session.Remove(SessionQuizTitleKey);
            Session.Remove(SessionQuizDueDateKey);
            Session.Remove(SessionQuizMaxAttemptsKey);
        }

        private bool SaveQuizToDatabase(Quiz quiz, DateTime? dueDate, int? maxAttempts)
        {
            string questionsJson = JsonConvert.SerializeObject(quiz.Questions);

            string query = @"
INSERT INTO Quizzes (SubjectCode, QuizTitle, QuestionsJSON, CreatedDate, DueDate, MaxAttempts)
VALUES (@SubjectCode, @QuizTitle, @QuestionsJSON, @CreatedDate, @DueDate, @MaxAttempts);";

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", quiz.SubjectCode);
                cmd.Parameters.AddWithValue("@QuizTitle", quiz.QuizTitle);
                cmd.Parameters.AddWithValue("@QuestionsJSON", questionsJson);
                cmd.Parameters.AddWithValue("@CreatedDate", quiz.CreatedDate);
                cmd.Parameters.AddWithValue("@DueDate", (object)dueDate ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@MaxAttempts", (object)maxAttempts ?? DBNull.Value);

                try
                {
                    con.Open();
                    return cmd.ExecuteNonQuery() > 0;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("SaveQuizToDatabase error: " + ex.Message);
                    return false;
                }
            }
        }

        private void ShowStatusMessage(string message, string type)
        {
            litStatusMessage.Text = $"<div class='status-message {type}'>{message}</div>";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}
