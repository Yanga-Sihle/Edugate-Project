using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Edugate_Project
{
    public partial class Pricing : System.Web.UI.Page
    {
        private string ConnectionString =>
            ConfigurationManager.ConnectionStrings["EdugateDBConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            EnsureAuthenticated();
            if (!IsPostBack)
            {
                lblAdminName.Text = Convert.ToString(Session["AdminName"] ?? Session["AdminId"] ?? "Admin");
                BindCurrentPrices();
                BindGrid();
            }
        }

        private void EnsureAuthenticated()
        {
            if (Session["AdminId"] == null) Response.Redirect("~/Default.aspx", true);
        }

        private void Toast(string msg, string type = "success")
        {
            ScriptManager.RegisterStartupScript(
                this, GetType(), Guid.NewGuid().ToString(),
                "showAlert(" + HttpUtility.JavaScriptStringEncode(msg, true) + "," + HttpUtility.JavaScriptStringEncode(type, true) + ");",
                true);
        }

        private void BindCurrentPrices()
        {
            decimal std = 0m, prem = 0m;
            string currency = "ZAR";
            bool haveStandard = false, havePremium = false;

            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT PlanName, Price, Currency
FROM PricingPlans
WHERE PlanName IN ('Standard','Premium');", cn))
            {
                cn.Open();
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string plan = Convert.ToString(r["PlanName"]);
                        decimal price = Convert.ToDecimal(r["Price"]);
                        string cur = Convert.ToString(r["Currency"]);

                        if (currency == null) currency = cur; else currency = cur ?? currency;

                        if (string.Equals(plan, "Standard", StringComparison.OrdinalIgnoreCase))
                        {
                            std = price; haveStandard = true;
                        }
                        else if (string.Equals(plan, "Premium", StringComparison.OrdinalIgnoreCase))
                        {
                            prem = price; havePremium = true;
                        }
                    }
                }
            }

            // Fill UI
            txtStandardPrice.Text = std.ToString("0.00");
            txtPremiumPrice.Text = prem.ToString("0.00");
            var item = ddlCurrency.Items.FindByValue(currency ?? "ZAR");
            if (item != null) { ddlCurrency.ClearSelection(); item.Selected = true; }

            lblCurrentStandard.Text = "R " + std.ToString("N2");
            lblCurrentPremium.Text = "R " + prem.ToString("N2");

            if (!haveStandard || !havePremium)
                Toast("Pricing rows missing. Run the setup SQL to create 'Standard' and 'Premium' entries.", "info");
        }

        private void BindGrid()
        {
            using (var cn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"
SELECT PlanName, Price, Currency, ModifiedBy, ModifiedOn
FROM PricingPlans
ORDER BY CASE WHEN PlanName='Standard' THEN 0 WHEN PlanName='Premium' THEN 1 ELSE 2 END;", cn))
            {
                var dt = new DataTable();
                cn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
                gvPrices.DataSource = dt;
                gvPrices.DataBind();
            }
        }

        protected void btnSavePrices_Click(object sender, EventArgs e)
        {
            try
            {
                decimal std, prem;
                if (!decimal.TryParse((txtStandardPrice.Text ?? "").Trim(), out std) || std < 0m)
                { Toast("Enter a valid Standard price.", "info"); return; }

                if (!decimal.TryParse((txtPremiumPrice.Text ?? "").Trim(), out prem) || prem < 0m)
                { Toast("Enter a valid Premium price.", "info"); return; }

                string currency = (ddlCurrency.SelectedValue ?? "ZAR").Trim();
                string admin = Convert.ToString(Session["AdminId"] ?? "Admin");

                using (var cn = new SqlConnection(ConnectionString))
                {
                    cn.Open();
                    using (var tx = cn.BeginTransaction())
                    {
                        try
                        {
                            // Ensure rows exist (no insert here; just check count)
                            int existing;
                            using (var chk = new SqlCommand(@"
SELECT COUNT(*) FROM PricingPlans WHERE PlanName IN ('Standard','Premium');", cn, tx))
                            {
                                existing = Convert.ToInt32(chk.ExecuteScalar());
                            }

                            if (existing < 2)
                            {
                                tx.Rollback();
                                Toast("Cannot save: pricing rows missing. Run the setup SQL to create them.", "error");
                                return;
                            }

                            // UPDATE only
                            using (var upStd = new SqlCommand(@"
UPDATE PricingPlans
   SET Price=@p, Currency=@c, ModifiedBy=@by, ModifiedOn=SYSUTCDATETIME()
 WHERE PlanName='Standard';", cn, tx))
                            {
                                upStd.Parameters.AddWithValue("@p", std);
                                upStd.Parameters.AddWithValue("@c", currency);
                                upStd.Parameters.AddWithValue("@by", admin);
                                upStd.ExecuteNonQuery();
                            }

                            using (var upPrem = new SqlCommand(@"
UPDATE PricingPlans
   SET Price=@p, Currency=@c, ModifiedBy=@by, ModifiedOn=SYSUTCDATETIME()
 WHERE PlanName='Premium';", cn, tx))
                            {
                                upPrem.Parameters.AddWithValue("@p", prem);
                                upPrem.Parameters.AddWithValue("@c", currency);
                                upPrem.Parameters.AddWithValue("@by", admin);
                                upPrem.ExecuteNonQuery();
                            }

                            tx.Commit();
                        }
                        catch
                        {
                            try { tx.Rollback(); } catch { }
                            throw;
                        }
                    }
                }

                BindCurrentPrices();
                BindGrid();
                Toast("Prices updated.", "success");
            }
            catch (Exception ex)
            {
                Toast("Failed to update prices: " + ex.Message, "error");
            }
        }
    }
}
