using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

// Add this namespace if you are using data tables or similar structures
using System.Data;

namespace Edugate_Project
{
    public partial class Research : System.Web.UI.Page
    {
        // Dummy data for demonstration. In a real application, this would come from a database.
        private List<ResearchOpportunity> _allResearchOpportunities;
        private int PageSize = 6; // Number of items per page
        protected int CurrentPage // Property to keep track of the current page
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitializeResearchData(); // Initialize data only on the first load
                BindResearchRepeater();
            }
        }

        private void InitializeResearchData()
        {
            _allResearchOpportunities = new List<ResearchOpportunity>
            {
                new ResearchOpportunity { Id = 1, Title = "AI for Climate Change", Institution = "Tech University", Field = "Artificial Intelligence", Type = "Summer Research", Duration = "8 Weeks", Location = "Online", Deadline = DateTime.Parse("2025-08-15"), Description = "Join a team researching AI applications to model and mitigate climate change effects.", ApplicationUrl = "https://example.com/ai-climate" },
                new ResearchOpportunity { Id = 2, Title = "Genomic Sequencing Internship", Institution = "Bio Research Institute", Field = "Biotechnology", Type = "Paid Internship", Duration = "12 Weeks", Location = "On-site", Deadline = DateTime.Parse("2025-09-01"), Description = "A paid internship focusing on advanced genomic sequencing techniques.", ApplicationUrl = "https://example.com/genomic-intern" },
                new ResearchOpportunity { Id = 3, Title = "Quantum Computing Algorithms", Institution = "Physics Lab", Field = "Quantum Computing", Type = "Academic Year", Duration = "1 Year", Location = "On-site", Deadline = DateTime.Parse("2025-10-01"), Description = "Long-term research on developing new algorithms for quantum computers.", ApplicationUrl = "https://example.com/quantum-algos" },
                new ResearchOpportunity { Id = 4, Title = "Sustainable Agriculture Practices", Institution = "Agri-Tech Solutions", Field = "Environmental Science", Type = "Volunteer", Duration = "6 Months", Location = "Field-based", Deadline = DateTime.Parse("2025-07-20"), Description = "Volunteer opportunity to research and implement sustainable farming methods.", ApplicationUrl = "https://example.com/agri-sustain" },
                new ResearchOpportunity { Id = 5, Title = "Machine Learning in Healthcare", Institution = "Med-AI Hub", Field = "Artificial Intelligence", Type = "Summer Research", Duration = "10 Weeks", Location = "Hybrid", Deadline = DateTime.Parse("2025-08-10"), Description = "Explore the use of machine learning models for disease diagnosis.", ApplicationUrl = "https://example.com/ml-healthcare" },
                new ResearchOpportunity { Id = 6, Title = "Big Data Analytics in Finance", Institution = "FinTech Innovations", Field = "Data Science", Type = "Paid Internship", Duration = "3 Months", Location = "Remote", Deadline = DateTime.Parse("2025-09-15"), Description = "Analyze large financial datasets to identify market trends.", ApplicationUrl = "https://example.com/fintech-data" },
                new ResearchOpportunity { Id = 7, Title = "Neuroplasticity Studies", Institution = "Brain & Cognition Center", Field = "Neuroscience", Type = "Academic Year", Duration = "9 Months", Location = "On-site", Deadline = DateTime.Parse("2025-11-01"), Description = "Research on the brain's ability to change and adapt.", ApplicationUrl = "https://example.com/neuro-studies" },
                new ResearchOpportunity { Id = 8, Title = "Renewable Energy Grid Optimization", Institution = "Green Power Corp", Field = "Renewable Energy", Type = "Summer Research", Duration = "8 Weeks", Location = "On-site", Deadline = DateTime.Parse("2025-08-25"), Description = "Optimize energy distribution in renewable power grids.", ApplicationUrl = "https://example.com/green-energy" },
                new ResearchOpportunity { Id = 9, Title = "Cybersecurity Threat Detection", Institution = "InfoSec Lab", Field = "Computer Science", Type = "Paid Internship", Duration = "6 Months", Location = "On-site", Deadline = DateTime.Parse("2025-10-05"), Description = "Develop algorithms for detecting and preventing cyber threats.", ApplicationUrl = "https://example.com/cybersecurity" },
                new ResearchOpportunity { Id = 10, Title = "Drug Discovery with AI", Institution = "Pharma Innovations", Field = "Biotechnology", Type = "Academic Year", Duration = "1 Year", Location = "Hybrid", Deadline = DateTime.Parse("2025-12-01"), Description = "Using AI to accelerate the discovery of new pharmaceutical drugs.", ApplicationUrl = "https://example.com/drug-discovery" }
            };

            // Store in session or ViewState if you need to persist it across postbacks
            // or if the data doesn't come from a constant source.
            Session["AllResearchOpportunities"] = _allResearchOpportunities;
        }

        private void BindResearchRepeater()
        {
            if (Session["AllResearchOpportunities"] == null)
            {
                InitializeResearchData(); // Re-initialize if for some reason it's lost (e.g., session timeout)
            }

            List<ResearchOpportunity> filteredOpportunities = (List<ResearchOpportunity>)Session["AllResearchOpportunities"];

            // Apply filters
            string selectedField = ddlField.SelectedValue;
            string selectedType = ddlType.SelectedValue;
            string selectedDeadline = ddlDeadline.SelectedValue;

            if (!string.IsNullOrEmpty(selectedField))
            {
                filteredOpportunities = filteredOpportunities.Where(r => r.Field == selectedField).ToList();
            }

            if (!string.IsNullOrEmpty(selectedType))
            {
                filteredOpportunities = filteredOpportunities.Where(r => r.Type == selectedType).ToList();
            }

            if (!string.IsNullOrEmpty(selectedDeadline))
            {
                if (selectedDeadline.ToLower() == "rolling")
                {
                    // Assuming "rolling" means no specific fixed deadline, or a very far future date
                    // For demo, we might just include all if 'rolling' is picked, or filter for very far dates
                    // For a real app, you'd need a clear definition of "rolling" in your data.
                }
                else
                {
                    int days = int.Parse(selectedDeadline);
                    DateTime cutoffDate = DateTime.Now.AddDays(days);
                    filteredOpportunities = filteredOpportunities.Where(r => r.Deadline.HasValue && r.Deadline.Value <= cutoffDate).ToList();
                }
            }

            // Handle no results visibility
            pnlNoResults.Visible = filteredOpportunities.Count == 0;

            // Pagination logic
            int totalRecords = filteredOpportunities.Count;
            int totalPages = (int)Math.Ceiling((double)totalRecords / PageSize);

            // Ensure CurrentPage is within bounds
            if (CurrentPage > totalPages && totalPages > 0)
            {
                CurrentPage = totalPages;
            }
            else if (CurrentPage <= 0 && totalPages > 0)
            {
                CurrentPage = 1;
            }
            else if (totalPages == 0) // No results, so no pages
            {
                CurrentPage = 1;
            }

            // Get the subset of data for the current page
            List<ResearchOpportunity> pagedOpportunities = filteredOpportunities
                .Skip((CurrentPage - 1) * PageSize)
                .Take(PageSize)
                .ToList();

            rptResearch.DataSource = pagedOpportunities;
            rptResearch.DataBind();

            SetupPagination(totalPages);
        }

        private void SetupPagination(int totalPages)
        {
            if (totalPages <= 1)
            {
                paginationContainer.Visible = false;
                return;
            }

            paginationContainer.Visible = true;
            btnPrev.Enabled = CurrentPage > 1;
            btnNext.Enabled = CurrentPage < totalPages;

            List<int> pageNumbers = new List<int>();
            for (int i = 1; i <= totalPages; i++)
            {
                pageNumbers.Add(i);
            }
            rptPageNumbers.DataSource = pageNumbers;
            rptPageNumbers.DataBind();
        }

        // >>>>>>>>>>>>>>> THIS IS THE MISSING/INCORRECT METHOD <<<<<<<<<<<<<<<<<
        protected void FilterResearch(object sender, EventArgs e)
        {
            // When a filter (dropdown) changes, reset to the first page and rebind
            CurrentPage = 1;
            BindResearchRepeater();
        }

        protected void PageChange(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string commandArg = btn.CommandArgument;

            if (commandArg == "prev")
            {
                CurrentPage--;
            }
            else if (commandArg == "next")
            {
                CurrentPage++;
            }
            else
            {
                CurrentPage = int.Parse(commandArg);
            }
            BindResearchRepeater();
        }

        protected void SaveOpportunity(object source, CommandEventArgs e)
        {
            // This is where you would implement the logic to save the opportunity for the logged-in user.
            // For now, let's just show a simple message.
            string opportunityId = e.CommandArgument.ToString();
            // Implement actual save logic (e.g., store in database associated with user)
            // You might want to get the current user's ID from Session or User.Identity.Name

            // For demonstration, let's just display a client-side alert
            string script = $"alert('Opportunity {opportunityId} saved successfully (dummy action)!');";
            ScriptManager.RegisterStartupScript(this, GetType(), "SaveSuccess", script, true);
        }
    }

    // A simple class to represent a research opportunity
    public class ResearchOpportunity
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Institution { get; set; }
        public string Field { get; set; }
        public string Type { get; set; }
        public string Duration { get; set; }
        public string Location { get; set; }
        public DateTime? Deadline { get; set; } // Nullable if some are "rolling" or don't have a fixed date
        public string Description { get; set; }
        public string ApplicationUrl { get; set; }
    }
}