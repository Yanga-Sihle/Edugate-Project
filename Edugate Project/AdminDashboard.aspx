<%@ Page Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" 
    CodeBehind="AdminDashboard.aspx.cs" Inherits="Edugate_Project.AdminDashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>Admin Dashboard - Edugate STEM</title>
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
        .pro-cards{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:14px;margin-bottom:14px}
        .pro-card{background:rgba(33,58,87,.75);border:1px solid var(--accent-teal);border-radius:14px;padding:16px}
        .pro-title{font-weight:700;color:var(--text-light);display:flex;align-items:center;gap:8px}
        .pro-icon{color:var(--accent-green)}
        .pro-value{font-size:1.6rem;font-weight:800;color:var(--accent-green)}
        .pro-label{font-size:.9rem;color:var(--accent-light-green);opacity:.9}
        .pro-grid{display:grid;grid-template-columns:repeat(12,minmax(0,1fr));gap:14px}
        .pro-donut{grid-column:span 5;background:rgba(33,58,87,.75);border:1px solid var(--accent-teal);border-radius:14px;padding:16px}
        .pro-bars{grid-column:span 7;background:rgba(33,58,87,.75);border:1px solid var(--accent-teal);border-radius:14px;padding:16px}
        .chart-wrap{position:relative;width:100%;height:320px}
        .pro-select{appearance:none;background:var(--primary-dark);color:var(--text-light);border:2px solid var(--accent-teal);border-radius:8px;padding:.45rem .75rem;font-weight:700}
        .pro-select:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 3px rgba(69,223,177,.2)}
        .upload-form{background:rgba(33,58,87,.8);padding:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);margin-bottom:2rem;border:1px solid var(--accent-teal);backdrop-filter:blur(5px)}
        .form-row{display:flex;gap:1.5rem;margin-bottom:1.5rem}.form-group{flex:1}
        .form-label{display:block;margin-bottom:.5rem;font-weight:600;color:var(--text-light)}
        .form-control{width:100%;padding:.8rem 1rem;border:2px solid var(--accent-teal);border-radius:10px;font-size:1rem;background:var(--primary-dark);color:var(--text-light);transition:all .3s ease}
        .form-control:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 3px rgba(69,223,177,.2)}
        .form-select{appearance:none;background-image:url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");background-repeat:no-repeat;background-position:right .75rem center;background-size:1em}
        .file-upload{margin-top:.5rem}.file-upload-input{width:.1px;height:.1px;opacity:0;overflow:hidden;position:absolute;z-index:-1}
        .file-upload-label{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:2rem;border:2px dashed var(--accent-teal);border-radius:10px;cursor:pointer;transition:all .3s ease;text-align:center;background:rgba(33,58,87,.5)}
        .file-upload-label:hover{border-color:var(--accent-green);background:rgba(69,223,177,.1)}.file-upload-label i{font-size:2rem;color:var(--accent-green);margin-bottom:.5rem}
        .file-name{margin-top:.75rem;font-size:.9rem;color:var(--accent-light-green)}
        .btn-primary{background:var(--accent-green);color:var(--primary-dark);border:none;padding:.8rem 1.5rem;border-radius:50px;font-size:1rem;font-weight:700;cursor:pointer;transition:all .3s ease;display:inline-block;text-align:center}
        .btn-primary:hover{background:var(--primary-dark);color:var(--accent-green);box-shadow:0 0 0 1px var(--accent-green);transform:translateY(-3px)}
        .table-responsive{overflow-x:auto;margin-bottom:2rem;border-radius:16px;box-shadow:0 4px 15px rgba(0,0,0,.1);border:1px solid var(--accent-teal);background:rgba(33,58,87,.8);backdrop-filter:blur(5px)}
        .materials-table,.premium-table{width:100%;border-collapse:collapse}
        .materials-table th,.premium-table th{background:rgba(20,145,155,.3);padding:1rem;text-align:left;font-weight:700;color:var(--text-light);border-bottom:2px solid var(--accent-teal)}
        .materials-table td,.premium-table td{padding:1rem;border-bottom:1px solid rgba(69,223,177,.1);vertical-align:middle;color:var(--text-light)}
        .materials-table tr:hover,.premium-table tr:hover{background:rgba(69,223,177,.1)}
        .status-active{display:inline-block;padding:.25rem .75rem;background:rgba(69,223,177,.2);color:var(--accent-green);border-radius:50px;font-size:.85rem;font-weight:600}
        .status-inactive{display:inline-block;padding:.25rem .75rem;background:rgba(108,117,125,.2);color:var(--text-light);border-radius:50px;font-size:.85rem;font-weight:600}
        .status-pending{display:inline-block;padding:.25rem .75rem;background:rgba(248,150,30,.2);color:#f8961e;border-radius:50px;font-size:.85rem;font-weight:600}
        .reports-tabs{display:flex;border-bottom:1px solid var(--accent-teal);margin-bottom:1.5rem}
        .tab-btn{padding:.75rem 1.5rem;background:none;border:none;cursor:pointer;font-size:.95rem;font-weight:600;color:var(--text-light);position:relative;margin-right:.5rem;transition:all .3s}
        .tab-btn:hover{color:var(--accent-green)}.tab-btn.active{color:var(--accent-green)}
        .tab-btn.active:after{content:'';position:absolute;bottom:-1px;left:0;width:100%;height:2px;background:var(--accent-green)}
        .tab-content{display:none}.tab-content.active{display:block}
        .pagination table{margin:1rem auto}
        .pagination a{padding:.5rem .75rem;margin:0 .25rem;border:1px solid var(--accent-teal);border-radius:4px;text-decoration:none;color:var(--text-light);transition:all .3s}
        .pagination a:hover{border-color:var(--accent-green);color:var(--accent-green)}
        .pagination span{padding:.5rem .75rem;margin:0 .25rem;border:1px solid var(--accent-green);border-radius:4px;background:var(--accent-green);color:var(--primary-dark);font-weight:600}
        .action-btn{background:none;border:none;color:var(--text-light);cursor:pointer;margin:0 .25rem;font-size:1rem;transition:all .3s}
        .action-btn:hover{color:var(--accent-green);transform:scale(1.1)}
        @media (max-width:768px){
            .admin-sidebar{transform:translateX(-100%);width:280px}.admin-sidebar.active{transform:translateX(0)}
            .admin-content{margin-left:0}
            .pro-cards{grid-template-columns:repeat(2,minmax(0,1fr))}
            .pro-donut{grid-column:span 12}
            .pro-bars{grid-column:span 12}
        }
        @media (max-width:576px){.pro-cards{grid-template-columns:1fr}.section-title{font-size:1.5rem}}
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
            <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="#materials-section"><i class="fas fa-book"></i> Study Materials</a></li>
            <li><a href="#reports-section"><i class="fas fa-chart-bar"></i> Reports</a></li>
            <li><a href="Pricing.aspx"><i class="fas fa-tags"></i> Pricing</a></li>
            <li><a href="AdminScholarships.aspx"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
            <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>

    <!-- Main -->
    <div class="admin-content">
        <h1 class="section-title">Admin Dashboard</h1>
       
        <section class="pro-panel">

            <div class="pro-top">
                <div>
                    <div class="title">Overview</div>
                    <div class="muted">Snapshot of your platform activity</div>
                </div>

                <span class="pro-chip"><i class="far fa-calendar-alt" style="margin-right:6px"></i>Last 90 days</span>
               

                    <asp:Button ID="btnExportExcel" runat="server" Text="Export (Excel)"
CssClass="btn-primary" OnClick="btnExportExcel_Click" CausesValidation="false" UseSubmitBehavior="false" />

                 

            </div>

            <!-- Mini Cards -->
            <div class="pro-cards">
                <!-- Revenue -->
                <div class="pro-card">
                    <div class="pro-title"><i class="fas fa-sack-dollar pro-icon"></i> Revenue</div>
                    <div class="pro-value"><asp:Label ID="lblRevenue" runat="server" Text="R 0.00"></asp:Label></div>
                    <div class="pro-label">Premium + Standard (approved payments)</div>
                </div>

                <!-- Learner Performance -->
                <div class="pro-card">
                    <div class="pro-title"><i class="fas fa-chart-line pro-icon"></i> Learner Performance</div>
                    <div class="pro-value"><asp:Label ID="lblLearnerPerformance" runat="server" Text="--"></asp:Label>%</div>
                    <div class="pro-label">Overall average across students</div>
                </div>

                <div class="pro-card">
                    <div class="pro-title"><i class="fas fa-gem pro-icon"></i> Premium Schools</div>
                    <div class="pro-value"><asp:Label ID="lblPremiumSchools" runat="server" Text="0"></asp:Label></div>
                    <div class="pro-label">Currently premium</div>
                </div>
                <div class="pro-card">
                    <div class="pro-title"><i class="fas fa-folder-open pro-icon"></i> Study Materials</div>
                    <div class="pro-value"><asp:Label ID="lblMaterials" runat="server" Text="0"></asp:Label></div>
                    <div class="pro-label">Items in library</div>
                </div>
            </div>

            <!-- Charts Row -->
            <div class="pro-grid">
                <!-- Doughnut / Line: Premium vs Standard -->
                <div class="pro-donut">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                        <div class="pro-title"><i class="fas fa-balance-scale pro-icon"></i> Premium vs Standard</div>
                        <div>
                            <label style="margin-right:8px;font-weight:700;color:var(--text-light)">View:</label>
                            <select id="selectPremiumView" class="pro-select">
                                <option value="pie" selected>Pie</option>
                                <option value="line">Line</option>
                            </select>
                        </div>
                    </div>
                    <div class="chart-wrap"><canvas id="chartPremium"></canvas></div>
                </div>

               
                <div class="pro-bars">
                    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
                        <div class="pro-title"><i class="fas fa-chart-bar pro-icon"></i> Schools by Count</div>
                        <div>
                            <label style="margin-right:8px;font-weight:700;color:var(--text-light)">View:</label>
                            <select id="selectMetric" class="pro-select">
                                <option value="students" selected>Students</option>
                                <option value="teachers">Teachers</option>
                            </select>
                        </div>
                    </div>
                    <div class="chart-wrap"><canvas id="chartTopSchools"></canvas></div>
                </div>
            </div>

            <!-- Hidden fields for charts -->
            <asp:HiddenField ID="hfPremiumCount" runat="server" />
            <asp:HiddenField ID="hfStandardCount" runat="server" />
            <asp:HiddenField ID="hfSchoolLabels" runat="server" />
            <asp:HiddenField ID="hfStudentCounts" runat="server" />
            <asp:HiddenField ID="hfTeacherCounts" runat="server" />
            <asp:HiddenField ID="hfMonthLabels" runat="server" />
            <asp:HiddenField ID="hfPremiumMonthly" runat="server" />
            <asp:HiddenField ID="hfSchoolMonthly" runat="server" />
            <asp:HiddenField ID="hfPremiumChartPng" runat="server" />
<asp:HiddenField ID="hfTopSchoolsChartPng" runat="server" />

        </section>

        <!-- ====== Study Materials ====== -->
        <section id="materials-section">
            <h2 class="section-title">Upload Study Material</h2>
            <div class="upload-form">
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Material Type</label>
                        <asp:DropDownList ID="ddlMaterialType" runat="server" CssClass="form-control form-select">
                            <asp:ListItem Value="">Select Type</asp:ListItem>
                            <asp:ListItem Value="Question Paper">Question Paper</asp:ListItem>
                            <asp:ListItem Value="Textbook">Textbook</asp:ListItem>
                            <asp:ListItem Value="Video">Video Lesson</asp:ListItem>
                            <asp:ListItem Value="Notes">Study Notes</asp:ListItem>
                            <asp:ListItem Value="Other">Other</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Subject</label>
                        <asp:DropDownList ID="ddlSubject" runat="server" CssClass="form-control form-select">
                            <asp:ListItem Value="">Select Subject</asp:ListItem>
                            <asp:ListItem Value="Mathematics">Mathematics</asp:ListItem>
                            <asp:ListItem Value="Physical Sciences">Physical Sciences</asp:ListItem>
                            <asp:ListItem Value="Life Sciences">Life Sciences</asp:ListItem>
                            <asp:ListItem Value="Information Technology">Information Technology</asp:ListItem>
                            <asp:ListItem Value="Engineering">Engineering</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label class="form-label">Grade Level</label>
                        <asp:DropDownList ID="ddlGrade" runat="server" CssClass="form-control form-select">
                            <asp:ListItem Value="">Select Grade</asp:ListItem>
                            <asp:ListItem Value="10">Grade 10</asp:ListItem>
                            <asp:ListItem Value="11">Grade 11</asp:ListItem>
                            <asp:ListItem Value="12">Grade 12</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Title</label>
                        <asp:TextBox ID="txtMaterialTitle" runat="server" CssClass="form-control" placeholder="Enter material title"></asp:TextBox>
                    </div>
                </div>
                <div class="form-group">
                    <label class="form-label">Description</label>
                    <asp:TextBox ID="txtMaterialDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Enter material description"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Upload File</label>
                    <div class="file-upload">
                        <asp:FileUpload ID="fileMaterial" runat="server" CssClass="file-upload-input" />
                        <label for="<%= fileMaterial.ClientID %>" class="file-upload-label">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <span>Choose file or drag & drop here</span>
                        </label>
                        <div class="file-name">
                            <asp:Label ID="lblFileName" runat="server" Text="No file selected"></asp:Label>
                        </div>
                    </div>
                </div>
                <asp:Button ID="btnUploadMaterial" runat="server" Text="Upload Material" CssClass="btn-primary" OnClick="btnUploadMaterial_Click" />
            </div>

            <h3 class="section-title">Recent Uploads</h3>
            <div class="table-responsive">
                <asp:GridView ID="gvMaterials" runat="server" CssClass="materials-table" AutoGenerateColumns="false" GridLines="None"
                    AllowPaging="true" PageSize="5" OnPageIndexChanging="gvMaterials_PageIndexChanging">
                    <Columns>
                        <asp:BoundField DataField="Title" HeaderText="Title" />
                        <asp:BoundField DataField="Type" HeaderText="Type" />
                        <asp:BoundField DataField="Subject" HeaderText="Subject" />
                        <asp:BoundField DataField="Grade" HeaderText="Grade" />
                        <asp:BoundField DataField="UploadDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <button class="action-btn" title="View"><i class="fas fa-eye"></i></button>
                                <button class="action-btn" title="Download"><i class="fas fa-download"></i></button>
                                <button class="action-btn" title="Delete"><i class="fas fa-trash"></i></button>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <PagerStyle CssClass="pagination" />
                    <EmptyDataTemplate>
                        <div style="text-align:center;padding:2rem;color:var(--accent-green);">No materials uploaded yet.</div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </section>

        <!-- ===== Reports & Analytics ===== -->
        <section id="reports-section">
            <h2 class="section-title">Reports & Analytics</h2>
            <div class="reports-tabs">
                <button class="tab-btn active" onclick="openTab(event, 'schools-tab'); return false;">Schools</button>
                <button class="tab-btn" onclick="openTab(event, 'learners-tab'); return false;">Learners</button>
                <button class="tab-btn" onclick="openTab(event, 'premium-tab'); return false;">Premium Status</button>
                <button class="tab-btn" onclick="openTab(event, 'payments-tab'); return false;">Payments</button>
            </div>

            <!-- Schools -->
            <div id="schools-tab" class="tab-content active">
                <div class="table-responsive">
                    <asp:GridView ID="gvSchools" runat="server" CssClass="premium-table" AutoGenerateColumns="false" GridLines="None"
                        AllowPaging="true" PageSize="5" OnPageIndexChanging="gvSchools_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="SchoolName" HeaderText="School Name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="Phone" HeaderText="Phone" />
                            <asp:BoundField DataField="GradeLevel" HeaderText="Grade Level" />
                            <asp:BoundField DataField="RegistrationDate" HeaderText="Registration Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="ActiveLearners" HeaderText="Active Learners" />
                            <asp:TemplateField HeaderText="Premium">
                                <ItemTemplate>
                                    <span class='<%# Eval("IsPremium").ToString() == "True" ? "status-active" : "status-inactive" %>'>
                                        <%# Eval("IsPremium").ToString() == "True" ? "Premium" : "Standard" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pagination" />
                    </asp:GridView>
                </div>
            </div>

            <!-- Learners -->
            <div id="learners-tab" class="tab-content">
                <div class="table-responsive">
                    <asp:GridView ID="gvLearners" runat="server" CssClass="premium-table" AutoGenerateColumns="false" GridLines="None"
                        AllowPaging="true" PageSize="5" OnPageIndexChanging="gvLearners_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="Gender" HeaderText="Gender" />
                            <asp:BoundField DataField="Grade" HeaderText="Grade" />
                            <asp:BoundField DataField="SchoolName" HeaderText="School" />
                            <asp:BoundField DataField="RegistrationDate" HeaderText="Registration Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="MaterialsAccessed" HeaderText="Materials Accessed" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# Eval("IsActive").ToString() == "1" ? "status-active" : "status-inactive" %>'>
                                        <%# Eval("IsActive").ToString() == "1" ? "Active" : "Inactive" %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pagination" />
                    </asp:GridView>
                </div>
            </div>

            <!-- Premium Status -->
            <div id="premium-tab" class="tab-content">
                <div class="table-responsive">
                   <%-- <asp:GridView ID="gvPremiumSchools" runat="server" CssClass="premium-table" AutoGenerateColumns="false" GridLines="None"
                        AllowPaging="true" PageSize="5" OnPageIndexChanging="gvPremiumSchools_PageIndexChanging">
                        <Columns>
                            <asp:BoundField DataField="SchoolCode" HeaderText="School Code" />
                            <asp:BoundField DataField="SchoolName" HeaderText="School Name" />
                            <asp:BoundField DataField="Email" HeaderText="Email" />
                            <asp:BoundField DataField="Phone" HeaderText="Phone" />
                            <asp:BoundField DataField="GradeLevel" HeaderText="Grade Level" />
                            <asp:BoundField DataField="RegistrationDate" HeaderText="Registration Date" />
                            <asp:BoundField DataField="PaymentMethod" HeaderText="Payment Method" />
                            <asp:BoundField DataField="PaymentVerified" HeaderText="Verified" />
                            <asp:BoundField DataField="ChequeNumber" HeaderText="Cheque Number" />
                            <asp:BoundField DataField="ChequeDate" HeaderText="Cheque Date" />
                            <asp:BoundField DataField="ChequeBank" HeaderText="Bank" />
                        </Columns>
                        <PagerStyle CssClass="pagination" />
                    </asp:GridView>--%>
                    <asp:GridView ID="gvSubscriptionRequests"
    runat="server"
    AutoGenerateColumns="false"
    GridLines="None"
    CssClass="table"
    Visible="true"
    OnRowCommand="gvSubscriptionRequests_RowCommand">

    <Columns>
        <asp:BoundField DataField="SchoolCode" HeaderText="School Code" />
        <asp:BoundField DataField="IsPremium" HeaderText="Requested Subscription" SortExpression="IsPremium" />
        <asp:BoundField DataField="RequestDate" HeaderText="Request Date" SortExpression="RequestDate" />
        <asp:BoundField DataField="Status" HeaderText="Status" SortExpression="Status" />

        <%-- Approve --%>
        <asp:TemplateField>
            <ItemTemplate>
                <asp:Button ID="btnApprove"
                    runat="server"
                    Text="Approve"
                    CommandName="Approve"
                    CommandArgument='<%# Eval("RequestId") %>' />
            </ItemTemplate>
        </asp:TemplateField>

        <%-- Reject --%>
        <asp:TemplateField>
            <ItemTemplate>
                <asp:Button ID="btnReject"
                    runat="server"
                    Text="Reject"
                    CommandName="Reject"
                    CommandArgument='<%# Eval("RequestId") %>' />
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>

                </div>
            </div>

            <!-- Payments -->
            <div id="payments-tab" class="tab-content">
                <div class="table-responsive">
                    <asp:GridView ID="gvSchoolPayments" runat="server" CssClass="premium-table" AutoGenerateColumns="false" GridLines="None"
                        AllowPaging="true" PageSize="5" OnPageIndexChanging="gvSchoolPayments_PageIndexChanging"
                        OnRowCommand="gvSchoolPayments_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="SchoolName" HeaderText="School Name" />
                            <asp:BoundField DataField="Plan" HeaderText="Plan" />
                            <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice #" />
                         
                            <asp:BoundField DataField="PaymentDate" HeaderText="Payment Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="StartDate" HeaderText="Start Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="EndDate" HeaderText="End Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="PaymentMethod" HeaderText="Method" />
                            <asp:TemplateField HeaderText="Cheque Info">
                                <ItemTemplate>
                                    <%# Eval("PaymentMethod").ToString() == "Cheque" ? $"Cheque #{Eval("ChequeNumber")} ({Eval("ChequeBank")})" : "N/A" %>
                                </ItemTemplate>
                            </asp:TemplateField>
                        <asp:TemplateField HeaderText="Proof/Invoice">
  <ItemTemplate>
    <%# string.IsNullOrEmpty(Convert.ToString(Eval("FileName")))
        ? "N/A"
        : ("<a class='btn-primary' style='padding:.3rem .6rem;font-size:.8rem' target='_blank' href='"
           + Page.ResolveUrl("~/FileDownload.ashx")
           + "?file=" + Server.UrlEncode(Convert.ToString(Eval("FileName")))
           + "&original=" + Server.UrlEncode(Convert.ToString(Eval("InvoiceNumber")) + ".pdf")
           + "'>Download</a>") %>
  </ItemTemplate>
</asp:TemplateField>


                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# GetPaymentStatusClass(Eval("PaymentVerified"), Eval("PaymentMethod")) %>'>
                                        <%# GetPaymentStatusText(Eval("PaymentVerified"), Eval("PaymentMethod")) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <PagerStyle CssClass="pagination" />
                    </asp:GridView>
                </div>

       


            </div>
        </section>

        <!-- ===== Payment Verification (admin actions) ===== -->
        <asp:UpdatePanel ID="updPayments" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <section id="payments-section">
                    <div class="card mt-4">
                        <div class="card-header bg-primary text-white"><h5>Payment Verification</h5></div>

                        <!-- Pending to verify -->
                        <asp:GridView ID="gvPendingPayments" runat="server" AutoGenerateColumns="false"
                            CssClass="premium-table" OnRowCommand="gvPendingPayments_RowCommand"
                            EmptyDataText="No pending payments to verify"
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvPendingPayments_PageIndexChanging"
                            DataKeyNames="SubmissionId">
                            <Columns>
                                <asp:BoundField DataField="SubmissionId" HeaderText="ID" Visible="false" />
                                <asp:BoundField DataField="SchoolName" HeaderText="School" />
                                <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice #" />
                                <asp:BoundField DataField="PaymentMethod" HeaderText="Method" />
                          <asp:TemplateField HeaderText="Invoice/Proof">
  <ItemTemplate>
    <%# string.IsNullOrEmpty(Convert.ToString(Eval("FileName")))
        ? "N/A"
        : ("<a class='btn-primary' style='padding:.3rem .6rem;font-size:.8rem' target='_blank' href='"
           + Page.ResolveUrl("~/FileDownload.ashx")
           + "?file=" + Server.UrlEncode(Convert.ToString(Eval("FileName")))
           + "&original=" + Server.UrlEncode(Convert.ToString(Eval("OriginalFileName")))
           + "'>" + HttpUtility.HtmlEncode(Convert.ToString(Eval("OriginalFileName"))) + "</a>") %>
  </ItemTemplate>
</asp:TemplateField>


                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# GetStatusClass(Convert.ToString(Eval("Status"))) %>'><%# Eval("Status") %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actions">
                                    <ItemTemplate>
                                        <asp:Button ID="btnApprove" runat="server" Text="Approve" CommandName="Approve"
                                            CommandArgument='<%# Eval("SubmissionId") %>' CssClass="btn btn-sm btn-success"
                                            Visible='<%# Convert.ToString(Eval("Status")) == "Pending" %>' />
                                        <asp:Button ID="btnReject" runat="server" Text="Reject" CommandName="Reject"
                                            CommandArgument='<%# Eval("SubmissionId") %>' CssClass="btn btn-sm btn-danger"
                                            Visible='<%# Convert.ToString(Eval("Status")) == "Pending" %>' />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <PagerSettings Mode="NumericFirstLast" />
                            <PagerStyle CssClass="pagination" />
                        </asp:GridView>

                        <!-- All submissions (history) -->
                        <div class="card-body">
                            <asp:GridView ID="gvPaymentSubmissions" runat="server" AutoGenerateColumns="false"
                                CssClass="premium-table" OnRowCommand="gvPaymentSubmissions_RowCommand"
                                EmptyDataText="No pending payments to verify"
                                AllowPaging="true" PageSize="10" OnPageIndexChanging="gvPaymentSubmissions_PageIndexChanging"
                                DataKeyNames="SubmissionId">
                                <Columns>
                                    <asp:BoundField DataField="SubmissionId" HeaderText="ID" Visible="false" />
                                    <asp:BoundField DataField="SchoolName" HeaderText="School" />
                                    <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice #" />
                                    <asp:BoundField DataField="PaymentMethod" HeaderText="Method" />
                                    <asp:BoundField DataField="SubmissionDate" HeaderText="Submitted On" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                                 <asp:TemplateField HeaderText="Proof">
    <ItemTemplate>
        <%# string.IsNullOrEmpty(Convert.ToString(Eval("FileName")))
            ? "N/A"
            : ("<a class='btn-primary' style='padding:.3rem .6rem;font-size:.8rem' target='_blank' href='"
               + Page.ResolveUrl("~/FileDownload.ashx")
               + "?file=" + Server.UrlEncode(Convert.ToString(Eval("FileName")))
               + "&original=" + Server.UrlEncode(Convert.ToString(Eval("OriginalFileName")))
               + "'>View</a>") %>
    </ItemTemplate>
</asp:TemplateField>


                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate>
                                            <span class='<%# GetStatusClass(Convert.ToString(Eval("Status"))) %>'><%# Eval("Status") %></span>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Actions">
                                        <ItemTemplate>
                                           <asp:LinkButton 
                                             runat="server"
                                               CommandName="ViewFile"
                                                    CommandArgument='<%# Eval("FileName") %>'
                                                           Text="View" />

                                            <asp:LinkButton ID="lnkVerify" runat="server" CommandName="VerifyPayment"
                                                CommandArgument='<%# Eval("SubmissionId") %>' Text="Verify" CssClass="btn-primary"
                                                style="padding:.3rem .6rem;font-size:.8rem" />
                                            <asp:LinkButton ID="lnkReject" runat="server" CommandName="RejectPayment"
                                                CommandArgument='<%# Eval("SubmissionId") %>' Text="Reject" CssClass="btn-secondary"
                                                style="padding:.3rem .6rem;font-size:.8rem" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                                <PagerStyle CssClass="pagination" />
                            </asp:GridView>
                        </div>
                    </div>
                </section>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="gvPendingPayments" EventName="RowCommand" />
                <asp:AsyncPostBackTrigger ControlID="gvPendingPayments" EventName="PageIndexChanging" />
                <asp:AsyncPostBackTrigger ControlID="gvPaymentSubmissions" EventName="RowCommand" />
                <asp:AsyncPostBackTrigger ControlID="gvPaymentSubmissions" EventName="PageIndexChanging" />
                <asp:PostBackTrigger ControlID="btnExportExcel" />
                

            </Triggers>
        </asp:UpdatePanel>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    function getCanvasDataURLSafe(id) {
        var c = document.getElementById(id);
        if (!c) return "";
        try { return c.toDataURL("image/png"); } catch (e) { return ""; }
    }

    function prepAndExportPdf() {
        // Capture charts into hidden fields; if CORS-tainted, values will be empty strings (that’s fine)
        document.getElementById('<%= hfPremiumChartPng.ClientID %>').value   = getCanvasDataURLSafe('chartPremium');
      document.getElementById('<%= hfTopSchoolsChartPng.ClientID %>').value = getCanvasDataURLSafe('chartTopSchools');

      // IMPORTANT: return true to let WebForms do a regular postback
      return true;
  }
    document.addEventListener('DOMContentLoaded', function () {
        var fu = document.getElementById('<%= fileMaterial.ClientID %>');
        if (fu) fu.addEventListener('change', function (e) {
            var nm = e.target.files[0] ? e.target.files[0].name : 'No file selected';
            document.getElementById('<%= lblFileName.ClientID %>').textContent = nm;
        });

        window.openTab = function (evt, tabName) {
            var i, tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) tabcontent[i].classList.remove("active");
            var tabbuttons = document.getElementsByClassName("tab-btn");
            for (i = 0; i < tabbuttons.length; i++) tabbuttons[i].classList.remove("active");
            document.getElementById(tabName).classList.add("active");
            evt.currentTarget.classList.add("active");
            if (evt.preventDefault) evt.preventDefault();
            return false;
        };

        window.showAlert = function (message, type) {
            var wrap = document.createElement('div');
            wrap.style.position = 'fixed'; wrap.style.bottom = '20px'; wrap.style.right = '20px';
            wrap.style.zIndex = '9999'; wrap.style.padding = '12px 16px'; wrap.style.borderRadius = '12px';
            wrap.style.fontWeight = '800';
            wrap.style.background = (type === 'success' ? '#28a745' : (type === 'error' ? '#dc3545' : '#14919B'));
            wrap.style.color = '#fff'; wrap.textContent = message;
            document.body.appendChild(wrap);
            setTimeout(function () { document.body.removeChild(wrap); }, 3500);
        };

        const premium = parseInt(document.getElementById('<%= hfPremiumCount.ClientID %>').value || '0', 10);
        const standard = parseInt(document.getElementById('<%= hfStandardCount.ClientID %>').value || '0', 10);
        const labels = JSON.parse(document.getElementById('<%= hfSchoolLabels.ClientID %>').value || '[]');
        const studentCounts = JSON.parse(document.getElementById('<%= hfStudentCounts.ClientID %>').value || '[]');
        const teacherCounts = JSON.parse(document.getElementById('<%= hfTeacherCounts.ClientID %>').value || '[]');

        const monthLabels = JSON.parse(document.getElementById('<%= hfMonthLabels.ClientID %>').value || '[]');
        const premiumMonthly = JSON.parse(document.getElementById('<%= hfPremiumMonthly.ClientID %>').value || '[]');
        const schoolsMonthly = JSON.parse(document.getElementById('<%= hfSchoolMonthly.ClientID %>').value || '[]');

        function makeGradient(ctx) {
            const g = ctx.createLinearGradient(0, 0, 0, 300);
            g.addColorStop(0, 'rgba(69,223,177,0.45)');
            g.addColorStop(1, 'rgba(69,223,177,0.05)');
            return g;
        }
        function makeGradient2(ctx) {
            const g = ctx.createLinearGradient(0, 0, 0, 300);
            g.addColorStop(0, 'rgba(20,145,155,0.45)');
            g.addColorStop(1, 'rgba(20,145,155,0.05)');
            return g;
        }

        const premiumCanvas = document.getElementById('chartPremium');
        let premiumChart;

        function buildPremiumPie() {
            return new Chart(premiumCanvas, {
                type: 'doughnut',
                data: {
                    labels: ['Premium', 'Standard'],
                    datasets: [{ data: [premium, standard], backgroundColor: ['#45DFB1', '#14919B'], borderWidth: 0 }]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { labels: { color: '#DAD1CB', font: { weight: 700 } } } }
                }
            });
        }

        function buildPremiumLine() {
            const ctx = premiumCanvas.getContext('2d');
            return new Chart(premiumCanvas, {
                type: 'line',
                data: {
                    labels: monthLabels,
                    datasets: [
                        {
                            label: 'Premium activations',
                            data: premiumMonthly,
                            borderColor: '#45DFB1',
                            backgroundColor: makeGradient(ctx),
                            fill: true,
                            tension: .35,
                            borderWidth: 2
                        },
                        {
                            label: 'School registrations',
                            data: schoolsMonthly,
                            borderColor: '#14919B',
                            backgroundColor: makeGradient2(ctx),
                            fill: true,
                            tension: .35,
                            borderWidth: 2
                        }
                    ]
                },
                options: {
                    responsive: true, maintainAspectRatio: false,
                    plugins: { legend: { labels: { color: '#DAD1CB' } } },
                    scales: {
                        x: { ticks: { color: '#DAD1CB' }, grid: { color: 'rgba(255,255,255,.08)' } },
                        y: { ticks: { color: '#DAD1CB' }, grid: { color: 'rgba(255,255,255,.08)' }, beginAtZero: true }
                    }
                }
            });
        }

        function rebuildPremiumChart(view) {
            if (premiumChart) { premiumChart.destroy(); }
            premiumChart = (view === 'line') ? buildPremiumLine() : buildPremiumPie();
        }

        rebuildPremiumChart('pie');
        document.getElementById('selectPremiumView').addEventListener('change', function () {
            rebuildPremiumChart(this.value);
        });

        const ctxBar = document.getElementById('chartTopSchools');
        const barChart = new Chart(ctxBar, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{ label: 'Students', data: studentCounts, backgroundColor: '#45DFB1', borderWidth: 0 }]
            },
            options: {
                responsive: true, maintainAspectRatio: false,
                plugins: { legend: { labels: { color: '#DAD1CB' } } },
                scales: {
                    x: { ticks: { color: '#DAD1CB' }, grid: { color: 'rgba(255,255,255,.08)' } },
                    y: { ticks: { color: '#DAD1CB' }, grid: { color: 'rgba(255,255,255,.08)' }, beginAtZero: true }
                }
            }
        });
        function getCanvasDataURLSafe(id) {
            const c = document.getElementById(id);
            if (!c) return "";
            try { return c.toDataURL("image/png"); } catch (e) { return ""; }
        }

        document.getElementById('selectMetric').addEventListener('change', function () {
            const isTeachers = this.value === 'teachers';
            barChart.data.datasets[0].label = isTeachers ? 'Teachers' : 'Students';
            barChart.data.datasets[0].data = isTeachers ? teacherCounts : studentCounts;
            barChart.update();
        });
    });
</script>
</asp:Content>
