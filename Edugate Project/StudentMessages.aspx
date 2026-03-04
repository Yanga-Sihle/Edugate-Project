<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentMessages.aspx.cs"
    Inherits="Edugate_Project.StudentMessages" MasterPageFile="~/Student.master" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - My Messages</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        :root {
            --primary-dark:#213A57; --primary-orange:#0B6477; --accent-teal:#14919B;
            --text-light:#DAD1CB; --accent-green:#45DFB1; --accent-light-green:#80ED99;
        }

        /* ===== Shell ===== */
        .student-dashboard{display:flex;min-height:100vh;background-color:var(--primary-dark);color:var(--text-light);font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif}
        .student-sidebar{
            width:280px;background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            color:#fff;padding:2rem 1rem;position:fixed;height:100vh;box-shadow:0 8px 32px rgba(33,58,87,.25);
            border-right:2px solid var(--accent-green);z-index:1000
        }
        .student-content{
            flex:1;margin-left:280px;padding:2rem;background-color:rgba(33,58,87,.7);
            min-height:100vh;backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal)
        }

        /* ===== Sidebar ===== */
        .student-profile{text-align:center;padding:1rem 0 2rem;border-bottom:1px solid rgba(255,255,255,.1);margin-bottom:1.5rem}
        .student-avatar{width:80px;height:80px;border-radius:50%;object-fit:cover;border:3px solid var(--accent-green);margin-bottom:1rem}
        .student-name{font-size:1.2rem;margin:.5rem 0;font-weight:700;color:var(--text-light)}
        .student-status{font-size:.85rem;color:var(--accent-light-green);margin:0}
        .student-menu{list-style:none;padding:0;margin:0}
        .student-menu li{margin-bottom:.5rem}
        .student-menu a{
            display:flex;align-items:center;color:rgba(255,255,255,.85);padding:.75rem 1rem;border-radius:8px;text-decoration:none;transition:all .2s
        }
        .student-menu a:hover,.student-menu a.active{background:rgba(69,223,177,.2);color:var(--text-light)}
        .student-menu a i{margin-right:.75rem;width:20px;text-align:center}

        /* ===== Container ===== */
        .messages-container{
            max-width:1200px;margin:0 auto;padding:2.5rem 2rem;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            border-radius:24px;box-shadow:0 8px 32px rgba(33,58,87,.25);border:2px solid var(--accent-green)
        }
        .messages-hero{text-align:center;margin-bottom:1.25rem}
        .messages-hero h2{margin:0 0 .25rem;font-size:2.2rem;font-weight:800;color:var(--text-light)}
        .messages-hero p{font-size:1.05rem;color:var(--accent-light-green);opacity:.95;margin:0}

        /* ===== Filters & Tabs ===== */
        .filter-section{background:rgba(33,58,87,.7);border-radius:16px;padding:1rem;border:1px solid var(--accent-teal);margin-bottom:1.2rem;backdrop-filter:blur(5px)}
        .filter-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:.8rem;margin-bottom:.6rem}
        .filter-control{width:100%;padding:.7rem 1rem;border:2px solid var(--accent-teal);border-radius:10px;background:var(--primary-dark);color:var(--text-light)}
        .filter-actions{display:flex;gap:.6rem;justify-content:flex-end;flex-wrap:wrap}
        .btn-action{
            padding:.6rem 1.1rem;background:var(--accent-green);color:var(--primary-dark);
            border-radius:50px;font-weight:800;border:none;cursor:pointer;transition:.2s
        }
        .btn-action:hover{background:var(--primary-dark);color:var(--accent-green);box-shadow:0 0 0 1px var(--accent-green)}

        .messages-tabs{display:flex;border-bottom:2px solid var(--accent-teal);margin:0 0 1rem;gap:.6rem;justify-content:center}
        .tab-btn{padding:.7rem 1.2rem;background:none;border:none;border-bottom:3px solid transparent;color:var(--text-light);font-weight:800;cursor:pointer}
        .tab-btn.active{border-bottom-color:var(--accent-green);color:var(--accent-green)}

        /* ===== Lists ===== */
        .messages-list{list-style:none;margin:0;padding:0}
        .message-item{background:rgba(33,58,87,.7);backdrop-filter:blur(5px);border:1px solid var(--accent-teal);border-radius:16px;padding:1.1rem;margin-bottom:1rem;transition:transform .15s}
        .message-item:hover{transform:translateY(-2px)}
        .message-unread{border-left:4px solid var(--accent-green)}
        .message-priority-high{border-left:4px solid #E63946}
        .message-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:.5rem;border-bottom:1px solid rgba(255,255,255,.12);padding-bottom:.5rem}
        .message-subject{font-weight:700;margin:.35rem 0}
        .message-actions{display:flex;gap:.5rem;flex-wrap:wrap}
        .btn-delete{background:#E63946 !important;color:#fff}
        .btn-delete:hover{color:#fff;box-shadow:none}

        .no-messages{text-align:center;padding:2rem;color:var(--text-light);border:1px dashed rgba(255,255,255,.25);border-radius:16px}

        /* ===== Alert ===== */
        .alert{padding:12px 20px;border-radius:8px;margin-bottom:12px;display:none}
        .alert-success{background:#e8f5e9;color:#2e7d32;border:1px solid #a5d6a7}
        .alert-error{background:#ffebee;color:#c62828;border:1px solid #ef9a9a}

        /* ===== Reply Panel ===== */
        #<%= pnlReply.ClientID %>{background:rgba(33,58,87,.8);border:1px solid var(--accent-teal);border-radius:16px;padding:1rem;margin-top:1rem}

        /* ===== Responsive ===== */
        @media (max-width:992px){.student-sidebar{width:240px}.student-content{margin-left:240px}}
        @media (max-width:768px){
            .student-sidebar{position:relative;width:100%;height:auto;border-right:0}
            .student-content{margin-left:0;padding:1rem}
        }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="student-dashboard">
    <!-- Sidebar (classic layout restored) -->
    <div class="student-sidebar">
        <div class="student-profile">
            <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
            <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server" /></h3>
            <p class="student-status">Active Student</p>
        </div>
        <ul class="student-menu">
            <li><a href="StudentDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="StudentMark.aspx"><i class="fas fa-marker"></i> Upload School Report</a></li>
            <li><a href="Scholarships.aspx"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
            <li><a href="CareerGuidance.aspx"><i class="fas fa-compass"></i> Career Guidance</a></li>
            <li><a href="StudentMaterials.aspx"><i class="fas fa-book-open"></i> Study Materials</a></li>
            <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>

    <!-- Main -->
    <div class="student-content">
        <!-- alert banner (server-driven) -->
        <div id="alertContainer" runat="server" class="alert" style="display:none">
            <span id="alertMessage" runat="server"></span>
        </div>

        <div class="messages-container">
            <div class="messages-hero">
                <h2>My Messages 💬</h2>
                <p>View and manage your messages from teachers</p>
            </div>

            <!-- Filters + New message -->
            <div class="filter-section">
                <div class="filter-grid">
                    <div>
                        <label style="display:block;margin-bottom:.25rem">Filter by</label>
                        <asp:DropDownList ID="ddlFilter" runat="server" CssClass="filter-control">
                            <asp:ListItem Value="all" Text="All Messages" Selected="True" />
                            <asp:ListItem Value="unread" Text="Unread Messages" />
                            <asp:ListItem Value="read" Text="Read Messages" />
                            <asp:ListItem Value="priority" Text="Priority Messages" />
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label style="display:block;margin-bottom:.25rem">Sort by</label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="filter-control">
                            <asp:ListItem Value="newest" Text="Newest First" Selected="True" />
                            <asp:ListItem Value="oldest" Text="Oldest First" />
                            <asp:ListItem Value="sender" Text="Sender" />
                            <asp:ListItem Value="priority" Text="Priority" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="filter-actions">
                    <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn-action" OnClick="FilterMessages" />
                    <asp:Button ID="btnClearFilters" runat="server" Text="Clear Filters" CssClass="btn-action" OnClick="ClearFilters" />
                    <asp:Button ID="btnNewMessage" runat="server" Text="New Message to a Teacher" CssClass="btn-action" OnClick="btnNewMessage_Click" />
                </div>
            </div>

            <!-- Tabs (same handlers) -->
            <div class="messages-tabs">
                <asp:Button ID="btnTabInbox" runat="server" Text="Inbox" CssClass="tab-btn active" OnClick="ChangeTab" CommandArgument="inbox" />
                <asp:Button ID="btnTabArchived" runat="server" Text="Archived" CssClass="tab-btn" OnClick="ChangeTab" CommandArgument="archived" />
            </div>

            <!-- INBOX -->
            <asp:Panel ID="pnlInbox" runat="server" Visible="true">
                <asp:Repeater ID="rptMessages" runat="server" OnItemCommand="rptMessages_ItemCommand">
                    <HeaderTemplate><ul class="messages-list"></HeaderTemplate>
                    <ItemTemplate>
                        <li class='message-item <%# (bool)Eval("IsRead") ? "" : "message-unread" %> <%# (string)Eval("Priority") == "High" ? "message-priority-high" : "" %>'>
                            <div class="message-header">
                                <div>
                                    <strong><%# Eval("SenderName") %></strong>
                                    <%# (bool)Eval("IsRead") ? "" : "<span style=\"margin-left:.5rem;background:var(--accent-green);color:var(--primary-dark);padding:.15rem .5rem;border-radius:12px;font-weight:800;font-size:.75rem\">NEW</span>" %>
                                    <%# (string)Eval("Priority") == "High" ? "<span style=\"margin-left:.5rem;background:#E63946;color:#fff;padding:.15rem .5rem;border-radius:12px;font-weight:800;font-size:.75rem\">PRIORITY</span>" : "" %>
                                </div>
                                <span><%# Eval("SentDate", "{0:MMM dd, yyyy hh:mm tt}") %></span>
                            </div>
                            <div class="message-subject"><%# Eval("Subject") %></div>
                            <div class="message-body"><%# Eval("Body") %></div>
                            <div class="message-actions">
                                <asp:Button ID="btnMarkRead" runat="server" Text='<%# (bool)Eval("IsRead") ? "Mark Unread" : "Mark Read" %>'
                                    CommandName="ToggleRead" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action" />
                                <asp:Button ID="btnReply" runat="server" Text="Reply"
                                    CommandName="Reply" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action" />
                                <asp:Button ID="btnArchive" runat="server" Text="Archive"
                                    CommandName="Archive" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action" />
                                <asp:Button ID="btnDelete" runat="server" Text="Delete"
                                    CommandName="Delete" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action btn-delete"
                                    OnClientClick="return confirm('Delete this message?');" />
                            </div>
                        </li>
                    </ItemTemplate>
                    <FooterTemplate></ul></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoMessages" runat="server" CssClass="no-messages" Visible="false">
                    <i class="fas fa-envelope-open" style="font-size:3rem;opacity:.5"></i>
                    <h3 style="margin:.5rem 0">No messages</h3>
                    <p>Your inbox is empty.</p>
                </asp:Panel>
            </asp:Panel>

            <!-- ARCHIVED -->
            <asp:Panel ID="pnlArchived" runat="server" Visible="false">
                <asp:Repeater ID="rptArchivedMessages" runat="server" OnItemCommand="rptArchivedMessages_ItemCommand">
                    <HeaderTemplate><ul class="messages-list"></HeaderTemplate>
                    <ItemTemplate>
                        <li class="message-item">
                            <div class="message-header">
                                <strong><%# Eval("SenderName") %></strong>
                                <span><%# Eval("SentDate", "{0:MMM dd, yyyy hh:mm tt}") %></span>
                            </div>
                            <div class="message-subject"><%# Eval("Subject") %></div>
                            <div class="message-body"><%# Eval("Body") %></div>
                            <div class="message-actions">
                                <asp:Button ID="btnUnarchive" runat="server" Text="Move to Inbox"
                                    CommandName="Unarchive" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action" />
                                <asp:Button ID="btnDeleteArchived" runat="server" Text="Delete"
                                    CommandName="Delete" CommandArgument='<%# Eval("MessageID") %>' CssClass="btn-action btn-delete"
                                    OnClientClick="return confirm('Permanently delete this message?');" />
                            </div>
                        </li>
                    </ItemTemplate>
                    <FooterTemplate></ul></FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlNoArchivedMessages" runat="server" CssClass="no-messages" Visible="false">
                    <i class="fas fa-archive" style="font-size:3rem;opacity:.5"></i>
                    <h3 style="margin:.5rem 0">No archived messages</h3>
                    <p>You don't have any archived messages.</p>
                </asp:Panel>
            </asp:Panel>

            <!-- Reply / Compose (IDs unchanged) -->
            <asp:Panel ID="pnlReply" runat="server" Visible="false">
                <h3 style="margin:0 0 .6rem">Compose to a Teacher</h3>

                <div class="filter-grid">
                    <div class="filter-group">
                        <label>Teacher</label>
                        <asp:DropDownList ID="ddlTeachers" runat="server" CssClass="filter-control"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlTeachers_SelectedIndexChanged" />
                    </div>
                    <div class="filter-group">
                        <label>Subject (auto)</label>
                        <asp:TextBox ID="txtReplySubjectName" runat="server" CssClass="filter-control" ReadOnly="true" />
                    </div>
                </div>

                <div class="filter-grid" style="margin-top:.6rem">
                    <div class="filter-group">
                        <label>Title</label>
                        <asp:TextBox ID="txtReplyTitle" runat="server" CssClass="filter-control" MaxLength="100" />
                    </div>
                </div>

                <div class="filter-group" style="margin-top:.6rem">
                    <label>Message</label>
                    <asp:TextBox ID="txtReplyBody" runat="server" CssClass="filter-control" TextMode="MultiLine" Rows="5" MaxLength="1000" />
                </div>

                <div class="filter-actions" style="margin-top:.8rem">
                    <asp:Button ID="btnSendReply" runat="server" Text="Send" CssClass="btn-action" OnClick="btnSendReply_Click" />
                    <asp:Button ID="btnCancelReply" runat="server" Text="Cancel" CssClass="btn-action" OnClick="btnCancelReply_Click" />
                </div>

                <asp:HiddenField ID="hfReplyForMessageId" runat="server" />
                <asp:HiddenField ID="hfReplySchoolCode" runat="server" />
                <asp:HiddenField ID="hfReplySubjectCode" runat="server" />
            </asp:Panel>
        </div>
    </div>
</div>

<script>
    // Show server alert (SetAlert)
    window.onload = function () {
        var alertContainer = document.getElementById('<%= alertContainer.ClientID %>');
        var alertMessage = document.getElementById('<%= alertMessage.ClientID %>');
        if (alertMessage && alertMessage.innerHTML && alertMessage.innerHTML.trim() !== '') {
            alertContainer.style.display = 'block';
            alertContainer.className = 'alert <%= (AlertType == "error" ? "alert-error" : "alert-success") %>';
        }
    };
</script>
</asp:Content>
