<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UploadMarks.aspx.cs" Inherits="Edugate_Project.UploadMarks" MasterPageFile="~/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Upload Marks</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* =========================
           Palette
        ==========================*/
        :root {
            --primary-dark:#213A57;
            --primary-orange:#0B6477;
            --accent-teal:#14919B;
            --text-light:#DAD1CB;
            --accent-green:#45DFB1;
            --accent-light-green:#80ED99;
            --error-red:#E63946;
        }

        /* =========================
           Base Typography (Inter)
        ==========================*/
        html { font-size: 16px; }
        body {
            background-color: var(--primary-dark);
            color: var(--text-light);
            font-family: 'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;
            font-weight: 400;
            line-height: 1.55;
            margin: 0;
            min-height: 100vh;
        }
        .text-xs{font-size:.75rem}.text-sm{font-size:.875rem}.text-base{font-size:1rem}
        .text-lg{font-size:1.125rem}.text-xl{font-size:1.25rem}.text-2xl{font-size:1.5rem}
        .text-3xl{font-size:2rem}.text-4xl{font-size:2.5rem}
        .fw-600{font-weight:600}.fw-700{font-weight:700}.fw-800{font-weight:800}

        /* =========================
           Layout / Sidebar (unified)
        ==========================*/
        .dashboard-wrapper{display:flex;min-height:100vh;}
        .sidebar{
            width:280px;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            padding:2rem 1rem;
            box-shadow:0 8px 32px 0 rgba(33,58,87,.25);
            overflow-y:auto; position:fixed; height:100vh; z-index:1000;
            border-right:2px solid var(--accent-green);
        }
        .sidebar-header{text-align:center;padding-bottom:1.25rem;border-bottom:1px solid rgba(255,255,255,.2);margin-bottom:1.25rem;}
        .teacher-avatar{
            width:80px;height:80px;border-radius:50%;
            border:3px solid var(--accent-green);margin:0 auto .75rem;
            background:var(--primary-dark);display:flex;align-items:center;justify-content:center;
            font-size:2rem;color:var(--accent-green);
        }
        .sidebar-header h3{color:#fff;margin:.5rem 0 .25rem;font-weight:700;font-size:1.2rem;}
        .sidebar-header p{color:var(--accent-light-green);margin:0;font-size:.85rem;}
        .sidebar-nav{list-style:none;padding:0;margin:0;}
        .sidebar-nav li{margin-bottom:.5rem;}
        .nav-item{
            display:flex;align-items:center;padding:.75rem 1rem;border-radius:6px;
            color:rgba(255,255,255,.9);text-decoration:none;transition:all .2s;font-weight:600;font-size:1rem;
        }
        .nav-item:hover,.nav-item.active{background:rgba(69,223,177,.2);color:var(--text-light);}
        .nav-item i{margin-right:.75rem;width:20px;text-align:center;font-size:1.1rem;}

        /* =========================
           Main / Container
        ==========================*/
        .main-content{
            flex:1;margin-left:280px;padding:2rem;
            background:rgba(33,58,87,.7);min-height:100vh;backdrop-filter:blur(5px);
            border-left:1px solid var(--accent-teal);
        }
        .upload-container{
            max-width:1200px;margin:0 auto;
            padding:2.5rem 2rem 2rem;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            border-radius:24px;box-shadow:0 8px 32px 0 rgba(33,58,87,.25);
            border:2px solid var(--accent-green);
        }
        .header-section{text-align:center;margin-bottom:22px;}
        .header-section h1{color:var(--text-light);font-weight:800;font-size:2.2rem;margin:0 0 6px;}
        .header-sub{font-size:1.05rem;color:var(--accent-light-green);opacity:.95;font-weight:600;margin:0;}

        /* Info panel */
        .info-panel{
            background:rgba(33,58,87,.7);padding:20px;border-radius:16px;margin:18px 0 25px;
            border:1px solid var(--accent-teal);display:flex;flex-wrap:wrap;gap:18px;backdrop-filter:blur(5px);
        }
        .info-item{display:flex;align-items:center;gap:8px;}
        .info-label{font-weight:700;color:var(--accent-light-green);}
        .info-value{font-weight:800;color:var(--accent-green);}

        /* Sections / Cards */
        .form-section{
            background:rgba(33,58,87,.7);border-radius:16px;padding:22px;margin-bottom:22px;
            border:1px solid var(--accent-teal);backdrop-filter:blur(5px);
        }
        .form-section h3{
            color:var(--accent-green);margin:0 0 14px;
            padding-bottom:10px;border-bottom:1px solid var(--accent-teal);
            font-size:1.5rem;font-weight:700;text-align:left;
        }

        /* Inputs */
        .form-group{margin-bottom:16px;}
        .form-label{display:block;margin-bottom:6px;font-weight:600;color:var(--accent-light-green);font-size:.95rem;}
        .form-control{
            width:100%;padding:.8rem 1rem;border:1px solid var(--accent-teal);border-radius:10px;
            font-size:1rem;color:var(--text-light);background:rgba(33,58,87,.6);box-sizing:border-box;
            transition:border-color .2s,box-shadow .2s;font-family:'Inter',sans-serif;
        }
        .form-control:focus{border-color:var(--accent-green);outline:none;box-shadow:0 0 0 2px rgba(69,223,177,.3);}

        /* Buttons */
        .btn{padding:.8rem 1.4rem;border-radius:999px;font-weight:700;cursor:pointer;border:none;transition:all .2s;font-size:1rem;display:inline-block;text-align:center;}
        .btn-primary{
            background:linear-gradient(135deg,var(--accent-green),var(--accent-light-green));color:var(--primary-dark);
        }
        .btn-primary:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(69,223,177,.35);}
        .btn-secondary{background-color:rgba(108,117,125,.85);color:#fff;}
        .btn-secondary:hover{transform:translateY(-2px);box-shadow:0 8px 24px rgba(108,117,125,.35);}
        .file-link{color:var(--accent-green);text-decoration:none;font-weight:700;}
        .file-link:hover{color:var(--accent-light-green);text-decoration:underline;}

        /* Alerts */
        .alert{padding:14px;margin:16px 0;border-radius:10px;font-weight:700;text-align:center;font-size:1rem;border:1px solid transparent;}
        .alert-success{background:rgba(69,223,177,.18);color:var(--accent-green);border-color:var(--accent-green);}
        .alert-danger{background:rgba(230,57,70,.18);color:var(--error-red);border-color:var(--error-red);}

        /* Tables */
        .grid-view{
            width:100%;border-collapse:separate;border-spacing:0;margin-top:14px;
            background:rgba(33,58,87,.55);border:1px solid var(--accent-teal);border-radius:12px;overflow:hidden;
        }
        .grid-view th{
            background:var(--accent-teal);color:#fff;padding:14px;text-align:left;font-weight:700;
        }
        .grid-view td{padding:12px 14px;border-top:1px solid var(--accent-teal);color:var(--text-light);}
        .grid-view tr:nth-child(even){background:rgba(33,58,87,.35);}
        .grid-view tr:hover{background:rgba(20,145,155,.22);}

        small{color:var(--accent-light-green);font-size:.9rem;display:block;margin-top:6px;}

        /* Responsive */
        @media (max-width: 992px){
            .sidebar{width:240px;padding:1.5rem .75rem;}
            .main-content{margin-left:240px;padding:1.5rem;}
        }
        @media (max-width: 767px){
            .dashboard-wrapper{flex-direction:column;}
            .sidebar{width:100%;height:auto;position:relative;}
            .main-content{margin-left:0;padding:1rem;}
            .upload-container{padding:1.25rem;margin-top:.75rem;}
            .header-section h1{font-size:2rem;}
            .info-panel{flex-direction:column;gap:10px;}
        }
        @media (max-width: 480px){
            .form-section{padding:14px;}
            .btn{width:100%;margin-bottom:10px;}
            .grid-view{font-size:.95rem;}
            .grid-view th,.grid-view td{padding:10px 12px;}
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="teacher-avatar"><i class="fas fa-user"></i></div>
                <h3><asp:Label ID="lblSidebarTeacherName" runat="server"></asp:Label></h3>
                <p>Teacher</p>
            </div>
            <ul class="sidebar-nav">
                <li><a href="TeacherDashboard.aspx" class="nav-item"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
                <li><a href="#profile" class="nav-item"><i class="fas fa-user-edit"></i><span>Edit Profile</span></a></li>
                <li><a href="QuizManagement.aspx" class="nav-item"><i class="fas fa-question-circle"></i><span>Manage Quizzes</span></a></li>
                <li><a href="TeacherFileUpload.aspx" class="nav-item"><i class="fas fa-tasks"></i><span>Student Assessments</span></a></li>
                <li><a href="TeacherSendMessage.aspx" class="nav-item"><i class="fas fa-envelope"></i><span>Messages</span></a></li>
                <li><a href="UploadMarks.aspx" class="nav-item active"><i class="fas fa-chart-bar"></i><span>Manage Marks</span></a></li>
                <li>
                    <a href="Default.aspx" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
                </li>
            </ul>
        </div>

        <!-- Main -->
        <div class="main-content">
            <div class="upload-container">
                <div class="header-section">
                    <h1>Student Marks Management</h1>
                    <p class="header-sub">Upload from files or enter marks manually — with live previews</p>
                </div>

                <!-- Debug -->
                <asp:Panel ID="pnlDebug" runat="server" Visible="false" CssClass="alert alert-info">
                    <i class="fas fa-info-circle"></i>
                    <asp:Label ID="lblDebug" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Info -->
                <div class="info-panel">
                    <div class="info-item"><span class="info-label">Teacher:</span><asp:Label ID="lblTeacher" runat="server" CssClass="info-value"></asp:Label></div>
                    <div class="info-item"><span class="info-label">Subject:</span><asp:Label ID="lblSubject" runat="server" CssClass="info-value"></asp:Label></div>
                    <div class="info-item"><span class="info-label">Class:</span><asp:Label ID="lblClass" runat="server" CssClass="info-value"></asp:Label></div>
                </div>

                <!-- Class Selection -->
                <div class="form-section">
                    <h3>Class Selection</h3>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Select Class:" CssClass="form-label"></asp:Label>
                        <asp:DropDownList ID="ddlClasses" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlClasses_SelectedIndexChanged"></asp:DropDownList>
                    </div>
                </div>

                <!-- Upload -->
                <div class="form-section">
                    <h3>Upload Marks from File</h3>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Select Assessment (Quiz / Assignment):" CssClass="form-label"></asp:Label>
                        <asp:DropDownList ID="ddlQuizzes" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Select File:" CssClass="form-label"></asp:Label>
                        <asp:FileUpload ID="fileUploadMarks" runat="server" CssClass="form-control" />
                        <small>Accepted formats: .xlsx, .csv (Max 2MB)</small>
                    </div>
                    <div class="form-group">
                        <asp:Button ID="btnUpload" runat="server" Text="Upload Marks" CssClass="btn btn-primary" OnClick="btnUpload_Click" />
                        <asp:Button ID="btnDownloadTemplate" runat="server" Text="Download Template" CssClass="btn btn-secondary" OnClick="btnDownloadTemplate_Click" />
                    </div>
                </div>

                <!-- Submissions -->
                <div class="form-section">
                    <h3>Student Submissions</h3>
                    <asp:GridView ID="gvStudentSubmissions" runat="server" CssClass="grid-view" AutoGenerateColumns="false" EmptyDataText="No student submissions found.">
                        <Columns>
                            <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                            <asp:BoundField DataField="ClassName" HeaderText="Class" />
                            <asp:TemplateField HeaderText="Submitted File">
                                <ItemTemplate>
                                    <a href='<%# Eval("SubmittedFilePath") %>' target="_blank" class="file-link"><%# Eval("OriginalFileName") %></a>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="SubmissionMessage" HeaderText="Message" NullDisplayText="No message" />
                            <asp:BoundField DataField="SubmissionDate" HeaderText="Submission Date" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- Manual -->
                <div class="form-section">
                    <h3>Manual Marks Entry</h3>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Select Student:" CssClass="form-label"></asp:Label>
                        <asp:DropDownList ID="ddlStudents" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Select Assessment (Quiz / Assignment):" CssClass="form-label"></asp:Label>
                        <asp:DropDownList ID="ddlQuizManual" runat="server" CssClass="form-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlQuizManual_SelectedIndexChanged">
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Score:" CssClass="form-label"></asp:Label>
                        <asp:TextBox ID="txtScore" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Total Marks:" CssClass="form-label"></asp:Label>
                        <asp:TextBox ID="txtTotalMarks" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                        <small>Required for assignments. Quizzes auto-validate against their TotalMarks.</small>
                    </div>
                    <div class="form-group">
                        <asp:Label runat="server" Text="Comments:" CssClass="form-label"></asp:Label>
                        <asp:TextBox ID="txtComments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnAddManual" runat="server" Text="Add Marks" CssClass="btn btn-primary" OnClick="btnAddManual_Click" />
                </div>

                <!-- Live preview for the selected assessment -->
                <div class="form-section">
                    <h3>Marks for Selected Assessment</h3>

                    <!-- Quiz results preview -->
                    <asp:Panel ID="pnlQuizResults" runat="server" Visible="false">
                        <asp:GridView ID="gvQuizResults" runat="server" CssClass="grid-view" AutoGenerateColumns="false"
                            EmptyDataText="No quiz marks found for this quiz.">
                            <Columns>
                                <asp:BoundField DataField="ResultId" HeaderText="Result ID" />
                                <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                                <asp:BoundField DataField="Score" HeaderText="Score" />
                                <asp:BoundField DataField="CompletionDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>

                    <!-- Assignment marks preview -->
                    <asp:Panel ID="pnlAssignmentMarks" runat="server" Visible="false">
                        <asp:GridView ID="gvAssignmentMarks" runat="server" CssClass="grid-view" AutoGenerateColumns="false"
                            EmptyDataText="No assignment marks found for this file.">
                            <Columns>
                                <asp:BoundField DataField="AssignmentResultId" HeaderText="Result ID" />
                                <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                                <asp:BoundField DataField="Score" HeaderText="Score" />
                                <asp:BoundField DataField="TotalMarks" HeaderText="Total Marks" />
                                <asp:BoundField DataField="Percentage" HeaderText="Percentage" DataFormatString="{0}%" />
                                <asp:BoundField DataField="CompletionDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy HH:mm}" />
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>
                </div>

                <!-- Status -->
                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
                    <i class="fas fa-check-circle"></i> <asp:Label ID="lblSuccess" runat="server"></asp:Label>
                </asp:Panel>
                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger">
                    <i class="fas fa-exclamation-circle"></i> <asp:Label ID="lblError" runat="server"></asp:Label>
                </asp:Panel>

                <!-- Recent (quizzes) -->
                <div class="form-section">
                    <h3>Recent Marks</h3>
                    <asp:GridView ID="gvRecentMarks" runat="server" CssClass="grid-view" AutoGenerateColumns="false" EmptyDataText="No marks records found.">
                        <Columns>
                            <asp:BoundField DataField="StudentName" HeaderText="Student Name" />
                            <asp:BoundField DataField="QuizTitle" HeaderText="Quiz" />
                            <asp:BoundField DataField="Score" HeaderText="Score" />
                            <asp:BoundField DataField="UploadDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
