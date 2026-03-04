using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;
using Edugate_Project.Models;

namespace Edugate_Project
{
    public partial class TakeQuiz : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        private Quiz CurrentStudentQuiz
        {
            get { return Session["CurrentStudentQuiz"] as Quiz; }
            set { Session["CurrentStudentQuiz"] = value; }
        }

        private int CurrentQuestionIndex
        {
            get { return Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0; }
            set { Session["CurrentQuestionIndex"] = value; }
        }

        private List<string> StudentAnswers
        {
            get
            {
                if (Session["StudentAnswers"] == null)
                {
                    Session["StudentAnswers"] = new List<string>(new string[CurrentStudentQuiz?.Questions.Count ?? 0]);
                }
                return (List<string>)Session["StudentAnswers"];
            }
            set { Session["StudentAnswers"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsStudentLoggedIn"] == null || !(bool)Session["IsStudentLoggedIn"] || Session["StudentID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                PopulateSubjectsDropdown();

                string subjectCodeFromQuery = Request.QueryString["subjectCode"];
                if (!string.IsNullOrEmpty(subjectCodeFromQuery))
                {
                    ListItem itemToSelect = ddlSubjects.Items.FindByValue(subjectCodeFromQuery);
                    if (itemToSelect != null)
                    {
                        ddlSubjects.SelectedValue = subjectCodeFromQuery;
                        LoadQuizzesForSelectedSubject(subjectCodeFromQuery);
                        litSelectedSubjectName.Text = itemToSelect.Text;
                    }
                    else
                    {
                        ShowSubjectSelectionPanel();
                        ShowStatusMessage("The requested subject was not found. Please select from the list.", "info");
                    }
                }
                else
                {
                    ShowSubjectSelectionPanel();
                }
            }

            // keep the RBL styling behavior
            ScriptManager.RegisterStartupScript(this, GetType(), "ApplyRadioButtonStyling", "applyRadioButtonStyling();", true);
        }

        /* =========================
           SUBJECTS (FILTERED)
           ========================= */

        // Get SchoolCode + GradeLevel (falls back to Grade) for the logged-in student
        private (string SchoolCode, string GradeLevelOrGrade)? GetStudentSchoolAndGrade(int studentId)
        {
            const string sql = @"
                SELECT SchoolCode, GradeLevel, Grade
                FROM Students
                WHERE StudentId = @StudentId AND ISNULL(IsActive,1) = 1;";

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                try
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            string schoolCode = r["SchoolCode"]?.ToString();
                            string gradeLevel = r["GradeLevel"]?.ToString();
                            if (string.IsNullOrWhiteSpace(gradeLevel))
                                gradeLevel = r["Grade"]?.ToString();

                            if (!string.IsNullOrWhiteSpace(schoolCode) && !string.IsNullOrWhiteSpace(gradeLevel))
                                return (schoolCode, gradeLevel);
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("GetStudentSchoolAndGrade error: " + ex.Message);
                }
            }
            return null;
        }

        // Get subjects by SchoolCode + GradeLevel
        private List<Subject> GetSubjectsForStudent(string schoolCode, string gradeLevel)
        {
            var subjects = new List<Subject>();

            const string sql = @"
                SELECT SubjectCode, SubjectName
                FROM Subjects
                WHERE SchoolCode = @SchoolCode
                  AND GradeLevel = @GradeLevel
                ORDER BY SubjectName;";

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                cmd.Parameters.AddWithValue("@GradeLevel", gradeLevel);
                try
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            subjects.Add(new Subject
                            {
                                SubjectCode = r["SubjectCode"].ToString(),
                                SubjectName = r["SubjectName"].ToString()
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("GetSubjectsForStudent error: " + ex.Message);
                    ShowStatusMessage("Error loading subjects. Please try again.", "error");
                }
            }

            return subjects;
        }
        protected void rptAvailableQuizzes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "StartQuiz")
            {
                // IsLocked was included in the bound anonymous object; read it from a hidden field or via a control
                // Easiest: add a HiddenField in ItemTemplate bound to IsLocked and read it here.

                var hid = (HiddenField)e.Item.FindControl("hidIsLocked");
                bool isLocked = hid != null && hid.Value == "1";

                if (isLocked)
                {
                    ShowStatusMessage("This quiz is locked (past due date or max attempts reached).", "info");
                    return;
                }

                if (int.TryParse(e.CommandArgument.ToString(), out int quizId))
                {
                    StartSelectedQuiz(quizId);
                }
                else
                {
                    ShowStatusMessage("Invalid quiz selection. Please try again.", "error");
                }
            }
        }


        // Populate the dropdown with ONLY the student's subjects (by SchoolCode + GradeLevel/Grade)
        private void PopulateSubjectsDropdown()
        {
            ddlSubjects.Items.Clear();

            if (Session["StudentID"] == null)
            {
                ddlSubjects.Items.Add(new ListItem("No Subjects Available", ""));
                return;
            }

            int studentId = Convert.ToInt32(Session["StudentID"]);
            var sg = GetStudentSchoolAndGrade(studentId);

            if (sg == null)
            {
                ddlSubjects.Items.Add(new ListItem("No Subjects Available", ""));
                ShowStatusMessage("Your school/grade info is incomplete. Please contact administration.", "info");
                return;
            }

            var subjects = GetSubjectsForStudent(sg.Value.SchoolCode, sg.Value.GradeLevelOrGrade);

            if (subjects.Any())
            {
                foreach (var s in subjects)
                {
                    ddlSubjects.Items.Add(new ListItem(s.SubjectName, s.SubjectCode));
                }
                ddlSubjects.Items.Insert(0, new ListItem("-- Select Subject --", ""));
                ddlSubjects.SelectedIndex = 0;
            }
            else
            {
                ddlSubjects.Items.Add(new ListItem("No Subjects Available", ""));
                ShowStatusMessage("No subjects found for your school and grade.", "info");
            }
        }

        protected void ddlSubjects_SelectedIndexChanged(object sender, EventArgs e)
        {
            string selectedSubjectCode = ddlSubjects.SelectedValue;
            if (!string.IsNullOrEmpty(selectedSubjectCode) && selectedSubjectCode != "-- Select Subject --")
            {
                LoadQuizzesForSelectedSubject(selectedSubjectCode);
                // Show friendly subject name above the quizzes
                litSelectedSubjectName.Text = ddlSubjects.SelectedItem?.Text ?? selectedSubjectCode;
            }
            else
            {
                pnlAvailableQuizzes.Visible = false;
                litNoQuizzesForSubject.Visible = false;
                ShowStatusMessage("", "");
            }
        }

        /* =========================
           QUIZ LIST / START
           ========================= */

        private void LoadQuizzesForSelectedSubject(string subjectCode)
        {
            var quizzesForSubject = new List<Quiz>();

            const string sql = @"
        SELECT QuizID, QuizTitle, SubjectCode, QuestionsJSON, DueDate, MaxAttempts
        FROM Quizzes
        WHERE SubjectCode = @SubjectCode
        ORDER BY QuizTitle;";

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);

                try
                {
                    con.Open();
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            var quiz = new Quiz
                            {
                                QuizID = (int)r["QuizID"],
                                QuizTitle = r["QuizTitle"].ToString(),
                                SubjectCode = r["SubjectCode"].ToString(),
                                DueDate = r["DueDate"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(r["DueDate"]),
                                MaxAttempts = r["MaxAttempts"] == DBNull.Value ? (int?)null : Convert.ToInt32(r["MaxAttempts"]),
                                Questions = new List<Question>()
                            };

                            var questionsJson = r["QuestionsJSON"]?.ToString();
                            if (!string.IsNullOrEmpty(questionsJson))
                            {
                                try { quiz.Questions = JsonConvert.DeserializeObject<List<Question>>(questionsJson) ?? new List<Question>(); }
                                catch { /* leave empty; we'll still list the quiz */ }
                            }

                            quizzesForSubject.Add(quiz);
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error loading quizzes for subject {subjectCode}: {ex.Message}");
                    ShowStatusMessage("Error loading quizzes for this subject. Please try again.", "error");
                }
            }

            if (quizzesForSubject.Any())
            {
                int studentId = Convert.ToInt32(Session["StudentID"]);

                // Project to a concrete DTO so bindings are stable across postbacks
                var view = quizzesForSubject.Select(q =>
                {
                    int attemptsUsed = GetAttemptsUsed(q.QuizID, studentId);
                    int maxAtt = q.MaxAttempts ?? 0;

                    string dueDisp = q.DueDate.HasValue
                        ? $"Due: {q.DueDate.Value:dd MMM yyyy HH:mm}"
                        : "No due date";

                    string attemptsDisp = (maxAtt > 0)
                        ? $"Attempts: {attemptsUsed}/{maxAtt}"
                        : $"Attempts used: {attemptsUsed}";

                    var reasons = new List<string>();
                    if (q.DueDate.HasValue && DateTime.Now > q.DueDate.Value) reasons.Add("Past due date");
                    if (maxAtt > 0 && attemptsUsed >= maxAtt) reasons.Add("Max attempts reached");
                    string lockReason = reasons.Count > 0 ? string.Join("; ", reasons) : null;

                    return new Edugate_Project.Models.QuizListItem
                    {
                        QuizID = q.QuizID,
                        Title = q.QuizTitle,
                        QuestionCount = q.Questions?.Count ?? 0,
                        DueDateDisplay = dueDisp,
                        AttemptsDisplay = attemptsDisp,
                        LockReason = lockReason,
                        IsLocked = !string.IsNullOrEmpty(lockReason)
                    };
                }).ToList();

                rptAvailableQuizzes.DataSource = view;
                rptAvailableQuizzes.DataBind();

                pnlAvailableQuizzes.Visible = true;
                litNoQuizzesForSubject.Visible = false;
                ShowStatusMessage("", "");
            }
            else
            {
                rptAvailableQuizzes.DataSource = null;
                rptAvailableQuizzes.DataBind();

                pnlAvailableQuizzes.Visible = true;
                litNoQuizzesForSubject.Visible = true;
                ShowStatusMessage("No quizzes found for this subject. Please check back later.", "info");
            }

            // Friendly subject name above the list
            if (string.IsNullOrWhiteSpace(litSelectedSubjectName.Text))
                litSelectedSubjectName.Text = ddlSubjects.Items.FindByValue(subjectCode)?.Text ?? subjectCode;
        }





        private void StartSelectedQuiz(int quizId)
        {
            Quiz quizToLoad = null;
            const string query = @"
                SELECT QuizID, QuizTitle, SubjectCode, QuestionsJSON
                FROM Quizzes
                WHERE QuizID = @QuizID;";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@QuizID", quizId);
                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            quizToLoad = new Quiz
                            {
                                QuizID = (int)reader["QuizID"],
                                QuizTitle = reader["QuizTitle"].ToString(),
                                SubjectCode = reader["SubjectCode"].ToString()
                            };

                            string questionsJson = reader["QuestionsJSON"].ToString();
                            if (!string.IsNullOrEmpty(questionsJson))
                            {
                                quizToLoad.Questions = JsonConvert.DeserializeObject<List<Question>>(questionsJson);
                            }
                            else
                            {
                                quizToLoad.Questions = new List<Question>();
                            }
                        }
                    }
                }
                catch (JsonSerializationException jsonEx)
                {
                    System.Diagnostics.Debug.WriteLine($"JSON Deserialization Error for QuizID {quizId}: {jsonEx.Message}");
                    ShowStatusMessage("Error processing quiz questions. Data might be corrupted. Please contact support.", "error");
                    ShowSubjectSelectionPanel();
                    return;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error fetching quiz {quizId} from DB: {ex.Message}");
                    ShowStatusMessage("Error loading quiz details. Please try again.", "error");
                    ShowSubjectSelectionPanel();
                    return;
                }
            }

            CurrentStudentQuiz = quizToLoad;

            if (CurrentStudentQuiz != null && CurrentStudentQuiz.Questions.Any())
            {
                InitializeQuiz();
                QuizPanel.Visible = true;
                pnlSubjectAndQuizSelection.Visible = false;
                ResultPanel.Visible = false;
                ShowStatusMessage("", "");
            }
            else
            {
                ShowStatusMessage("No questions available for the selected quiz. Please choose another or contact your teacher.", "info");
                ShowSubjectSelectionPanel();
            }
        }

        /* =========================
           QUIZ FLOW
           ========================= */

        private void InitializeQuiz()
        {
            CurrentQuestionIndex = 0;
            StudentAnswers = new List<string>(new string[CurrentStudentQuiz.Questions.Count]);
            LoadQuestion(CurrentQuestionIndex);
        }

        private void LoadQuestion(int index)
        {
            if (CurrentStudentQuiz == null || !CurrentStudentQuiz.Questions.Any())
            {
                lblQuestionText.Text = "Error: Quiz data not loaded or no questions available.";
                return;
            }

            if (index >= 0 && index < CurrentStudentQuiz.Questions.Count)
            {
                Question currentQuestion = CurrentStudentQuiz.Questions[index];
                lblQuestionNumber.Text = $"Question {index + 1} of {CurrentStudentQuiz.Questions.Count}";
                lblQuestionText.Text = currentQuestion.QuestionText;

                rblAnswerOptions.Items.Clear();
                foreach (string option in currentQuestion.Options)
                {
                    rblAnswerOptions.Items.Add(new ListItem(option, option));
                }

                if (StudentAnswers.Count > index && !string.IsNullOrEmpty(StudentAnswers[index]))
                {
                    ListItem itemToSelect = rblAnswerOptions.Items.FindByValue(StudentAnswers[index]);
                    if (itemToSelect != null)
                    {
                        itemToSelect.Selected = true;
                    }
                    else
                    {
                        rblAnswerOptions.ClearSelection();
                    }
                }
                else
                {
                    rblAnswerOptions.ClearSelection();
                }

                UpdateNavigationButtons();
            }
            else if (index == CurrentStudentQuiz.Questions.Count)
            {
                ShowResults();
            }
        }

        private void SaveCurrentAnswer()
        {
            if (CurrentStudentQuiz == null || !CurrentStudentQuiz.Questions.Any()) return;

            while (StudentAnswers.Count <= CurrentQuestionIndex)
            {
                StudentAnswers.Add("");
            }

            if (rblAnswerOptions.SelectedItem != null)
            {
                StudentAnswers[CurrentQuestionIndex] = rblAnswerOptions.SelectedItem.Value;
            }
            else
            {
                StudentAnswers[CurrentQuestionIndex] = "";
            }
        }

        private void UpdateNavigationButtons()
        {
            if (CurrentStudentQuiz == null || !CurrentStudentQuiz.Questions.Any())
            {
                btnPrevious.Visible = false;
                btnNext.Visible = false;
                btnSubmitQuiz.Visible = false;
                return;
            }

            btnPrevious.Visible = CurrentQuestionIndex > 0;
            btnNext.Visible = CurrentQuestionIndex < CurrentStudentQuiz.Questions.Count - 1;
            btnSubmitQuiz.Visible = CurrentQuestionIndex == CurrentStudentQuiz.Questions.Count - 1;
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            CurrentQuestionIndex++;
            LoadQuestion(CurrentQuestionIndex);
        }

        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            CurrentQuestionIndex--;
            LoadQuestion(CurrentQuestionIndex);
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer();
            ShowResults();
        }

        private void ShowResults()
        {
            QuizPanel.Visible = false;
            ResultPanel.Visible = true;

            int correctAnswers = 0;
            int totalQuestions = CurrentStudentQuiz?.Questions.Count ?? 0;

            if (totalQuestions > 0)
            {
                // Calculate the number of correct answers
                for (int i = 0; i < totalQuestions; i++)
                {
                    Question question = CurrentStudentQuiz.Questions[i];
                    string studentAnswer = (StudentAnswers.Count > i && !string.IsNullOrEmpty(StudentAnswers[i])) ? StudentAnswers[i] : "Unanswered";

                    if (studentAnswer == question.CorrectAnswer)
                    {
                        correctAnswers++;
                    }
                }

                // Calculate percentage score
                double percentage = ((double)correctAnswers / totalQuestions) * 100;
                lblScore.Text = $"{percentage:F2}%";  // Display score as percentage

                litResultDetails.Text = $"You answered {correctAnswers} out of {totalQuestions} questions correctly. Your score: {percentage:F2}%";

                // Save to QuizResults table
                if (Session["StudentID"] != null)
                {
                    int studentId = Convert.ToInt32(Session["StudentID"]);
                    int quizIdToSave = CurrentStudentQuiz.QuizID;
                    SaveQuizResult(quizIdToSave, studentId, percentage, totalQuestions);  // Save percentage instead of raw score
                }

                ShowStatusMessage("Quiz submitted successfully!", "success");
            }
            else
            {
                lblScore.Text = "N/A";
                litResultDetails.Text = "Could not calculate results. Quiz data missing.";
                ShowStatusMessage("Error calculating quiz results. Please try again.", "error");
            }
        }


        private bool SaveQuizResult(int quizId, int studentId, double percentage, int totalQuestions)
        {
            const string query = @"
        INSERT INTO QuizResults (QuizId, StudentId, Score, CompletionDate)
        VALUES (@QuizId, @StudentId, @Score, GETDATE());";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@QuizId", quizId);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@Score", percentage);  // Save percentage

                try
                {
                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    return rowsAffected > 0;
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error saving quiz result: {ex.Message}");
                    return false;
                }
            }
        }


        protected void btnRestartQuiz_Click(object sender, EventArgs e)
        {
            CurrentStudentQuiz = null;
            CurrentQuestionIndex = 0;
            StudentAnswers = null;

            ShowSubjectSelectionPanel();
            PopulateSubjectsDropdown();
            ShowStatusMessage("", "");
        }
        private int GetAttemptsUsed(int quizId, int studentId)
        {
            const string sql = @"SELECT COUNT(*) FROM QuizResults
                         WHERE QuizId = @QuizId AND StudentId = @StudentId;";
            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@QuizId", quizId);
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                con.Open();
                var v = cmd.ExecuteScalar();
                return (v == null || v == DBNull.Value) ? 0 : Convert.ToInt32(v);
            }
        }

        private void ShowSubjectSelectionPanel()
        {
            pnlSubjectAndQuizSelection.Visible = true;
            pnlAvailableQuizzes.Visible = false;
            QuizPanel.Visible = false;
            ResultPanel.Visible = false;
        }

        private void ShowStatusMessage(string message, string type)
        {
            litStatusMessage.Text = $"<div class='status-message {type}'>{message}</div>";
        }
    }
}
