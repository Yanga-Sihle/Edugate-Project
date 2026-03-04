using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class UploadMarks : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!IsTeacherAuthenticated())
                {
                    Response.Redirect("TeacherLogin.aspx");
                    return;
                }

                // Cache SchoolCode (used by submissions filter)
                _ = GetTeacherSchoolCode();

                LoadTeacherData();
                InitializeTeacherData();
                LoadInitialData();
            }
        }

        // ===================== Auth / Session =====================

        private bool IsTeacherAuthenticated()
        {
            return Session["TeacherID"] != null &&
                   Session["IsTeacherLoggedIn"] != null &&
                   (bool)Session["IsTeacherLoggedIn"];
        }

        private string GetTeacherSchoolCode()
        {
            if (Session["SchoolCode"] is string sc && !string.IsNullOrWhiteSpace(sc))
                return sc;

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 SchoolCode FROM Teachers WHERE TeacherID = @TeacherID", conn))
            {
                cmd.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                conn.Open();
                object obj = cmd.ExecuteScalar();
                string school = obj?.ToString();
                Session["SchoolCode"] = school;
                return school;
            }
        }

        // ===================== Header / Initial =====================

        private void LoadTeacherData()
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand("SELECT FullName FROM Teachers WHERE TeacherID = @TeacherID", connection))
            {
                command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                connection.Open();
                object result = command.ExecuteScalar();
                if (result != null) lblSidebarTeacherName.Text = result.ToString();
            }
        }

        private void InitializeTeacherData()
        {
            try
            {
                if (Session["TeacherID"] == null) { ShowError("TeacherID session variable is null. Please login again."); return; }
                if (Session["SubjectCode"] == null) { ShowError("SubjectCode session variable is null. Please login again."); return; }

                lblTeacher.Text = Session["FullName"]?.ToString() ?? "Teacher";
                lblSubject.Text = Session["SubjectCode"]?.ToString() ?? "Subject";

                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    string query = @"SELECT t.FullName, s.SubjectName, t.GradeLevel
                                     FROM Teachers t
                                     INNER JOIN Subjects s ON t.SubjectCode = s.SubjectCode
                                     WHERE t.TeacherID = @TeacherID";
                    using (SqlCommand command = new SqlCommand(query, connection))
                    {
                        command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                        connection.Open();
                        using (SqlDataReader reader = command.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblTeacher.Text = reader["FullName"].ToString();
                                lblSubject.Text = reader["SubjectName"].ToString();
                                lblClass.Text = reader["GradeLevel"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex) { ShowError("Error initializing teacher data: " + ex.Message); }
        }

        private void LoadInitialData()
        {
            try
            {
                if (Session["TeacherID"] == null) { ShowError("TeacherID session variable is null. Please login again."); return; }
                if (Session["SubjectCode"] == null) { ShowError("SubjectCode session variable is null. Please login again."); return; }

                int teacherId = Convert.ToInt32(Session["TeacherID"]);
                string subjectCode = Session["SubjectCode"].ToString();

                ShowDebugInfo($"TeacherID: {teacherId}, SubjectCode: {subjectCode}");

                LoadTeacherClasses(teacherId, subjectCode);
                LoadAssessments(subjectCode); // Populate both dropdowns with quizzes + assignments
                LoadRecentMarks(teacherId, subjectCode); // quizzes only, per current grid
                LoadStudentSubmissions(teacherId, subjectCode);
            }
            catch (Exception ex) { ShowError("Error loading initial data: " + ex.Message); }
        }

        private void LoadTeacherClasses(int teacherId, string subjectCode)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand(
                @"SELECT DISTINCT GradeLevel FROM Teachers 
                  WHERE TeacherID = @TeacherID AND SubjectCode = @SubjectCode ORDER BY GradeLevel", connection))
            {
                command.Parameters.AddWithValue("@TeacherID", teacherId);
                command.Parameters.AddWithValue("@SubjectCode", subjectCode);

                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    ddlClasses.DataSource = reader;
                    ddlClasses.DataTextField = "GradeLevel";
                    ddlClasses.DataValueField = "GradeLevel";
                    ddlClasses.DataBind();

                    if (ddlClasses.Items.Count == 0)
                        ddlClasses.Items.Insert(0, new ListItem("No classes available", "0"));
                    else
                        ddlClasses.Items.Insert(0, new ListItem("-- Select Class --", "0"));
                }
                catch (Exception ex)
                {
                    ShowError("Error loading classes: " + ex.Message);
                    ddlClasses.Items.Clear();
                    ddlClasses.Items.Insert(0, new ListItem("Error loading classes", "0"));
                }
            }
        }

        protected void ddlClasses_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlClasses.SelectedValue != "0" && ddlClasses.SelectedValue != "No classes available")
            {
                try
                {
                    string gradeLevel = ddlClasses.SelectedValue;
                    int teacherId = Convert.ToInt32(Session["TeacherID"]);
                    string subjectCode = Session["SubjectCode"].ToString();

                    LoadClassStudents(gradeLevel, subjectCode);
                    LoadAssessments(subjectCode); // refresh list for context
                    LoadRecentMarks(teacherId, subjectCode, gradeLevel);
                    LoadStudentSubmissions(teacherId, subjectCode, gradeLevel);
                }
                catch (Exception ex) { ShowError("Error loading class data: " + ex.Message); }
            }
            else
            {
                ddlStudents.Items.Clear(); ddlStudents.Items.Insert(0, new ListItem("-- Select Class First --", "0"));
                ddlQuizzes.Items.Clear(); ddlQuizzes.Items.Insert(0, new ListItem("-- Select Class First --", "0"));
                ddlQuizManual.Items.Clear(); ddlQuizManual.Items.Insert(0, new ListItem("-- Select Class First --", "0"));
            }
        }

        private void LoadClassStudents(string gradeLevel, string subjectCode)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand(
                @"SELECT s.StudentId, s.FullName 
                  FROM Students s
                  INNER JOIN StudentSubjects ss ON s.StudentId = ss.StudentID
                  WHERE (s.GradeLevel = @GradeLevel OR s.Grade = @GradeLevel)
                  AND ss.SubjectCode = @SubjectCode
                  ORDER BY s.FullName", connection))
            {
                command.Parameters.AddWithValue("@GradeLevel", gradeLevel);
                command.Parameters.AddWithValue("@SubjectCode", subjectCode);

                try
                {
                    connection.Open();
                    SqlDataReader reader = command.ExecuteReader();
                    ddlStudents.DataSource = reader;
                    ddlStudents.DataTextField = "FullName";
                    ddlStudents.DataValueField = "StudentId";
                    ddlStudents.DataBind();

                    if (ddlStudents.Items.Count == 0)
                        ddlStudents.Items.Insert(0, new ListItem("No students found in this class", "0"));
                    else
                        ddlStudents.Items.Insert(0, new ListItem("-- Select Student --", "0"));
                }
                catch (Exception ex)
                {
                    ShowError("Error loading students: " + ex.Message);
                    ddlStudents.Items.Clear();
                    ddlStudents.Items.Insert(0, new ListItem("Error loading students", "0"));
                }
            }
        }

        // ===================== Assessments: Quizzes + UploadedFiles =====================

        private void LoadAssessments(string subjectCode)
        {
            // Quizzes
            DataTable dtQuizzes = new DataTable();
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand(
                @"SELECT QuizID, QuizTitle, TotalMarks 
                  FROM Quizzes 
                  WHERE SubjectCode = @SubjectCode 
                  ORDER BY CreatedDate DESC", connection))
            {
                command.Parameters.AddWithValue("@SubjectCode", subjectCode);
                connection.Open();
                dtQuizzes.Load(command.ExecuteReader());
            }

            // Assignments from UploadedFiles (by teacher and subject)
            DataTable dtAssignments = new DataTable();
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand(
                @"SELECT FileID AS AssignmentId, FileName, FilePath, UploadDate
                  FROM UploadedFiles
                  WHERE SubjectCode = @SubjectCode
                    AND TeacherID   = @TeacherID
                  ORDER BY UploadDate DESC", connection))
            {
                command.Parameters.AddWithValue("@SubjectCode", subjectCode);
                command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                connection.Open();
                dtAssignments.Load(command.ExecuteReader());
            }

            // Build unified table for dropdowns
            var table = new DataTable();
            table.Columns.Add("Value"); // "Q|{QuizID}" or "A|{FileID}"
            table.Columns.Add("Text");  // Display label

            foreach (DataRow r in dtQuizzes.Rows)
            {
                table.Rows.Add($"Q|{r["QuizID"]}", $"[Quiz] {r["QuizTitle"]} (/{r["TotalMarks"]})");
            }
            foreach (DataRow r in dtAssignments.Rows)
            {
                table.Rows.Add($"A|{r["AssignmentId"]}", $"[Assignment] {r["FileName"]}");
            }

            BindUnifiedDropdown(ddlQuizzes, table);
            BindUnifiedDropdown(ddlQuizManual, table);
        }

        private void BindUnifiedDropdown(DropDownList ddl, DataTable table)
        {
            ddl.DataSource = table;
            ddl.DataTextField = "Text";
            ddl.DataValueField = "Value";
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem("-- Select Assessment --", "0"));
        }

        // ===================== Manual dropdown change (toggle preview) =====================

        protected void ddlQuizManual_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                pnlQuizResults.Visible = false;
                pnlAssignmentMarks.Visible = false;

                if (ddlQuizManual.SelectedValue == "0") return;

                var parts = ddlQuizManual.SelectedValue.Split('|');
                if (parts.Length != 2) throw new Exception("Invalid assessment selection.");
                string kind = parts[0];
                int id = int.Parse(parts[1]);

                if (kind == "Q")
                {
                    pnlQuizResults.Visible = true;
                    BindSelectedQuizResults(id);
                }
                else if (kind == "A")
                {
                    pnlAssignmentMarks.Visible = true;
                    BindSelectedAssignmentMarks(id);
                }
            }
            catch (Exception ex)
            {
                ShowError("Error loading assessment details: " + ex.Message);
            }
        }

        private void BindSelectedQuizResults(int quizId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    qr.ResultId,
                    s.FullName AS StudentName,
                    qr.Score,
                    qr.CompletionDate
                FROM QuizResults qr
                INNER JOIN Students s ON s.StudentId = qr.StudentId
                WHERE qr.QuizId = @QuizId
                ORDER BY qr.CompletionDate DESC;", conn))
            {
                cmd.Parameters.AddWithValue("@QuizId", quizId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                gvQuizResults.DataSource = dt;
                gvQuizResults.DataBind();
            }
        }

        private void BindSelectedAssignmentMarks(int assignmentId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                SELECT
                    am.AssignmentResultId,
                    s.FullName AS StudentName,
                    am.Score,
                    am.TotalMarks,
                    CAST(am.Score * 100.0 / NULLIF(am.TotalMarks,0) AS DECIMAL(5,2)) AS Percentage,
                    am.CompletionDate
                FROM AssignmentMarks am
                INNER JOIN Students s ON s.StudentId = am.StudentId
                WHERE am.AssignmentId = @AssignmentId
                ORDER BY am.CompletionDate DESC;", conn))
            {
                cmd.Parameters.AddWithValue("@AssignmentId", assignmentId);

                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                gvAssignmentMarks.DataSource = dt;
                gvAssignmentMarks.DataBind();
            }
        }

        // ===================== Recent (quizzes only; matches grid columns) =====================

        private void LoadRecentMarks(int teacherId, string subjectCode, string gradeLevel = null)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string query = @"
                    SELECT TOP 20 
                        s.FullName AS StudentName,
                        q.QuizTitle,
                        qr.Score,
                        q.TotalMarks,
                        CAST((qr.Score * 100.0 / q.TotalMarks) AS DECIMAL(5,2)) AS Percentage,
                        qr.CompletionDate AS UploadDate
                    FROM QuizResults qr
                    JOIN Students s ON qr.StudentId = s.StudentId
                    JOIN Quizzes q  ON qr.QuizId   = q.QuizID
                    WHERE q.SubjectCode = @SubjectCode
                      " + (!string.IsNullOrEmpty(gradeLevel) ? "AND (s.GradeLevel = @GradeLevel OR s.Grade = @GradeLevel)" : "") + @"
                    ORDER BY qr.CompletionDate DESC";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    if (!string.IsNullOrEmpty(gradeLevel))
                        command.Parameters.AddWithValue("@GradeLevel", gradeLevel);

                    try
                    {
                        connection.Open();
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(command).Fill(dt);
                        gvRecentMarks.DataSource = dt;
                        gvRecentMarks.DataBind();
                    }
                    catch (Exception ex) { ShowError("Error loading recent marks: " + ex.Message); }
                }
            }
        }

        // ===================== Student Submissions (SchoolCode scoped) =====================

        private void LoadStudentSubmissions(int teacherId, string subjectCode, string gradeLevel = null)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                string schoolCode = GetTeacherSchoolCode();

                string query = @"
                    SELECT 
                        ss.SubmissionID,
                        s.FullName AS StudentName,
                        s.GradeLevel AS ClassName,
                        ss.SubjectCode,
                        ss.OriginalFileName,
                        ss.SubmittedFilePath,
                        ss.SubmissionMessage,
                        ss.SubmissionDate
                    FROM StudentSubmissions ss
                    INNER JOIN Students s ON ss.StudentID = s.StudentId
                    WHERE s.SchoolCode = @SchoolCode
                      AND ss.TeacherID  = @TeacherID
                      AND ss.SubjectCode = @SubjectCode
                      " + (!string.IsNullOrEmpty(gradeLevel) ? "AND (s.GradeLevel = @GradeLevel OR s.Grade = @GradeLevel)" : "") + @"
                    ORDER BY ss.SubmissionDate DESC";

                using (SqlCommand command = new SqlCommand(query, connection))
                {
                    command.Parameters.AddWithValue("@SchoolCode", (object)schoolCode ?? DBNull.Value);
                    command.Parameters.AddWithValue("@TeacherID", teacherId);
                    command.Parameters.AddWithValue("@SubjectCode", subjectCode);
                    if (!string.IsNullOrEmpty(gradeLevel))
                        command.Parameters.AddWithValue("@GradeLevel", gradeLevel);

                    try
                    {
                        connection.Open();
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(command).Fill(dt);
                        gvStudentSubmissions.DataSource = dt;
                        gvStudentSubmissions.DataBind();
                    }
                    catch (Exception ex) { ShowError("Error loading student submissions: " + ex.Message); }
                }
            }
        }

        // ===================== Manual Add =====================

        protected void btnAddManual_Click(object sender, EventArgs e)
        {
            if (!IsTeacherAuthenticated()) { Response.Redirect("TeacherLogin.aspx"); return; }

            try
            {
                if (ddlStudents.SelectedValue == "0" || ddlStudents.SelectedValue == "No students found in this class")
                    throw new Exception("Please select a student");

                if (ddlQuizManual.SelectedValue == "0" || ddlQuizManual.SelectedValue == "Error loading quizzes")
                    throw new Exception("Please select an assessment");

                if (!int.TryParse(txtScore.Text, out int score) || score < 0)
                    throw new Exception("Please enter a valid score");

                // UI TotalMarks (needed for assignments since UploadedFiles doesn't have totals)
                int.TryParse(txtTotalMarks.Text, out int uiTotalMarks);
                string comments = txtComments.Text;

                int studentId = int.Parse(ddlStudents.SelectedValue);

                // Value format: "Q|{QuizID}" or "A|{FileID}"
                string[] parts = ddlQuizManual.SelectedValue.Split('|');
                if (parts.Length != 2) throw new Exception("Invalid assessment selection.");
                string kind = parts[0];
                int id = int.Parse(parts[1]);

                if (kind == "Q")
                {
                    // Validate vs Quizzes.TotalMarks
                    int totalMarks = GetQuizTotalMarks(id);
                    if (score > totalMarks)
                        throw new Exception($"Score cannot exceed total marks ({totalMarks}).");

                    SaveQuizMarkToDatabase(studentId, id, score);
                    ShowSuccess("Quiz mark added successfully!");
                }
                else if (kind == "A")
                {
                    // Ensure teacher uploaded this assignment and teaches its subject
                    int teacherId = Convert.ToInt32(Session["TeacherID"]);
                    if (!TeacherOwnsAssignmentAndSubject(teacherId, id))
                        throw new Exception("You can only grade assignments you uploaded for your subject.");

                    // Assignments (UploadedFiles) require TotalMarks entered by teacher
                    if (uiTotalMarks <= 0)
                        throw new Exception("Please enter Total Marks for the assignment.");
                    if (score > uiTotalMarks)
                        throw new Exception($"Score cannot exceed total marks ({uiTotalMarks}).");

                    SaveAssignmentMarkToDatabase(studentId, id /*FileID*/, score, uiTotalMarks, comments);
                    ShowSuccess("Assignment mark added successfully!");
                }
                else
                {
                    throw new Exception("Unknown assessment type.");
                }

                // Refresh correct preview grid instantly
                if (kind == "Q")
                {
                    pnlQuizResults.Visible = true;
                    pnlAssignmentMarks.Visible = false;
                    BindSelectedQuizResults(id);
                }
                else
                {
                    pnlQuizResults.Visible = false;
                    pnlAssignmentMarks.Visible = true;
                    BindSelectedAssignmentMarks(id);
                }

                // Refresh the "Recent Marks" (quiz-only list)
                int tId = Convert.ToInt32(Session["TeacherID"]);
                string subjectCode = Session["SubjectCode"]?.ToString();
                string gradeLevel = ddlClasses.SelectedItem?.Text ?? null;
                LoadRecentMarks(tId, subjectCode, gradeLevel);

                // Clear inputs (leave TotalMarks for convenience)
                txtScore.Text = "";
                txtComments.Text = "";
            }
            catch (Exception ex)
            {
                ShowError("Error: " + ex.Message);
            }
        }

        private int GetQuizTotalMarks(int quizId)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand command = new SqlCommand("SELECT TotalMarks FROM Quizzes WHERE QuizID = @QuizID", connection))
            {
                command.Parameters.AddWithValue("@QuizID", quizId);
                connection.Open();
                object result = command.ExecuteScalar();
                if (result != null && int.TryParse(result.ToString(), out int totalMarks))
                    return totalMarks;

                throw new Exception("Could not retrieve total marks for the selected quiz");
            }
        }

        private void SaveQuizMarkToDatabase(int studentId, int quizId, int score)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO QuizResults (StudentId, QuizId, Score, CompletionDate)
                VALUES (@StudentId, @QuizId, @Score, GETDATE());", connection))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@QuizId", quizId);
                cmd.Parameters.AddWithValue("@Score", score);
                connection.Open();
                int rows = cmd.ExecuteNonQuery();
                if (rows == 0) throw new Exception("Failed to save quiz mark.");
            }
        }

        private void SaveAssignmentMarkToDatabase(int studentId, int assignmentFileId, int score, int totalMarks, string comments)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO AssignmentMarks (AssignmentId, StudentId, Score, TotalMarks, CompletionDate, Comments)
                VALUES (@AssignmentId, @StudentId, @Score, @TotalMarks, GETDATE(), @Comments);", connection))
            {
                cmd.Parameters.AddWithValue("@AssignmentId", assignmentFileId); // FileID from UploadedFiles
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                cmd.Parameters.AddWithValue("@Score", score);
                cmd.Parameters.AddWithValue("@TotalMarks", totalMarks);
                cmd.Parameters.AddWithValue("@Comments", (object)(comments ?? string.Empty));
                connection.Open();
                int rows = cmd.ExecuteNonQuery();
                if (rows == 0) throw new Exception("Failed to save assignment mark.");
            }
        }

        // NEW: ensure teacher uploaded the assignment AND teaches its subject
        private bool TeacherOwnsAssignmentAndSubject(int teacherId, int assignmentFileId)
        {
            const string sql = @"
                SELECT COUNT(1)
                FROM UploadedFiles uf
                INNER JOIN Teachers t ON t.TeacherID = @TeacherID
                WHERE uf.FileID = @AssignmentId
                  AND uf.TeacherID = @TeacherID
                  AND uf.SubjectCode = t.SubjectCode;";

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                cmd.Parameters.AddWithValue("@AssignmentId", assignmentFileId);
                conn.Open();
                int count = Convert.ToInt32(cmd.ExecuteScalar());
                return count > 0;
            }
        }

        // ===================== File Upload (placeholder) =====================

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (!IsTeacherAuthenticated()) { Response.Redirect("TeacherLogin.aspx"); return; }

            try
            {
                if (ddlQuizzes.SelectedValue == "0" || ddlQuizzes.SelectedValue == "Error loading quizzes")
                    throw new Exception("Please select an assessment");

                if (!fileUploadMarks.HasFile)
                    throw new Exception("Please select a file to upload");

                string fileExtension = Path.GetExtension(fileUploadMarks.FileName).ToLower();
                if (fileExtension != ".xlsx" && fileExtension != ".csv")
                    throw new Exception("Only .xlsx and .csv files are allowed");

                if (fileUploadMarks.PostedFile.ContentLength > 2097152)
                    throw new Exception("File size cannot exceed 2MB");

                // Here you can parse and bulk insert depending on selection kind (Q/A)
                ProcessUploadedFile(fileUploadMarks.PostedFile, ParseAssessmentId(ddlQuizzes.SelectedValue));

                ShowSuccess("Marks uploaded successfully!");
                LoadRecentMarks(Convert.ToInt32(Session["TeacherID"]), Session["SubjectCode"].ToString(), ddlClasses.SelectedValue);
            }
            catch (NotImplementedException nie) { ShowError(nie.Message); }
            catch (Exception ex) { ShowError("Error uploading file: " + ex.Message); }
        }

        private (string kind, int id) ParseAssessmentId(string value)
        {
            var parts = value.Split('|');
            if (parts.Length != 2) throw new Exception("Invalid assessment selection.");
            return (parts[0], int.Parse(parts[1]));
        }

        private void ProcessUploadedFile(HttpPostedFile file, (string kind, int id) assessment)
        {
            // Implement XLSX/CSV parsing & insert here if needed.
            throw new NotImplementedException("File processing functionality is not yet implemented");
        }

        protected void btnDownloadTemplate_Click(object sender, EventArgs e)
        {
            if (!IsTeacherAuthenticated()) { Response.Redirect("TeacherLogin.aspx"); return; }

            try
            {
                string csvContent = "StudentID,StudentName,Score,Comments\n" +
                                    "12345,John Doe,85,Good work!\n" +
                                    "67890,Jane Smith,92,Excellent performance!";

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=MarksTemplate.csv");
                Response.ContentType = "text/csv";
                Response.Charset = "";
                Response.Output.Write(csvContent);
                Response.Flush();
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex) { ShowError("Error downloading template: " + ex.Message); }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }

        // ===================== UI Helpers =====================

        private void ShowSuccess(string message)
        {
            pnlSuccess.Visible = true;
            lblSuccess.Text = message;
            pnlError.Visible = false;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            lblError.Text = message;
            pnlSuccess.Visible = false;
        }

        private void ShowDebugInfo(string message)
        {
            pnlDebug.Visible = true;
            lblDebug.Text = message;
        }
    }
}
