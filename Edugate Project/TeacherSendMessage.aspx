<%@ Page Language="C#" MasterPageFile="~/Admin.master" AutoEventWireup="true"
    CodeBehind="TeacherSendMessage.aspx.cs" Inherits="Edugate_Project.TeacherSendMessage" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>Teacher – Messages | Edugate STEM</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        /* =========================
           Palette
        ==========================*/
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
            --error-red: #E63946;
        }

        /* =========================
           Base Typography (Inter)
        ==========================*/
        html { font-size: 16px; }
        body {
            background-color: var(--primary-dark);
            color: var(--text-light);
            font-family: 'Inter','Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
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
           Layout (unified with Teacher pages)
        ==========================*/
        .admin-dashboard { display: flex; min-height: 100vh; }

        /* Sidebar */
        .admin-sidebar{
            width: 280px;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            color: #fff;
            padding: 2rem 1rem;
            position: fixed;
            height: 100vh;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,.25);
            border-right: 2px solid var(--accent-green);
            z-index: 1000;
        }
        .admin-profile{
            text-align: center;
            padding: 1rem 0 2rem;
            border-bottom: 1px solid rgba(255,255,255,.1);
            margin-bottom: 1.5rem;
        }
        .admin-avatar{
            width: 80px; height: 80px; border-radius: 50%;
            border: 3px solid var(--accent-green);
            display:flex; align-items:center; justify-content:center;
            background: var(--primary-dark); color: var(--accent-green);
            font-size: 2rem; margin: 0 auto 1rem;
        }
        .admin-name{ font-size: 1.2rem; margin: .5rem 0; font-weight: 700; color: var(--text-light); }
        .admin-role{ font-size: .85rem; color: var(--accent-light-green); margin: 0; }

        .admin-menu{ list-style: none; padding: 0; margin: 0; }
        .admin-menu li{ margin-bottom: .5rem; }
        .admin-menu a, .admin-menu button{
            display: flex; align-items: center;
            color: rgba(255,255,255,.9);
            padding: .75rem 1rem; border-radius: 6px;
            text-decoration: none; transition: all .2s;
            background: none; border: none; width: 100%; text-align: left; cursor: pointer;
            font-size: 1rem; font-weight: 600;
        }
        .admin-menu a:hover, .admin-menu a.active, .admin-menu button:hover{
            background: rgba(69,223,177,.2); color: var(--text-light);
        }
        .admin-menu i{ margin-right: .75rem; width: 20px; text-align: center; font-size: 1.1rem; }

        /* Main area shell */
        .admin-content{
            flex: 1;
            margin-left: 280px;
            padding: 2rem;
            background: rgba(33,58,87,.7);
            min-height: 100vh;
            backdrop-filter: blur(5px);
            border-left: 1px solid var(--accent-teal);
        }

        /* Page container (match other teacher pages) */
        .page-container{
            max-width: 1100px;
            margin: 0 auto;
            padding: 2.2rem 2rem 2rem;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            border: 2px solid var(--accent-green);
            box-shadow: 0 8px 32px rgba(33,58,87,.25);
        }

        .section-title{
            color: var(--text-light);
            margin: 0 0 1.25rem;
            font-weight: 800;
            font-size: 2.2rem; /* slightly below 2.5rem header */
            text-align: center;
        }
        .section-sub{
            font-size: 1.1rem;
            text-align: center;
            color: var(--accent-light-green);
            margin: -4px 0 1.25rem;
            opacity: .95;
            font-weight: 600;
        }

        /* Panels / cards */
        .panel{
            background: rgba(33,58,87,.8);
            border: 1px solid var(--accent-teal);
            border-radius: 16px;
            padding: 18px;
            box-shadow: 0 8px 32px rgba(0,0,0,.15);
            margin-bottom: 18px;
        }
        .muted{ color: var(--accent-light-green); opacity: .95; font-size: .95rem; }

        /* Inputs */
        .label{
            display:block; margin-bottom:.4rem;
            color: var(--accent-light-green); font-weight: 600; font-size: .95rem;
        }
        .control{
            width:100%; padding:.8rem 1rem;
            border:1px solid var(--accent-teal);
            border-radius:10px; background: rgba(33,58,87,.7);
            color: var(--text-light); font-size: 1rem;
            transition: all .2s ease; box-sizing: border-box;
        }
        .control:focus{ outline:none; border-color: var(--accent-green); box-shadow: 0 0 0 2px rgba(69,223,177,.3); }

        .row{ display:grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 16px; }

        /* Tabs */
        .tabs{ display:flex; gap:8px; border-bottom:2px solid var(--accent-teal); margin-bottom:12px; }
        .tab-btn{
            padding:.8rem 1.2rem; background:none; border:none; border-bottom:3px solid transparent;
            color:var(--text-light); font-weight:800; cursor:pointer; transition: all .15s ease;
        }
        .tab-btn.active{ border-bottom-color: var(--accent-green); color: var(--accent-green); }

        /* Actions / Buttons */
        .actions{ display:flex; gap:.6rem; justify-content:flex-end; margin-top:12px; }
        .btn{
            background: transparent; color: var(--text-light);
            border: 1px solid var(--accent-teal);
            padding: .7rem 1.4rem; border-radius: 999px;
            font-weight: 700; cursor: pointer; transition: all .2s ease;
        }
        .btn:hover{ border-color: var(--accent-green); color: var(--accent-green); }
        .btn-primary{
            background: linear-gradient(135deg, var(--accent-green), var(--accent-light-green));
            color: var(--primary-dark); border: none;
        }
        .btn-primary:hover{
            background: var(--primary-dark); color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
        }
        .btn-danger{ background: var(--error-red); color: #fff; border: none; }
        .btn-danger:hover{ background: #b92b37; }

        /* Lists */
        .list{ list-style:none; margin:0; padding:0; }
        .item{
            background: rgba(255,255,255,.05);
            border: 1px solid rgba(255,255,255,.15);
            border-radius: 12px; padding: 12px; margin: 10px 0;
        }
        .item-head{ display:flex; justify-content:space-between; gap: 12px; align-items: baseline; }
        .badge{
            padding: 2px 8px; border-radius: 999px;
            border: 1px solid var(--accent-teal); margin-left: 6px; font-weight: 700; font-size: .8rem;
            color: var(--accent-light-green);
        }

        /* Responsive */
        @media (max-width: 992px){
            .admin-sidebar{ width: 240px; padding: 1.5rem .75rem; }
            .admin-content{ margin-left: 240px; padding: 1.5rem; }
        }
        @media (max-width: 767px){
            .admin-sidebar{ width: 100%; height: auto; position: relative; }
            .admin-content{ margin-left: 0; padding: 1rem; }
            .page-container{ padding: 1.25rem; }
            .section-title{ font-size: 2rem; }
        }
        @media (max-width: 480px){
            .section-title{ font-size: 1.8rem; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="admin-dashboard">
    <!-- Sidebar -->
    <div class="admin-sidebar">
        <div class="admin-profile">
            <div class="admin-avatar"><i class="fas fa-user"></i></div>
            <h3 class="admin-name"><asp:Label ID="lblSidebarTeacherName" runat="server" /></h3>
            <p class="admin-role">Teacher</p>
        </div>
        <ul class="admin-menu">
            <li><a href="TeacherDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="QuizManagement.aspx"><i class="fas fa-question-circle"></i> Manage Quizzes</a></li>
            <li><a href="TeacherFileUpload.aspx"><i class="fas fa-tasks"></i> Student Assessments</a></li>
            <li><a href="TeacherSendMessage.aspx" class="active"><i class="fas fa-envelope"></i> Messages</a></li>
            <li><a href="UploadMarks.aspx"><i class="fas fa-chart-bar"></i> Manage Marks</a></li>
            <li><a href="Default.aspx" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a></li>
        </ul>
    </div>

    <!-- Main -->
    <div class="admin-content">
        <div class="page-container">
            <h1 class="section-title">Messages</h1>
            <div class="section-sub">Compose broadcasts and read student replies — all in one place</div>

            <!-- Header panel -->
            <section class="panel" style="display:flex;align-items:center;justify-content:space-between;gap:12px;">
                <div>
                    <div style="font-weight:800;color:#fff" class="text-lg">Communicate with students</div>
                    <div class="muted">Target a grade level or specific students, then send</div>
                </div>
                <div class="muted" style="font-weight:700;">
                    Subject:&nbsp;<span style="color:var(--accent-green)"><asp:Label ID="lblTeacherSubject" runat="server" /></span>
                </div>
            </section>

            <!-- Tabs -->
            <div class="tabs">
                <asp:Button ID="btnTabCompose" runat="server" Text="Compose to Students" CssClass="tab-btn active" OnClick="btnTabCompose_Click" />
                <asp:Button ID="btnTabInbox"   runat="server" Text="Student Messages"   CssClass="tab-btn"         OnClick="btnTabInbox_Click" />
            </div>

            <!-- ================= COMPOSE TAB ================= -->
            <asp:Panel ID="pnlCompose" runat="server">
                <section class="panel">
                    <div class="row">
                        <div>
                            <label class="label" for="<%= ddlGradeLevel.ClientID %>">Grade Level</label>
                            <asp:DropDownList ID="ddlGradeLevel" runat="server" CssClass="control" AutoPostBack="true" OnSelectedIndexChanged="Filters_Changed">
                                <asp:ListItem Value="" Text="-- All Grade Levels --" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div>
                            <label class="label" for="<%= ddlStudents.ClientID %>">Students</label>
                            <asp:DropDownList ID="ddlStudents" runat="server" CssClass="control" AutoPostBack="true" OnSelectedIndexChanged="Filters_Changed">
                                <asp:ListItem Value="ALL" Text="-- All students (filtered) --" Selected="True"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div>
                            <label class="label" for="<%= ddlPriority.ClientID %>">Priority</label>
                            <asp:DropDownList ID="ddlPriority" runat="server" CssClass="control">
                                <asp:ListItem Value="Normal" Text="Normal" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="High" Text="High Priority"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <asp:Panel ID="pnlRecipientCount" runat="server" Visible="false" CssClass="muted" Style="margin-top:8px">
                        Will be sent to approximately <strong><asp:Literal ID="litRecipientCount" runat="server" /></strong> students
                    </asp:Panel>
                </section>

                <section class="panel">
                    <div class="row">
                        <div style="grid-column:1/-1">
                            <label class="label" for="<%= txtSubject.ClientID %>">Subject</label>
                            <asp:TextBox ID="txtSubject" runat="server" CssClass="control" MaxLength="100" placeholder="Enter message subject" />
                        </div>
                        <div style="grid-column:1/-1">
                            <label class="label" for="<%= txtMessage.ClientID %>">Message</label>
                            <asp:TextBox ID="txtMessage" runat="server" CssClass="control" TextMode="MultiLine" Rows="8" MaxLength="1000" placeholder="Type your message here..." />
                        </div>
                    </div>

                    <div class="actions">
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn" OnClick="btnCancel_Click" CausesValidation="false" />
                        <asp:Button ID="btnSend"   runat="server" Text="Send Message" CssClass="btn btn-primary" OnClick="btnSend_Click" />
                    </div>

                    <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="panel" Style="border-color:var(--accent-green); background:rgba(69,223,177,.12); margin-top:12px;">
                        <strong>Sent!</strong> <asp:Literal ID="litSuccess" runat="server"></asp:Literal>
                    </asp:Panel>
                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="panel" Style="border-color:#E63946; background:rgba(230,57,70,.12); margin-top:12px;">
                        <strong>Error:</strong> <asp:Literal ID="litError" runat="server"></asp:Literal>
                    </asp:Panel>
                </section>
            </asp:Panel>

            <!-- ================= STUDENT INBOX TAB ================= -->
            <asp:Panel ID="pnlStudentInbox" runat="server" Visible="false">
                <section class="panel" style="display:flex;align-items:center;justify-content:space-between;gap:10px;">
                    <div class="muted">Messages sent by students enrolled in your subject</div>
                    <div style="display:flex;gap:8px">
                        <asp:Button ID="btnInbox"    runat="server" Text="Inbox"    CssClass="btn" OnClick="btnInbox_Click" />
                        <asp:Button ID="btnArchived" runat="server" Text="Archived" CssClass="btn" OnClick="btnArchived_Click" />
                    </div>
                </section>

                <section class="panel">
                    <asp:Repeater ID="rptStudentMsgs" runat="server" OnItemCommand="rptStudentMsgs_ItemCommand">
                        <HeaderTemplate><ul class="list"></HeaderTemplate>
                        <ItemTemplate>
                            <li class="item">
                                <div class="item-head">
                                    <div>
                                        <strong><%# Eval("StudentName") %></strong>
                                        <%# Convert.ToBoolean(Eval("IsRead")) ? "" : "<span class='badge'>NEW</span>" %>
                                    </div>
                                    <div class="muted"><%# Eval("DateSent","{0:dd MMM yyyy HH:mm}") %></div>
                                </div>
                                <div class="text-lg fw-800" style="margin:.35rem 0;"><%# Eval("Title") %></div>
                                <div class="muted"><%# Eval("Preview") %></div>
                                <div class="actions" style="margin-top:.5rem">
                                    <asp:Button ID="btnToggleRead" runat="server"
                                        Text='<%# Convert.ToBoolean(Eval("IsRead")) ? "Mark Unread" : "Mark Read" %>'
                                        CommandName="ToggleRead" CommandArgument='<%# Eval("STMID") %>' CssClass="btn" />
                                    <asp:Button ID="btnToggleArchive" runat="server"
                                        Text='<%# Convert.ToBoolean(Eval("IsArchived")) ? "Unarchive" : "Archive" %>'
                                        CommandName="ToggleArchive" CommandArgument='<%# Eval("STMID") %>' CssClass="btn" />
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                        CommandName="Delete" CommandArgument='<%# Eval("STMID") %>' CssClass="btn btn-danger"
                                        OnClientClick="return confirm('Delete this message from your view?');" />
                                </div>
                                <%# Eval("OriginalMessageID") == DBNull.Value ? "" :
                                    "<div class='muted' style='margin-top:.35rem'>Reply to broadcast ID: " + Eval("OriginalMessageID") + "</div>" %>
                            </li>
                        </ItemTemplate>
                        <FooterTemplate></ul></FooterTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlEmptyInbox" runat="server" Visible="false" CssClass="panel" Style="margin-top:8px; text-align:center;">
                        No messages here.
                    </asp:Panel>
                </section>
            </asp:Panel>
        </div>
    </div>
</div>
</asp:Content>
