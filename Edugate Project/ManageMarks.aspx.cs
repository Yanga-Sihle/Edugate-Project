using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class ManageMarks : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                         "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["TeacherID"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                LoadClasses();
                LoadSubjects();
            }
        }

        private void LoadClasses()
        {
            string query = "SELECT ClassID, ClassName FROM Classes ORDER BY ClassName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    try
                    {
                        con.Open();
                        SqlDataReader reader = cmd.ExecuteReader();
                        ddlClass.DataSource = reader;
                        ddlClass.DataTextField = "ClassName";
                        ddlClass.DataValueField = "ClassID";
                        ddlClass.DataBind();
                        ddlClass.Items.Insert(0, new ListItem("-- Select Class --", ""));
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading classes: " + ex.Message;
                    }
                }
            }
        }

        private void LoadSubjects()
        {
            if (Session["TeacherID"] == null) return;

            int teacherId = (int)Session["TeacherID"];
            string query = @"SELECT s.SubjectCode, s.SubjectName 
                           FROM Subjects s
                           INNER JOIN TeacherSubjects ts ON s.SubjectCode = ts.SubjectCode
                           WHERE ts.TeacherID = @TeacherID
                           ORDER BY s.SubjectName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                    try
                    {
                        con.Open();
                        SqlDataReader reader = cmd.ExecuteReader();
                        ddlSubject.DataSource = reader;
                        ddlSubject.DataTextField = "SubjectName";
                        ddlSubject.DataValueField = "SubjectCode";
                        ddlSubject.DataBind();
                        ddlSubject.Items.Insert(0, new ListItem("-- Select Subject --", ""));
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading subjects: " + ex.Message;
                    }
                }
            }
        }

        protected void LoadStudents(object sender, EventArgs e)
        {
            if (ddlClass.SelectedValue == "") return;

            string query = @"SELECT s.StudentID, s.FirstName + ' ' + s.LastName AS FullName
                          FROM Students s
                          WHERE s.ClassID = @ClassID
                          ORDER BY s.LastName, s.FirstName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ClassID", ddlClass.SelectedValue);
                    try
                    {
                        con.Open();
                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        // Initialize marks table structure
                        DataTable marksTable = new DataTable();
                        marksTable.Columns.Add("StudentID", typeof(int));
                        marksTable.Columns.Add("FullName", typeof(string));
                        marksTable.Columns.Add("Mark", typeof(string));
                        marksTable.Columns.Add("Feedback", typeof(string));

                        foreach (DataRow row in dt.Rows)
                        {
                            marksTable.Rows.Add(row["StudentID"], row["FullName"], "", "");
                        }

                        gvStudentMarks.DataSource = marksTable;
                        gvStudentMarks.DataBind();
                        pnlMarksEntry.Visible = true;
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading students: " + ex.Message;
                        pnlMarksEntry.Visible = false;
                    }
                }
            }
        }

        protected void LoadAssessments(object sender, EventArgs e)
        {
            if (ddlSubject.SelectedValue == "") return;

            string query = @"SELECT 'quiz' AS AssessmentType, QuizID AS ID, QuizTitle AS Title 
                          FROM Quizzes 
                          WHERE SubjectCode = @SubjectCode
                          UNION
                          SELECT 'test' AS AssessmentType, TestID AS ID, TestName AS Title 
                          FROM Tests 
                          WHERE SubjectCode = @SubjectCode
                          UNION
                          SELECT 'assignment' AS AssessmentType, AssignmentID AS ID, AssignmentTitle AS Title 
                          FROM Assignments 
                          WHERE SubjectCode = @SubjectCode
                          ORDER BY Title";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubjectCode", ddlSubject.SelectedValue);
                    try
                    {
                        con.Open();
                        SqlDataReader reader = cmd.ExecuteReader();
                        ddlAssessment.DataSource = reader;
                        ddlAssessment.DataTextField = "Title";
                        ddlAssessment.DataValueField = "ID";
                        ddlAssessment.DataBind();
                        ddlAssessment.Items.Insert(0, new ListItem("-- Select Assessment --", ""));
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading assessments: " + ex.Message;
                    }
                }
            }
        }

        protected void LoadStudentMarks(object sender, EventArgs e)
        {
            if (ddlClass.SelectedValue == "" || ddlSubject.SelectedValue == "" || ddlAssessment.SelectedValue == "")
            {
                lblMessage.Text = "Please select class, subject and assessment";
                return;
            }

            string query = @"SELECT s.StudentID, s.FirstName + ' ' + s.LastName AS FullName, 
                           ISNULL(m.Score, '') AS Mark, ISNULL(m.Feedback, '') AS Feedback
                          FROM Students s
                          LEFT JOIN StudentMarks m ON s.StudentID = m.StudentID 
                              AND m.SubjectCode = @SubjectCode 
                              AND m.AssessmentId = @AssessmentID
                              AND m.AssessmentType = @AssessmentType
                          WHERE s.ClassID = @ClassID
                          ORDER BY s.LastName, s.FirstName";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ClassID", ddlClass.SelectedValue);
                    cmd.Parameters.AddWithValue("@SubjectCode", ddlSubject.SelectedValue);
                    cmd.Parameters.AddWithValue("@AssessmentID", ddlAssessment.SelectedValue);
                    cmd.Parameters.AddWithValue("@AssessmentType", GetAssessmentType(ddlAssessment.SelectedValue));

                    try
                    {
                        con.Open();
                        SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        adapter.Fill(dt);

                        gvStudentMarks.DataSource = dt;
                        gvStudentMarks.DataBind();
                        pnlMarksEntry.Visible = true;
                        lblMessage.Text = "";
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading student marks: " + ex.Message;
                        pnlMarksEntry.Visible = false;
                    }
                }
            }
        }

        private string GetAssessmentType(string assessmentId)
        {
            // This is a simplified approach - you might need a better way to determine assessment type
            if (assessmentId.StartsWith("Q")) return "quiz";
            if (assessmentId.StartsWith("T")) return "test";
            return "assignment";
        }

        protected void SubmitMarks(object sender, EventArgs e)
        {
            if (ddlClass.SelectedValue == "" || ddlSubject.SelectedValue == "" || ddlAssessment.SelectedValue == "")
            {
                lblMessage.Text = "Please select class, subject and assessment";
                return;
            }

            string assessmentType = GetAssessmentType(ddlAssessment.SelectedValue);
            int teacherId = (int)Session["TeacherID"];
            bool success = true;

            foreach (GridViewRow row in gvStudentMarks.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    string studentId = gvStudentMarks.DataKeys[row.RowIndex].Value.ToString();
                    TextBox txtMark = (TextBox)row.FindControl("txtMark");
                    TextBox txtFeedback = (TextBox)row.FindControl("txtFeedback");

                    string mark = txtMark.Text.Trim();
                    string feedback = txtFeedback.Text.Trim();

                    if (!string.IsNullOrEmpty(mark))
                    {
                        if (!SaveMark(studentId, ddlSubject.SelectedValue, ddlAssessment.SelectedValue,
                            assessmentType, mark, feedback, teacherId))
                        {
                            success = false;
                        }
                    }
                }
            }

            if (success)
            {
                lblMessage.Text = "Marks submitted successfully!";
                lblMessage.ForeColor = System.Drawing.Color.Green;
            }
            else
            {
                lblMessage.Text = "Some marks were not saved. Please check and try again.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        private bool SaveMark(string studentId, string subjectCode, string assessmentId,
                            string assessmentType, string mark, string feedback, int teacherId)
        {
            string query = @"IF EXISTS (SELECT 1 FROM StudentMarks 
                          WHERE StudentID = @StudentID 
                          AND SubjectCode = @SubjectCode 
                          AND AssessmentId = @AssessmentID
                          AND AssessmentType = @AssessmentType)
                          BEGIN
                              UPDATE StudentMarks 
                              SET Score = @Score, 
                                  Feedback = @Feedback,
                                  DateGraded = GETDATE(),
                                  GradedBy = @TeacherID
                              WHERE StudentID = @StudentID 
                              AND SubjectCode = @SubjectCode 
                              AND AssessmentId = @AssessmentID
                              AND AssessmentType = @AssessmentType
                          END
                          ELSE
                          BEGIN
                              INSERT INTO StudentMarks 
                              (StudentID, SubjectCode, AssessmentId, AssessmentType, 
                               Score, Feedback, DateSubmitted, DateGraded, GradedBy)
                              VALUES 
                              (@StudentID, @SubjectCode, @AssessmentID, @AssessmentType, 
                               @Score, @Feedback, GETDATE(), GETDATE(), @TeacherID)
                          END";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@StudentID", studentId);
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    cmd.Parameters.AddWithValue("@AssessmentID", assessmentId);
                    cmd.Parameters.AddWithValue("@AssessmentType", assessmentType);
                    cmd.Parameters.AddWithValue("@Score", mark);
                    cmd.Parameters.AddWithValue("@Feedback", feedback);
                    cmd.Parameters.AddWithValue("@TeacherID", teacherId);

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        return true;
                    }
                    catch (Exception ex)
                    {
                        // Log error
                        System.Diagnostics.Debug.WriteLine("Error saving mark: " + ex.Message);
                        return false;
                    }
                }
            }
        }
    }
}