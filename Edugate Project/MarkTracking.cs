using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Edugate_Project
{
    public class StudentMarks
    {
        // Property for subject name
        public string Subject { get; set; }

        // Property for numerical mark (percentage)
        public int Mark { get; set; }

        // Property for letter grade (A+, B, etc.)
        public string Grade { get; set; }

        // Property for pass/fail status
        public string Status { get; set; } // "Passed" or "Failed"

        // Constructor to initialize a new StudentMark object
        public StudentMarks(string subject, int mark)
        {
            Subject = subject;
            Mark = mark;
            Grade = GetGrade(mark);
            Status = (mark >= 50) ? "Passed" : "Failed"; // Assume 50% is passing
        }

        // Helper method to calculate grade based on mark percentage
        private string GetGrade(int mark)
        {
            if (mark >= 90) return "A+";
            if (mark >= 80) return "A";
            if (mark >= 70) return "B";
            if (mark >= 60) return "C";
            if (mark >= 50) return "D";
            return "F";
        }
    }
}