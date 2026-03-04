<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherFileUpload.aspx.cs" Inherits="Edugate_Project.TeacherFileUpload" MasterPageFile="~/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Upload Files & Messages</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        /* =========================
           Palette
        ==========================*/
        :root{
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
        html{font-size:16px;}
        body{
            background-color:var(--primary-dark);
            color:var(--text-light);
            font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;
            font-weight:400;
            line-height:1.55;
            margin:0; min-height:100vh;
        }
        .text-xs{font-size:.75rem}.text-sm{font-size:.875rem}.text-base{font-size:1rem}
        .text-lg{font-size:1.125rem}.text-xl{font-size:1.25rem}.text-2xl{font-size:1.5rem}
        .text-3xl{font-size:2rem}.text-4xl{font-size:2.5rem}
        .fw-600{font-weight:600}.fw-700{font-weight:700}.fw-800{font-weight:800}

        /* =========================
           Layout
        ==========================*/
        .dashboard-wrapper{display:flex;min-height:100vh;}

        /* Sidebar (unified with TeacherDashboard) */
        .sidebar{
            width:280px;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            padding:2rem 1rem;
            box-shadow:0 8px 32px 0 rgba(33,58,87,.25);
            position:fixed;height:100vh;overflow-y:auto;
            border-right:2px solid var(--accent-green);
            z-index:1000;
        }
        .sidebar-header{
            text-align:center;padding-bottom:1.25rem;
            border-bottom:1px solid rgba(255,255,255,.2);margin-bottom:1.25rem;
        }
        .teacher-avatar{
            width:80px;height:80px;border-radius:50%;border:3px solid var(--accent-green);
            margin:0 auto .75rem;background:var(--primary-dark);
            display:flex;align-items:center;justify-content:center;color:var(--accent-green);font-size:2rem;
        }
        .sidebar-header h3{color:#fff;margin:.5rem 0 .25rem;font-weight:700;font-size:1.2rem;}
        .sidebar-header p{color:var(--accent-light-green);margin:0;font-size:.85rem;}

        .sidebar-nav{list-style:none;padding:0;margin:0;}
        .sidebar-nav li{margin-bottom:.5rem;}
        .nav-item{
            display:flex;align-items:center;padding:.75rem 1rem;border-radius:6px;
            text-decoration:none;color:rgba(255,255,255,.9);
            transition:all .2s ease;font-size:1rem;font-weight:600;
        }
        .nav-item:hover,.nav-item.active{background:rgba(69,223,177,.2);color:var(--text-light);}
        .nav-item i{margin-right:.75rem;width:20px;text-align:center;font-size:1.1rem;}

        /* Main shell */
        .main-content{
            flex:1;margin-left:280px;padding:2rem;
            background-color:rgba(33,58,87,.7);min-height:100vh;
            backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal);
        }

        /* =========================
           Page Container & Headings
        ==========================*/
        .page-container{
            max-width:1000px;margin:0 auto;
            padding:2.5rem 2rem 2rem;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            border-radius:24px;border:2px solid var(--accent-green);
            box-shadow:0 8px 32px rgba(33,58,87,.25);
            position:relative;overflow:hidden;
        }
        .page-header{
            text-align:center;margin-bottom:1.25rem;color:var(--text-light);
            font-size:2.5rem;font-weight:800;
        }
        .page-subtitle{
            font-size:1.2rem;text-align:center;color:var(--accent-light-green);
            margin-bottom:2rem;opacity:.95;font-weight:600;
        }

        /* =========================
           Forms (unified)
        ==========================*/
        .form-group{margin-bottom:1rem;}
        .form-group label{
            display:block;margin-bottom:.4rem;color:var(--accent-light-green);
            font-weight:600;font-size:.95rem;
        }
        .form-control{
            width:100%;padding:.75rem;border-radius:12px;box-sizing:border-box;
            border:1px solid var(--accent-teal);
            background:rgba(33,58,87,.7);color:var(--text-light);
            font-size:1rem;transition:all .2s ease;backdrop-filter:blur(5px);
        }
        .form-control:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 2px rgba(69,223,177,.3);}
        textarea.form-control{min-height:120px;resize:vertical;}

        /* FileUpload look */
        .asp-fileupload{
            width:100%;padding:.65rem .9rem;border-radius:12px;box-sizing:border-box;
            border:1px solid var(--accent-teal);background:rgba(33,58,87,.7);color:var(--text-light);
            transition:all .2s ease;
        }
        .asp-fileupload:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 2px rgba(69,223,177,.3);}

        /* Buttons (unified) */
        .btn{
            display:inline-block;border:none;cursor:pointer;user-select:none;
            padding:.85rem 1.75rem;border-radius:25px;font-weight:700;font-size:1rem;
            transition:transform .2s ease, box-shadow .2s ease, background .2s ease, color .2s ease;
            width:100%;
        }
        .btn:hover{transform:translateY(-2px);}
        .btn-success{background:linear-gradient(135deg,var(--accent-green),var(--accent-light-green));color:var(--primary-dark);box-shadow:0 4px 15px rgba(69,223,177,.3);}
        .btn-success:hover{box-shadow:0 8px 25px rgba(69,223,177,.4);}
        .btn-danger{background:var(--error-red);color:#fff;width:auto;border-radius:20px;padding:.5rem 1rem;font-weight:700;}
        .btn-danger:hover{background:var(--primary-dark);color:var(--error-red);box-shadow:0 0 0 1px var(--error-red);}

        /* Status messages */
        .status-message{margin-top:1rem;padding:15px;border-radius:12px;font-weight:700;text-align:center;border:1px solid transparent;}
        .status-message.success{background:rgba(69,223,177,.2);color:var(--accent-green);border-color:var(--accent-green);}
        .status-message.error{background:rgba(230,57,70,.2);color:var(--error-red);border-color:var(--error-red);}

        /* Uploaded files list */
        .current-files-section{margin-top:2rem;padding-top:1.5rem;border-top:1px dashed var(--accent-teal);}
        .current-files-section h3{
            color:var(--accent-green);text-align:center;margin-bottom:1rem;font-size:1.5rem;font-weight:700;
        }
        .file-item{
            background:rgba(33,58,87,.7);border:1px solid var(--accent-teal);
            border-radius:12px;padding:1rem;margin-bottom:1rem;
            box-shadow:0 2px 10px rgba(0,0,0,.1);transition:all .2s ease;
        }
        .file-item:hover{transform:translateY(-3px);box-shadow:0 8px 25px rgba(0,0,0,.2);border-color:var(--accent-green);}
        .file-item p{margin:.35rem 0;font-size:1rem;color:var(--text-light);}
        .file-details{font-size:.9rem;color:var(--accent-light-green);}

        /* Responsive */
        @media (max-width:992px){
            .sidebar{width:240px;padding:1.5rem .75rem;}
            .main-content{margin-left:240px;padding:1.5rem;}
        }
        @media (max-width:767px){
            .dashboard-wrapper{flex-direction:column;}
            .sidebar{width:100%;height:auto;position:relative;}
            .main-content{margin-left:0;padding:1rem;}
            .page-container{padding:1.5rem;margin-top:1rem;}
            .page-header{font-size:2rem;}
            .page-subtitle{font-size:1.1rem;margin-bottom:1.5rem;}
            .btn{width:100%;}
        }
        @media (max-width:480px){
            .page-header{font-size:1.8rem;}
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
                <li><a href="TeacherFileUpload.aspx" class="nav-item active"><i class="fas fa-tasks"></i><span>Student Assessments</span></a></li>
                <li><a href="TeacherSendMessage.aspx" class="nav-item"><i class="fas fa-envelope"></i><span>Messages</span></a></li>
                <li><a href="UploadMarks.aspx" class="nav-item"><i class="fas fa-chart-bar"></i><span>Manage Marks</span></a></li>
                <li>
                    <a href="Default.aspx" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
                </li>
            </ul>
        </div>

        <!-- Main -->
        <div class="main-content">
            <div class="page-container">
                <h1 class="page-header">Upload Files & Send Messages <i class="fas fa-file-upload"></i></h1>
                <p class="page-subtitle">Share resources with your students and include a note if you want</p>

                <!-- Upload form -->
                <asp:Panel ID="FileUploadPanel" runat="server">
                    <div class="form-group">
                        <label for="<%= txtMessage.ClientID %>">Message to Students (optional)</label>
                        <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine"
                                     CssClass="form-control" placeholder="Enter a message for your students..."></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label for="<%= FileUploadControl.ClientID %>">Select File to Upload</label>
                        <asp:FileUpload ID="FileUploadControl" runat="server" CssClass="asp-fileupload" />
                    </div>

                    <asp:Button ID="btnUpload" runat="server"
                                Text="Upload File & Send Message"
                                OnClick="btnUpload_Click"
                                CssClass="btn btn-success" />
                </asp:Panel>

                <!-- Status -->
                <asp:Literal ID="litStatusMessage" runat="server"></asp:Literal>

                <!-- Recent uploads -->
                <asp:Panel ID="CurrentUploadsPanel" runat="server" CssClass="current-files-section" Visible="false">
                    <h3><i class="fas fa-folder-open"></i> Your Recent Uploads</h3>
                    <asp:Repeater ID="rptUploadedFiles" runat="server">
                        <ItemTemplate>
                            <div class="file-item">
                                <asp:Button ID="btnDeleteFile" runat="server" Text="Delete File"
                                    CommandName="DeleteFile" CommandArgument='<%# Eval("FileID") %>'
                                    OnCommand="btnDeleteFile_Command" CssClass="btn btn-danger" />
                                <p><strong><i class="fas fa-file-alt"></i> File:</strong> <%# Eval("FileName") %></p>
                                <p><strong><i class="fas fa-comment"></i> Message:</strong> <%# Eval("Message") %></p>
                                <p class="file-details"><i class="fas fa-calendar-alt"></i> Uploaded on: <%# Eval("UploadDate", "{0:yyyy-MM-dd HH:mm}") %></p>
                                <p class="file-details"><i class="fas fa-book"></i> Subject: <%# Eval("SubjectName") %> (<%# Eval("SubjectCode") %>)</p>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>
