using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                lblRegMessage.Text = "<span style='color:red;'>Passwords do not match.</span>";
                return;
            }

            // Save to database here (placeholder)
            lblRegMessage.Text = "<span style='color:green;'>Registration successful. You may now login.</span>";
        }
    }
}