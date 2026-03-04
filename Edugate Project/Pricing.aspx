<%@ Page Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true"
    CodeBehind="Pricing.aspx.cs" Inherits="Edugate_Project.Pricing" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>Pricing - Edugate STEM</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        :root{--primary-dark:#213A57;--primary-orange:#0B6477;--accent-teal:#14919B;--text-light:#DAD1CB;--accent-green:#45DFB1;--accent-light-green:#80ED99;}
        .admin-dashboard{display:flex;min-height:100vh;background-color:var(--primary-dark);color:var(--text-light);font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}
        .admin-sidebar{width:280px;background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);color:#fff;padding:2rem 1rem;position:fixed;height:100vh;box-shadow:0 8px 32px rgba(33,58,87,.25);border-right:2px solid var(--accent-green);z-index:1000}
        .admin-profile{text-align:center;padding:1rem 0 2rem;border-bottom:1px solid rgba(255,255,255,.1);margin-bottom:1.5rem}
        .admin-avatar{width:80px;height:80px;border-radius:50%;object-fit:cover;border:3px solid var(--accent-green);margin-bottom:1rem}
        .admin-name{font-size:1.2rem;margin:.5rem 0;font-weight:700;color:var(--text-light)} .admin-role{font-size:.85rem;color:var(--accent-light-green);margin:0}
        .admin-menu{list-style:none;padding:0;margin:0} .admin-menu li{margin-bottom:.5rem}
        .admin-menu a{display:flex;align-items:center;color:rgba(255,255,255,.8);padding:.75rem 1rem;border-radius:6px;text-decoration:none;transition:all .2s}
        .admin-menu a:hover,.admin-menu a.active{background:rgba(69,223,177,.2);color:var(--text-light)} .admin-menu a i{margin-right:.75rem;width:20px;text-align:center}
        .admin-content{flex:1;margin-left:280px;padding:2rem;background:rgba(33,58,87,.7);min-height:100vh;backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal)}
        .section-title{color:var(--text-light);margin-bottom:1.5rem;font-weight:700;position:relative;padding-bottom:.75rem;font-size:1.8rem}
        .section-title:after{content:'';position:absolute;bottom:0;left:0;width:50px;height:3px;background:var(--accent-green)}

        .pro-cards{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:14px;margin-bottom:14px}
        .pro-card{background:rgba(33,58,87,.75);border:1px solid var(--accent-teal);border-radius:14px;padding:16px}
        .pro-title{font-weight:700;color:var(--text-light);display:flex;align-items:center;gap:8px}
        .pro-icon{color:var(--accent-green)}
        .pro-value{font-size:1.6rem;font-weight:800;color:var(--accent-green)}
        .pro-label{font-size:.9rem;color:var(--accent-light-green);opacity:.9}

        .upload-form{background:rgba(33,58,87,.8);padding:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);margin-bottom:2rem;border:1px solid var(--accent-teal);backdrop-filter:blur(5px)}
        .form-row{display:flex;gap:1.5rem;margin-bottom:1.5rem} .form-group{flex:1}
        .form-label{display:block;margin-bottom:.5rem;font-weight:600;color:var(--text-light)}
        .form-control{width:100%;padding:.8rem 1rem;border:2px solid var(--accent-teal);border-radius:10px;font-size:1rem;background:var(--primary-dark);color:var(--text-light);transition:all .3s ease}
        .form-control:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 3px rgba(69,223,177,.2)}
        .form-select{appearance:none;background-image:url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");background-repeat:no-repeat;background-position:right .75rem center;background-size:1em}
        .btn-primary{background:var(--accent-green);color:var(--primary-dark);border:none;padding:.8rem 1.5rem;border-radius:50px;font-size:1rem;font-weight:700;cursor:pointer;transition:all .3s ease;display:inline-block;text-align:center}
        .btn-primary:hover{background:var(--primary-dark);color:var(--accent-green);box-shadow:0 0 0 1px var(--accent-green);transform:translateY(-3px)}

        .table-responsive{overflow-x:auto;margin-bottom:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);border:1px solid var(--accent-teal);background:rgba(33,58,87,.8);backdrop-filter:blur(5px)}
        .premium-table{width:100%;border-collapse:collapse}
        .premium-table th{background:rgba(20,145,155,.3);padding:1rem;text-align:left;font-weight:700;color:var(--text-light);border-bottom:2px solid var(--accent-teal)}
        .premium-table td{padding:1rem;border-bottom:1px solid rgba(69,223,177,.1);vertical-align:middle;color:var(--text-light)}
        .premium-table tr:hover{background:rgba(69,223,177,.1)}

        @media (max-width:768px){
            .admin-sidebar{transform:translateX(-100%);width:280px}.admin-sidebar.active{transform:translateX(0)}
            .admin-content{margin-left:0}
            .pro-cards{grid-template-columns:1fr}
        }
        @media (max-width:576px){.section-title{font-size:1.5rem}}
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="admin-dashboard">
    <asp:ScriptManagerProxy ID="smProxy" runat="server" />

    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-profile">
            <asp:Image ID="imgAdminAvatar" runat="server" CssClass="admin-avatar" ImageUrl="~/images/admin-avatar.jpg" />
            <h3 class="admin-name"><asp:Label ID="lblAdminName" runat="server" Text="Admin Name"></asp:Label></h3>
            <p class="admin-role">System Administrator</p>
        </div>
        <ul class="admin-menu">
            <li><a href="AdminDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="AdminDashboard.aspx#reports-section"><i class="fas fa-chart-bar"></i> Reports</a></li>
            <li><a href="AdminDashboard.aspx#materials-section"><i class="fas fa-book"></i> Study Materials</a></li>
           <li><a href="Pricing.aspx" class="active"><i class="fas fa-tags"></i> Pricing</a></li>
            <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
           
        </ul>
    </div>

    <!-- Main -->
    <div class="admin-content">
        <h1 class="section-title">Pricing (Edit Only)</h1>

        <!-- Current values at a glance -->
        <div class="pro-cards" style="margin-top:-.5rem;margin-bottom:1.25rem">
            <div class="pro-card">
                <div class="pro-title"><i class="fas fa-cube pro-icon"></i> Standard</div>
                <div class="pro-value"><asp:Label ID="lblCurrentStandard" runat="server" Text="R 0.00"></asp:Label></div>
                <div class="pro-label">Current price</div>
            </div>
            <div class="pro-card">
                <div class="pro-title"><i class="fas fa-gem pro-icon"></i> Premium</div>
                <div class="pro-value"><asp:Label ID="lblCurrentPremium" runat="server" Text="R 0.00"></asp:Label></div>
                <div class="pro-label">Current price</div>
            </div>
        </div>

        <!-- Edit form (updates existing rows only) -->
        <section class="upload-form">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px">
                <div class="pro-title"><i class="fas fa-sliders-h pro-icon"></i> Update Prices</div>
                <span class="status-active" style="font-weight:800">Admin-only</span>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label class="form-label">Standard (ZAR)</label>
                    <asp:TextBox ID="txtStandardPrice" runat="server" CssClass="form-control" placeholder="e.g. 199.00"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Premium (ZAR)</label>
                    <asp:TextBox ID="txtPremiumPrice" runat="server" CssClass="form-control" placeholder="e.g. 399.00"></asp:TextBox>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group" style="max-width:260px">
                    <label class="form-label">Currency</label>
                    <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-control form-select">
                        <asp:ListItem Value="ZAR" Selected="True">ZAR (R)</asp:ListItem>
                        <asp:ListItem Value="USD">USD ($)</asp:ListItem>
                        <asp:ListItem Value="EUR">EUR (€)</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div class="form-group" style="align-self:flex-end;display:flex;gap:.5rem;flex-wrap:wrap">
                    <asp:Button ID="btnSavePrices" runat="server" CssClass="btn-primary" Text="Save Prices" OnClick="btnSavePrices_Click" />
                    <asp:HyperLink ID="hlBack" runat="server" CssClass="btn-primary" NavigateUrl="~/AdminDashboard.aspx" Text="Back to Dashboard" />
                </div>
            </div>
            <small style="opacity:.8">This page updates existing plans only — no new rows are created.</small>
        </section>

        <!-- Current table (no history) -->
        <h3 class="section-title">Current Prices</h3>
        <div class="table-responsive">
            <asp:GridView ID="gvPrices" runat="server" CssClass="premium-table" AutoGenerateColumns="false" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="PlanName" HeaderText="Plan" />
                    <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="R {0:N2}" />
                    <asp:BoundField DataField="Currency" HeaderText="Currency" />
                    <asp:BoundField DataField="ModifiedBy" HeaderText="Modified By" />
                    <asp:BoundField DataField="ModifiedOn" HeaderText="Modified On" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                </Columns>
                <EmptyDataTemplate>
                    <div style="text-align:center;padding:2rem;color:var(--accent-green);">Pricing rows are missing. Please run the setup SQL.</div>
                </EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</div>

<script>
    // Toast helper
    window.showAlert = window.showAlert || function (message, type) {
        var wrap = document.createElement('div');
        wrap.style.position = 'fixed'; wrap.style.bottom = '20px'; wrap.style.right = '20px';
        wrap.style.zIndex = '9999'; wrap.style.padding = '12px 16px'; wrap.style.borderRadius = '12px';
        wrap.style.fontWeight = '800';
        wrap.style.background = (type === 'success' ? '#28a745' : (type === 'error' ? '#dc3545' : '#14919B'));
        wrap.style.color = '#fff'; wrap.textContent = message;
        document.body.appendChild(wrap);
        setTimeout(function () { document.body.removeChild(wrap); }, 3500);
    };
</script>
</asp:Content>
