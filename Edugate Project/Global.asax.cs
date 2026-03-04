using System;
using System.Web;
using System.Web.UI; // Required for ScriptManager and ScriptResourceMapping

namespace Edugate_Project
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // IMPORTANT: This section registers jQuery for ASP.NET Web Forms Unobtrusive Validation.
            // It ensures that ASP.NET's validation controls can find and use jQuery for client-side validation.

            // Define the path to your jQuery file.
            // *** CRITICAL: VERIFY THIS PATH! ***
            // Right-click on your jQuery file (e.g., jquery-3.7.1.min.js) in Solution Explorer,
            // go to Properties, and check its "Relative Path" or "Build Action" (should be Content).
            // Example: If jQuery is in 'YourProjectName/Scripts/jquery-3.7.1.min.js', the path is "~/Scripts/jquery-3.7.1.min.js".
            string jqueryPath = "~/Scripts/jquery-3.7.1.min.js"; // Adjust this to your actual jQuery minified file
            string jqueryDebugPath = "~/Scripts/jquery-3.7.1.js"; // Adjust this to your actual jQuery un-minified file (for debugging)

            // Check if the mapping already exists to prevent errors on hot-reloads in development
            if (ScriptManager.ScriptResourceMapping.GetDefinition("jquery") == null)
            {
                ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                    new ScriptResourceDefinition
                    {
                        Path = jqueryPath,
                        DebugPath = jqueryDebugPath,
                        // Using a CDN is highly recommended for performance and reliability.
                        // Ensure the CDN URL matches the jQuery version you are using.
                        CdnPath = "https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.1.min.js",
                        CdnDebugPath = "https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.7.1.js",
                        CdnSupportsSecureConnection = true,
                        // This expression checks if jQuery has loaded successfully in the browser.
                        LoadSuccessExpression = "window.jQuery"
                    });
            }

            // You might have other application startup code here, such as:
            // RouteConfig.RegisterRoutes(RouteTable.Routes); // If you are using ASP.NET Routing
            // BundleConfig.RegisterBundles(BundleTable.Bundles); // If you are using Bundling and Minification
        }

        void Application_End(object sender, EventArgs e)
        {
            // Code that runs on application shutdown
        }

        void Application_Error(object sender, EventArgs e)
        {
            // Code that runs when an unhandled error occurs
        }

        void Session_Start(object sender, EventArgs e)
        {
            // Code that runs when a new session is started
        }

        void Session_End(object sender, EventArgs e)
        {
            // Code that runs when a session ends.
        }
    }
}
