using System;
using System.IO;
using System.Web;

namespace Edugate_Project
{
    public class FileDownload : IHttpHandler
    {
        // Canonical folder for new files
        private static readonly string PrimaryFolderVirtual = "~/Uploads/Payments";
        // Backward-compat (old folder)
        private static readonly string LegacyFolderVirtual = "~/Uploads/PaymentProofs";

        public void ProcessRequest(HttpContext context)
        {
            try
            {
                var fileArg = (context.Request["file"] ?? "").Trim();
                var originalName = context.Request["original"];

                if (string.IsNullOrWhiteSpace(fileArg))
                {
                    NotFound(context, "Missing file parameter.");
                    return;
                }

                // Accept: bare filename OR a virtual path (~/ or /)
                string normalizedVirtual = NormalizeToVirtualPath(fileArg);

                // Try exact virtual, then primary, then legacy
                string physicalPath = ResolveExistingPhysicalPath(context, normalizedVirtual, fileArg);
                if (physicalPath == null)
                {
                    NotFound(context, "File not found for: " + fileArg);
                    return;
                }

                var ext = Path.GetExtension(physicalPath)?.ToLowerInvariant();
                var contentType = GetMime(ext);
                var download = string.IsNullOrEmpty(originalName) ? Path.GetFileName(physicalPath) : originalName;

                context.Response.Clear();
                context.Response.ContentType = contentType;
                context.Response.AddHeader("Content-Length", new FileInfo(physicalPath).Length.ToString());
                context.Response.AddHeader(
                    "Content-Disposition",
                    "attachment; filename=\"" + HttpUtility.UrlEncode(download) + "\""
                );

                context.Response.TransmitFile(physicalPath);
                context.Response.Flush();
            }
            catch (Exception ex)
            {
                context.Response.StatusCode = 500;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Error: " + ex.Message);
            }
            finally
            {
                try { context.ApplicationInstance.CompleteRequest(); } catch { }
            }
        }

        private static string NormalizeToVirtualPath(string arg)
        {
            if (arg.StartsWith("~/")) return arg;
            if (arg.StartsWith("/")) return "~" + arg;
            return VirtualPathUtility.Combine(PrimaryFolderVirtual, arg.Replace('\\', '/'));
        }

        private static string ResolveExistingPhysicalPath(HttpContext ctx, string normalizedVirtual, string originalArg)
        {
            // exact path
            var p1 = ctx.Server.MapPath(normalizedVirtual);
            if (File.Exists(p1)) return p1;

            bool isBare = !(originalArg.StartsWith("~/") || originalArg.StartsWith("/"));

            if (isBare)
            {
                var p2 = ctx.Server.MapPath(VirtualPathUtility.Combine(PrimaryFolderVirtual, originalArg));
                if (File.Exists(p2)) return p2;

                var p3 = ctx.Server.MapPath(VirtualPathUtility.Combine(LegacyFolderVirtual, originalArg));
                if (File.Exists(p3)) return p3;
            }

            // if someone passed a legacy virtual path directly
            if (normalizedVirtual.StartsWith(LegacyFolderVirtual, StringComparison.OrdinalIgnoreCase))
            {
                var p4 = ctx.Server.MapPath(normalizedVirtual);
                if (File.Exists(p4)) return p4;
            }

            return null;
        }

        private static void NotFound(HttpContext ctx, string msg)
        {
            ctx.Response.StatusCode = 404;
            ctx.Response.ContentType = "text/plain";
            ctx.Response.Write(msg);
        }

        private static string GetMime(string ext)
        {
            switch (ext)
            {
                case ".pdf": return "application/pdf";
                case ".jpg":
                case ".jpeg": return "image/jpeg";
                case ".png": return "image/png";
                case ".doc": return "application/msword";
                case ".docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
                case ".xls": return "application/vnd.ms-excel";
                case ".xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                default: return "application/octet-stream";
            }
        }

        public bool IsReusable => false;
    }
}
