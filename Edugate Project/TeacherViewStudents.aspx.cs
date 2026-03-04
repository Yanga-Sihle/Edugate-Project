using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class TeacherViewStudents : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["TeacherID"] == null)
                {
                    Response.Redirect("Default.aspx");
                    return;
                }

                LoadSubjects();
                LoadAssessments();
                LoadSubmissions();
            }
        }

        private void LoadSubjects()
        {
            int teacherId = (int)Session["TeacherID"];
            string query = @"SELECT s.SubjectCode, s.SubjectName 
                          FROM Subjects s
                          INNER JOIN TeacherSubjects ts ON s.SubjectCode = ts.SubjectCode
                          WHERE ts.TeacherID = @TeacherID
                          ORDER BY s.SubjectName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                con.Open();
                ddlSubject.DataSource = cmd.ExecuteReader();
                ddlSubject.DataTextField = "SubjectName";
                ddlSubject.DataValueField = "SubjectCode";
                ddlSubject.DataBind();
                ddlSubject.Items.Insert(0, new ListItem("-- Select Subject --", ""));
            }
        }

        private void LoadAssessments()
        {
            string subjectCode = ddlSubject.SelectedValue;
            string assessmentType = ddlAssessmentType.SelectedValue;

            if (string.IsNullOrEmpty(subjectCode) || string.IsNullOrEmpty(assessmentType))
            {
                ddlAssessment.Items.Clear();
                return;
            }

            string query = "";
            if (assessmentType == "assignment")
            {
                query = @"SELECT AssignmentId AS Id, AssignmentTitle AS Title 
                        FROM Assignments WHERE SubjectCode = @SubjectCode";
            }
            else if (assessmentType == "test")
            {
                query = @"SELECT TestId AS Id, TestName AS Title 
                        FROM Tests WHERE SubjectCode = @SubjectCode";
            }
            else // quiz
            {
                query = @"SELECT QuizId AS Id, QuizTitle AS Title 
                        FROM Quizzes WHERE SubjectCode = @SubjectCode";
            }

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                con.Open();
                ddlAssessment.DataSource = cmd.ExecuteReader();
                ddlAssessment.DataTextField = "Title";
                ddlAssessment.DataValueField = "Id";
                ddlAssessment.DataBind();
                ddlAssessment.Items.Insert(0, new ListItem("-- Select Assessment --", ""));
            }
        }

        protected void FilterSubmissions(object sender, EventArgs e)
        {
            if (ddlSubject.SelectedIndex > 0 && ddlAssessmentType.SelectedIndex >= 0)
            {
                LoadAssessments();
            }
            LoadSubmissions();
        }

        private void LoadSubmissions()
        {
            string subjectCode = ddlSubject.SelectedValue;
            string assessmentType = ddlAssessmentType.SelectedValue;
            string assessmentId = ddlAssessment.SelectedValue;

            if (string.IsNullOrEmpty(subjectCode) || string.IsNullOrEmpty(assessmentType) ||
                string.IsNullOrEmpty(assessmentId))
            {
                gvSubmissions.DataSource = null;
                gvSubmissions.DataBind();
                return;
            }

            string query = @"SELECT ss.SubmissionId, s.StudentId, s.FullName, 
                           ss.FilePath, ss.SubmissionDate, sm.Score, sm.Feedback
                    FROM StudentSubmissions ss
                    INNER JOIN Students s ON ss.StudentId = s.StudentId
                    LEFT JOIN StudentMarks sm ON ss.SubmissionId = sm.SubmissionId
                    WHERE ss.SubjectCode = @SubjectCode
                    AND ss.AssessmentType = @AssessmentType
                    AND ss.AssessmentId = @AssessmentId
                    ORDER BY s.FullName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                cmd.Parameters.AddWithValue("@AssessmentType", assessmentType);
                cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);

                con.Open();
                DataTable dt = new DataTable();
                dt.Load(cmd.ExecuteReader());
                gvSubmissions.DataSource = dt;
                gvSubmissions.DataBind();
            }
        }

        protected void BtnSaveGrades_Click(object sender, EventArgs e)
        {
            int teacherId = (int)Session["TeacherID"];
            string subjectCode = ddlSubject.SelectedValue;
            string assessmentType = ddlAssessmentType.SelectedValue;
            string assessmentId = ddlAssessment.SelectedValue;

            foreach (GridViewRow row in gvSubmissions.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    string submissionId = gvSubmissions.DataKeys[row.RowIndex].Value.ToString();
                    TextBox txtGrade = (TextBox)row.FindControl("txtGrade");
                    TextBox txtFeedback = (TextBox)row.FindControl("txtFeedback");

                    string grade = txtGrade.Text;
                    string feedback = txtFeedback.Text;

                    if (!string.IsNullOrEmpty(grade))
                    {
                        string query = @"IF EXISTS (SELECT 1 FROM StudentMarks WHERE SubmissionId = @SubmissionId)
                                      BEGIN
                                          UPDATE StudentMarks 
                                          SET Score = @Score, 
                                              Feedback = @Feedback,
                                              GradedDate = GETDATE(),
                                              GradedBy = @TeacherId
                                          WHERE SubmissionId = @SubmissionId
                                      END
                                      ELSE
                                      BEGIN
                                          INSERT INTO StudentMarks (
                                              StudentId, SubjectCode, AssessmentType, 
                                              AssessmentId, SubmissionId, Score, 
                                              Feedback, DateGraded, GradedBy
                                          )
                                          SELECT 
                                              ss.StudentId, ss.SubjectCode, ss.AssessmentType,
                                              ss.AssessmentId, ss.SubmissionId, @Score,
                                              @Feedback, GETDATE(), @TeacherId
                                          FROM StudentSubmissions ss
                                          WHERE ss.SubmissionId = @SubmissionId
                                      END";

                        using (SqlConnection con = new SqlConnection(ConnectionString))
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@SubmissionId", submissionId);
                            cmd.Parameters.AddWithValue("@Score", grade);
                            cmd.Parameters.AddWithValue("@Feedback", feedback);
                            cmd.Parameters.AddWithValue("@TeacherId", teacherId);

                            con.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }

            // Reload to show updated grades
            LoadSubmissions();
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Grades saved successfully!');", true);
        }

        protected void GvSubmissions_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView rowView = (DataRowView)e.Row.DataItem;
                if (rowView["Score"] != DBNull.Value)
                {
                    TextBox txtGrade = (TextBox)e.Row.FindControl("txtGrade");
                    txtGrade.Text = rowView["Score"].ToString();
                }
            }
        }
    }
}