using System;
using System.Web;
using System.Configuration;
using System.Data.SqlClient;

namespace Edugate_Project
{
    public class LogMaterialAccess : IHttpHandler
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        public void ProcessRequest(HttpContext context)
        {
            // Only process POST requests
            if (context.Request.HttpMethod != "POST")
            {
                context.Response.StatusCode = 405; // Method Not Allowed
                return;
            }

            string materialIdStr = context.Request.Form["materialId"];
            string isDownloadStr = context.Request.Form["isDownload"];

            if (string.IsNullOrEmpty(materialIdStr) || string.IsNullOrEmpty(isDownloadStr))
            {
                context.Response.StatusCode = 400; // Bad Request
                return;
            }

            int materialId;
            bool isDownload;

            if (!int.TryParse(materialIdStr, out materialId) || !bool.TryParse(isDownloadStr, out isDownload))
            {
                context.Response.StatusCode = 400; // Bad Request
                return;
            }

            // Get student ID from session (if available)
            int studentId = 0;
            if (context.Session != null && context.Session["StudentId"] != null)
            {
                studentId = Convert.ToInt32(context.Session["StudentId"]);
            }

            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    string query = @"INSERT INTO MaterialAccessLogs 
                                  (StudentId, MaterialId, AccessDate, IsDownload, IsPreview)
                                  VALUES (@StudentId, @MaterialId, GETDATE(), @IsDownload, @IsPreview)";

                    SqlCommand cmd = new SqlCommand(query, connection);
                    cmd.Parameters.AddWithValue("@StudentId", studentId);
                    cmd.Parameters.AddWithValue("@MaterialId", materialId);
                    cmd.Parameters.AddWithValue("@IsDownload", isDownload);
                    cmd.Parameters.AddWithValue("@IsPreview", !isDownload);

                    connection.Open();
                    cmd.ExecuteNonQuery();
                }

                context.Response.StatusCode = 200;
                context.Response.Write("Success");
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("Error logging access: " + ex.Message);
            }
        }

        public bool IsReusable => false;
    }
}