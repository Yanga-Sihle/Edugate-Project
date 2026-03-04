using System;
using System.Web;
using System.IO;
using System.Configuration;
using System.Data.SqlClient;

namespace Edugate_Project
{
    public class PreviewMaterial : IHttpHandler
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        public void ProcessRequest(HttpContext context)
        {
            string id = context.Request.QueryString["id"];

            if (string.IsNullOrEmpty(id))
            {
                context.Response.StatusCode = 400;
                context.Response.Write("Material ID not specified");
                return;
            }

            int materialId;
            if (!int.TryParse(id, out materialId))
            {
                context.Response.StatusCode = 400;
                context.Response.Write("Invalid Material ID");
                return;
            }

            try
            {
                using (SqlConnection connection = new SqlConnection(ConnectionString))
                {
                    string query = "SELECT FileName FROM Materials WHERE MaterialId = @MaterialId";
                    SqlCommand cmd = new SqlCommand(query, connection);
                    cmd.Parameters.AddWithValue("@MaterialId", materialId);

                    connection.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        string fileName = reader["FileName"].ToString();
                        string filePath = context.Server.MapPath("~/Uploads/Materials/") + fileName;
                        string fileExtension = Path.GetExtension(fileName).ToLower();

                        if (File.Exists(filePath))
                        {
                            context.Response.Clear();

                            switch (fileExtension)
                            {
                                case ".pdf":
                                    context.Response.ContentType = "application/pdf";
                                    break;
                                case ".jpg":
                                case ".jpeg":
                                    context.Response.ContentType = "image/jpeg";
                                    break;
                                case ".png":
                                    context.Response.ContentType = "image/png";
                                    break;
                                default:
                                    context.Response.ContentType = "application/octet-stream";
                                    break;
                            }

                            context.Response.TransmitFile(filePath);
                            context.Response.Flush();
                        }
                        else
                        {
                            context.Response.StatusCode = 404;
                            context.Response.Write("File not found");
                        }
                    }
                    else
                    {
                        context.Response.StatusCode = 404;
                        context.Response.Write("Material not found");
                    }
                }
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.Write("Error previewing file: " + ex.Message);
            }
        }

        public bool IsReusable => false;
    }
}