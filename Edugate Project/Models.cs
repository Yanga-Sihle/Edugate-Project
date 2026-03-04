using System;
using System.Collections.Generic;
// No longer need System.Security.Cryptography or System.Text directly in models
// as they are for utility/logic, not model definition.

namespace Edugate_Project.Models // It's good practice to put models in a sub-namespace
{
    // --- Model Classes ---

    public class Subject
    {
        public string SubjectCode { get; set; }
        public string SubjectName { get; set; }
    }

    public class Question
    {
        public string QuestionText { get; set; }
        public List<string> Options { get; set; } = new List<string>();
        public string CorrectAnswer { get; set; }
        public string QuestionID { get; set; } 
    }

    public class Quiz
    {
        public int QuizID { get; set; }
        public string SubjectCode { get; set; }
        public string QuizTitle { get; set; }
        public DateTime CreatedDate { get; set; } // Added: Matches Quizzes table
        public List<Question> Questions { get; set; } = new List<Question>(); // This will be serialized/deserialized to/from QuestionsJSON
        public string SubjectName { get; set; } // For display purposes (joined from Subjects)
        public DateTime? DueDate { get; set; }       // null = no due date
        public int? MaxAttempts { get; set; }
    }

    public class Teacher
    {
        public int TeacherID { get; set; }
        public string Username { get; set; }
        public string PasswordHash { get; set; }
        public string Email { get; set; }
        public string FullName { get; set; }
        public string SubjectCode { get; set; }
        public DateTime RegistrationDate { get; set; }
        public int SchoolCode { get; set; }
    }

    // Renamed from 'Students' to 'Student' (singular entity naming convention)
    public class Student
    {
        public int StudentID { get; set; }
        public string FullName { get; set; }
        public string Address { get; set; } // Added: Matches Students table
        public string Gender { get; set; }  // Added: Matches Students table
        public string Email { get; set; }   // Used for login username
        public string PasswordHash { get; set; }
        public DateTime RegistrationDate { get; set; }
        public string SchoolCode { get; set; } // Added: Matches Students table

        // Removed 'Username' property as it doesn't exist in your DB table
        // Removed 'SubjectCode' property as student-subject is a many-to-many via StudentSubjects table
    }

    public class UploadedFile
    {
        public int FileID { get; set; }
        public int TeacherID { get; set; }
        public string SubjectCode { get; set; }
        public string FileName { get; set; }
        public string FilePath { get; set; } // Relative path on the server
        public string Message { get; set; }
        public DateTime UploadDate { get; set; }

        // Optional display properties, populated via joins in queries
        public string TeacherUsername { get; set; }
        public string TeacherFullName { get; set; } // Added for consistency
        public string SubjectName { get; set; }
    }

    public class StudentSubmission
    {
        public int SubmissionID { get; set; }
        public int StudentID { get; set; }
        public int? TeacherID { get; set; } // Nullable, if not always directly linked
        public string SubjectCode { get; set; }
        public string OriginalFileName { get; set; }
        public string SubmittedFilePath { get; set; } // Relative path on the server
        public string SubmissionMessage { get; set; }
        public DateTime SubmissionDate { get; set; }

        // For display purposes, populated via joins in queries
        public string StudentFullName { get; set; } // Added for consistency with Student model
        public string SubjectName { get; set; }
        public string TeacherFullName { get; set; } // Added for consistency
    }
    // Inside your Edugate_Project.Models namespace (e.g., in Models.cs)
    public class QuizListItem
    {
        public int QuizID { get; set; }
        public string Title { get; set; }
        public int QuestionCount { get; set; }

        public string DueDateDisplay { get; set; }
        public string AttemptsDisplay { get; set; }
        public string LockReason { get; set; }
        public bool IsLocked { get; set; }
    }

    public class QuizAttempt
    {
        public int AttemptID { get; set; }
        public int QuizID { get; set; }
        public int StudentID { get; set; }
        public int? Score { get; set; } // Nullable, if quiz isn't graded immediately
        public DateTime AttemptDate { get; set; }
        public string AnswersSubmitted { get; set; } // Store student's answers (e.g., JSON string)

        // For display purposes, populated via joins in queries
        public string QuizTitle { get; set; }
        public string StudentFullName { get; set; } // Changed from Username for consistency
        public string SubjectCode { get; set; }
        public string SubjectName { get; set; } // Added for convenience
    }
}