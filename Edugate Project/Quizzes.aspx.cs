using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Edugate_Project.Models;

namespace Edugate_Project
{
    public partial class Quizzes : System.Web.UI.Page
    {
        // Define a simple structure for a question
        

        // --- Quiz Data (Hardcoded for example, ideally loaded from DB or XML) ---
        private List<Question> QuizQuestions
        {
            get
            {
                // Store quiz questions in Session to persist across postbacks
                if (Session["QuizQuestions"] == null)
                {
                    // Initialize your quiz questions here.
                    // In a real application, these would come from a database.
                    var questions = new List<Question>
                    {
                        new Question
                        {
                            QuestionText = "What does STEM stand for?",
                            Options = new List<string> { "Science, Technology, Engineering, Mathematics", "Studies, Training, Education, Media", "Sports, Talent, Exercise, Music", "Systems, Theory, Environment, Management" },
                            CorrectAnswer = "Science, Technology, Engineering, Mathematics"
                        },
                        new Question
                        {
                            QuestionText = "Which of these is NOT a renewable energy source?",
                            Options = new List<string> { "Solar Power", "Wind Power", "Natural Gas", "Hydroelectric Power" },
                            CorrectAnswer = "Natural Gas"
                        },
                        new Question
                        {
                            QuestionText = "What is the largest planet in our solar system?",
                            Options = new List<string> { "Mars", "Jupiter", "Earth", "Saturn" },
                            CorrectAnswer = "Jupiter"
                        },
                        new Question
                        {
                            QuestionText = "What is the chemical symbol for water?",
                            Options = new List<string> { "O2", "CO2", "H2O", "NaCl" },
                            CorrectAnswer = "H2O"
                        },
                        new Question
                        {
                            QuestionText = "Which field focuses on designing and building structures?",
                            Options = new List<string> { "Biology", "Chemistry", "Engineering", "Physics" },
                            CorrectAnswer = "Engineering"
                        }
                    };
                    Session["QuizQuestions"] = questions;
                }
                return (List<Question>)Session["QuizQuestions"];
            }
        }

        // Current question index to track student's progress through the quiz
        private int CurrentQuestionIndex
        {
            get { return Session["CurrentQuestionIndex"] != null ? (int)Session["CurrentQuestionIndex"] : 0; }
            set { Session["CurrentQuestionIndex"] = value; }
        }

