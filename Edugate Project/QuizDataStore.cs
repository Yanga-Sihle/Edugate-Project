using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography; // For SHA256 password hashing (if still used)
using System.Text; // For encoding
using Edugate_Project.Models; // ADD THIS LINE to correctly reference your model classes

namespace Edugate_Project
{
   
    public static class QuizDataStore
    {
        // Now 'Subject', 'Quiz', 'Teacher', 'Question' are found because they are defined above
        private static Dictionary<string, Edugate_Project.Models.Subject> _subjects = new Dictionary<string, Edugate_Project.Models.Subject>(StringComparer.OrdinalIgnoreCase);
        private static Dictionary<string, List<Edugate_Project.Models.Quiz>> _quizzesBySubject = new Dictionary<string, List<Edugate_Project.Models.Quiz>>(StringComparer.OrdinalIgnoreCase);
        private static Dictionary<string, Edugate_Project.Models.Teacher> _teachersByUsername = new Dictionary<string, Edugate_Project.Models.Teacher>(StringComparer.OrdinalIgnoreCase);
        private static int _nextTeacherId = 1; // Simple ID generator for teachers

        // Public method to get all subjects
        public static List<Edugate_Project.Models.Subject> GetAvailableSubjects()
        {
            return _subjects.Values.OrderBy(s => s.SubjectName).ToList();
        }

        // Public method to add or update a quiz
        public static void AddOrUpdateQuiz(Edugate_Project.Models.Quiz quiz)
        {
            if (quiz == null || string.IsNullOrWhiteSpace(quiz.SubjectCode) || string.IsNullOrWhiteSpace(quiz.QuizTitle))
            {
                Console.WriteLine("Attempted to add a null quiz or a quiz with no subject code/title.");
                return;
            }

            if (!_quizzesBySubject.ContainsKey(quiz.SubjectCode))
            {
                _quizzesBySubject[quiz.SubjectCode] = new List<Edugate_Project.Models.Quiz>();
            }

            var existingQuiz = _quizzesBySubject[quiz.SubjectCode]
                                   .FirstOrDefault(q => q.QuizTitle.Equals(quiz.QuizTitle, StringComparison.OrdinalIgnoreCase));

            if (existingQuiz != null)
            {
                existingQuiz.Questions = quiz.Questions;
                Console.WriteLine($"Updated quiz '{quiz.QuizTitle}' for subject '{quiz.SubjectCode}'.");
            }
            else
            {
                _quizzesBySubject[quiz.SubjectCode].Add(quiz);
                Console.WriteLine($"Added new quiz '{quiz.QuizTitle}' for subject '{quiz.SubjectCode}'.");
            }
        }

        // Public method to get quizzes by subject code
        public static List<Edugate_Project.Models.Quiz> GetQuizzesBySubjectCode(string subjectCode)
        {
            _quizzesBySubject.TryGetValue(subjectCode, out List<Edugate_Project.Models.Quiz> quizzes);
            return quizzes ?? new List<Edugate_Project.Models.Quiz>();
        }

        // Public method to register a new teacher
        public static bool RegisterTeacher(Edugate_Project.Models.Teacher teacher)
        {
            if (teacher == null || string.IsNullOrWhiteSpace(teacher.Username) || string.IsNullOrWhiteSpace(teacher.PasswordHash) || string.IsNullOrWhiteSpace(teacher.SubjectCode))
            {
                Console.WriteLine("Attempted to register a teacher with missing required fields.");
                return false;
            }

            if (_teachersByUsername.ContainsKey(teacher.Username))
            {
                Console.WriteLine($"Teacher with username '{teacher.Username}' already exists.");
                return false; // Username already taken
            }

            if (!_subjects.ContainsKey(teacher.SubjectCode))
            {
                Console.WriteLine($"Subject code '{teacher.SubjectCode}' does not exist.");
                return false; // Subject does not exist
            }

            teacher.TeacherID = _nextTeacherId++; // Assign a simple ID
            _teachersByUsername.Add(teacher.Username, teacher);
            Console.WriteLine($"Teacher '{teacher.Username}' registered successfully for subject '{teacher.SubjectCode}'.");
            return true;
        }

        // Public method to find a teacher by username
        public static Edugate_Project.Models.Teacher GetTeacherByUsername(string username)
        {
            _teachersByUsername.TryGetValue(username, out Edugate_Project.Models.Teacher teacher);
            return teacher;
        }

        // Simple password hashing (for demonstration ONLY, use stronger methods in production like BCrypt.Net)
        public static string HashPassword(string password)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        // Static constructor to pre-load some initial data
        static QuizDataStore()
        {
            // Pre-load subjects
            _subjects.Add("MATH112", new Edugate_Project.Models.Subject { SubjectCode = "MATH112", SubjectName = "Mathematics" });
            _subjects.Add("PHYS201", new Edugate_Project.Models.Subject { SubjectCode = "PHYS201", SubjectName = "Physics" });
            _subjects.Add("CHEM303", new Edugate_Project.Models.Subject { SubjectCode = "CHEM303", SubjectName = "Chemistry" });
            _subjects.Add("COMP404", new Edugate_Project.Models.Subject { SubjectCode = "COMP404", SubjectName = "Computer Science" });

            // Pre-load some quizzes (using the updated AddOrUpdateQuiz method)
            AddOrUpdateQuiz(new Edugate_Project.Models.Quiz
            {
                SubjectCode = "MATH112",
                QuizTitle = "Algebra Basics",
                Questions = new List<Edugate_Project.Models.Question> // Explicitly type the list
                {
                    new Edugate_Project.Models.Question { QuestionText = "What is 2 + 2?", Options = new List<string> { "3", "4", "5", "6" }, CorrectAnswer = "4" },
                    new Edugate_Project.Models.Question { QuestionText = "Solve for x: x + 5 = 10", Options = new List<string> { "3", "5", "7", "15" }, CorrectAnswer = "5" }
                }
            });

            AddOrUpdateQuiz(new Edugate_Project.Models.Quiz
            {
                SubjectCode = "PHYS201",
                QuizTitle = "Newton's Laws",
                Questions = new List<Edugate_Project.Models.Question> // Explicitly type the list
                {
                    new Edugate_Project.Models.Question { QuestionText = "What is Newton's first law also known as?", Options = new List<string> { "Law of Gravity", "Law of Inertia", "Law of Motion", "Law of Conservation" }, CorrectAnswer = "Law of Inertia" }
                }
            });

            // Pre-load a sample teacher
            RegisterTeacher(new Edugate_Project.Models.Teacher
            {
                Username = "teachermath",
                PasswordHash = HashPassword("Password123!"), // Hashed password
                Email = "teachermath@example.com",
                FullName = "Alice Smith",
                SubjectCode = "MATH112"
            });

            RegisterTeacher(new Edugate_Project.Models.Teacher
            {
                Username = "teacherphys",
                PasswordHash = HashPassword("Password123!"), // Hashed password
                Email = "teacherphys@example.com",
                FullName = "Bob Johnson",
                SubjectCode = "PHYS201"
            });
        }
    }
}
