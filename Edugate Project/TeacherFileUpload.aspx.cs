using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using Edugate_Project.Models;

namespace Edugate_Project
{
    public partial class TeacherFileUpload : System.Web.UI.Page
    {
        private string ConnectionString = ConfigurationManager.ConnectionStrings["EdugateDBConnection"]?.ConnectionString ??
                                          "Data Source=YourServerName;Initial Catalog=EdugateDB;Integrated Security=True";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check
            if (Session["IsTeacherLoggedIn"] == null || !(bool)Session["IsTeacherLoggedIn"] || Session["TeacherID"] == null)
            {
                Response.Redirect("TeacherLogin.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadTeacherData();
                // Ensure subject code is available for the session (UploadMarks relies on it)
                var _ = GetSubjectCode();
                BindUploadedFiles();
            }
        }

        /// <summary>
        /// Resolve the teacher's SubjectCode in a way that is consistent with UploadMarks.
        /// Preferred: Session["SubjectCode"]. Fallbacks: Session["TeacherSubjectCode"] then DB.
        /// Also writes Session["SubjectCode"] so other pages see the same value.
        /// </summary>
        private string GetSubjectCode()
        {
            if (Session["SubjectCode"] is string sc && !string.IsNullOrWhiteSpace(sc))
                return sc;

            if (Session["TeacherSubjectCode"] is string tsc && !string.IsNullOrWhiteSpace(tsc))
            {
                Session["SubjectCode"] = tsc;
                return tsc;
            }

            // Fallback to DB lookup
            string subject = null;
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT SubjectCode FROM Teachers WHERE TeacherID = @TeacherID", con))
            {
                cmd.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                con.Open();
                object obj = cmd.ExecuteScalar();
                subject = obj?.ToString();
            }

            if (!string.IsNullOrWhiteSpace(subject))
                Session["SubjectCode"] = subject;

            return subject;
        }

        private void LoadTeacherData()
        {
            using (SqlConnection connection = new SqlConnection(ConnectionString))
            using (SqlCommand command = new SqlCommand("SELECT FullName FROM Teachers WHERE TeacherID = @TeacherID", connection))
            {
                command.Parameters.AddWithValue("@TeacherID", Session["TeacherID"]);
                connection.Open();
                object result = command.ExecuteScalar();
                if (result != null)
                {
                    lblSidebarTeacherName.Text = result.ToString();
                }
            }
        }

        protected void btnUpload_Click(object sender, EventArgs e)
        {
            int teacherId = (int)Session["TeacherID"];
            string subjectCode = GetSubjectCode(); // <-- unified subject code
            string message = txtMessage.Text.Trim();

            if (string.IsNullOrWhiteSpace(subjectCode))
            {
                ShowStatusMessage("Your subject code could not be determined. Please log in again.", "error");
                return;
            }

            string fileName = "";
            string filePathOnDisk = "";
            bool fileUploaded = false;

            // Optional: allow message-only posts (no file)
            if (!FileUploadControl.HasFile && string.IsNullOrWhiteSpace(message))
            {
                ShowStatusMessage("Please select a file to upload or enter a message.", "error");
                return;
            }

            if (FileUploadControl.HasFile)
            {
                try
                {
                    // ~/Uploads/{SubjectCode}/
                    string uploadDir = Server.MapPath($"~/Uploads/{subjectCode}/");
                    if (!Directory.Exists(uploadDir))
                    {
                        Directory.CreateDirectory(uploadDir);
                    }

                    fileName = Path.GetFileName(FileUploadControl.FileName);
                    filePathOnDisk = Path.Combine(uploadDir, fileName);

                    // Ensure unique filename
                    int count = 1;
                    string uniqueName = fileName;
                    while (File.Exists(filePathOnDisk))
                    {
                        uniqueName = $"{Path.GetFileNameWithoutExtension(fileName)} ({count++}){Path.GetExtension(fileName)}";
                        filePathOnDisk = Path.Combine(uploadDir, uniqueName);
                    }
                    fileName = uniqueName;

                    FileUploadControl.SaveAs(filePathOnDisk);
                    fileUploaded = true;
                }
                catch (Exception ex)
                {
                    ShowStatusMessage($"File upload failed: {ex.Message}", "error");
                    return;
                }
            }

            // Convert to a web-relative path for storage (e.g., "Uploads/MATH101/Assignment 1.pdf")
            string relativePath = null;
            if (fileUploaded)
            {
                string root = Server.MapPath("~/");
                relativePath = filePathOnDisk.Replace(root, "").TrimStart(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar)
                                             .Replace("\\", "/");
            }

            // Save DB record
            if (SaveUploadedFileToDatabase(teacherId, subjectCode, fileName, relativePath, message))
            {
                ShowStatusMessage("File and message uploaded successfully!", "success");
                txtMessage.Text = string.Empty;
                BindUploadedFiles();
            }
            else
            {
                ShowStatusMessage("Failed to save file information to the database.", "error");
                if (fileUploaded && File.Exists(filePathOnDisk))
                {
                    try { File.Delete(filePathOnDisk); } catch { /* swallow */ }
                }
            }
        }

