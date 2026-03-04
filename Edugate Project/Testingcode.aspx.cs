using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.Script.Serialization;

namespace Edugate_Project
{
    public partial class Testingcode : Page
    {
        // Exposed to .aspx for charts
        public string threatSummaryJson { get; set; }
        public string threatsByVirusJson { get; set; }

        // In-memory data for demo; replace with repo/EF/ADO calls
        private static List<ThreatRecord> _allThreats;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Wire events (since OnClick is not set in markup)
            btnSearch.Click += BtnSearch_Click;

            if (!IsPostBack)
            {
                // 1) Load or fetch your data
                _allThreats = SeedThreats();

                // 2) Bind dashboard
                BindUser();
                BindKPIs(_allThreats);
                BindCharts(_allThreats);
                BindTable(_allThreats);
            }
        }

        private void BtnSearch_Click(object sender, EventArgs e)
        {
            var q = (txtSearch.Text ?? string.Empty).Trim().ToLowerInvariant();

            var filtered = string.IsNullOrWhiteSpace(q)
                ? _allThreats
                : _allThreats.Where(t =>
                        (t.DeviceId ?? "").ToLower().Contains(q) ||
                        (t.VirusName ?? "").ToLower().Contains(q) ||
                        (t.FilePath ?? "").ToLower().Contains(q))
                    .ToList();

            // Rebind just the table and (optionally) KPIs/charts for filtered scope
            BindTable(filtered);
            BindKPIs(filtered);
            BindCharts(filtered);
        }

        private void BindUser()
        {
            // Replace with your auth/user context
            lblUserName.Text = "Kathryn Murphy";
        }

        private void BindKPIs(List<ThreatRecord> data)
        {
            // Example KPI calculations (replace with your logic)
            int totalThreats = data.Count;
            lblTotalThreats.Text = $"{totalThreats}";

            // “Risk” percentages here are illustrative
            double videoRisk = PercentOf(data, r => r.FileType.Equals("Video", StringComparison.OrdinalIgnoreCase));
            lblVideoRisk.Text = $"{videoRisk:0}%";

            // Risk score demo: scale 0–1000 by severity counts
            int sevHigh = data.Count(t => t.Severity == Severity.High);
            int sevMed = data.Count(t => t.Severity == Severity.Medium);
            int computedScore = Math.Max(0, Math.Min(1000, 400 + sevHigh * 40 + sevMed * 20));
            lblRiskScore.Text = computedScore.ToString();
        }

        private void BindCharts(List<ThreatRecord> data)
        {
            // Threat Summary (monthly line)
            var months = Enumerable.Range(1, 12).ToArray();
            var series = months.Select(m => data.Count(d => d.Date.Month == m)).ToArray();

            var summary = new
            {
                labels = new[] { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" },
                datasets = new object[]
                {
                    new {
                        label = "Threats",
                        data = series,
                        tension = 0.35,
                        fill = false,
                        borderWidth = 3,
                        borderColor = "rgba(140,115,255,1)",
                        pointRadius = 0
                    }
                }
            };

            // Threats by Virus (donut)
            var virusGroups = data
                .GroupBy(d => d.VirusName)
                .OrderByDescending(g => g.Count())
                .Take(6)
                .ToList();

            var donut = new
            {
                labels = virusGroups.Select(g => g.Key).ToArray(),
                datasets = new object[]
                {
                    new {
                        data = virusGroups.Select(g => g.Count()).ToArray()
                    }
                }
            };

            var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
            threatSummaryJson = serializer.Serialize(summary);
            threatsByVirusJson = serializer.Serialize(donut);
        }

        private void BindTable(List<ThreatRecord> data)
        {
            gvThreatDetails.DataSource = data
                .OrderByDescending(r => r.Date)
                .ToList();
            gvThreatDetails.DataBind();
        }

        // ----- Helpers -----

        private static double PercentOf(List<ThreatRecord> data, Func<ThreatRecord, bool> predicate)
        {
            if (data == null || data.Count == 0) return 0;
            double count = data.Count(predicate);
            return Math.Round((count / data.Count) * 100.0, 0);
        }

        private static List<ThreatRecord> SeedThreats()
        {
            // Demo data that resembles the UI—swap with DB results
            var now = DateTime.UtcNow.Date;
            var rand = new Random(42);
            var viruses = new[] { "ECRYPTOV", "WANNACRY", "TRICKBOT", "KOVTER", "DRIDEX", "QBOT" };
            var devices = new[] { "crazyfla928", "desktop-220", "engvm-372", "mbp-ops-12", "srv-files-03" };
            var types = new[] { "Image", "Video", "Document", "Executable", "Archive" };

            var list = new List<ThreatRecord>();
            // Create a few months of randomized records
            for (int i = 0; i < 160; i++)
            {
                var daysAgo = rand.Next(0, 180);
                var dt = now.AddDays(-daysAgo);
                var virus = viruses[rand.Next(viruses.Length)];
                var dev = devices[rand.Next(devices.Length)];
                var ftype = types[rand.Next(types.Length)];
                var sev = (Severity)rand.Next(0, 3);

                list.Add(new ThreatRecord
                {
                    Date = dt,
                    DeviceId = dev,
                    VirusName = virus,
                    FilePath = $@"C:\Users\{dev}\Downloads\file_{1000 + i}.{ExtFor(ftype)}",
                    FileType = ftype,
                    Severity = sev
                });
            }

            // A couple of deterministic examples matching the screenshot labels
            list.Add(new ThreatRecord { Date = now.AddDays(-2), DeviceId = "engvm-372", VirusName = "ECRYPTOV", FilePath = @"C:\work\vm\payload.bin", FileType = "Executable", Severity = Severity.High });
            list.Add(new ThreatRecord { Date = now.AddDays(-12), DeviceId = "desktop-220", VirusName = "TRICKBOT", FilePath = @"C:\Users\Public\Pictures\thumb.jpg", FileType = "Image", Severity = Severity.Medium });

            return list;
        }

        private static string ExtFor(string fileType)
        {
            switch ((fileType ?? "").ToLowerInvariant())
            {
                case "image": return "jpg";
                case "video": return "mp4";
                case "document": return "pdf";
                case "executable": return "exe";
                case "archive": return "zip";
                default: return "dat";
            }
        }

        // ----- Data model -----
        private class ThreatRecord
        {
            public DateTime Date { get; set; }
            public string DeviceId { get; set; }
            public string VirusName { get; set; }
            public string FilePath { get; set; }
            public string FileType { get; set; }
            public Severity Severity { get; set; }
        }

        private enum Severity
        {
            Low = 0,
            Medium = 1,
            High = 2
        }
    }
}
