using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class StudentMessages : System.Web.UI.Page
    {
        // ---- CONFIG ----
        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString
            ?? "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        private bool _isPremiumSchool = false;

        // alert bindings for the banner
        protected string AlertMessage { get; set; }
        protected string AlertType { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsStudentLoggedIn"] == null || !(bool)Session["IsStudentLoggedIn"] || Session["StudentID"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litStudentFullName.Text = Convert.ToString(Session["StudentFullName"] ?? "Student");

                int studentId = Convert.ToInt32(Session["StudentID"]);
                string schoolCode = GetStudentSchoolCode(studentId);
                _isPremiumSchool = GetIsPremiumBySchoolCode(schoolCode);
                ViewState["IsPremiumSchool"] = _isPremiumSchool;

                LoadMessages();
                LoadArchivedMessages();

                if (Session["AlertMessage"] != null)
                {
                    AlertMessage = Session["AlertMessage"].ToString();
                    AlertType = Session["AlertType"]?.ToString() ?? "success";
                    Session.Remove("AlertMessage");
                    Session.Remove("AlertType");
                }

                pnlReply.Visible = false;
                pnlArchived.Visible = false;
                pnlInbox.Visible = true;
            }
            else
            {
                _isPremiumSchool = ViewState["IsPremiumSchool"] != null && (bool)ViewState["IsPremiumSchool"];
            }
        }

        // ===== Helpers =====
        private string GetStudentSchoolCode(int studentId)
        {
            const string sql = @"SELECT SchoolCode FROM dbo.Students WHERE StudentId=@sid";
            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@sid", studentId);
                con.Open();
                var o = cmd.ExecuteScalar();
                return o?.ToString();
            }
        }

        private string GetStudentGradeLevel(int studentId)
        {
            const string sql = @"SELECT GradeLevel FROM dbo.Students WHERE StudentId=@sid";
            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@sid", studentId);
                con.Open();
                var o = cmd.ExecuteScalar();
                return o?.ToString();
            }
        }

        private bool GetIsPremiumBySchoolCode(string schoolCode)
        {
            if (string.IsNullOrWhiteSpace(schoolCode)) return false;
            const string sql = @"SELECT ISNULL(IsPremium,0) FROM dbo.Schools WHERE SchoolCode=@sc";
            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@sc", schoolCode);
                con.Open();
                var o = cmd.ExecuteScalar();
                return (o != null && Convert.ToBoolean(o));
            }
        }

        private void SetAlert(string message, string type = "success")
        {
            Session["AlertMessage"] = message;
            Session["AlertType"] = type;
            AlertMessage = message;
            AlertType = type;
        }

        private void ExecNonQuery(string sql, int studentId, int messageId)
        {
            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@StudentID", studentId);
                cmd.Parameters.AddWithValue("@MessageID", messageId);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // ===== Lists =====
        private void LoadMessages()
        {
            int studentId = Convert.ToInt32(Session["StudentID"]);
            string filter = ddlFilter.SelectedValue; // all, unread, read, priority
            string sort = ddlSort.SelectedValue;     // newest, oldest, sender, priority

            string sql = @"
SELECT
    mr.MessageID,
    m.SenderName,
    m.Subject,
    m.Body,
    m.DateSent AS SentDate,
    mr.IsRead,
    m.Priority
FROM dbo.MessageRecipients mr
JOIN dbo.Messages m ON mr.MessageID = m.MessageID
WHERE mr.StudentID = @StudentID
  AND ISNULL(mr.IsDeleted,0) = 0
  AND ISNULL(mr.IsArchived,0) = 0
  AND ISNULL(m.IsActive,1) = 1
  AND (m.ExpiryDate IS NULL OR m.ExpiryDate >= GETDATE())
";

            if (filter == "unread")
                sql += " AND mr.IsRead = 0";
            else if (filter == "read")
                sql += " AND mr.IsRead = 1";
            else if (filter == "priority")
                sql += " AND m.Priority = 'High'";

            sql += " ORDER BY ";
            switch (sort)
            {
                case "oldest": sql += "m.DateSent ASC"; break;
                case "sender": sql += "m.SenderName ASC, m.DateSent DESC"; break;
                case "priority": sql += "CASE WHEN m.Priority='High' THEN 1 ELSE 0 END DESC, m.DateSent DESC"; break;
                default: sql += "m.DateSent DESC"; break;
            }

            using (var con = new SqlConnection(ConnectionString))
            using (var da = new SqlDataAdapter(sql, con))
            {
                da.SelectCommand.Parameters.AddWithValue("@StudentID", studentId);
                var dt = new DataTable();
                da.Fill(dt);
                rptMessages.DataSource = dt;
                rptMessages.DataBind();
                pnlNoMessages.Visible = dt.Rows.Count == 0;
            }
        }

        private void LoadArchivedMessages()
        {
            int studentId = Convert.ToInt32(Session["StudentID"]);
            string sql = @"
SELECT
    mr.MessageID,
    m.SenderName,
    m.Subject,
    m.Body,
    m.DateSent AS SentDate,
    mr.IsRead,
    m.Priority
FROM dbo.MessageRecipients mr
JOIN dbo.Messages m ON mr.MessageID = m.MessageID
WHERE mr.StudentID = @StudentID
  AND ISNULL(mr.IsDeleted,0) = 0
  AND ISNULL(mr.IsArchived,0) = 1
  AND ISNULL(m.IsActive,1) = 1
ORDER BY m.DateSent DESC";
            using (var con = new SqlConnection(ConnectionString))
            using (var da = new SqlDataAdapter(sql, con))
            {
                da.SelectCommand.Parameters.AddWithValue("@StudentID", studentId);
                var dt = new DataTable();
                da.Fill(dt);
                rptArchivedMessages.DataSource = dt;
                rptArchivedMessages.DataBind();
                pnlNoArchivedMessages.Visible = dt.Rows.Count == 0;
            }
        }

        // ===== Event handlers wired in markup =====
        protected void FilterMessages(object sender, EventArgs e)
        {
            LoadMessages();
            SetAlert("Filters applied.", "success");
        }

        protected void ClearFilters(object sender, EventArgs e)
        {
            ddlFilter.SelectedValue = "all";
            ddlSort.SelectedValue = "newest";
            LoadMessages();
            SetAlert("Filters cleared.", "success");
        }

        protected void ChangeTab(object sender, EventArgs e)
        {
            var btn = (Button)sender;
            string tab = btn.CommandArgument; // "inbox" or "archived"

            pnlInbox.Visible = (tab == "inbox");
            pnlArchived.Visible = (tab == "archived");

            if (pnlArchived.Visible) LoadArchivedMessages();
            else LoadMessages();

            // keep compose hidden when switching
            pnlReply.Visible = false;
        }

        protected void rptMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int studentId = Convert.ToInt32(Session["StudentID"]);
            int messageId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "ToggleRead":
                    ExecNonQuery(@"
UPDATE dbo.MessageRecipients
SET DateRead = CASE WHEN IsRead=1 THEN NULL ELSE GETDATE() END,
    IsRead   = CASE WHEN IsRead=1 THEN 0 ELSE 1 END
WHERE StudentID=@StudentID AND MessageID=@MessageID AND ISNULL(IsDeleted,0)=0;", studentId, messageId);
                    SetAlert("Message status updated.");
                    LoadMessages();
                    return;

                case "Reply":
                    PrepareReplyPanel(messageId);
                    return;

                case "Archive":
                    ExecNonQuery(@"
UPDATE dbo.MessageRecipients
SET IsArchived=1
WHERE StudentID=@StudentID AND MessageID=@MessageID AND ISNULL(IsDeleted,0)=0;", studentId, messageId);
                    SetAlert("Message archived.");
                    LoadMessages();
                    return;

                case "Delete":
                    ExecNonQuery(@"
UPDATE dbo.MessageRecipients
SET IsDeleted=1
WHERE StudentID=@StudentID AND MessageID=@MessageID;", studentId, messageId);
                    SetAlert("Message deleted.");
                    LoadMessages();
                    return;
            }
        }

        protected void rptArchivedMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int studentId = Convert.ToInt32(Session["StudentID"]);
            int messageId = Convert.ToInt32(e.CommandArgument);

            switch (e.CommandName)
            {
                case "Unarchive":
                    ExecNonQuery(@"
UPDATE dbo.MessageRecipients
SET IsArchived=0
WHERE StudentID=@StudentID AND MessageID=@MessageID AND ISNULL(IsDeleted,0)=0;", studentId, messageId);
                    SetAlert("Moved to inbox.");
                    LoadArchivedMessages();
                    return;

                case "Delete":
                    ExecNonQuery(@"
UPDATE dbo.MessageRecipients
SET IsDeleted=1
WHERE StudentID=@StudentID AND MessageID=@MessageID;", studentId, messageId);
                    SetAlert("Archived message deleted.");
                    LoadArchivedMessages();
                    return;
            }
        }

        // ===== Compose / Reply =====
        protected void btnNewMessage_Click(object sender, EventArgs e)
        {
            // open compose panel detached from a specific message
            int studentId = Convert.ToInt32(Session["StudentID"]);
            string schoolCode = GetStudentSchoolCode(studentId);
            string gradeLevel = GetStudentGradeLevel(studentId);

            hfReplyForMessageId.Value = string.Empty;
            hfReplySchoolCode.Value = schoolCode ?? string.Empty;

            LoadTeachersForCompose(studentId, schoolCode, gradeLevel, preferredSubjectCode: null);

            txtReplyTitle.Text = string.Empty;
            txtReplyBody.Text = string.Empty;
            pnlReply.Visible = true;
        }

        private void PrepareReplyPanel(int originalMessageId)
        {
            int studentId = Convert.ToInt32(Session["StudentID"]);
            string schoolCode = GetStudentSchoolCode(studentId);
            string gradeLevel = GetStudentGradeLevel(studentId);

            string preferredSubjectCode = null;
            string origSubjectTitle = null;

            using (var con = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand("SELECT SubjectCode, Subject FROM dbo.Messages WHERE MessageID=@mid", con))
            {
                cmd.Parameters.AddWithValue("@mid", originalMessageId);
                con.Open();
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        preferredSubjectCode = Convert.ToString(r["SubjectCode"]);
                        origSubjectTitle = Convert.ToString(r["Subject"]);
                    }
                }
            }

            hfReplyForMessageId.Value = originalMessageId.ToString();
            hfReplySchoolCode.Value = schoolCode ?? string.Empty;

            LoadTeachersForCompose(studentId, schoolCode, gradeLevel, preferredSubjectCode);

            txtReplyTitle.Text = string.IsNullOrWhiteSpace(origSubjectTitle) ? "RE:" : $"RE: {origSubjectTitle}";
            pnlReply.Visible = true;
        }

        private void LoadTeachersForCompose(int studentId, string schoolCode, string gradeLevel, string preferredSubjectCode)
        {
            const string sql = @"
SELECT DISTINCT 
    t.TeacherID,
    t.FullName AS TeacherName,
    t.SubjectCode,
    ISNULL(s.SubjectName, t.SubjectCode) AS SubjectName
FROM dbo.Teachers t
LEFT JOIN dbo.Subjects s ON s.SubjectCode = t.SubjectCode
INNER JOIN dbo.StudentSubjects ss ON ss.SubjectCode = t.SubjectCode
INNER JOIN dbo.Students stu ON stu.StudentId = ss.StudentID
WHERE stu.StudentId = @sid
  AND t.SchoolCode  = @sc
ORDER BY TeacherName;";

            using (var con = new SqlConnection(ConnectionString))
            using (var da = new SqlDataAdapter(sql, con))
            {
                da.SelectCommand.Parameters.AddWithValue("@sid", studentId);
                da.SelectCommand.Parameters.AddWithValue("@sc", schoolCode ?? (object)DBNull.Value);

                var dt = new DataTable();
                da.Fill(dt);

                ddlTeachers.Items.Clear();
                foreach (DataRow row in dt.Rows)
                {
                    string teacherId = Convert.ToString(row["TeacherID"]);
                    string tName = Convert.ToString(row["TeacherName"]);
                    string subjCode = Convert.ToString(row["SubjectCode"]);
                    string subjName = Convert.ToString(row["SubjectName"]);
                    ddlTeachers.Items.Add(new ListItem($"{tName} — {subjName}", $"{teacherId}|{subjCode}"));
                }

                // auto-select by preferred subject if present
                if (!string.IsNullOrWhiteSpace(preferredSubjectCode))
                {
                    foreach (ListItem li in ddlTeachers.Items)
                    {
                        var parts = li.Value.Split('|');
                        if (parts.Length == 2 && parts[1].Equals(preferredSubjectCode, StringComparison.OrdinalIgnoreCase))
                        {
                            ddlTeachers.ClearSelection();
                            li.Selected = true;
                            break;
                        }
                    }
                }

                if (ddlTeachers.Items.Count > 0)
                {
                    var sel = ddlTeachers.SelectedItem ?? ddlTeachers.Items[0];
                    var parts = sel.Value.Split('|');
                    string subjCode = parts.Length == 2 ? parts[1] : "";
                    hfReplySubjectCode.Value = subjCode;
                    txtReplySubjectName.Text = sel.Text.Contains("—") ? sel.Text.Split('—')[1].Trim() : subjCode;
                }
                else
                {
                    hfReplySubjectCode.Value = "";
                    txtReplySubjectName.Text = "";
                }
            }
        }

        protected void ddlTeachers_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlTeachers.SelectedItem == null) return;

            var parts = ddlTeachers.SelectedValue.Split('|');
            hfReplySubjectCode.Value = (parts.Length == 2 ? parts[1] : "");
            txtReplySubjectName.Text = ddlTeachers.SelectedItem.Text.Contains("—")
                ? ddlTeachers.SelectedItem.Text.Split('—')[1].Trim()
                : hfReplySubjectCode.Value;

            pnlReply.Visible = true; // keep panel open
        }

        protected void btnSendReply_Click(object sender, EventArgs e)
        {
            try
            {
                int studentId = Convert.ToInt32(Session["StudentID"]);
                string studentName = Convert.ToString(Session["StudentFullName"] ?? "Student");
                string schoolCode = string.IsNullOrWhiteSpace(hfReplySchoolCode.Value)
                                    ? GetStudentSchoolCode(studentId)
                                    : hfReplySchoolCode.Value;

                // TeacherID|SubjectCode packed in dropdown value
                if (ddlTeachers.SelectedItem == null)
                {
                    SetAlert("Please pick a teacher.", "error");
                    pnlReply.Visible = true;
                    return;
                }

                var parts = ddlTeachers.SelectedValue.Split('|');
                if (parts.Length != 2)
                {
                    SetAlert("Invalid teacher selection.", "error");
                    pnlReply.Visible = true;
                    return;
                }

                int teacherId = Convert.ToInt32(parts[0]);
                string subjectCode = parts[1];
                string replyTitle = (txtReplyTitle.Text ?? "").Trim();
                string replyBody = (txtReplyBody.Text ?? "").Trim();

                if (string.IsNullOrWhiteSpace(replyTitle) || string.IsNullOrWhiteSpace(replyBody))
                {
                    SetAlert("Please enter a title and message.", "error");
                    pnlReply.Visible = true;
                    return;
                }

                // Insert into TeacherStudentMessages (student -> teacher)
                using (var con = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
INSERT INTO dbo.TeacherStudentMessages
    (SchoolCode, SubjectCode, FromStudentID, ToTeacherID, Title, Body, DateSent, IsReadByTeacher, IsDeleted)
VALUES
    (@SchoolCode, @SubjectCode, @FromStudentID, @ToTeacherID, @Title, @Body, GETDATE(), 0, 0);", con))
                {
                    cmd.Parameters.AddWithValue("@SchoolCode", schoolCode ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@SubjectCode", subjectCode ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@FromStudentID", studentId);
                    cmd.Parameters.AddWithValue("@ToTeacherID", teacherId);
                    cmd.Parameters.AddWithValue("@Title", replyTitle);
                    cmd.Parameters.AddWithValue("@Body", replyBody);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                // reset compose
                txtReplyTitle.Text = "";
                txtReplyBody.Text = "";
                pnlReply.Visible = false;

                SetAlert("Message sent successfully.", "success");
                LoadMessages();
            }
            catch (Exception ex)
            {
                SetAlert("Could not send your message: " + ex.Message, "error");
                pnlReply.Visible = true;
            }
        }

        protected void btnCancelReply_Click(object sender, EventArgs e)
        {
            pnlReply.Visible = false;
            txtReplyTitle.Text = "";
            txtReplyBody.Text = "";
        }
    }
}
