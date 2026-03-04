using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class MyGrades : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        // Cached per request
        private bool _isPremiumSchool = false;
        private string _studentSchoolCode = null;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsStudentLoggedIn"] == null || !(bool)Session["IsStudentLoggedIn"] || Session["StudentID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Student name on sidebar
                if (Session["StudentFullName"] != null)
                    litStudentFullName.Text = Session["StudentFullName"].ToString();

                // Determine premium state once and persist for postbacks
                int studentId = (int)Session["StudentID"];
                _studentSchoolCode = GetStudentSchoolCode(studentId);
                _isPremiumSchool = GetIsPremiumBySchoolCode(_studentSchoolCode);
                ViewState["IsPremiumSchool"] = _isPremiumSchool;

                // Optional: show a “Premium/Free” badge if you add <asp:Literal ID="litPlanBadge" ... />
                SetPlanBadge();

                // Optional: grey-out gated links if you convert them to LinkButtons with those IDs
                SetPremiumVisualState();

                // Load subjects (now real subjects) and marks
                LoadSubjects();
                LoadMarks();
                UpdateSummaryCards();
            }
            else
            {
                // Recover premium flag on postback for click handler
                _isPremiumSchool = ViewState["IsPremiumSchool"] != null && (bool)ViewState["IsPremiumSchool"];
            }
        }

        /// <summary>
        /// Gets the SchoolCode for the logged-in student.
        /// </summary>
        private string GetStudentSchoolCode(int studentId)
        {
            string code = null;
            const string sql = @"SELECT SchoolCode FROM [Edugate].[dbo].[Students] WHERE StudentId = @StudentId";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                try
                {
                    con.Open();
                    object scalar = cmd.ExecuteScalar();
                    code = scalar?.ToString();
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error getting SchoolCode: {ex.Message}");
                }
            }

            return code;
        }

        /// <summary>
        /// Returns true if the school (by SchoolCode) is Premium.
        /// </summary>
        private bool GetIsPremiumBySchoolCode(string schoolCode)
        {
            if (string.IsNullOrWhiteSpace(schoolCode)) return false;

            const string sql = @"SELECT ISNULL(IsPremium, 0) 
                                 FROM [Edugate].[dbo].[Schools] 
                                 WHERE SchoolCode = @SchoolCode";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode.Trim());
                try
                {
                    con.Open();
                    object scalar = cmd.ExecuteScalar();
                    return scalar != null && Convert.ToBoolean(scalar);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error checking premium: {ex.Message}");
                    return false;
                }
            }
        }

        /// <summary>
        /// One handler to gate all Premium-only sidebar actions.
        /// Attach to LinkButtons with CommandArgument = target url.
        /// </summary>
        protected void RestrictedNav_Click(object sender, EventArgs e)
        {
            var btn = sender as LinkButton;
            string targetUrl = btn?.CommandArgument;

            if (_isPremiumSchool)
            {
                if (!string.IsNullOrWhiteSpace(targetUrl))
                {
                    Response.Redirect(targetUrl, false);
                }
                return;
            }

            string msg = "Your school is on the Free plan. Please ask your school administrator to upgrade to Premium to access Scholarships, Career Guidance, Study Materials, and Upload School Report.";
            ScriptManager.RegisterStartupScript(this, GetType(), "UpgradeNotice",
                $"alert('{msg.Replace("'", "\\'")}');", true);
        }

        /// <summary>
        /// Optional badge under avatar (won't error if not present).
        /// </summary>
        private void SetPlanBadge()
        {
            try
            {
                var lit = FindControl("litPlanBadge") as Literal;
                if (lit != null) lit.Text = _isPremiumSchool ? "Premium" : "Free";
            }
            catch { /* ignore */ }
        }

        /// <summary>
        /// Optional: visually gray-out gated items when on Free. Works only if you add LinkButtons with these IDs.
        /// </summary>
        private void SetPremiumVisualState()
        {
            if (_isPremiumSchool) return;

            TryAppendDisabledClass(FindControl("lnkUploadReport") as WebControl);
            TryAppendDisabledClass(FindControl("lnkScholarships") as WebControl);
            TryAppendDisabledClass(FindControl("lnkCareer") as WebControl);
            TryAppendDisabledClass(FindControl("lnkMaterials") as WebControl);
        }

        private void TryAppendDisabledClass(WebControl ctrl)
        {
            if (ctrl == null) return;
            if (string.IsNullOrWhiteSpace(ctrl.CssClass))
                ctrl.CssClass = "disabled";
            else if (!ctrl.CssClass.Contains("disabled"))
                ctrl.CssClass += " disabled";
        }

        // ---------------- Subjects (now real subjects from both assessment types) ----------------

        private void LoadSubjects()
        {
            ddlSubjects.Items.Clear();
            ddlSubjects.Items.Add(new ListItem("All Subjects", "all"));

            int studentId = (int)Session["StudentID"];

            const string sql = @"
                WITH QuizSubjects AS (
                    SELECT DISTINCT s.SubjectCode, s.SubjectName
                    FROM QuizResults qr
                    INNER JOIN Quizzes q ON q.QuizID = qr.QuizId
                    INNER JOIN Subjects s ON s.SubjectCode = q.SubjectCode
                    WHERE qr.StudentId = @StudentId
                ),
                AssignmentSubjects AS (
                    SELECT DISTINCT s.SubjectCode, s.SubjectName
                    FROM AssignmentMarks am
                    INNER JOIN UploadedFiles uf ON uf.FileID = am.AssignmentId
                    INNER JOIN Subjects s ON s.SubjectCode = uf.SubjectCode
                    WHERE am.StudentId = @StudentId
                )
                SELECT DISTINCT SubjectCode, SubjectName
                FROM (
                    SELECT * FROM QuizSubjects
                    UNION ALL
                    SELECT * FROM AssignmentSubjects
                ) x
                ORDER BY SubjectName;";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                try
                {
                    con.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string code = r["SubjectCode"].ToString();
                            string name = r["SubjectName"].ToString();
                            ddlSubjects.Items.Add(new ListItem(name, code));
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"LoadSubjects error: {ex.Message}");
                }
            }
        }

        // ---------------- Main load & binding ----------------

        private void LoadMarks()
        {
            int studentId = (int)Session["StudentID"];
            string subjectFilter = ddlSubjects.SelectedValue;    // "all" or SubjectCode
            string typeFilter = ddlAssessmentType.SelectedValue; // quiz/assignment/all
            string timeFilter = ddlTimePeriod.SelectedValue;

            DataTable allMarks = GetAllMarksForDisplay(studentId, subjectFilter, typeFilter, timeFilter);

            // NEW: remove duplicates (keep the latest row per assessment)
            allMarks = DeduplicateByAssessmentKeepLatest(allMarks);

            DataTable quizMarks = allMarks.Clone();
            DataTable assignmentMarks = allMarks.Clone();

            foreach (DataRow row in allMarks.Rows)
            {
                string assessmentType = row["AssessmentType"].ToString();
                DataRow newRow;

                switch (assessmentType)
                {
                    case "Quiz":
                        newRow = quizMarks.NewRow();
                        newRow.ItemArray = row.ItemArray;
                        quizMarks.Rows.Add(newRow);
                        break;

                    case "Assignment":
                        newRow = assignmentMarks.NewRow();
                        newRow.ItemArray = row.ItemArray;
                        assignmentMarks.Rows.Add(newRow);
                        break;
                }
            }

            gvAllMarks.DataSource = allMarks;
            gvAllMarks.DataBind();

            gvQuizzes.DataSource = quizMarks;
            gvQuizzes.DataBind();

            gvAssignments.DataSource = assignmentMarks;
            gvAssignments.DataBind();

            RegisterChartScript(allMarks);
        }

        // Keep only the most recent row per (AssessmentType, AssessmentId)
        private DataTable DeduplicateByAssessmentKeepLatest(DataTable dt)
        {
            if (dt == null || dt.Rows.Count == 0) return dt;

            var latestPerAssessment =
                dt.AsEnumerable()
                  .GroupBy(r => new
                  {
                      Type = r.Field<string>("AssessmentType") ?? "",
                      Id = r.Field<int?>("AssessmentId") ?? -1
                  })
                  .Select(g =>
                  {
                      // Prefer the row with the most recent DateSubmitted; fall back to CompletionDate
                      return g.OrderByDescending(r =>
                      {
                          DateTime a = r.Table.Columns.Contains("DateSubmitted") && r["DateSubmitted"] != DBNull.Value
                              ? r.Field<DateTime>("DateSubmitted")
                              : DateTime.MinValue;

                          DateTime b = r.Table.Columns.Contains("CompletionDate") && r["CompletionDate"] != DBNull.Value
                              ? r.Field<DateTime>("CompletionDate")
                              : DateTime.MinValue;

                          return a > b ? a : b;
                      }).First();
                  });

            var deduped = dt.Clone();
            foreach (var row in latestPerAssessment)
                deduped.ImportRow(row);

            // Preserve the same sort (by DateSubmitted desc)
            var dv = deduped.DefaultView;
            dv.Sort = "DateSubmitted DESC";
            return dv.ToTable();
        }

        private DataTable GetAllMarksForDisplay(int studentId, string subjectCode, string assessmentType, string timePeriod)
        {
            DataTable allMarks = new DataTable();
            allMarks.Columns.Add("SubjectName", typeof(string));
            allMarks.Columns.Add("AssessmentType", typeof(string));
            allMarks.Columns.Add("Title", typeof(string));
            allMarks.Columns.Add("DateSubmitted", typeof(DateTime));
            allMarks.Columns.Add("Score", typeof(double));
            allMarks.Columns.Add("Feedback", typeof(string));
            allMarks.Columns.Add("QuizId", typeof(int));
            allMarks.Columns.Add("CompletionDate", typeof(DateTime));
            allMarks.Columns.Add("Status", typeof(string));
            allMarks.Columns.Add("Grade", typeof(string));
            allMarks.Columns.Add("DateGraded", typeof(DateTime));
            allMarks.Columns.Add("AssessmentId", typeof(int));

            // Quizzes
            if (assessmentType == "all" || assessmentType == "quiz")
            {
                DataTable quizResults = GetQuizResultsForDisplay(studentId, timePeriod, subjectCode);
                foreach (DataRow row in quizResults.Rows)
                {
                    double score = row["Score"] == DBNull.Value ? 0 : Convert.ToDouble(row["Score"]);

                    DataRow newRow = allMarks.NewRow();
                    newRow["SubjectName"] = row["SubjectName"];
                    newRow["AssessmentType"] = "Quiz";
                    newRow["Title"] = row["Title"];
                    newRow["DateSubmitted"] = row["CompletionDate"];
                    newRow["CompletionDate"] = row["CompletionDate"];
                    newRow["Score"] = score; // already 0–100
                    newRow["Status"] = row["Status"];
                    newRow["QuizId"] = row["QuizId"];
                    newRow["Grade"] = CalculateGrade(Convert.ToInt32(score));
                    newRow["AssessmentId"] = row["QuizId"];
                    allMarks.Rows.Add(newRow);
                }
            }

            // Assignments
            if (assessmentType == "all" || assessmentType == "assignment")
            {
                DataTable assignmentResults = GetAssignmentMarksForDisplay(studentId, timePeriod, subjectCode);
                foreach (DataRow row in assignmentResults.Rows)
                {
                    double score = row["Score"] == DBNull.Value ? 0 : Convert.ToDouble(row["Score"]);

                    DataRow newRow = allMarks.NewRow();
                    newRow["SubjectName"] = row["SubjectName"];
                    newRow["AssessmentType"] = "Assignment";
                    newRow["Title"] = row["AssignmentTitle"];
                    newRow["DateSubmitted"] = row["CompletionDate"];
                    newRow["CompletionDate"] = row["CompletionDate"];
                    newRow["DateGraded"] = row["CompletionDate"];
                    newRow["Score"] = score; // computed % safely
                    newRow["Feedback"] = row["Comments"];
                    newRow["Grade"] = CalculateGrade(Convert.ToInt32(score));
                    newRow["AssessmentId"] = row["AssignmentId"];
                    allMarks.Rows.Add(newRow);
                }
            }

            DataView dv = allMarks.DefaultView;
            dv.Sort = "DateSubmitted DESC";
            return dv.ToTable();
        }

        // QuizResults with SubjectName
        private DataTable GetQuizResultsForDisplay(int studentId, string timePeriod, string subjectCode = "all")
        {
            DataTable quizResults = new DataTable();
            string query = @"
                SELECT 
                    qr.ResultId,
                    qr.QuizId,
                    ISNULL(q.QuizTitle, 'Quiz #' + CAST(qr.QuizId AS NVARCHAR(20))) AS Title,
                    s.SubjectName,
                    CAST(qr.Score AS FLOAT) AS Score,
                    qr.CompletionDate,
                    CASE WHEN CAST(qr.Score AS FLOAT) >= 60 THEN 'Pass' ELSE 'Fail' END AS Status
                FROM QuizResults qr
                INNER JOIN Quizzes q  ON q.QuizID      = qr.QuizId
                INNER JOIN Subjects s ON s.SubjectCode = q.SubjectCode
                WHERE qr.StudentId = @StudentId";

            if (!string.Equals(subjectCode, "all", StringComparison.OrdinalIgnoreCase))
                query += " AND s.SubjectCode = @SubjectCode";

            if (timePeriod != "all")
                query += " AND qr.CompletionDate >= @StartDate";

            query += " ORDER BY qr.CompletionDate DESC";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                if (!string.Equals(subjectCode, "all", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);

                if (timePeriod != "all")
                    cmd.Parameters.AddWithValue("@StartDate", GetStartDateForPeriod(timePeriod));

                try
                {
                    con.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(quizResults);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error loading quiz results: {ex.Message}");
                }
            }
            return quizResults;
        }

        // AssignmentMarks with SubjectName and safe %
        private DataTable GetAssignmentMarksForDisplay(int studentId, string timePeriod, string subjectCode = "all")
        {
            DataTable assignmentResults = new DataTable();
            string query = @"
                SELECT 
                    am.AssignmentResultId,
                    am.AssignmentId,
                    COALESCE(uf.FileName, 'Assignment #' + CAST(am.AssignmentId AS NVARCHAR(20))) AS AssignmentTitle,
                    s.SubjectName,
                    CASE 
                        WHEN NULLIF(am.TotalMarks, 0) IS NOT NULL 
                            THEN (CAST(am.Score AS FLOAT) / NULLIF(am.TotalMarks, 0)) * 100
                        ELSE 0
                    END AS Score,
                    am.CompletionDate,
                    am.Comments
                FROM AssignmentMarks am
                INNER JOIN UploadedFiles uf ON uf.FileID      = am.AssignmentId
                INNER JOIN Subjects s       ON s.SubjectCode  = uf.SubjectCode
                WHERE am.StudentId = @StudentId";

            if (!string.Equals(subjectCode, "all", StringComparison.OrdinalIgnoreCase))
                query += " AND s.SubjectCode = @SubjectCode";

            if (timePeriod != "all")
                query += " AND am.CompletionDate >= @StartDate";

            query += " ORDER BY am.CompletionDate DESC";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);

                if (!string.Equals(subjectCode, "all", StringComparison.OrdinalIgnoreCase))
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);

                if (timePeriod != "all")
                    cmd.Parameters.AddWithValue("@StartDate", GetStartDateForPeriod(timePeriod));

                try
                {
                    con.Open();
                    SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                    adapter.Fill(assignmentResults);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error loading assignment results: {ex.Message}");
                }
            }
            return assignmentResults;
        }

        private (double average, int count) GetQuizAverageAndCount(int studentId, string timePeriod)
        {
            double average = 0;
            int count = 0;

            string query = @"
                SELECT COUNT(*) as QuizCount,
                       AVG(CAST(qr.Score AS FLOAT)) as AverageScore
                FROM QuizResults qr
                WHERE qr.StudentId = @StudentId";

            if (timePeriod != "all")
                query += " AND qr.CompletionDate >= @StartDate";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                if (timePeriod != "all")
                    cmd.Parameters.AddWithValue("@StartDate", GetStartDateForPeriod(timePeriod));

                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            count = reader["QuizCount"] != DBNull.Value ? Convert.ToInt32(reader["QuizCount"]) : 0;
                            average = reader["AverageScore"] != DBNull.Value ? Convert.ToDouble(reader["AverageScore"]) : 0;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error getting quiz average: {ex.Message}");
                }
            }
            return (average, count);
        }

        private (double average, int count) GetAssignmentAverageAndCount(int studentId, string timePeriod)
        {
            double average = 0;
            int count = 0;

            string query = @"
                SELECT COUNT(*) AS Cnt,
                       AVG(
                           CASE 
                               WHEN NULLIF(am.TotalMarks, 0) IS NOT NULL
                                   THEN (CAST(am.Score AS FLOAT) / NULLIF(am.TotalMarks, 0)) * 100
                               ELSE 0
                           END
                       ) AS AvgPct
                FROM AssignmentMarks am
                WHERE am.StudentId = @StudentId";

            if (timePeriod != "all")
                query += " AND am.CompletionDate >= @StartDate";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@StudentId", studentId);
                if (timePeriod != "all")
                    cmd.Parameters.AddWithValue("@StartDate", GetStartDateForPeriod(timePeriod));

                try
                {
                    con.Open();
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            count = r["Cnt"] != DBNull.Value ? Convert.ToInt32(r["Cnt"]) : 0;
                            average = r["AvgPct"] != DBNull.Value ? Convert.ToDouble(r["AvgPct"]) : 0;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error getting assignment average: {ex.Message}");
                }
            }
            return (average, count);
        }

        private void UpdateSummaryCards()
        {
            int studentId = (int)Session["StudentID"];
            string timeFilter = ddlTimePeriod.SelectedValue;

            var quiz = GetQuizAverageAndCount(studentId, timeFilter);
            var assign = GetAssignmentAverageAndCount(studentId, timeFilter);

            double overallAverage = 0;
            int totalCount = quiz.count + assign.count;

            if (totalCount > 0)
                overallAverage = (quiz.average * quiz.count + assign.average * assign.count) / totalCount;

            litOverallAverage.Text = overallAverage.ToString("0.0");
            litQuizAverage2.Text = quiz.average.ToString("0.0");
            litQuizCount2.Text = quiz.count.ToString();
            litAssignmentAverage.Text = assign.average.ToString("0.0");
            litAssignmentCount.Text = assign.count.ToString();
        }

        private DateTime GetStartDateForPeriod(string timePeriod)
        {
            DateTime startDate = DateTime.Now;

            switch (timePeriod.ToLower())
            {
                case "current":
                    int currentMonth = DateTime.Now.Month;
                    int termStartMonth = GetCurrentTermStartMonth();
                    startDate = currentMonth < termStartMonth
                        ? new DateTime(DateTime.Now.Year - 1, termStartMonth, 1)
                        : new DateTime(DateTime.Now.Year, termStartMonth, 1);
                    break;

                case "last":
                    int lastTermStartMonth = GetCurrentTermStartMonth() - 4;
                    if (lastTermStartMonth <= 0)
                    {
                        lastTermStartMonth += 12;
                        startDate = new DateTime(DateTime.Now.Year - 1, lastTermStartMonth, 1);
                    }
                    else
                    {
                        startDate = new DateTime(DateTime.Now.Year, lastTermStartMonth, 1);
                    }
                    break;

                case "month":
                    startDate = DateTime.Now.AddDays(-30);
                    break;

                default:
                    startDate = DateTime.MinValue;
                    break;
            }

            return startDate;
        }

        private int GetCurrentTermStartMonth()
        {
            int currentMonth = DateTime.Now.Month;
            if (currentMonth >= 2 && currentMonth < 6) return 2;
            else if (currentMonth >= 6 && currentMonth < 10) return 6;
            else return 10;
        }

        protected void FilterMarks(object sender, EventArgs e)
        {
            LoadMarks();
            UpdateSummaryCards();
        }

        protected void ChangeTab(object sender, EventArgs e)
        {
            Button clickedButton = (Button)sender;
            string tabName = clickedButton.CommandArgument;

            btnTabAll.CssClass = "tab-btn";
            btnTabQuizzes.CssClass = "tab-btn";
            btnTabAssignments.CssClass = "tab-btn";

            tabAll.Style["display"] = "none";
            tabQuizzes.Style["display"] = "none";
            tabAssignments.Style["display"] = "none";

            switch (tabName)
            {
                case "all":
                    btnTabAll.CssClass += " active";
                    tabAll.Style["display"] = "block";
                    break;
                case "quiz":
                    btnTabQuizzes.CssClass += " active";
                    tabQuizzes.Style["display"] = "block";
                    break;
                case "assignment":
                    btnTabAssignments.CssClass += " active";
                    tabAssignments.Style["display"] = "block";
                    break;
            }
        }

        public string GetGradeCssClass(int score)
        {
            if (score >= 80) return "grade-pass";
            if (score >= 60) return "grade-average";
            return "grade-fail";
        }

        public string CalculateGrade(int score)
        {
            if (score >= 90) return "A+";
            if (score >= 85) return "A";
            if (score >= 80) return "A-";
            if (score >= 75) return "B+";
            if (score >= 70) return "B";
            if (score >= 65) return "B-";
            if (score >= 60) return "C+";
            if (score >= 55) return "C";
            if (score >= 50) return "C-";
            if (score >= 45) return "D+";
            if (score >= 40) return "D";
            return "F";
        }

        protected void ExportMarksToCsv(object sender, EventArgs e)
        {
            int studentId = ((int)Session["StudentID"]);
            string typeFilter = ddlAssessmentType.SelectedValue;
            string timeFilter = ddlTimePeriod.SelectedValue;
            string subjectFilter = ddlSubjects.SelectedValue; // "all" or SubjectCode

            DataTable allMarks = GetAllMarksForDisplay(studentId, subjectFilter, typeFilter, timeFilter);

            // (Optional) Also de-dupe the export to match on-screen view:
            allMarks = DeduplicateByAssessmentKeepLatest(allMarks);

            if (allMarks.Rows.Count > 0)
            {
                StringBuilder sb = new StringBuilder();
                sb.AppendLine("Subject,Assessment Type,Title,Date,Score,Grade,Feedback");

                foreach (DataRow row in allMarks.Rows)
                {
                    string grade = row["Grade"] != DBNull.Value ? row["Grade"].ToString() : "";
                    string feedback = row["Feedback"] != DBNull.Value ? row["Feedback"].ToString().Replace("\"", "\"\"") : "";

                    sb.AppendLine($"\"{row["SubjectName"]}\",\"{row["AssessmentType"]}\",\"{row["Title"]}\",\"{Convert.ToDateTime(row["DateSubmitted"]):yyyy-MM-dd}\",{row["Score"]}%,\"{grade}\",\"{feedback}\"");
                }

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=MyMarks.csv");
                Response.Charset = "";
                Response.ContentType = "application/text";
                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
        }

        protected void ExportQuizResultsToCsv(object sender, EventArgs e)
        {
            int studentId = (int)Session["StudentID"];
            string timeFilter = ddlTimePeriod.SelectedValue;
            string subjectFilter = ddlSubjects.SelectedValue; // "all" or SubjectCode

            DataTable quizResults = GetQuizResultsForDisplay(studentId, timeFilter, subjectFilter);

            if (quizResults.Rows.Count > 0)
            {
                StringBuilder sb = new StringBuilder();
                sb.AppendLine("Quiz Title,Subject,Completion Date,Score,Status");

                // (Optional) if you want export-level de-dupe by QuizId, keep latest:
                var latestByQuiz =
                    quizResults.AsEnumerable()
                               .GroupBy(r => r.Field<int>("QuizId"))
                               .Select(g => g.OrderByDescending(r => r.Field<DateTime>("CompletionDate")).First());

                foreach (var row in latestByQuiz)
                {
                    sb.AppendLine($"\"{row["Title"]}\",\"{row["SubjectName"]}\",\"{Convert.ToDateTime(row["CompletionDate"]):yyyy-MM-dd}\",{row["Score"]}%,{row["Status"]}");
                }

                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=QuizResults.csv");
                Response.Charset = "";
                Response.ContentType = "application/text";
                Response.Output.Write(sb.ToString());
                Response.Flush();
                Response.End();
            }
        }

        private void RegisterChartScript(DataTable marksData)
        {
            if (marksData.Rows.Count > 0)
            {
                var monthlyAverages = marksData.AsEnumerable()
                    .Where(r => r["Score"] != DBNull.Value && r["DateSubmitted"] != DBNull.Value)
                    .GroupBy(r => new
                    {
                        Year = Convert.ToDateTime(r["DateSubmitted"]).Year,
                        Month = Convert.ToDateTime(r["DateSubmitted"]).Month
                    })
                    .Select(g => new
                    {
                        Period = new DateTime(g.Key.Year, g.Key.Month, 1),
                        Average = g.Average(r => Convert.ToDouble(r["Score"]))
                    })
                    .OrderBy(x => x.Period)
                    .ToList();

                string labels = string.Join(",", monthlyAverages.Select(m => $"\"{m.Period:MMM yyyy}\""));
                string data = string.Join(",", monthlyAverages.Select(m => m.Average.ToString("0")));

                string script = $@"
                    <script>
                        document.addEventListener('DOMContentLoaded', function() {{
                            const chartData = {{
                                labels: [{labels}],
                                datasets: [{{
                                    label: 'Monthly Average',
                                    data: [{data}],
                                    borderColor: '#45DFB1',
                                    tension: 0.4,
                                    fill: false
                                }}]
                            }};
                            
                            const config = {{
                                type: 'line',
                                data: chartData,
                                options: {{
                                    responsive: true,
                                    plugins: {{
                                        legend: {{
                                            position: 'top',
                                            labels: {{ color: 'white' }}
                                        }}
                                    }},
                                    scales: {{
                                        y: {{
                                            beginAtZero: true,
                                            max: 100,
                                            ticks: {{
                                                callback: function (value) {{ return value + '%'; }},
                                                color: 'white'
                                            }},
                                            grid: {{ color: 'rgba(255, 255, 255, 0.2)' }}
                                        }},
                                        x: {{
                                            ticks: {{ color: 'white' }},
                                            grid: {{ color: 'rgba(255, 255, 255, 0.2)' }}
                                        }}
                                    }}
                                }}
                            }};
                            
                            var marksChart = new Chart(
                                document.getElementById('marksChart'),
                                config
                            );
                        }});
                    </script>";

                ClientScript.RegisterStartupScript(this.GetType(), "ChartScript", script);
            }
        }
    }
}
