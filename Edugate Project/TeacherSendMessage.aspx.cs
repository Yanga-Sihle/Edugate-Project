using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class TeacherSendMessage : System.Web.UI.Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        // which tab is active
        private enum Tab { Compose, Inbox }
        private Tab ActiveTab
        {
            get => (Tab)(ViewState["ActiveTab"] ?? Tab.Compose);
            set => ViewState["ActiveTab"] = value;
        }

        // for inbox: show archived or not
        private bool ShowArchived
        {
            get => (bool?)ViewState["ShowArchived"] ?? false;
            set => ViewState["ShowArchived"] = value;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsTeacherAuthenticated())
            {
                Response.Redirect("TeacherLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadTeacherNameAndSubject();
                // Compose tab init:
                LoadGradeLevels();
                LoadStudents();
                UpdateRecipientCount();

                // default tab
                SwitchTab(Tab.Compose);
            }
        }

        private bool IsTeacherAuthenticated()
        {
            return Session["TeacherID"] != null &&
                   Session["IsTeacherLoggedIn"] != null &&
                   (bool)Session["IsTeacherLoggedIn"];
        }

        private void LoadTeacherNameAndSubject()
        {
            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT t.FullName, s.SubjectName, t.SubjectCode, t.SchoolCode
                FROM Teachers t
                LEFT JOIN Subjects s ON t.SubjectCode = s.SubjectCode
                WHERE t.TeacherID = @TeacherID;", conn))
            {
                cmd.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        lblSidebarTeacherName.Text = r["FullName"]?.ToString() ?? "Teacher";
                        lblTeacherSubject.Text = r["SubjectName"]?.ToString() ?? "Subject";

                        if (Session["SubjectCode"] == null)
                            Session["SubjectCode"] = r["SubjectCode"]?.ToString();

                        if (Session["SchoolCode"] == null)
                            Session["SchoolCode"] = r["SchoolCode"]?.ToString();
                    }
                }
            }
        }

        /* ========== Compose (broadcast) ========== */

        private void LoadGradeLevels()
        {
            string schoolCode = Session["SchoolCode"]?.ToString();
            string subjectCode = Session["SubjectCode"]?.ToString();

            ddlGradeLevel.Items.Clear();
            ddlGradeLevel.Items.Add(new ListItem("-- All Grade Levels --", ""));

            if (string.IsNullOrWhiteSpace(schoolCode) || string.IsNullOrWhiteSpace(subjectCode))
            {
                pnlRecipientCount.Visible = false;
                ShowError("School or subject info missing. Re-login.");
                return;
            }

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT DISTINCT s.GradeLevel
                FROM Students s
                INNER JOIN StudentSubjects ss ON s.StudentId = ss.StudentID
                WHERE s.SchoolCode = @SchoolCode
                  AND ss.SubjectCode = @SubjectCode
                  AND s.IsActive = 1
                ORDER BY s.GradeLevel;", conn))
            {
                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        var val = r["GradeLevel"]?.ToString();
                        if (!string.IsNullOrWhiteSpace(val))
                            ddlGradeLevel.Items.Add(new ListItem(val, val));
                    }
                }
            }
        }

        private void LoadStudents()
        {
            string schoolCode = Session["SchoolCode"]?.ToString();
            string subjectCode = Session["SubjectCode"]?.ToString();
            string gradeLevel = ddlGradeLevel.SelectedValue;

            ddlStudents.Items.Clear();
            ddlStudents.Items.Add(new ListItem("-- All students (filtered) --", "ALL"));

            if (string.IsNullOrWhiteSpace(schoolCode) || string.IsNullOrWhiteSpace(subjectCode))
            {
                pnlRecipientCount.Visible = false;
                ShowError("School or subject info missing. Re-login.");
                return;
            }

            using (var conn = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
                SELECT DISTINCT s.StudentId, s.FullName
                FROM Students s
                INNER JOIN StudentSubjects ss ON s.StudentId = ss.StudentID
                WHERE s.SchoolCode = @SchoolCode
                  AND ss.SubjectCode = @SubjectCode
                  AND s.IsActive = 1
                  AND (@GradeLevel = '' OR s.GradeLevel = @GradeLevel)
                ORDER BY s.FullName;", conn))
            {
                cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                cmd.Parameters.AddWithValue("@GradeLevel", string.IsNullOrEmpty(gradeLevel) ? "" : gradeLevel);

                conn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        ddlStudents.Items.Add(
                            new ListItem(r["FullName"].ToString(),
                                         r["StudentId"].ToString())
                        );
                    }
                }
            }
        }

        protected void Filters_Changed(object sender, EventArgs e)
        {
            if (sender == ddlGradeLevel) LoadStudents();
            UpdateRecipientCount();
        }

        private void UpdateRecipientCount()
        {
            try
            {
                string schoolCode = Session["SchoolCode"]?.ToString();
                string subjectCode = Session["SubjectCode"]?.ToString();
                string gradeLevel = ddlGradeLevel.SelectedValue;
                string studentChoice = ddlStudents.SelectedValue;

                if (string.IsNullOrWhiteSpace(schoolCode) || string.IsNullOrWhiteSpace(subjectCode))
                {
                    pnlRecipientCount.Visible = false;
                    ShowError("School or subject info missing. Re-login.");
                    return;
                }

                int count;
                if (!string.IsNullOrEmpty(studentChoice) && studentChoice != "ALL")
                {
                    count = 1;
                }
                else
                {
                    using (var conn = new SqlConnection(connectionString))
                    using (var cmd = new SqlCommand(@"
                        SELECT COUNT(DISTINCT s.StudentId)
                        FROM Students s
                        INNER JOIN StudentSubjects ss ON s.StudentId = ss.StudentID
                        WHERE s.SchoolCode = @SchoolCode
                          AND ss.SubjectCode = @SubjectCode
                          AND s.IsActive = 1
                          AND (@GradeLevel = '' OR s.GradeLevel = @GradeLevel);", conn))
                    {
                        cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                        cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                        cmd.Parameters.AddWithValue("@GradeLevel", string.IsNullOrEmpty(gradeLevel) ? "" : gradeLevel);

                        conn.Open();
                        count = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }

                litRecipientCount.Text = count.ToString();
                pnlRecipientCount.Visible = true;
            }
            catch (Exception ex)
            {
                pnlRecipientCount.Visible = false;
                ShowError("Error updating recipient count: " + ex.Message);
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (!IsTeacherAuthenticated()) { Response.Redirect("TeacherLogin.aspx"); return; }

            string schoolCode = Session["SchoolCode"]?.ToString();
            string subjectCode = Session["SubjectCode"]?.ToString();
            int teacherId = Convert.ToInt32(Session["TeacherID"]);
            string teacherName = Session["TeacherFullName"]?.ToString() ?? "Teacher";

            if (string.IsNullOrWhiteSpace(schoolCode) || string.IsNullOrWhiteSpace(subjectCode))
            {
                ShowError("School or subject information is missing. Please log in again.");
                return;
            }

            string gradeLevel = ddlGradeLevel.SelectedValue;   // may be empty
            string studentChoice = ddlStudents.SelectedValue;     // "ALL" or StudentId
            string priority = ddlPriority.SelectedValue;
            string subj = (txtSubject.Text ?? "").Trim();
            string body = (txtMessage.Text ?? "").Trim();

            if (string.IsNullOrWhiteSpace(subj)) { ShowError("Please enter a message subject."); return; }
            if (string.IsNullOrWhiteSpace(body)) { ShowError("Please enter a message."); return; }

            // Build recipient list
            List<int> recipientIds = new List<int>();
            try
            {
                if (!string.IsNullOrEmpty(studentChoice) && studentChoice != "ALL")
                {
                    if (int.TryParse(studentChoice, out int sid)) recipientIds.Add(sid);
                }
                else
                {
                    using (var conn = new SqlConnection(connectionString))
                    using (var cmd = new SqlCommand(@"
                        SELECT DISTINCT s.StudentId
                        FROM Students s
                        INNER JOIN StudentSubjects ss ON s.StudentId = ss.StudentID
                        WHERE s.SchoolCode = @SchoolCode
                          AND ss.SubjectCode = @SubjectCode
                          AND s.IsActive = 1
                          AND (@GradeLevel = '' OR s.GradeLevel = @GradeLevel);", conn))
                    {
                        cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                        cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                        cmd.Parameters.AddWithValue("@GradeLevel", string.IsNullOrEmpty(gradeLevel) ? "" : gradeLevel);

                        conn.Open();
                        using (var r = cmd.ExecuteReader())
                        {
                            while (r.Read()) recipientIds.Add(Convert.ToInt32(r["StudentId"]));
                        }
                    }
                }

                if (recipientIds.Count == 0) { ShowError("No students match the selected filters."); return; }

                // Insert message + recipients
                using (var conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    var tx = conn.BeginTransaction();

                    try
                    {
                        int messageId;
                        using (var cmd = new SqlCommand(@"
                            INSERT INTO Messages
                                (SchoolCode, SubjectID, SenderType, SenderID, SenderName, Subject, Body, Priority,
                                 TargetGradeLevel, TargetGrade, DateSent, ExpiryDate, IsActive, SubjectCode)
                            VALUES
                                (@SchoolCode, NULL, 'Teacher', @SenderID, @SenderName, @Subject, @Body, @Priority,
                                 @TargetGradeLevel, NULL, GETDATE(), NULL, 1, @SubjectCode);
                            SELECT CAST(SCOPE_IDENTITY() AS INT);", conn, tx))
                        {
                            cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                            cmd.Parameters.AddWithValue("@SenderID", teacherId);
                            cmd.Parameters.AddWithValue("@SenderName", teacherName);
                            cmd.Parameters.AddWithValue("@Subject", subj);
                            cmd.Parameters.AddWithValue("@Body", body);
                            cmd.Parameters.AddWithValue("@Priority", priority);
                            if (string.IsNullOrEmpty(gradeLevel))
                                cmd.Parameters.AddWithValue("@TargetGradeLevel", DBNull.Value);
                            else
                                cmd.Parameters.AddWithValue("@TargetGradeLevel", gradeLevel);
                            cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);

                            messageId = (int)cmd.ExecuteScalar();
                        }

                        using (var cmdRec = new SqlCommand(@"
                            INSERT INTO MessageRecipients (MessageID, StudentID, IsRead, DateRead, IsArchived, IsDeleted)
                            VALUES (@MessageID, @StudentID, 0, NULL, 0, 0);", conn, tx))
                        {
                            cmdRec.Parameters.Add("@MessageID", SqlDbType.Int).Value = messageId;
                            cmdRec.Parameters.Add("@StudentID", SqlDbType.Int);

                            foreach (var sid in recipientIds)
                            {
                                cmdRec.Parameters["@StudentID"].Value = sid;
                                cmdRec.ExecuteNonQuery();
                            }
                        }

                        tx.Commit();

                        pnlSuccess.Visible = true;
                        pnlError.Visible = false;
                        litSuccess.Text = $"Sent to {recipientIds.Count} student{(recipientIds.Count == 1 ? "" : "s")}.";
                        ResetForm();
                    }
                    catch (Exception exTx)
                    {
                        tx.Rollback();
                        ShowError("An error occurred while sending your message: " + exTx.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("An error occurred while preparing recipients: " + ex.Message);
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetForm();
            pnlSuccess.Visible = false;
            pnlError.Visible = false;
        }

        private void ResetForm()
        {
            txtSubject.Text = "";
            txtMessage.Text = "";
            ddlPriority.SelectedValue = "Normal";
            ddlGradeLevel.SelectedValue = "";
            LoadStudents();
            pnlRecipientCount.Visible = false;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            pnlSuccess.Visible = false;
            litError.Text = message;
        }

        /* ========== Tabs switching ========== */
        protected void btnTabCompose_Click(object sender, EventArgs e) => SwitchTab(Tab.Compose);
        protected void btnTabInbox_Click(object sender, EventArgs e) => SwitchTab(Tab.Inbox);

        private void SwitchTab(Tab tab)
        {
            ActiveTab = tab;

            // update visibility
            pnlCompose.Visible = (tab == Tab.Compose);
            pnlStudentInbox.Visible = (tab == Tab.Inbox);

            // update tab button styles
            btnTabCompose.CssClass = "tab-btn" + (tab == Tab.Compose ? " active" : "");
            btnTabInbox.CssClass = "tab-btn" + (tab == Tab.Inbox ? " active" : "");

            if (tab == Tab.Inbox)
            {
                // default to inbox (not archived)
                if (!IsPostBack) ShowArchived = false;
                BindStudentInbox();
                // pills state
                btnInbox.CssClass = "pill" + (!ShowArchived ? " active" : "");
                btnArchived.CssClass = "pill" + (ShowArchived ? " active" : "");
            }
        }

        /* ========== Student Inbox (student -> teacher) ========== */

        protected void btnInbox_Click(object sender, EventArgs e)
        {
            ShowArchived = false;
            btnInbox.CssClass = "pill active";
            btnArchived.CssClass = "pill";
            BindStudentInbox();
        }

        protected void btnArchived_Click(object sender, EventArgs e)
        {
            ShowArchived = true;
            btnInbox.CssClass = "pill";
            btnArchived.CssClass = "pill active";
            BindStudentInbox();
        }

        private void BindStudentInbox()
        {
            int teacherId = Convert.ToInt32(Session["TeacherID"]);
            var dt = GetStudentMessagesForTeacher(teacherId, ShowArchived);
            rptStudentMsgs.DataSource = dt;
            rptStudentMsgs.DataBind();
            pnlEmptyInbox.Visible = dt.Rows.Count == 0;
        }

        private DataTable GetStudentMessagesForTeacher(int teacherId, bool archived)
        {
            const string sql = @"
SELECT
    stm.STMID,
    stm.DateSent,
    stm.Title,
    LEFT(stm.Body, 400) AS Preview,
    s.FullName AS StudentName,
    stm.SubjectCode,
    stm.OriginalMessageID,
    stms.IsRead,
    stms.IsArchived
FROM dbo.StudentTeacherMessages stm
JOIN dbo.StudentTeacherMessageStatus stms ON stms.STMID = stm.STMID
JOIN dbo.Students s ON s.StudentId = stm.StudentID
WHERE stms.TeacherID = @TeacherID
  AND ISNULL(stm.IsDeletedByTeacher,0) = 0
  AND stms.IsArchived = @IsArchived
ORDER BY stm.DateSent DESC;";

            var dt = new DataTable();
            using (var con = new SqlConnection(connectionString))
            using (var da = new SqlDataAdapter(sql, con))
            {
                da.SelectCommand.Parameters.AddWithValue("@TeacherID", teacherId);
                da.SelectCommand.Parameters.AddWithValue("@IsArchived", archived ? 1 : 0);
                da.Fill(dt);
            }
            return dt;
        }

        protected void rptStudentMsgs_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int teacherId = Convert.ToInt32(Session["TeacherID"]);
            int stmid = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "ToggleRead":
                    ToggleRead(stmid, teacherId);
                    break;
                case "ToggleArchive":
                    ToggleArchive(stmid, teacherId);
                    break;
                case "Delete":
                    DeleteForTeacher(stmid, teacherId);
                    break;
            }
            BindStudentInbox();
        }

        private void ToggleRead(int stmid, int teacherId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
UPDATE dbo.StudentTeacherMessageStatus
SET IsRead = CASE WHEN IsRead=1 THEN 0 ELSE 1 END,
    DateRead = CASE WHEN IsRead=1 THEN NULL ELSE GETDATE() END
WHERE STMID=@id AND TeacherID=@tid;", con))
            {
                cmd.Parameters.AddWithValue("@id", stmid);
                cmd.Parameters.AddWithValue("@tid", teacherId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void ToggleArchive(int stmid, int teacherId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
UPDATE dbo.StudentTeacherMessageStatus
SET IsArchived = CASE WHEN IsArchived=1 THEN 0 ELSE 1 END
WHERE STMID=@id AND TeacherID=@tid;", con))
            {
                cmd.Parameters.AddWithValue("@id", stmid);
                cmd.Parameters.AddWithValue("@tid", teacherId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private void DeleteForTeacher(int stmid, int teacherId)
        {
            using (var con = new SqlConnection(connectionString))
            using (var cmd = new SqlCommand(@"
UPDATE dbo.StudentTeacherMessages
SET IsDeletedByTeacher = 1
WHERE STMID=@id AND TeacherID=@tid;", con))
            {
                cmd.Parameters.AddWithValue("@id", stmid);
                cmd.Parameters.AddWithValue("@tid", teacherId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}
