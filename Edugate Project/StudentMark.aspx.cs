using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.SessionState;

namespace Edugate_Project
{
    public partial class MarkTracking : Page
    {
        private const string SessionMarksKey = "StudentMarks";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session[SessionMarksKey] == null)
                {
                    Session[SessionMarksKey] = new List<StudentMark>();
                }
                LoadStudentMarks();
            }
        }

        private void LoadStudentMarks()
        {
            List<StudentMark> marks = (List<StudentMark>)Session[SessionMarksKey];
            gvMarks.DataSource = marks;
            gvMarks.DataBind();
            UpdateOverallSummary(marks);
        }

        private void UpdateOverallSummary(List<StudentMark> marks)
        {
            lblTotalSubjects.InnerText = marks.Count.ToString();
            lblOverallAverage.InnerText = marks.Any() ? $"{marks.Average(m => m.Mark):F2}%" : "0%";
            lblPassedSubjects.InnerText = marks.Count(m => m.Status == "Passed").ToString();
        }

        protected void btnAddMark_Click(object sender, EventArgs e)
        {
            string subject = ddlNewSubject.SelectedValue.Trim();
            int mark;

            if (string.IsNullOrEmpty(subject) || subject == "-- Select Subject --")
            {
                ShowQualificationError("Please select a subject.");
                return;
            }

            if (!int.TryParse(txtNewMark.Text, out mark) || mark < 0 || mark > 100)
            {
                ShowQualificationError("Mark must be a number between 0 and 100");
                return;
            }

            List<StudentMark> marks = (List<StudentMark>)Session[SessionMarksKey];
            var existing = marks.FirstOrDefault(m => m.Subject.Equals(subject, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                existing.Mark = mark;
                existing.Grade = StudentMark.CalculateGrade(mark);
                existing.Status = (mark >= 50) ? "Passed" : "Failed";
            }
            else
            {
                marks.Add(new StudentMark(subject, mark));
            }

            Session[SessionMarksKey] = marks;
            LoadStudentMarks();
            ddlNewSubject.SelectedValue = "";
            txtNewMark.Text = "";
            qualificationResults.Visible = false;
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadStudentMarks();
            qualificationResults.Visible = false;
        }

        protected void gvMarks_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[0].Attributes["data-label"] = "Subject:";
                e.Row.Cells[1].Attributes["data-label"] = "Mark (%):";
                e.Row.Cells[2].Attributes["data-label"] = "Grade:";
                e.Row.Cells[3].Attributes["data-label"] = "Status:";
            }
        }

        protected void btnCheckQualification_Click(object sender, EventArgs e)
        {
            string career = ddlCareer.SelectedValue;
            List<StudentMark> marks = (List<StudentMark>)Session[SessionMarksKey];

            qualificationResults.Visible = true;
            qualificationResults.Attributes["class"] = "qualification-results show";

            if (string.IsNullOrEmpty(career) || career == "-- Select Career --")
            {
                ShowQualificationError("Please select a career");
                return;
            }

            if (marks.Count < 1)
            {
                ShowQualificationWarning("Add at least one subject to check qualification");
                return;
            }

            bool qualifies = false;
            string details = "";
            int overallAvg = (int)marks.Average(m => m.Mark);

            switch (career)
            {
                case "Data Scientist":
                    int mathMarkDS = GetSubjectMark(marks, "Mathematics");
                    int csMarkDS = GetSubjectMark(marks, "Computer Application Technology");
                    qualifies = mathMarkDS >= 75 && csMarkDS >= 70 && overallAvg >= 70;
                    details = qualifies ?
                        $"Excellent analytical skills with Mathematics ({mathMarkDS}%) and Computer Application Technology ({csMarkDS}%)" :
                        $"Requires 75% in Mathematics (you: {mathMarkDS}%) and 70% in Computer Application Technology (you: {csMarkDS}%) with overall 70% average (you: {overallAvg}%)";
                    break;

                case "AI Developer":
                    int mathMarkAI = GetSubjectMark(marks, "Mathematics");
                    int csMarkAI = GetSubjectMark(marks, "Computer Application Technology");
                    int physicsMarkAI = GetSubjectMark(marks, "Physics");
                    qualifies = mathMarkAI >= 80 && csMarkAI >= 75 && physicsMarkAI >= 70 && overallAvg >= 75;
                    details = qualifies ?
                        $"Exceptional skills in Mathematics ({mathMarkAI}%), Computer Application Technology ({csMarkAI}%) and Physics ({physicsMarkAI}%)" :
                        $"Requires 80% in Mathematics (you: {mathMarkAI}%), 75% in Computer Application Technology (you: {csMarkAI}%) and 70% in Physics (you: {physicsMarkAI}%) with overall 75% average (you: {overallAvg}%)";
                    break;

                case "Software Developer":
                    int csMark = GetSubjectMark(marks, "Computer Application Technology");
                    int mathMark = GetSubjectMark(marks, "Mathematics");
                    qualifies = csMark >= 70 && mathMark >= 65 && overallAvg >= 65;
                    details = qualifies ?
                        $"Excellent marks in Computer Application Technology ({csMark}%) and Mathematics ({mathMark}%)" :
                        $"Requires 70% in Computer Application Technology (you: {csMark}%) and 65% in Mathematics (you: {mathMark}%) with overall 65% average (you: {overallAvg}%)";
                    break;

                case "Data and Security Analysis":
                    int csMarkSec = GetSubjectMark(marks, "Computer Application Technology");
                    int mathMarkSec = GetSubjectMark(marks, "Mathematics");
                    qualifies = csMarkSec >= 75 && mathMarkSec >= 70 && overallAvg >= 70;
                    details = qualifies ?
                        $"Excellent technical skills in Computer Application Technology ({csMarkSec}%) and Mathematics ({mathMarkSec}%)" :
                        $"Requires 75% in Computer Application Technology (you: {csMarkSec}%) and 70% in Mathematics (you: {mathMarkSec}%) with overall 70% average (you: {overallAvg}%)";
                    break;

                case "Civil Engineering":
                    int mathMarkCE = GetSubjectMark(marks, "Mathematics");
                    int physicsMarkCE = GetSubjectMark(marks, "Physics");
                    int egdMark = GetSubjectMark(marks, "Engineering Graphic Design");
                    qualifies = mathMarkCE >= 70 && physicsMarkCE >= 65 && egdMark >= 65 && overallAvg >= 65;
                    details = qualifies ?
                        $"Strong aptitude for Mathematics ({mathMarkCE}%), Physics ({physicsMarkCE}%) and Engineering Graphic Design ({egdMark}%)" :
                        $"Requires 70% in Mathematics (you: {mathMarkCE}%), 65% in Physics (you: {physicsMarkCE}%) and 65% in Engineering Graphic Design (you: {egdMark}%) with overall 65% average (you: {overallAvg}%)";
                    break;

                case "Chemical Engineering":
                    int chemistryMarkChE = GetSubjectMark(marks, "Chemistry");
                    int mathMarkChE = GetSubjectMark(marks, "Mathematics");
                    int physicsMarkChE = GetSubjectMark(marks, "Physics");
                    qualifies = chemistryMarkChE >= 75 && mathMarkChE >= 70 && physicsMarkChE >= 65 && overallAvg >= 70;
                    details = qualifies ?
                        $"Excellent understanding of Chemistry ({chemistryMarkChE}%), Mathematics ({mathMarkChE}%) and Physics ({physicsMarkChE}%)" :
                        $"Requires 75% in Chemistry (you: {chemistryMarkChE}%), 70% in Mathematics (you: {mathMarkChE}%) and 65% in Physics (you: {physicsMarkChE}%) with overall 70% average (you: {overallAvg}%)";
                    break;

                case "Biomedical Engineer":
                    int lifeScienceMark = GetSubjectMark(marks, "Life Science");
                    int physicsMark = GetSubjectMark(marks, "Physics");
                    int mathMarkBE = GetSubjectMark(marks, "Mathematics");
                    qualifies = lifeScienceMark >= 70 && physicsMark >= 65 && mathMarkBE >= 65 && overallAvg >= 65;
                    details = qualifies ?
                        $"Strong foundation in Life Science ({lifeScienceMark}%), Physics ({physicsMark}%) and Mathematics ({mathMarkBE}%)" :
                        $"Requires 70% in Life Science (you: {lifeScienceMark}%), 65% in Physics (you: {physicsMark}%) and 65% in Mathematics (you: {mathMarkBE}%) with overall 65% average (you: {overallAvg}%)";
                    break;

                case "Biologist":
                    int lifeScienceMarkBio = GetSubjectMark(marks, "Life Science");
                    int chemistryMarkBio = GetSubjectMark(marks, "Chemistry");
                    qualifies = lifeScienceMarkBio >= 75 && chemistryMarkBio >= 65 && overallAvg >= 65;
                    details = qualifies ?
                        $"Strong foundation in Life Science ({lifeScienceMarkBio}%) and Chemistry ({chemistryMarkBio}%)" :
                        $"Requires 75% in Life Science (you: {lifeScienceMarkBio}%) and 65% in Chemistry (you: {chemistryMarkBio}%) with overall 65% average (you: {overallAvg}%)";
                    break;

                case "Astronomer":
                    int physicsMarkAstro = GetSubjectMark(marks, "Physics");
                    int mathMarkAstro = GetSubjectMark(marks, "Mathematics");
                    qualifies = physicsMarkAstro >= 80 && mathMarkAstro >= 80 && overallAvg >= 75;
                    details = qualifies ?
                        $"Exceptional skills in Physics ({physicsMarkAstro}%) and Mathematics ({mathMarkAstro}%)" :
                        $"Requires 80% in Physics (you: {physicsMarkAstro}%) and 80% in Mathematics (you: {mathMarkAstro}%) with overall 75% average (you: {overallAvg}%)";
                    break;

                case "Industrial Engineering":
                    int mathMarkIE = GetSubjectMark(marks, "Mathematics");
                    int physicsMarkIE = GetSubjectMark(marks, "Physics");
                    qualifies = mathMarkIE >= 70 && physicsMarkIE >= 65 && overallAvg >= 65;
                    details = qualifies ?
                        $"Strong analytical skills in Mathematics ({mathMarkIE}%) and Physics ({physicsMarkIE}%)" :
                        $"Requires 70% in Mathematics (you: {mathMarkIE}%) and 65% in Physics (you: {physicsMarkIE}%) with overall 65% average (you: {overallAvg}%)";
                    break;
            }

            DisplayQualificationResult(career, qualifies, details);
        }

        private int GetSubjectMark(List<StudentMark> marks, string subjectName)
        {
            return marks.FirstOrDefault(m => m.Subject.Equals(subjectName, StringComparison.OrdinalIgnoreCase))?.Mark ?? 0;
        }

        private void DisplayQualificationResult(string career, bool qualifies, string details)
        {
            qualificationResults.Visible = true;
            if (qualifies)
            {
                lblQualificationStatus.InnerText = $"Qualified for {career}!";
                lblQualificationDetails.InnerText = details;
                qualificationResults.Attributes["class"] = "qualification-results show";
                qualificationResults.Style["background"] = "linear-gradient(135deg, var(--accent-green), var(--accent-light-green))";
            }
            else
            {
                lblQualificationStatus.InnerText = $"Not Qualified for {career}";
                lblQualificationDetails.InnerText = details;
                qualificationResults.Attributes["class"] = "qualification-results show";
                qualificationResults.Style["background"] = "linear-gradient(135deg, #ff9966, #ff5e62)";
            }
        }

        private void ShowQualificationError(string message)
        {
            qualificationResults.Visible = true;
            lblQualificationStatus.InnerText = "Error";
            lblQualificationDetails.InnerText = message;
            qualificationResults.Attributes["class"] = "qualification-results show";
            qualificationResults.Style["background"] = "linear-gradient(135deg, #ff9966, #ff5e62)";
        }

        private void ShowQualificationWarning(string message)
        {
            qualificationResults.Visible = true;
            lblQualificationStatus.InnerText = "Warning";
            lblQualificationDetails.InnerText = message;
            qualificationResults.Attributes["class"] = "qualification-results show";
            qualificationResults.Style["background"] = "linear-gradient(135deg, #ff9966, #ff5e62)";
        }
    }

    public class StudentMark
    {
        public string Subject { get; set; }
        public int Mark { get; set; }
        public string Grade { get; set; }
        public string Status { get; set; }

        public StudentMark(string subject, int mark)
        {
            Subject = subject;
            Mark = mark;
            Grade = CalculateGrade(mark);
            Status = (mark >= 50) ? "Passed" : "Failed";
        }

        public static string CalculateGrade(int mark)
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