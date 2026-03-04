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
    public partial class StudentMaterials : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

  
        public string AlertMessage { get; set; }
        public string AlertType { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                
                if (Session["StudentId"] == null)
                {
                    Response.Redirect("StudentLogin.aspx");
                    return;
                }

            
                BindMaterials();
            }
        }

        private void BindMaterials()
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    string query = @"SELECT 
                                    MaterialId,
                                    Title,
                                    MaterialType,
                                    Subject,
                                    Grade,
                                    Description,
                                    FileName,
                                    OriginalFileName,
                                    UploadDate
                                FROM Materials
                                WHERE 1=1";

          
                    if (!string.IsNullOrEmpty(ddlSubjectFilter.SelectedValue))
                    {
                        query += " AND Subject = @Subject";
                    }

                    if (!string.IsNullOrEmpty(ddlGradeFilter.SelectedValue))
                    {
                        query += " AND Grade = @Grade";
                    }

                    if (!string.IsNullOrEmpty(ddlTypeFilter.SelectedValue))
                    {
                        query += " AND MaterialType = @MaterialType";
                    }

                    
                    query += " ORDER BY " + ddlSortFilter.SelectedValue;

                    SqlCommand cmd = new SqlCommand(query, connection);

        
                    if (!string.IsNullOrEmpty(ddlSubjectFilter.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@Subject", ddlSubjectFilter.SelectedValue);
                    }

                    if (!string.IsNullOrEmpty(ddlGradeFilter.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@Grade", ddlGradeFilter.SelectedValue);
                    }

                    if (!string.IsNullOrEmpty(ddlTypeFilter.SelectedValue))
                    {
                        cmd.Parameters.AddWithValue("@MaterialType", ddlTypeFilter.SelectedValue);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptMaterials.DataSource = dt;
                        rptMaterials.DataBind();
                        pnlNoResults.Visible = false;
                    }
                    else
                    {
                        rptMaterials.DataSource = null;
                        rptMaterials.DataBind();
                        pnlNoResults.Visible = true;
                    }
                }
            }
            catch (Exception ex)
            {
                LogError(ex);
                ShowAlert("Error loading materials. Please try again later.", "error");
            }
        }

        protected void rptMaterials_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                Literal litMaterialType = (Literal)e.Item.FindControl("litMaterialType");
                Literal litDescription = (Literal)e.Item.FindControl("litDescription");
                HyperLink btnPreview = (HyperLink)e.Item.FindControl("btnPreview");

          
                string type = row["MaterialType"].ToString();
                string icon = GetMaterialTypeIcon(type);
                litMaterialType.Text = $"{icon} {type}";

        
                if (string.IsNullOrEmpty(row["Description"].ToString()))
                {
                    litDescription.Text = "No description available.";
                }

                
                string fileExtension = System.IO.Path.GetExtension(row["FileName"].ToString()).ToLower();
                if (fileExtension == ".pdf" || fileExtension == ".jpg" || fileExtension == ".jpeg" || fileExtension == ".png")
                {
                    btnPreview.Visible = true;
                    btnPreview.NavigateUrl = $"PreviewMaterial.ashx?id={row["MaterialId"]}";
                    btnPreview.Attributes["onclick"] = $"logMaterialAccess({row["MaterialId"]}, false);";
                }
            }
        }

        private string GetMaterialTypeIcon(string type)
        {
            switch (type)
            {
                case "Question Paper":
                    return "<i class='fas fa-file-alt'></i>";
                case "Textbook":
                    return "<i class='fas fa-book'></i>";
                case "Video":
                    return "<i class='fas fa-video'></i>";
                case "Notes":
                    return "<i class='fas fa-sticky-note'></i>";
                default:
                    return "<i class='fas fa-file'></i>";
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindMaterials();
        }

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            ddlSubjectFilter.SelectedIndex = 0;
            ddlGradeFilter.SelectedIndex = 0;
            ddlTypeFilter.SelectedIndex = 0;
            ddlSortFilter.SelectedIndex = 0;
            BindMaterials();
        }

        private void ShowAlert(string message, string type = "error")
        {
            AlertMessage = message;
            AlertType = type;

            
            string script = $"showAlert('{message.Replace("'", "\\'")}', '{type}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "ShowAlert", script, true);
        }

        private void LogError(Exception ex)
        {
            try
            {
                string logDirectory = Server.MapPath("~/App_Data/Logs");
                string logFilePath = Path.Combine(logDirectory, "ErrorLog.txt");

               
                if (!Directory.Exists(logDirectory))
                {
                    Directory.CreateDirectory(logDirectory);
                }

                string logMessage = $"[{DateTime.Now}] Error in StudentMaterials: {ex.Message}\nStack Trace: {ex.StackTrace}\n\n";

                File.AppendAllText(logFilePath, logMessage);
            }
            catch (Exception logEx)
            {
                
                System.Diagnostics.Debug.WriteLine($"Failed to log error: {logEx.Message}");
                System.Diagnostics.Debug.WriteLine($"Original error: {ex.Message}");
            }
        }
    }
}