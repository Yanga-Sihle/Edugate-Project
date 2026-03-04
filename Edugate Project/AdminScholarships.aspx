<%@ Page Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true"
    CodeBehind="AdminScholarships.aspx.cs" Inherits="Edugate_Project.AdminScholarships" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>Admin – Scholarships | Edugate STEM</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        :root{--primary-dark:#213A57;--primary-orange:#0B6477;--accent-teal:#14919B;--text-light:#DAD1CB;--accent-green:#45DFB1;--accent-light-green:#80ED99;}
        .admin-dashboard{display:flex;min-height:100vh;background-color:var(--primary-dark);color:var(--text-light);font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;}
        .admin-sidebar{width:280px;background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);color:#fff;padding:2rem 1rem;position:fixed;height:100vh;box-shadow:0 8px 32px 0 rgba(33,58,87,.25);border-right:2px solid var(--accent-green);z-index:1000}
        .admin-profile{text-align:center;padding:1rem 0 2rem;border-bottom:1px solid rgba(255,255,255,.1);margin-bottom:1.5rem}
        .admin-avatar{width:80px;height:80px;border-radius:50%;object-fit:cover;border:3px solid var(--accent-green);margin-bottom:1rem}
        .admin-name{font-size:1.2rem;margin:.5rem 0;font-weight:700;color:var(--text-light)}.admin-role{font-size:.85rem;color:var(--accent-light-green);margin:0}
        .admin-menu{list-style:none;padding:0;margin:0}.admin-menu li{margin-bottom:.5rem}
        .admin-menu a{display:flex;align-items:center;color:rgba(255,255,255,.8);padding:.75rem 1rem;border-radius:6px;text-decoration:none;transition:all .2s}
        .admin-menu a:hover,.admin-menu a.active{background:rgba(69,223,177,.2);color:var(--text-light)}.admin-menu a i{margin-right:.75rem;width:20px;text-align:center}
        .admin-content{flex:1;margin-left:280px;padding:2rem;background:rgba(33,58,87,.7);min-height:100vh;backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal)}
        .section-title{color:var(--text-light);margin-bottom:1.5rem;font-weight:700;position:relative;padding-bottom:.75rem;font-size:1.8rem}
        .section-title:after{content:'';position:absolute;bottom:0;left:0;width:50px;height:3px;background:var(--accent-green)}

        .pro-panel{background:rgba(33,58,87,.8);border:1px solid var(--accent-teal);border-radius:16px;padding:18px;box-shadow:0 8px 32px rgba(0,0,0,.15);margin-bottom:28px}
        .pro-top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px}
        .pro-top .title{font-weight:800;color:var(--text-light)}
        .pro-top .muted{opacity:.85;color:var(--accent-light-green);font-weight:600}
        .pro-chip{padding:.35rem .6rem;border:1px solid var(--accent-teal);border-radius:999px;color:var(--accent-light-green);font-weight:700;font-size:.8rem}

        .upload-form{background:rgba(33,58,87,.8);padding:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);margin-bottom:2rem;border:1px solid var(--accent-teal);backdrop-filter:blur(5px)}
        .form-row{display:flex;gap:1.5rem;margin-bottom:1.5rem;flex-wrap:wrap}
        .form-group{flex:1;min-width:240px}
        .form-label{display:block;margin-bottom:.5rem;font-weight:600;color:var(--text-light)}
        .form-control{width:100%;padding:.8rem 1rem;border:2px solid var(--accent-teal);border-radius:10px;font-size:1rem;background:var(--primary-dark);color:var(--text-light);transition:all .3s ease}
        .form-control:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 3px rgba(69,223,177,.2)}
        .btn-primary{background:var(--accent-green);color:var(--primary-dark);border:none;padding:.8rem 1.5rem;border-radius:50px;font-size:1rem;font-weight:700;cursor:pointer;transition:all .3s ease;display:inline-block;text-align:center}
        .btn-primary:hover{background:var(--primary-dark);color:var(--accent-green);box-shadow:0 0 0 1px var(--accent-green);transform:translateY(-3px)}

        .table-responsive{overflow-x:auto;margin-bottom:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);border:1px solid var(--accent-teal);background:rgba(33,58,87,.8);backdrop-filter:blur(5px)}
        .premium-table{width:100%;border-collapse:collapse}
        .premium-table th{background:rgba(20,145,155,.3);padding:1rem;text-align:left;font-weight:700;color:var(--text-light);border-bottom:2px solid var(--accent-teal)}
        .premium-table td{padding:1rem;border-bottom:1px solid rgba(69,223,177,.1);vertical-align:middle;color:var(--text-light)}
        .premium-table tr:hover{background:rgba(69,223,177,.1)}
        .status-active{display:inline-block;padding:.25rem .6rem;background:rgba(69,223,177,.2);color:var(--accent-green);border-radius:999px;font-weight:700}
        .status-inactive{display:inline-block;padding:.25rem .6rem;background:rgba(108,117,125,.2);color:#ccc;border-radius:999px;font-weight:700}
        .file-badge{display:inline-block;margin:.15rem .25rem;padding:.25rem .5rem;border-radius:999px;background:rgba(20,145,155,.18);border:1px solid var(--accent-teal);color:var(--text-light);font-size:.85rem;text-decoration:none}
        .file-badge:hover{background:rgba(20,145,155,.3)}

        .pagination table{margin:1rem auto}
        .pagination a{padding:.5rem .75rem;margin:0 .25rem;border:1px solid var(--accent-teal);border-radius:4px;text-decoration:none;color:var(--text-light);transition:all .3s}
        .pagination a:hover{border-color:var(--accent-green);color:var(--accent-green)}
        .pagination span{padding:.5rem .75rem;margin:0 .25rem;border:1px solid var(--accent-green);border-radius:4px;background:var(--accent-green);color:var(--primary-dark);font-weight:600}

        @media (max-width:768px){
            .admin-sidebar{transform:translateX(-100%);width:280px}.admin-sidebar.active{transform:translateX(0)}
            .admin-content{margin-left:0}
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="admin-dashboard">
    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-profile">
            <asp:Image ID="imgAdminAvatar" runat="server" CssClass="admin-avatar" ImageUrl="~/images/admin-avatar.jpg" />
            <h3 class="admin-name"><asp:Label ID="lblAdminName" runat="server" Text='<%# Convert.ToString(Session["AdminName"] ?? Session["AdminId"] ?? "Admin") %>'></asp:Label></h3>
            <p class="admin-role">System Administrator</p>
        </div>
        <ul class="admin-menu">
            <li><a href="AdminDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="AdminDashboard.aspx#materials-section"><i class="fas fa-book"></i> Study Materials</a></li>
            <li><a href="AdminDashboard.aspx#reports-section"><i class="fas fa-chart-bar"></i> Reports</a></li>
            <li><a href="Pricing.aspx"><i class="fas fa-tags"></i> Pricing</a></li>
            <li><a href="AdminScholarships.aspx" class="active"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
            <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>

    <!-- Main -->
    <div class="admin-content">
        <h1 class="section-title">Scholarships</h1>

        <!-- Create / Edit Panel -->
        <section class="pro-panel">
            <div class="pro-top">
                <div>
                    <div class="title">Create Scholarship</div>
                    <div class="muted">Add a new scholarship students can discover and apply to</div>
                </div>
                <span class="pro-chip"><i class="fas fa-shield-heart" style="margin-right:6px"></i>Scholarship</span>
            </div>

            <div class="upload-form" style="margin:0">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Amount (optional)</label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="form-control" placeholder="e.g. 5000" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Deadline</label>
                        <asp:TextBox ID="txtDeadline" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Field</label>
                        <asp:TextBox ID="txtField" runat="server" CssClass="form-control" placeholder="e.g. Computer Science" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Type</label>
                        <asp:TextBox ID="txtType" runat="server" CssClass="form-control" placeholder="Merit-Based / Need-Based / Fellowship" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Application Website (optional)</label>
                        <asp:TextBox ID="txtUrl" runat="server" CssClass="form-control" placeholder="https://…" />
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group" style="flex:2">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4"
                                     placeholder="Brief summary, eligibility, how to apply…" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Requires Documents?</label>
                        <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px">
                            <asp:CheckBox ID="chkRequiresDocs" runat="server" Checked="true" />
                            <span class="muted">Enable in-app ‘Assist’ apply</span>
                        </div>
                        <label class="form-label">Required Documents (comma/pipe separated)</label>
                        <asp:TextBox ID="txtRequiredDocs" runat="server" CssClass="form-control"
                                     Text="ID Copy, Academic Record, Proof of Income" />
                    </div>
                </div>

                <asp:Button ID="btnSave" runat="server" Text="Save Scholarship" CssClass="btn-primary" OnClick="btnSave_Click" />
            </div>
        </section>

        <!-- List Panel -->
        <section class="pro-panel">
            <div class="pro-top">
                <div>
                    <div class="title">Existing Scholarships</div>
                    <div class="muted">Manage what students see in their portal</div>
                </div>
                <span class="pro-chip"><i class="fas fa-list" style="margin-right:6px"></i>Listing</span>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvScholarships" runat="server" AutoGenerateColumns="false" CssClass="premium-table"
                              GridLines="None" AllowPaging="true" PageSize="10"
                              OnPageIndexChanging="gvScholarships_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="ScholarshipId" HeaderText="ID" />
                        <asp:BoundField DataField="Name" HeaderText="Name" />
                        <asp:BoundField DataField="Amount" HeaderText="Amount" DataFormatString="{0:C0}" />
                        <asp:BoundField DataField="Deadline" HeaderText="Deadline" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:BoundField DataField="Field" HeaderText="Field" />
                        <asp:BoundField DataField="Type" HeaderText="Type" />
                        <asp:TemplateField HeaderText="Website">
                            <ItemTemplate>
                                <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("ApplicationUrl"))) 
                                      ? "—" 
                                      : $"<a class='btn-primary' style='padding:.3rem .6rem;font-size:.8rem' target='_blank' href='{Eval("ApplicationUrl")}'>Open</a>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Docs?">
                            <ItemTemplate>
                                <%# Convert.ToBoolean(Eval("RequiresDocuments")) ? "<span class='status-active'>Yes</span>" : "<span class='status-inactive'>No</span>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Active">
                            <ItemTemplate>
                                <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "status-active" : "status-inactive" %>'>
                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                </asp:GridView>
            </div>
        </section>

        <!-- ================= Assisted Applications Panel (NEW) ================= -->
        <section class="pro-panel">
            <div class="pro-top">
                <div>
                    <div class="title">Assisted Applications</div>
                    <div class="muted">Student submissions that need admin review / applying</div>
                </div>
                <span class="pro-chip"><i class="fas fa-file-arrow-down" style="margin-right:6px"></i>Submissions</span>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvApplications" runat="server" AutoGenerateColumns="false" CssClass="premium-table"
                    GridLines="None" AllowPaging="true" PageSize="10"
                    OnPageIndexChanging="gvApplications_PageIndexChanging"
                    OnRowDataBound="gvApplications_RowDataBound">
                    <Columns>
                        <asp:BoundField DataField="ApplicationId" HeaderText="ID" />
                        <asp:BoundField DataField="ScholarshipName" HeaderText="Scholarship" />
                        <asp:BoundField DataField="StudentFullName" HeaderText="Student" />
                        <asp:BoundField DataField="StudentEmail" HeaderText="Email" />
                        <asp:BoundField DataField="SubmittedOn" HeaderText="Submitted" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                        <asp:BoundField DataField="Status" HeaderText="Status" />
                   
                        <asp:TemplateField HeaderText="Zip/PDF">
                            <ItemTemplate>
                                <%# string.IsNullOrWhiteSpace(Convert.ToString(Eval("UploadedZipPath"))) 
                                     ? "—" 
                                     : $"<a class='file-badge' target='_blank' href='{ResolveUrl(Convert.ToString(Eval("UploadedZipPath")))}'>Download</a>" %>
                            </ItemTemplate>
                        </asp:TemplateField>
                     
                        <asp:TemplateField HeaderText="Files">
                            <ItemTemplate>
                                <asp:Repeater ID="rptFiles" runat="server">
                                    <ItemTemplate>
                                        <a class="file-badge" target="_blank" href='<%# ResolveUrl(Convert.ToString(Eval("FilePath"))) %>'>
                                            <%# Eval("OriginalFileName") %>
                                        </a>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                    <EmptyDataTemplate>
                        <div style="text-align:center;padding:2rem;color:var(--accent-green)">No assisted applications yet.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </section>
       
    </div>
</div>
</asp:Content>
