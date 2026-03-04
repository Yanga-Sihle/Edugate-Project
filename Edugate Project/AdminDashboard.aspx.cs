using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace Edugate_Project
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        /* ========================= LIFECYCLE ========================= */

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Make the export button a full postback even inside UpdatePanels
            var sm = ScriptManager.GetCurrent(Page);
            if (sm != null)
            {
                if (btnExportExcel != null) sm.RegisterPostBackControl(btnExportExcel);
            }
        }

        // Needed when we RenderControl(Grid) to HTML for Excel
        public override void VerifyRenderingInServerForm(Control control)
        {
            // Intentionally empty – required for export of server controls
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            EnsureAuthenticated();

            if (!IsPostBack)
            {
                lblAdminName.Text = Convert.ToString(Session["AdminName"] ?? Session["AdminId"] ?? "Admin");

                EnsureStandardPaymentsTable();           // Make sure StandardPayments table exists
                UpdateBlockingForStandardSchools();      // 30-day blocking for standard schools

                BindStats();                             // Revenues, KPIs
                BindDashboardChartData();                // Chart hidden fields
                BindSchools();
                BindLearners();
                //BindPremiumSchoolsGrid();
                BindSchoolPayments();
                BindSubscriptionChangeRequests();
                BindPendingPayments();
                BindPaymentSubmissions();

                BindMaterials();
            }
        }

        private void EnsureAuthenticated()
        {
            if (Session["AdminId"] == null)
            {
                Response.Redirect("~/Default.aspx", true);
            }
        }

        private void Toast(string msg, string type = "success")
        {
            ScriptManager.RegisterStartupScript(
                this, GetType(), Guid.NewGuid().ToString(),
                $"showAlert({HttpUtility.JavaScriptStringEncode(msg, true)},{HttpUtility.JavaScriptStringEncode(type, true)});",
                true);
        }

        private void UpdatePaymentsPanelIfPresent()
        {
            var up = FindControl("updPayments") as UpdatePanel;
            if (up != null) up.Update();
        }

        /* ========================= FILE STREAMING (FIX 404) ========================= */

        /// <summary>
        /// Streams a file to the browser. Accepts:
        ///  - Full URL (http/https) -> redirects
        ///  - Virtual path (~/Uploads/...) -> maps and streams
        ///  - Bare filename (payment_123.pdf) -> assumed under defaultVirtualFolder
        /// Falls back to ~/Uploads/Materials if file is not found in default folder.
        /// </summary>
        private void SendFileToClient(string storedPathOrFileName, string defaultVirtualFolder = "~/Uploads/Payments/")
        {
            try
            {
                if (string.IsNullOrWhiteSpace(storedPathOrFileName))
                    throw new FileNotFoundException("No file path provided.");

                // If it's an absolute URL, just redirect
                if (storedPathOrFileName.StartsWith("http", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect(storedPathOrFileName, false);
                    return;
                }

                // Normalize to a virtual path (if caller gave name only, combine with default folder)
                string virtualPath = storedPathOrFileName.StartsWith("~/") || storedPathOrFileName.StartsWith("/")
                    ? VirtualPathUtility.ToAppRelative(storedPathOrFileName)
                    : VirtualPathUtility.ToAppRelative(
                        VirtualPathUtility.Combine(defaultVirtualFolder, storedPathOrFileName));

                // Try exact file
                string physical = Server.MapPath(virtualPath);
                if (!File.Exists(physical))
                {
                    // Fallbacks
                    var tried = new List<string>();

                    tried.Add(physical);

                    // Also try in ~/Uploads (sometimes proofs get saved there)
                    var uploadsTry = Server.MapPath(
                        VirtualPathUtility.Combine("~/Uploads/", Path.GetFileName(storedPathOrFileName)));
                    if (File.Exists(uploadsTry)) physical = uploadsTry;
                    else
                    {
                        tried.Add(uploadsTry);

                        // Try Materials (you already had this)
                        var materialsTry = Server.MapPath(
                            VirtualPathUtility.Combine("~/Uploads/Materials/", Path.GetFileName(storedPathOrFileName)));
                        if (File.Exists(materialsTry)) physical = materialsTry;
                        else
                        {
                            tried.Add(materialsTry);

                            // If the DB had "payment_...pdf" but real file is .jpg/.png/.jpeg/.gif
                            var baseName = Path.GetFileNameWithoutExtension(storedPathOrFileName);
                            var probeFolder = Server.MapPath(defaultVirtualFolder);
                            var candidates = new[] { ".pdf", ".jpg", ".jpeg", ".png", ".gif" }
                                .Select(ext => Path.Combine(probeFolder, baseName + ext))
                                .ToList();

                            string found = candidates.FirstOrDefault(File.Exists);
                            if (found != null) physical = found;
                            else
                            {
                                tried.AddRange(candidates);
                                throw new FileNotFoundException("File not found. Tried:\n" + string.Join("\n", tried));
                            }
                        }
                    }
                }

                // MIME
                var extn = Path.GetExtension(physical)?.ToLowerInvariant() ?? "";
                string mime = "application/octet-stream";
                switch (extn)
                {
                    case ".pdf": mime = "application/pdf"; break;
                    case ".jpg":
                    case ".jpeg": mime = "image/jpeg"; break;
                    case ".png": mime = "image/png"; break;
                    case ".gif": mime = "image/gif"; break;
                    case ".doc": mime = "application/msword"; break;
                    case ".docx": mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"; break;
                    case ".xls": mime = "application/vnd.ms-excel"; break;
                    case ".xlsx": mime = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"; break;
                    case ".csv": mime = "text/csv"; break;
                }

                Response.Clear();
                Response.ContentType = mime;

                var disp = (mime == "application/pdf" || mime.StartsWith("image/", StringComparison.OrdinalIgnoreCase))
                    ? "inline" : "attachment";

                Response.AddHeader("Content-Disposition", $"{disp}; filename=\"{Path.GetFileName(physical)}\"");
                Response.TransmitFile(physical);
                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
                // expected after Response.End
            }
            catch (Exception ex)
            {
                Toast("Unable to open file: " + ex.Message, "error");
            }
        }


        /* ========================= DB SETUP ========================= */

        private void EnsureStandardPaymentsTable()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.StandardPayments') IS NULL
BEGIN
    CREATE TABLE dbo.StandardPayments
    (
        PaymentId       INT IDENTITY(1,1) PRIMARY KEY,
        SchoolCode      NVARCHAR(50)   NOT NULL,
        InvoiceNumber   NVARCHAR(50)   NOT NULL UNIQUE,
        Amount          DECIMAL(18,2)  NULL,
        PaymentMethod   NVARCHAR(50)   NULL,
        PaymentVerified BIT            NOT NULL DEFAULT(0),
        PaymentDate     DATETIME       NULL,
        StartDate       DATETIME       NULL,
        EndDate         DATETIME       NULL,
        FileName        NVARCHAR(400)  NULL
    );
END
", cn))
            {
                cn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        /* ========================= DASHBOARD DATA ========================= */

        private void BindDashboardChartData()
        {
            int premium = 0, standard = 0;
            var js = new JavaScriptSerializer();

            using (var cn = new SqlConnection(ConnectionString))
            {
                cn.Open();

                // Premium vs Standard snapshot (from Schools.IsPremium)
                using (var cmd = new SqlCommand(@"
SELECT
    SUM(CASE WHEN ISNULL(IsPremium,0)=1 THEN 1 ELSE 0 END) AS Premium,
    SUM(CASE WHEN ISNULL(IsPremium,0)=0 THEN 1 ELSE 0 END) AS Standard
FROM dbo.Schools;", cn))
                using (var r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        premium = Convert.ToInt32(r["Premium"]);
                        standard = Convert.ToInt32(r["Standard"]);
                    }
                }

                // Top N schools by Students
                var topN = 12;
                var dtStudents = new DataTable();
                using (var cmd = new SqlCommand(@"
SELECT TOP (@N) sc.SchoolName, sc.SchoolCode, COUNT(st.StudentId) AS Cnt
FROM dbo.Schools sc
LEFT JOIN dbo.Students st ON st.SchoolCode = sc.SchoolCode
GROUP BY sc.SchoolName, sc.SchoolCode
ORDER BY COUNT(st.StudentId) DESC;", cn))
                {
                    cmd.Parameters.AddWithValue("@N", topN);
                    new SqlDataAdapter(cmd).Fill(dtStudents);
                }

                // Teacher counts
                var dtTeachers = new DataTable();
                using (var cmd = new SqlCommand(@"
SELECT sc.SchoolCode, COUNT(t.TeacherID) AS Cnt
FROM dbo.Schools sc
LEFT JOIN dbo.Teachers t ON t.SchoolCode = sc.SchoolCode
GROUP BY sc.SchoolCode;", cn))
                {
                    new SqlDataAdapter(cmd).Fill(dtTeachers);
                }

                var labels = dtStudents.AsEnumerable().Select(r => Convert.ToString(r["SchoolName"])).ToList();
                var codes = dtStudents.AsEnumerable().Select(r => Convert.ToString(r["SchoolCode"])).ToList();
                var studCounts = dtStudents.AsEnumerable().Select(r => Convert.ToInt32(r["Cnt"])).ToList();

                var teacherLookup = dtTeachers.AsEnumerable()
                    .ToDictionary(r => Convert.ToString(r["SchoolCode"]), r => Convert.ToInt32(r["Cnt"]));
                var teachCounts = codes.Select(c => teacherLookup.ContainsKey(c) ? teacherLookup[c] : 0).ToList();

                // Last 12 months
                var start = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1).AddMonths(-11);

                // Premium activations per month (PaymentDate or StartDate)
                var dtPremMonthly = new DataTable();
                using (var cmd = new SqlCommand(@"
SELECT CAST(DATEFROMPARTS(YEAR(COALESCE(PaymentDate, StartDate)),
                          MONTH(COALESCE(PaymentDate, StartDate)), 1) AS date) AS M,
       COUNT(DISTINCT SchoolCode) AS Cnt
FROM dbo.PremiumSubscriptions
WHERE COALESCE(PaymentDate, StartDate) >= @start
  AND ISNULL(PaymentVerified,0)=1
GROUP BY CAST(DATEFROMPARTS(YEAR(COALESCE(PaymentDate, StartDate)),
                            MONTH(COALESCE(PaymentDate, StartDate)), 1) AS date)", cn))
                {
                    cmd.Parameters.AddWithValue("@start", start);
                    new SqlDataAdapter(cmd).Fill(dtPremMonthly);
                }

                var dtSchMonthly = new DataTable();
                using (var cmd = new SqlCommand(@"
SELECT CAST(DATEFROMPARTS(YEAR(RegistrationDate), MONTH(RegistrationDate), 1) AS date) AS M,
       COUNT(*) AS Cnt
FROM dbo.Schools
WHERE RegistrationDate >= @start
GROUP BY CAST(DATEFROMPARTS(YEAR(RegistrationDate), MONTH(RegistrationDate), 1) AS date)", cn))
                {
                    cmd.Parameters.AddWithValue("@start", start);
                    new SqlDataAdapter(cmd).Fill(dtSchMonthly);
                }

                var premDict = dtPremMonthly.AsEnumerable().ToDictionary(
                    r => Convert.ToDateTime(r["M"]).ToString("yyyy-MM"),
                    r => Convert.ToInt32(r["Cnt"])
                );
                var schDict = dtSchMonthly.AsEnumerable().ToDictionary(
                    r => Convert.ToDateTime(r["M"]).ToString("yyyy-MM"),
                    r => Convert.ToInt32(r["Cnt"])
                );

                var monthLabels = Enumerable.Range(0, 12)
                    .Select(i => start.AddMonths(i))
                    .Select(d => d.ToString("MMM yyyy"))
                    .ToList();

                var monthKeys = Enumerable.Range(0, 12)
                    .Select(i => start.AddMonths(i).ToString("yyyy-MM"))
                    .ToList();

                var premiumMonthly = monthKeys.Select(k => premDict.ContainsKey(k) ? premDict[k] : 0).ToList();
                var schoolsMonthly = monthKeys.Select(k => schDict.ContainsKey(k) ? schDict[k] : 0).ToList();

                // Push to hidden fields
                hfPremiumCount.Value = premium.ToString();
                hfStandardCount.Value = standard.ToString();

                var jsSer = new JavaScriptSerializer();
                hfSchoolLabels.Value = jsSer.Serialize(labels);
                hfStudentCounts.Value = jsSer.Serialize(studCounts);
                hfTeacherCounts.Value = jsSer.Serialize(teachCounts);
                hfMonthLabels.Value = jsSer.Serialize(monthLabels);
                hfPremiumMonthly.Value = jsSer.Serialize(premiumMonthly);
                hfSchoolMonthly.Value = jsSer.Serialize(schoolsMonthly);
            }
        }

        private void BindStats()
        {
            using (var cn = new SqlConnection(ConnectionString))
            {
                cn.Open();

                // Initialize revenue to 0
                decimal revenue = 0m;

                // Get all schools and their plan type
                var schoolRevenues = new Dictionary<string, decimal>();

                // Retrieve all the plans and their prices
                var pricingPlans = new Dictionary<string, decimal>();
                using (var cmd = new SqlCommand(@"
SELECT PlanName, Price
FROM dbo.PricingPlans;", cn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string planName = Convert.ToString(reader["PlanName"]);
                            decimal price = Convert.ToDecimal(reader["Price"]);
                            pricingPlans[planName] = price;
                        }
                    }
                }

                // Retrieve all schools and count the number of verified payments (both standard and premium)
                using (var cmd = new SqlCommand(@"
SELECT sc.SchoolCode, sc.IsPremium,
       COUNT(DISTINCT ps.SubmissionId) AS PaymentSubmissionsCount,
       COUNT(DISTINCT sp.PaymentId) AS StandardPaymentsCount
FROM dbo.Schools sc
LEFT JOIN dbo.PaymentSubmissions ps ON ps.SchoolCode = sc.SchoolCode AND ps.Status = 'Approved'  -- Only verified payments
LEFT JOIN dbo.StandardPayments sp ON sp.SchoolCode = sc.SchoolCode AND ISNULL(sp.PaymentVerified, 0) = 1  -- Only verified payments
GROUP BY sc.SchoolCode, sc.IsPremium;", cn))
                {
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string schoolCode = Convert.ToString(reader["SchoolCode"]);
                            bool isPremium = Convert.ToBoolean(reader["IsPremium"]);
                            int paymentSubmissionsCount = Convert.ToInt32(reader["PaymentSubmissionsCount"]);
                            int standardPaymentsCount = Convert.ToInt32(reader["StandardPaymentsCount"]);

                            // Calculate total payments for the school
                            int totalPayments = paymentSubmissionsCount + standardPaymentsCount;

                            // Determine the price based on whether the school is Premium or Standard
                            string planName = isPremium ? "Premium" : "Standard";
                            if (pricingPlans.ContainsKey(planName))
                            {
                                decimal price = pricingPlans[planName];

                                // Calculate revenue for this school and store it in the dictionary
                                schoolRevenues[schoolCode] = totalPayments * price;
                            }
                        }
                    }
                }

                // Sum up the revenue for all schools
                revenue = schoolRevenues.Values.Sum();

                // Display the revenue in the Label
                lblRevenue.Text = "R " + revenue.ToString("N2");

                // Learner Performance (defensive; returns 0 if tables missing)
                double overall = 0.0;
                using (var cn2 = new SqlConnection(ConnectionString))
                {
                    cn2.Open();
                    overall = ComputeAllStudentsOverallAverage(cn2);
                }
                lblLearnerPerformance.Text = overall.ToString("0.0");

                // Premium schools count
                using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.Schools WHERE ISNULL(IsPremium,0)=1;", cn))
                    lblPremiumSchools.Text = Convert.ToString(cmd.ExecuteScalar());

                // Materials count
                using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.Materials') IS NULL SELECT 0
ELSE SELECT COUNT(*) FROM dbo.Materials;", cn))
                    lblMaterials.Text = Convert.ToString(cmd.ExecuteScalar());
            }
        }


        private void BindSchools()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT  sc.SchoolCode,
        sc.SchoolName,
        sc.Email,
        sc.Phone,
        sc.GradeLevel,
        sc.RegistrationDate,
        sc.IsPremium,
        ISNULL(AL.ActiveLearners, 0) AS ActiveLearners
FROM dbo.Schools sc
LEFT JOIN (
    SELECT SchoolCode, COUNT(*) AS ActiveLearners
    FROM dbo.Students
    WHERE ISNULL(IsActive,1)=1
    GROUP BY SchoolCode
) AL ON AL.SchoolCode = sc.SchoolCode
ORDER BY sc.RegistrationDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvSchools.DataSource = dt;
                gvSchools.DataBind();
            }
        }

        private void BindLearners()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT  st.StudentId,
        st.FullName,
        st.Email,
        st.Gender,
        st.Grade,
        st.RegistrationDate,
        ISNULL(st.IsActive,1) AS IsActive,
        sc.SchoolName,
        0 AS MaterialsAccessed
FROM dbo.Students st
LEFT JOIN dbo.Schools sc ON sc.SchoolCode = st.SchoolCode
ORDER BY st.RegistrationDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvLearners.DataSource = dt;
                gvLearners.DataBind();
            }
        }

//        private void BindPremiumSchoolsGrid()
//        {
//            using (var cn = new SqlConnection(ConnectionString))
//            using (var cmd = new SqlCommand(@"
//SELECT  sc.SchoolCode,
//        sc.SchoolName,
//        sc.Email,
//        sc.Phone,
//        sc.GradeLevel,
//        sc.RegistrationDate,
//        ISNULL(sc.IsPremium, 0) AS IsPremium,
//        ps.PaymentMethod,
//        ISNULL(ps.PaymentVerified, 0) AS PaymentVerified,
//        CAST(NULL AS nvarchar(50))  AS ChequeNumber,
//        CAST(NULL AS date)          AS ChequeDate,
//        CAST(NULL AS nvarchar(100)) AS ChequeBank
//FROM dbo.Schools sc
//OUTER APPLY (
//    SELECT TOP 1 p.PaymentMethod, p.PaymentVerified, p.StartDate, p.EndDate, p.PaymentDate, p.InvoiceNumber, p.FileName
//    FROM dbo.PremiumSubscriptions p
//    WHERE p.SchoolCode = sc.SchoolCode AND ISNULL(p.PaymentVerified,0)=1
//    ORDER BY ISNULL(p.PaymentDate, p.StartDate) DESC, p.InvoiceNumber DESC
//) ps
//ORDER BY sc.RegistrationDate DESC;", cn))
//            {
//                var dt = new DataTable();
//                cn.Open();
//                new SqlDataAdapter(cmd).Fill(dt);
//                gvPremiumSchools.DataSource = dt;
//                gvPremiumSchools.DataBind();
//            }
//        }

        private void BindSchoolPayments()
        {
            // Build Premium + Standard union in memory
            var dt = new DataTable();
            dt.Columns.Add("SchoolName", typeof(string));
            dt.Columns.Add("Plan", typeof(string));
            dt.Columns.Add("InvoiceNumber", typeof(string));
            dt.Columns.Add("PaymentDate", typeof(DateTime));
            dt.Columns.Add("StartDate", typeof(DateTime));
            dt.Columns.Add("EndDate", typeof(DateTime));
            dt.Columns.Add("PaymentMethod", typeof(string));
            dt.Columns.Add("ChequeNumber", typeof(string));
            dt.Columns.Add("ChequeBank", typeof(string));
            dt.Columns.Add("PaymentVerified", typeof(bool));
            dt.Columns.Add("FileName", typeof(string));

            using (var cn = new SqlConnection(ConnectionString))
            {
                cn.Open();

                // Premium
                using (var cmd = new SqlCommand(@"
SELECT  sc.SchoolName,
        'Premium' AS [Plan],
        ps.InvoiceNumber,
        ps.PaymentDate,
        ps.StartDate,
        ps.EndDate,
        ps.PaymentMethod,
        CAST(NULL AS nvarchar(50))  AS ChequeNumber,
        CAST(NULL AS nvarchar(100)) AS ChequeBank,
        ISNULL(ps.PaymentVerified, 0) AS PaymentVerified,
        ps.FileName
FROM dbo.PremiumSubscriptions ps
LEFT JOIN dbo.Schools sc ON sc.SchoolCode = ps.SchoolCode;", cn))
                using (var da = new SqlDataAdapter(cmd))
                {
                    var tmp = new DataTable();
                    da.Fill(tmp);
                    foreach (DataRow r in tmp.Rows) dt.Rows.Add(r.ItemArray);
                }

                // Standard
                using (var cmd = new SqlCommand(@"
SELECT  sc.SchoolName,
        'Standard' AS [Plan],
        sp.InvoiceNumber,
        sp.PaymentDate,
        sp.StartDate,
        sp.EndDate,
        sp.PaymentMethod,
        CAST(NULL AS nvarchar(50))  AS ChequeNumber,
        CAST(NULL AS nvarchar(100)) AS ChequeBank,
        ISNULL(sp.PaymentVerified, 0) AS PaymentVerified,
        sp.FileName
FROM dbo.StandardPayments sp
LEFT JOIN dbo.Schools sc ON sc.SchoolCode = sp.SchoolCode;", cn))
                using (var da = new SqlDataAdapter(cmd))
                {
                    var tmp = new DataTable();
                    da.Fill(tmp);
                    foreach (DataRow r in tmp.Rows) dt.Rows.Add(r.ItemArray);
                }
            }

            var ordered = dt.AsEnumerable()
                .OrderByDescending(r => r.Field<DateTime?>("PaymentDate"))
                .ThenByDescending(r => r.Field<string>("InvoiceNumber"));

            gvSchoolPayments.DataSource = (ordered.Any() ? ordered.CopyToDataTable() : dt.Clone());
            gvSchoolPayments.DataBind();
        }

        /* ========================= PENDING PAYMENTS ========================= */

        private void BindPendingPayments()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT s.SubmissionId, sc.SchoolName, s.SchoolCode, s.InvoiceNumber, s.PaymentMethod,
       s.SubmissionDate, s.FileName, s.OriginalFileName,
       ISNULL(s.Status,'Pending') AS Status
FROM dbo.PaymentSubmissions s
JOIN dbo.Schools sc ON sc.SchoolCode = s.SchoolCode
WHERE ISNULL(s.Status,'Pending') = 'Pending'
ORDER BY s.SubmissionDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvPendingPayments.DataSource = dt;
                gvPendingPayments.DataBind();
            }
        }

        private void BindPaymentSubmissions()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT s.SubmissionId, sc.SchoolName, s.SchoolCode, s.InvoiceNumber, s.PaymentMethod,
       s.SubmissionDate, s.FileName, s.OriginalFileName,
       ISNULL(s.Status,'Pending') AS Status
FROM dbo.PaymentSubmissions s
JOIN dbo.Schools sc ON sc.SchoolCode = s.SchoolCode
ORDER BY s.SubmissionDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvPaymentSubmissions.DataSource = dt;
                gvPaymentSubmissions.DataBind();
            }
        }

        protected string GetStatusClass(string status)
        {
            status = (status ?? "").Trim();
            if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase)) return "status-active";
            if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase)) return "status-inactive";
            return "status-pending";
        }

        protected string GetPaymentStatusClass(object verifiedObj, object methodObj)
        {
            bool verified = false;
            if (verifiedObj != DBNull.Value && verifiedObj != null)
                bool.TryParse(Convert.ToString(verifiedObj), out verified);

            return verified ? "status-active" : "status-pending";
        }

        protected string GetPaymentStatusText(object verifiedObj, object methodObj)
        {
            bool verified = false;
            if (verifiedObj != DBNull.Value && verifiedObj != null)
                bool.TryParse(Convert.ToString(verifiedObj), out verified);

            string method = Convert.ToString(methodObj ?? "");
            return verified ? "Verified" : (string.IsNullOrEmpty(method) ? "Unspecified" : $"Awaiting {method} verification");
        }

        /* ========================= GRID EVENTS ========================= */

        protected void gvMaterials_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMaterials.PageIndex = e.NewPageIndex; BindMaterials();
        }
        protected void gvSchools_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvSchools.PageIndex = e.NewPageIndex; BindSchools();
        }
        protected void gvLearners_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvLearners.PageIndex = e.NewPageIndex; BindLearners();
        }
        //protected void gvPremiumSchools_PageIndexChanging(object sender, GridViewPageEventArgs e)
        //{
        //    gvPremiumSchools.PageIndex = e.NewPageIndex; BindPremiumSchoolsGrid();
        //}
        protected void gvSchoolPayments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvSchoolPayments.PageIndex = e.NewPageIndex; BindSchoolPayments();
        }
        protected void gvPendingPayments_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvPendingPayments.PageIndex = e.NewPageIndex; BindPendingPayments(); UpdatePaymentsPanelIfPresent();
        }
        protected void gvPaymentSubmissions_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvPaymentSubmissions.PageIndex = e.NewPageIndex; BindPaymentSubmissions(); UpdatePaymentsPanelIfPresent();
        }

        /* ========================= APPROVE / REJECT ========================= */

        protected void gvPendingPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Approve" && e.CommandName != "Reject") return;

            int submissionId = Convert.ToInt32(e.CommandArgument);
            bool approve = e.CommandName == "Approve";
            ForceApproveReject(submissionId, approve);
        }

        protected void gvPaymentSubmissions_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ViewFile")
            {
                // CHANGED: Stream the file instead of naive redirect
                var file = Convert.ToString(e.CommandArgument);
                SendFileToClient(file, "~/Uploads/Payments/");
            }
            else if (e.CommandName == "VerifyPayment")
            {
                ForceApproveReject(Convert.ToInt32(e.CommandArgument), true);
            }
            else if (e.CommandName == "RejectPayment")
            {
                ForceApproveReject(Convert.ToInt32(e.CommandArgument), false);
            }
        }

        private void ForceApproveReject(int submissionId, bool approve)
        {
            try
            {
                EnsureStandardPaymentsTable();

                using (var cn = new SqlConnection(ConnectionString))
                {
                    cn.Open();
                    var tx = cn.BeginTransaction();

                    try
                    {
                        string schoolCode = null, invoiceNumber = null, fileName = null, paymentMethod = null;
                        bool isPremiumSchool = false;

                        using (var get = new SqlCommand(@"
SELECT s.SchoolCode, s.InvoiceNumber, s.FileName, s.PaymentMethod, sc.IsPremium
FROM dbo.PaymentSubmissions s
JOIN dbo.Schools sc ON sc.SchoolCode = s.SchoolCode
WHERE s.SubmissionId=@id;", cn, tx))
                        {
                            get.Parameters.AddWithValue("@id", submissionId);
                            using (var r = get.ExecuteReader())
                            {
                                if (!r.Read()) throw new Exception("Submission not found.");

                                schoolCode = Convert.ToString(r["SchoolCode"]);
                                invoiceNumber = Convert.ToString(r["InvoiceNumber"]);
                                paymentMethod = r["PaymentMethod"] == DBNull.Value ? "Bank Transfer" : Convert.ToString(r["PaymentMethod"]);
                                fileName = r["FileName"] == DBNull.Value ? null : Convert.ToString(r["FileName"]);
                                isPremiumSchool = Convert.ToBoolean(r["IsPremium"] == DBNull.Value ? false : r["IsPremium"]);
                            }
                        }

                        using (var upd = new SqlCommand(@"
UPDATE dbo.PaymentSubmissions
   SET Status=@st, VerifiedBy=@vb, VerificationDate=GETDATE()
 WHERE SubmissionId=@id;", cn, tx))
                        {
                            upd.Parameters.AddWithValue("@st", approve ? "Approved" : "Rejected");
                            upd.Parameters.AddWithValue("@vb", Convert.ToString(Session["AdminId"] ?? "Admin"));
                            upd.Parameters.AddWithValue("@id", submissionId);
                            upd.ExecuteNonQuery();
                        }

                        if (approve)
                        {
                            if (isPremiumSchool)
                            {
                                using (var upsert = new SqlCommand(@"
IF EXISTS (SELECT 1 FROM dbo.PremiumSubscriptions WHERE InvoiceNumber=@inv)
BEGIN
    UPDATE dbo.PremiumSubscriptions
       SET SchoolCode=@code, PaymentMethod=@method, PaymentVerified=1,
           PaymentDate=GETDATE(), StartDate=ISNULL(StartDate, GETDATE()),
           EndDate=ISNULL(EndDate, DATEADD(MONTH,1,GETDATE())), FileName=@file
     WHERE InvoiceNumber=@inv;
END
 ELSE
BEGIN
    INSERT INTO dbo.PremiumSubscriptions
        (PaymentMethod, PaymentVerified, SchoolCode, StartDate, EndDate, PaymentDate, InvoiceNumber, FileName, Amount)
    VALUES
        (@method, 1, @code, GETDATE(), DATEADD(MONTH,1,GETDATE()), GETDATE(), @inv, @file, 0);
END

UPDATE dbo.Schools SET IsPremium=1 WHERE SchoolCode=@code;", cn, tx))
                                {
                                    upsert.Parameters.AddWithValue("@inv", invoiceNumber);
                                    upsert.Parameters.AddWithValue("@code", schoolCode);
                                    upsert.Parameters.AddWithValue("@method", paymentMethod);
                                    upsert.Parameters.AddWithValue("@file", (object)fileName ?? DBNull.Value);
                                    upsert.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                using (var upsert = new SqlCommand(@"
IF EXISTS (SELECT 1 FROM dbo.StandardPayments WHERE InvoiceNumber=@inv)
BEGIN
    UPDATE dbo.StandardPayments
       SET SchoolCode=@code, PaymentMethod=@method, PaymentVerified=1,
           PaymentDate=GETDATE(), StartDate=ISNULL(StartDate, GETDATE()),
           EndDate=ISNULL(EndDate, DATEADD(MONTH,1,GETDATE())), FileName=@file
     WHERE InvoiceNumber=@inv;
END
 ELSE
BEGIN
    INSERT INTO dbo.StandardPayments
        (SchoolCode, InvoiceNumber, PaymentMethod, PaymentVerified, PaymentDate, StartDate, EndDate, FileName, Amount)
    VALUES
        (@code, @inv, @method, 1, GETDATE(), GETDATE(), DATEADD(MONTH,1,GETDATE()), @file, 0);
END

-- Unblock standard-school users
IF COL_LENGTH('dbo.Students','IsActive') IS NOT NULL
   UPDATE dbo.Students SET IsActive=1 WHERE SchoolCode=@code;
IF COL_LENGTH('dbo.Teachers','IsActive') IS NOT NULL
   UPDATE dbo.Teachers SET IsActive=1 WHERE SchoolCode=@code;", cn, tx))
                                {
                                    upsert.Parameters.AddWithValue("@inv", invoiceNumber);
                                    upsert.Parameters.AddWithValue("@code", schoolCode);
                                    upsert.Parameters.AddWithValue("@method", paymentMethod);
                                    upsert.Parameters.AddWithValue("@file", (object)fileName ?? DBNull.Value);
                                    upsert.ExecuteNonQuery();
                                }
                            }
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }

                // Refresh UI
                BindPendingPayments();
                BindPaymentSubmissions();
                //BindPremiumSchoolsGrid();
                BindSchoolPayments();
                UpdatePaymentsPanelIfPresent();

                Toast(approve ? "Payment approved." : "Payment rejected.");
            }
            catch (Exception ex)
            {
                Toast("Error processing payment: " + ex.Message, "error");
            }
        }

        /* ========================= CHEQUE PROCESSING ========================= */

        

        private void BindMaterials()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.Materials') IS NULL
    SELECT TOP 0 1 AS Dummy
ELSE
    SELECT TOP 20
        Title,
        MaterialType AS [Type],
        Subject,
        Grade,
        UploadDate
    FROM dbo.Materials
    ORDER BY UploadDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                if (dt.Columns.Contains("Dummy"))
                {
                    gvMaterials.DataSource = null;
                    gvMaterials.DataBind();
                }
                else
                {
                    gvMaterials.DataSource = dt;
                    gvMaterials.DataBind();
                }
            }
        }

        protected void btnUploadMaterial_Click(object sender, EventArgs e)
        {
            try
            {
                if (!fileMaterial.HasFile) { Toast("Please choose a file to upload.", "info"); return; }

                // Save file under a web-accessible folder (NOT App_Data)
                var root = Server.MapPath("~/Uploads/Materials");
                Directory.CreateDirectory(root);

                var originalName = Path.GetFileName(fileMaterial.FileName);
                var ext = Path.GetExtension(originalName) ?? "";
                var safeName = $"{Path.GetFileNameWithoutExtension(originalName)}_{DateTime.UtcNow:yyyyMMddHHmmssfff}{ext}";
                var savedPath = Path.Combine(root, safeName);
                fileMaterial.SaveAs(savedPath);

                var relPath = "~/Uploads/Materials/" + safeName;

                using (var cn = new SqlConnection(ConnectionString))
                using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.Materials') IS NOT NULL
BEGIN
    INSERT INTO dbo.Materials
        (Title, MaterialType, Subject, Grade, [Description],
         FileName, OriginalFileName, UploadDate, UploadedBy, FileSize, FileType,
         DownloadCount, IsActive)
    VALUES
        (@title, @type, @subject, @grade, @desc,
         @fileName, @origName, GETDATE(), @uploadedBy, @size, @mime,
         0, 1);
END", cn))
                {
                    cmd.Parameters.AddWithValue("@title", (txtMaterialTitle.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@type", (ddlMaterialType.SelectedValue ?? "").Trim());
                    cmd.Parameters.AddWithValue("@subject", (ddlSubject.SelectedValue ?? "").Trim());
                    cmd.Parameters.AddWithValue("@grade", (ddlGrade.SelectedValue ?? "").Trim());
                    cmd.Parameters.AddWithValue("@desc", (txtMaterialDescription.Text ?? "").Trim());
                    cmd.Parameters.AddWithValue("@fileName", relPath);
                    cmd.Parameters.AddWithValue("@origName", originalName);
                    cmd.Parameters.AddWithValue("@uploadedBy", Convert.ToString(Session["AdminId"] ?? "Admin"));
                    cmd.Parameters.AddWithValue("@size", fileMaterial.PostedFile.ContentLength);
                    cmd.Parameters.AddWithValue("@mime", (object)fileMaterial.PostedFile.ContentType ?? DBNull.Value);

                    cn.Open();
                    cmd.ExecuteNonQuery();
                }

                BindMaterials();
                Toast("Material uploaded.", "success");
            }
            catch (Exception ex) { Toast("Upload failed: " + ex.Message, "error"); }
        }

        /* ========================= PERFORMANCE ========================= */

        private double ComputeAllStudentsOverallAverage(SqlConnection cnOpen)
        {
            decimal quizSumPct = 0m; int quizCnt = 0;
            using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.QuizResults') IS NOT NULL
BEGIN
    SELECT
        SUM(CAST(ISNULL(Score,0) AS decimal(18,6))) AS SumPct,
        COUNT(Score) AS Cnt
    FROM dbo.QuizResults;
END
ELSE
BEGIN
    SELECT CAST(0 AS decimal(18,6)) AS SumPct, CAST(0 AS int) AS Cnt;
END", cnOpen))
            using (var r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    if (r["SumPct"] != DBNull.Value) quizSumPct = Convert.ToDecimal(r["SumPct"]);
                    if (r["Cnt"] != DBNull.Value) quizCnt = Convert.ToInt32(r["Cnt"]);
                }
            }

            decimal assignSumPct = 0m; int assignCnt = 0;
            using (var cmd = new SqlCommand(@"
IF OBJECT_ID('dbo.AssignmentMarks') IS NOT NULL
BEGIN
    SELECT
        SUM(CASE WHEN ISNULL(TotalMarks,0) > 0 AND Score IS NOT NULL
                 THEN (CAST(Score AS decimal(18,6)) / NULLIF(CAST(TotalMarks AS decimal(18,6)),0)) * 100
                 ELSE 0 END) AS SumPct,
        SUM(CASE WHEN ISNULL(TotalMarks,0) > 0 AND Score IS NOT NULL THEN 1 ELSE 0 END) AS Cnt
    FROM dbo.AssignmentMarks;
END
ELSE
BEGIN
    SELECT CAST(0 AS decimal(18,6)) AS SumPct, CAST(0 AS int) AS Cnt;
END", cnOpen))
            using (var r = cmd.ExecuteReader())
            {
                if (r.Read())
                {
                    if (r["SumPct"] != DBNull.Value) assignSumPct = Convert.ToDecimal(r["SumPct"]);
                    if (r["Cnt"] != DBNull.Value) assignCnt = Convert.ToInt32(r["Cnt"]);
                }
            }

            var totalCnt = quizCnt + assignCnt;
            if (totalCnt <= 0) return 0.0;

            var avg = (quizSumPct + assignSumPct) / totalCnt;
            return Convert.ToDouble(avg);
        }

        /* ========================= BLOCKING (30 days) ========================= */

        private void UpdateBlockingForStandardSchools()
        {
            // Uses temp tables + IF COL_LENGTH checks (safe if IsActive columns are missing)
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
IF OBJECT_ID('tempdb..#ToBlock') IS NOT NULL DROP TABLE #ToBlock;
IF OBJECT_ID('tempdb..#ToUnblock') IS NOT NULL DROP TABLE #ToUnblock;

CREATE TABLE #ToBlock(SchoolCode NVARCHAR(50) PRIMARY KEY);
CREATE TABLE #ToUnblock(SchoolCode NVARCHAR(50) PRIMARY KEY);

;WITH LastStd AS (
    SELECT sp.SchoolCode, MAX(COALESCE(sp.PaymentDate, sp.StartDate)) AS LastPaid
    FROM dbo.StandardPayments sp
    WHERE ISNULL(sp.PaymentVerified,0)=1
    GROUP BY sp.SchoolCode
)
INSERT INTO #ToBlock(SchoolCode)
SELECT sc.SchoolCode
FROM dbo.Schools sc
LEFT JOIN LastStd ls ON ls.SchoolCode = sc.SchoolCode
WHERE ISNULL(sc.IsPremium,0)=0
  AND (ls.LastPaid IS NULL OR DATEDIFF(DAY, ls.LastPaid, GETDATE()) > 30);

;WITH LastStd2 AS (
    SELECT sp.SchoolCode, MAX(COALESCE(sp.PaymentDate, sp.StartDate)) AS LastPaid
    FROM dbo.StandardPayments sp
    WHERE ISNULL(sp.PaymentVerified,0)=1
    GROUP BY sp.SchoolCode
)
INSERT INTO #ToUnblock(SchoolCode)
SELECT sc.SchoolCode
FROM dbo.Schools sc
LEFT JOIN LastStd2 ls ON ls.SchoolCode = sc.SchoolCode
WHERE ISNULL(sc.IsPremium,0)=0
  AND ls.LastPaid IS NOT NULL
  AND DATEDIFF(DAY, ls.LastPaid, GETDATE()) <= 30;

IF COL_LENGTH('dbo.Students','IsActive') IS NOT NULL
BEGIN
    UPDATE st SET IsActive = 0
      FROM dbo.Students st
     WHERE st.SchoolCode IN (SELECT SchoolCode FROM #ToBlock)
       AND ISNULL(st.IsActive,1) <> 0;

    UPDATE st SET IsActive = 1
      FROM dbo.Students st
     WHERE st.SchoolCode IN (SELECT SchoolCode FROM #ToUnblock)
       AND ISNULL(st.IsActive,0) <> 1;
END

IF COL_LENGTH('dbo.Teachers','IsActive') IS NOT NULL
BEGIN
    UPDATE t SET IsActive = 0
      FROM dbo.Teachers t
     WHERE t.SchoolCode IN (SELECT SchoolCode FROM #ToBlock)
       AND ISNULL(t.IsActive,1) <> 0;

    UPDATE t SET IsActive = 1
      FROM dbo.Teachers t
     WHERE t.SchoolCode IN (SELECT SchoolCode FROM #ToUnblock)
       AND ISNULL(t.IsActive,0) <> 1;
END
", cn))
            {
                cn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        /* ========================= EXPORT (EXCEL) ========================= */

        // Use this HTML writer to render grids without paging
        private void RenderGridToHtml(HtmlTextWriter hw, string title, GridView grid)
        {
            hw.Write($"<h3 style='margin:16px 0 6px 0;font-family:Segoe UI, Arial'>{HttpUtility.HtmlEncode(title)}</h3>");

            if (grid == null) { hw.Write("<div>No data</div>"); return; }

            bool oldAllowPaging = grid.AllowPaging;
            int oldPageSize = grid.PageSize;
            int oldPageIndex = grid.PageIndex;

            grid.AllowPaging = false;

            // Bind full sets
            if (grid == gvSchools) BindSchools();
            else if (grid == gvLearners) BindLearners();
            //else if (grid == gvPremiumSchools) BindPremiumSchoolsGrid();
            else if (grid == gvSchoolPayments) BindSchoolPayments();

            grid.RenderControl(hw);

            // Restore
            grid.AllowPaging = oldAllowPaging;
            grid.PageSize = oldPageSize;
            grid.PageIndex = oldPageIndex;

            if (grid == gvSchools) BindSchools();
            else if (grid == gvLearners) BindLearners();
            //else if (grid == gvPremiumSchools) BindPremiumSchoolsGrid();
            else if (grid == gvSchoolPayments) BindSchoolPayments();
        }

        private static List<string> SafeDeserialize(JavaScriptSerializer js, string json)
        {
            try { return js.Deserialize<List<string>>(string.IsNullOrWhiteSpace(json) ? "[]" : json) ?? new List<string>(); }
            catch { return new List<string>(); }
        }
        private static List<int> SafeDeserializeInt(JavaScriptSerializer js, string json)
        {
            try { return js.Deserialize<List<int>>(string.IsNullOrWhiteSpace(json) ? "[]" : json) ?? new List<int>(); }
            catch { return new List<int>(); }
        }

        protected void btnExportExcel_Click(object sender, EventArgs e)
        {
            try
            {
                var js = new JavaScriptSerializer();

                var monthLabels = SafeDeserialize(js, hfMonthLabels.Value);
                var premiumMonthly = SafeDeserializeInt(js, hfPremiumMonthly.Value);
                var schoolsMonthly = SafeDeserializeInt(js, hfSchoolMonthly.Value);

                var schoolLabels = SafeDeserialize(js, hfSchoolLabels.Value);
                var studentCounts = SafeDeserializeInt(js, hfStudentCounts.Value);
                var teacherCounts = SafeDeserializeInt(js, hfTeacherCounts.Value);

                Response.Clear();
                Response.Buffer = true;
                Response.ContentType = "application/vnd.ms-excel";
                var fileName = "Edugate_Dashboard_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".xls";
                Response.AddHeader("Content-Disposition", "attachment;filename=" + fileName);
                Response.Charset = "";
                Response.ContentEncoding = System.Text.Encoding.UTF8;

                using (var sw = new StringWriter())
                using (var hw = new HtmlTextWriter(sw))
                {
                    hw.Write("<html><head><meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>");
                    hw.Write("<style>");
                    hw.Write("body{font-family:Segoe UI,Arial;}");
                    hw.Write("table{border-collapse:collapse;margin:8px 0;} th,td{border:1px solid #999;padding:6px 8px;} th{background:#f0f0f0;}");
                    hw.Write("</style></head><body>");

                    // Header
                    hw.Write("<h2>Edugate STEM — Admin Dashboard (Export)</h2>");
                    hw.Write("<div>Generated: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm") + "</div>");
                    hw.Write("<div>Admin: " + HttpUtility.HtmlEncode(lblAdminName.Text) + "</div><br/>");

                    // KPIs
                    hw.Write("<h3>Overview</h3>");
                    hw.Write("<table>");
                    hw.Write("<tr><th>Revenue</th><td>" + HttpUtility.HtmlEncode(lblRevenue.Text) + "</td></tr>");
                    hw.Write("<tr><th>Learner Performance</th><td>" + HttpUtility.HtmlEncode(lblLearnerPerformance.Text) + "%</td></tr>");
                    hw.Write("<tr><th>Premium Schools</th><td>" + HttpUtility.HtmlEncode(lblPremiumSchools.Text) + "</td></tr>");
                    hw.Write("<tr><th>Study Materials</th><td>" + HttpUtility.HtmlEncode(lblMaterials.Text) + "</td></tr>");
                    hw.Write("</table>");

                    // Monthly metrics
                    hw.Write("<h3>Monthly metrics</h3>");
                    hw.Write("<table><tr><th>Month</th><th>Premium activations</th><th>School registrations</th></tr>");
                    for (int i = 0; i < monthLabels.Count; i++)
                    {
                        var m = monthLabels[i];
                        var p = i < premiumMonthly.Count ? premiumMonthly[i] : 0;
                        var s = i < schoolsMonthly.Count ? schoolsMonthly[i] : 0;
                        hw.Write("<tr><td>" + HttpUtility.HtmlEncode(m) + "</td><td>" + p + "</td><td>" + s + "</td></tr>");
                    }
                    hw.Write("</table>");

                    // Top schools
                    hw.Write("<h3>Top schools (counts)</h3>");
                    hw.Write("<table><tr><th>School</th><th>Students</th><th>Teachers</th></tr>");
                    for (int i = 0; i < schoolLabels.Count; i++)
                    {
                        var name = i < schoolLabels.Count ? schoolLabels[i] : "";
                        var st = i < studentCounts.Count ? studentCounts[i] : 0;
                        var te = i < teacherCounts.Count ? teacherCounts[i] : 0;
                        hw.Write("<tr><td>" + HttpUtility.HtmlEncode(name) + "</td><td>" + st + "</td><td>" + te + "</td></tr>");
                    }
                    hw.Write("</table>");

                    // Full report tables
                    RenderGridToHtml(hw, "Schools", gvSchools);
                    RenderGridToHtml(hw, "Learners", gvLearners);
                    //RenderGridToHtml(hw, "Premium Status", gvPremiumSchools);
                    RenderGridToHtml(hw, "Payments", gvSchoolPayments);

                    hw.Write("</body></html>");

                    Response.Write(sw.ToString());
                    Response.Flush();
                    Response.End();
                }
            }
            catch (System.Threading.ThreadAbortException)
            {
                // Expected due to Response.End
            }
            catch (Exception ex)
            {
                Toast("Excel export failed: " + ex.Message, "error");
            }
        }
        protected void gvSubscriptionRequests_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Approve" || e.CommandName == "Reject")
            {
                int requestId = Convert.ToInt32(e.CommandArgument); 
                bool approve = e.CommandName == "Approve";  
                HandleSubscriptionChangeRequest(requestId, approve); 
            }
        }

        private void BindSubscriptionChangeRequests()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
        SELECT RequestId, SchoolCode, IsPremium, RequestDate, Status
        FROM dbo.SubscriptionChangeRequests
        WHERE Status = 'Pending'
        ORDER BY RequestDate DESC;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvSubscriptionRequests.DataSource = dt;
                gvSubscriptionRequests.DataBind();
            }
        }

        private void HandleSubscriptionChangeRequest(int requestId, bool approve)
        {
            try
            {
                using (var cn = new SqlConnection(ConnectionString))
                {
                    cn.Open();
                    var tx = cn.BeginTransaction();

                    string schoolCode = null;
                    bool isPremium = false;

                    // Retrieve request details
                    using (var cmd = new SqlCommand(@"
                SELECT SchoolCode, IsPremium
                FROM dbo.SubscriptionChangeRequests
                WHERE RequestId = @RequestId", cn, tx))
                    {
                        cmd.Parameters.AddWithValue("@RequestId", requestId);
                        using (var reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                schoolCode = reader["SchoolCode"].ToString();
                                isPremium = Convert.ToBoolean(reader["IsPremium"]);
                            }
                            else
                            {
                                throw new Exception("Request not found.");
                            }
                        }
                    }

                    // Update the subscription status based on approval
                    using (var cmd = new SqlCommand(@"
                UPDATE dbo.Schools
                SET IsPremium = @IsPremium
                WHERE SchoolCode = @SchoolCode", cn, tx))
                    {
                        cmd.Parameters.AddWithValue("@IsPremium", isPremium);
                        cmd.Parameters.AddWithValue("@SchoolCode", schoolCode);
                        cmd.ExecuteNonQuery();
                    }

                    // Update the request status to Approved or Rejected
                    using (var cmd = new SqlCommand(@"
                UPDATE dbo.SubscriptionChangeRequests
                SET Status = @Status
                WHERE RequestId = @RequestId", cn, tx))
                    {
                        cmd.Parameters.AddWithValue("@Status", approve ? "Approved" : "Rejected");
                        cmd.Parameters.AddWithValue("@RequestId", requestId);
                        cmd.ExecuteNonQuery();
                    }

                    // Commit the transaction
                    tx.Commit();

                    // Refresh UI and show success message
                    BindSubscriptionChangeRequests();
                    Toast(approve ? "Subscription change approved." : "Subscription change rejected.", "success");
                }
            }
            catch (Exception ex)
            {
                Toast("Error processing the request: " + ex.Message, "error");
            }
        }

        // Satisfy GridView OnRowCommand in your markup
        protected void gvSchoolPayments_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Placeholder for future commands (kept to avoid compile errors)
            // Example:
            // if (e.CommandName == "DownloadProof")
            // {
            //     var rel = Convert.ToString(e.CommandArgument);
            //     SendFileToClient(rel, "~/Uploads/Payments/");
            // }
        }
    }
}