        private bool SaveUploadedFileToDatabase(int teacherId, string subjectCode, string fileName, string relativeFilePath, string message)
        {
            string query = @"INSERT INTO UploadedFiles (TeacherID, SubjectCode, FileName, FilePath, Message, UploadDate)
                             VALUES (@TeacherID, @SubjectCode, @FileName, @FilePath, @Message, GETDATE())";

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);
                cmd.Parameters.AddWithValue("@SubjectCode", subjectCode);
                cmd.Parameters.AddWithValue("@FileName", (object)fileName ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@FilePath", string.IsNullOrWhiteSpace(relativeFilePath) ? (object)DBNull.Value : relativeFilePath);
                cmd.Parameters.AddWithValue("@Message", string.IsNullOrWhiteSpace(message) ? (object)DBNull.Value : message);

                try
                {
                    con.Open();
                    return cmd.ExecuteNonQuery() > 0;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error saving uploaded file info to DB: {ex.Message}");
                    return false;
                }
            }
        }

        private void BindUploadedFiles()
        {
            int teacherId = (int)Session["TeacherID"];

            // Use DISTINCT to avoid fan-out duplicates from joins
            string query = @"
        SELECT DISTINCT
            uf.FileID,
            uf.FileName,
            uf.Message,
            uf.UploadDate,
            uf.SubjectCode,
            s.SubjectName,
            t.Username AS TeacherUsername
        FROM UploadedFiles uf
        INNER JOIN Subjects s ON uf.SubjectCode = s.SubjectCode
        INNER JOIN Teachers t ON uf.TeacherID = t.TeacherID
        WHERE uf.TeacherID = @TeacherID
        ORDER BY uf.UploadDate DESC";

            var uploadedFiles = new List<UploadedFile>();

            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TeacherID", teacherId);

                try
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            uploadedFiles.Add(new UploadedFile
                            {
                                FileID = (int)reader["FileID"],
                                FileName = reader["FileName"] == DBNull.Value ? "" : reader["FileName"].ToString(),
                                Message = reader["Message"] == DBNull.Value ? "" : reader["Message"].ToString(),
                                UploadDate = (DateTime)reader["UploadDate"],
                                SubjectCode = reader["SubjectCode"].ToString(),
                                SubjectName = reader["SubjectName"].ToString(),
                                TeacherUsername = reader["TeacherUsername"].ToString()
                            });
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error binding uploaded files: {ex.Message}");
                    ShowStatusMessage("Error loading your uploaded files.", "error");
                }
            }

            // Extra safety: de-dupe in memory by FileID (handles any odd DB data)
            var distinct = uploadedFiles
                .GroupBy(f => f.FileID)
                .Select(g => g.OrderByDescending(x => x.UploadDate).First())
                .ToList();

            if (distinct.Count > 0)
            {
                rptUploadedFiles.DataSource = distinct;
                CurrentUploadsPanel.Visible = true;
            }
            else
            {
                rptUploadedFiles.DataSource = null;
                CurrentUploadsPanel.Visible = false;
            }

            rptUploadedFiles.DataBind();
        }

        protected void btnDeleteFile_Command(object source, CommandEventArgs e)
        {
            if (int.TryParse(e.CommandArgument.ToString(), out int fileIdToDelete))
            {
                string filePathToDelete = GetFilePathFromFileId(fileIdToDelete);

                if (DeleteFileFromDatabase(fileIdToDelete))
                {
                    if (!string.IsNullOrEmpty(filePathToDelete))
                    {
                        string fullPath = Server.MapPath($"~/{filePathToDelete}");
                        if (File.Exists(fullPath))
                        {
                            try
                            {
                                File.Delete(fullPath);
                                ShowStatusMessage("File and record deleted successfully.", "success");
                            }
                            catch (Exception ex)
                            {
                                ShowStatusMessage($"Record deleted, but failed to delete physical file: {ex.Message}", "error");
                            }
                        }
                        else
                        {
                            ShowStatusMessage("Record deleted, but physical file not found on server.", "info");
                        }
                    }
                    else
                    {
                        ShowStatusMessage("Record deleted, no physical file path found.", "info");
                    }
                    BindUploadedFiles();
                }
                else
                {
                    ShowStatusMessage("Failed to delete file record from the database.", "error");
                }
            }
        }

        private string GetFilePathFromFileId(int fileId)
        {
            string filePath = null;
            string query = "SELECT FilePath FROM UploadedFiles WHERE FileID = @FileID";
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@FileID", fileId);
                try
                {
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        filePath = result.ToString();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error getting file path for deletion: {ex.Message}");
                }
            }
            return filePath;
        }

        private bool DeleteFileFromDatabase(int fileId)
        {
            string query = "DELETE FROM UploadedFiles WHERE FileID = @FileID";
            using (SqlConnection con = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@FileID", fileId);
                try
                {
                    con.Open();
                    return cmd.ExecuteNonQuery() > 0;
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error deleting file record from DB: {ex.Message}");
                    return false;
                }
            }
        }

        private void ShowStatusMessage(string message, string type)
        {
            litStatusMessage.Text = $"<div class='status-message {type}'>{message}</div>";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}
