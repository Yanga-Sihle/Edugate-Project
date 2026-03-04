using System;
using System.IO;
using System.Web;

public class DownloadFile : IHttpHandler
{
    public void ProcessRequest(HttpContext context)
    {
        // 1) read and decode inputs
        string rawFile = context.Request.QueryString["file"];
        string rawOriginal = context.Request.QueryString["original"];

        if (string.IsNullOrWhiteSpace(rawFile))
        {
            BadRequest(context, "File name not specified");
            return;
        }

        string decodedFile = HttpUtility.UrlDecode(rawFile ?? "");
        string fileNameOnly = Path.GetFileName(decodedFile);            // strips any folders
        if (string.IsNullOrWhiteSpace(fileNameOnly))
        {
            BadRequest(context, "File name not specified");
            return;
        }

        // 2) block weird chars / traversal
        if (fileNameOnly.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0)
        {
            BadRequest(context, "Invalid file name");
            return;
        }

        // 3) map to your materials folder
        string baseDir = context.Server.MapPath("~/Uploads/Materials");
        string fullPath = Path.Combine(baseDir, fileNameOnly);

        // (Optional) double-check caller didn't smuggle a path
        if (!fullPath.StartsWith(baseDir, StringComparison.OrdinalIgnoreCase))
        {
            BadRequest(context, "Invalid path");
            return;
        }

        if (!File.Exists(fullPath))
        {
            NotFound(context, "File not found");
            return;
        }

        // 4) stream the file
        try
        {
            context.Response.Clear();
            context.Response.BufferOutput = true;
            context.Response.ContentType = MimeMapping.GetMimeMapping(fullPath);

            string downloadName = HttpUtility.UrlDecode(rawOriginal);
            if (string.IsNullOrWhiteSpace(downloadName))
                downloadName = Path.GetFileName(fullPath);

            // RFC 5987 for UTF-8 filenames
            context.Response.AddHeader(
                "Content-Disposition",
                "attachment; filename*=UTF-8''" + Uri.EscapeDataString(downloadName)
            );

            context.Response.TransmitFile(fullPath);
            context.Response.Flush();
        }
        catch (Exception ex)
        {
            context.Response.Clear();
            context.Response.StatusCode = 500;
            context.Response.Write("Error downloading file: " + HttpUtility.HtmlEncode(ex.Message));
        }
    }

    public bool IsReusable => false;

    private static void BadRequest(HttpContext c, string msg) { c.Response.StatusCode = 400; c.Response.Write(msg); }
    private static void NotFound(HttpContext c, string msg) { c.Response.StatusCode = 404; c.Response.Write(msg); }
}