        // List to store student's selected answers for each question
        // The index of this list corresponds to the question index in QuizQuestions.
        private List<string> StudentAnswers
        {
            get
            {
                if (Session["StudentAnswers"] == null)
                {
                    // Initialize with empty strings for each question
                    Session["StudentAnswers"] = new List<string>(new string[QuizQuestions.Count]);
                }
                return (List<string>)Session["StudentAnswers"];
            }
            set { Session["StudentAnswers"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // This block runs every time the page is loaded, including postbacks.
            if (!IsPostBack)
            {
                // Initialize the quiz only on the first load (not on button clicks)
                InitializeQuiz();
            }

            // Re-register the JavaScript function to apply custom styling to radio buttons.
            // This is important because ASP.NET re-renders controls on postback,
            // which can remove dynamic styling applied by client-side JS.
            ScriptManager.RegisterStartupScript(this, GetType(), "ApplyRadioButtonStyling", "applyRadioButtonStyling();", true);
        }

        /// <summary>
        /// Initializes or resets the quiz state.
        /// </summary>
        private void InitializeQuiz()
        {
            CurrentQuestionIndex = 0; // Start from the first question
            StudentAnswers = new List<string>(new string[QuizQuestions.Count]); // Clear all previous answers
            QuizPanel.Visible = true; // Show the quiz questions panel
            ResultPanel.Visible = false; // Hide the results panel
            LoadQuestion(CurrentQuestionIndex); // Load the first question
        }

        /// <summary>
        /// Loads and displays a specific question based on its index.
        /// </summary>
        /// <param name="index">The index of the question to load.</param>
        private void LoadQuestion(int index)
        {
            // Ensure the index is within valid bounds of the questions list
            if (index >= 0 && index < QuizQuestions.Count)
            {
                Question currentQuestion = QuizQuestions[index];
                lblQuestionNumber.Text = $"Question {index + 1} of {QuizQuestions.Count}";
                lblQuestionText.Text = currentQuestion.QuestionText;

                rblAnswerOptions.Items.Clear(); // Clear previous options
                // Add options for the current question
                foreach (string option in currentQuestion.Options)
                {
                    rblAnswerOptions.Items.Add(new ListItem(option, option));
                }

                // If the student has already answered this question, pre-select their answer
                if (!string.IsNullOrEmpty(StudentAnswers[index]))
                {
                    rblAnswerOptions.SelectedValue = StudentAnswers[index];
                }
                else
                {
                    rblAnswerOptions.ClearSelection(); // Clear selection if no answer was saved
                }

                UpdateNavigationButtons(); // Adjust button visibility
            }
            else if (index == QuizQuestions.Count) // If index goes beyond last question, quiz is finished
            {
                ShowResults();
            }
        }

        /// <summary>
        /// Saves the student's current selection for the displayed question.
        /// </summary>
        private void SaveCurrentAnswer()
        {
            if (rblAnswerOptions.SelectedItem != null)
            {
                // Save the value of the selected radio button
                StudentAnswers[CurrentQuestionIndex] = rblAnswerOptions.SelectedItem.Value;
            }
            else
            {
                // If nothing is selected, save an empty string
                StudentAnswers[CurrentQuestionIndex] = "";
            }
        }

        /// <summary>
        /// Updates the visibility of the Previous, Next, and Submit buttons.
        /// </summary>
        private void UpdateNavigationButtons()
        {
            // Previous button visible if not on the first question
            btnPrevious.Visible = CurrentQuestionIndex > 0;
            // Next button visible if not on the last question
            btnNext.Visible = CurrentQuestionIndex < QuizQuestions.Count - 1;
            // Submit button visible only on the last question
            btnSubmitQuiz.Visible = CurrentQuestionIndex == QuizQuestions.Count - 1;
        }

        /// <summary>
        /// Event handler for the "Next" button click.
        /// </summary>
        protected void btnNext_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer(); // Save the answer for the current question
            CurrentQuestionIndex++; // Move to the next question
            LoadQuestion(CurrentQuestionIndex); // Load the new question
        }

        /// <summary>
        /// Event handler for the "Previous" button click.
        /// </summary>
        protected void btnPrevious_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer(); // Save the answer for the current question
            CurrentQuestionIndex--; // Move to the previous question
            LoadQuestion(CurrentQuestionIndex); // Load the new question
        }

        /// <summary>
        /// Event handler for the "Submit Quiz" button click.
        /// </summary>
        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            SaveCurrentAnswer(); // Save the answer for the last question before submitting
            ShowResults(); // Display the quiz results
        }

        /// <summary>
        /// Calculates and displays the quiz results.
        /// </summary>
        private void ShowResults()
        {
            QuizPanel.Visible = false; // Hide the quiz questions
            ResultPanel.Visible = true; // Show the results panel

            int correctAnswers = 0;
            // Iterate through all questions and compare student's answers with correct answers
            for (int i = 0; i < QuizQuestions.Count; i++)
            {
                if (StudentAnswers[i] == QuizQuestions[i].CorrectAnswer)
                {
                    correctAnswers++; // Increment score if correct
                }
            }

            // Display the score
            lblScore.Text = $"{correctAnswers} / {QuizQuestions.Count}";
        }

        /// <summary>
        /// Event handler for the "Try Again!" (Restart Quiz) button click.
        /// </summary>
        protected void btnRestartQuiz_Click(object sender, EventArgs e)
        {
            InitializeQuiz(); // Resets the quiz to its initial state
        }
    }
}
