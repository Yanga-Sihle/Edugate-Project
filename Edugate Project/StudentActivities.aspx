<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentActivities.aspx.cs" Inherits="Edugate_Project.StudentActivities" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - My Activities</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Custom color palette variables */
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
        }

        /* General Body and Container Styling */
        .student-dashboard {
            display: flex;
            min-height: 100vh;
            background-color: var(--primary-dark);
            color: var(--text-light);
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* Sidebar Styling */
        .student-sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            color: white;
            padding: 2rem 1rem;
            position: fixed;
            height: 100vh;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border-right: 2px solid var(--accent-green);
            z-index: 1000;
            animation: fadeInLeft 0.8s ease-out forwards;
        }

        @keyframes fadeInLeft {
            from { opacity: 0; transform: translateX(-20px); }
            to   { opacity: 1; transform: translateX(0); }
        }

        .student-profile {
            text-align: center;
            padding: 1rem 0 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 1.5rem;
        }

        .student-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--accent-green);
            margin-bottom: 1rem;
        }

        .student-name { font-size: 1.2rem; margin: 0.5rem 0; font-weight: 700; color: var(--text-light); }
        .student-status { font-size: 0.85rem; color: var(--accent-light-green); margin: 0; }

        .student-menu { list-style: none; padding: 0; margin: 0; }
        .student-menu li { margin-bottom: 0.5rem; }
        .student-menu a {
            display: flex; align-items: center; color: rgba(255,255,255,0.8);
            padding: 0.75rem 1rem; border-radius: 6px; text-decoration: none; transition: all 0.2s;
        }
        .student-menu a:hover, .student-menu a.active { background-color: rgba(69, 223, 177, 0.2); color: var(--text-light); }
        .student-menu a i { margin-right: 0.75rem; width: 20px; text-align: center; }

        /* Main Content Area */
        .student-content {
            flex: 1; margin-left: 280px; padding: 2rem;
            background-color: rgba(33, 58, 87, 0.7); min-height: 100vh; backdrop-filter: blur(5px);
            border-left: 1px solid var(--accent-teal);
        }

        .page-container {
            max-width: 1200px; margin: 0 auto; padding: 2.5rem 2rem 2rem 2rem;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px; box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border: 2px solid var(--accent-green); animation: fadeInUp 0.8s ease-out forwards;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .page-title { text-align: center; color: var(--text-light); margin-bottom: 20px; font-size: 2.5rem; font-weight: 800; }

        /* Subject Filter */
        .filter-section {
            text-align: center; margin-bottom: 30px; padding: 15px;
            background-color: rgba(33, 58, 87, 0.5); border-radius: 16px;
            box-shadow: inset 0 1px 3px rgba(0,0,0,0.05); border: 1px solid var(--accent-teal); backdrop-filter: blur(5px);
        }
        .filter-section label { font-weight: 600; color: var(--accent-light-green); margin-right: 15px; font-size: 1.1rem; }
        .filter-section select {
            padding: 10px 15px; border: 1px solid var(--accent-green); border-radius: 6px; font-size: 1rem; color: var(--primary-dark);
            background-color: var(--accent-green); appearance: none;
            background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http://www.w3.org/2000/svg%22%20viewBox%3D%220%200%20256%20256%22%3E%3Cpath%20fill%3D%22%23213A57%22%20d%3D%22M128%20192L0%2064h256z%22/%3E%3C/svg%3E');
            background-repeat: no-repeat; background-position: right 10px center; background-size: 12px; cursor: pointer;
        }
        .filter-section select:focus { border-color: var(--accent-light-green); outline: none; box-shadow: 0 0 0 3px rgba(128, 237, 153, 0.2); }

        /* Section Headers */
        .section-header {
            color: var(--accent-green); font-size: 1.8rem; font-weight: 600; margin-top: 40px; margin-bottom: 25px;
            border-bottom: 2px solid rgba(218, 209, 203, 0.2); padding-bottom: 10px; text-align: center;
        }

        /* Activity and Submission Items */
        .uploaded-file-item, .submission-item {
            background-color: rgba(33, 58, 87, 0.7); backdrop-filter: blur(5px); border: 1px solid var(--accent-teal);
            border-radius: 16px; padding: 20px; margin-bottom: 20px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            display: flex; flex-direction: column; gap: 10px; transition: transform 0.3s ease;
        }
        .uploaded-file-item:hover, .submission-item:hover {
            transform: translateY(-5px); box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
            background-color: rgba(20, 145, 155, 0.3); border-color: var(--accent-green);
        }
        .uploaded-file-item p, .submission-item p { margin: 0; font-size: 1rem; color: var(--text-light); }
        .uploaded-file-item strong, .submission-item strong { color: var(--accent-light-green); }
        .uploaded-file-item .file-details, .submission-item .submission-details { font-size: 0.9rem; color: var(--text-light); opacity: 0.7; }
        .uploaded-file-item .file-link, .submission-item .file-link { color: var(--accent-green); text-decoration: none; font-weight: 600; transition: color 0.3s ease; }
        .uploaded-file-item .file-link:hover, .submission-item .file-link:hover { color: var(--accent-light-green); text-decoration: underline; }

        .no-activities-message, .no-submissions-message {
            text-align: center; color: var(--accent-light-green); font-style: italic; padding: 20px;
            border: 1px dashed rgba(218, 209, 203, 0.3); border-radius: 12px; margin-top: 20px;
            background-color: rgba(33, 58, 87, 0.5); backdrop-filter: blur(5px);
        }

        /* Submission Form */
        .submission-form-container {
            margin-top: 40px; padding: 30px; background-color: rgba(20, 145, 155, 0.3); backdrop-filter: blur(5px);
            border-radius: 16px; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2); border: 1px solid var(--accent-green);
        }
        .submission-form-container h3 { color: var(--accent-green); font-size: 1.6rem; margin-bottom: 20px; text-align: center; font-weight: 700; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: var(--text-light); }
        .form-group input[type="file"], .form-group textarea {
            width: 100%; padding: 12px 15px; border: 1px solid var(--accent-teal); border-radius: 8px; font-size: 1rem; color: var(--text-light);
            background-color: rgba(33, 58, 87, 0.7); box-sizing: border-box; transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-group input[type="file"] { padding: 8px 15px; }
        .form-group textarea { min-height: 100px; resize: vertical; }
        .form-group input[type="file"]:focus, .form-group textarea:focus { border-color: var(--accent-light-green); outline: none; box-shadow: 0 0 0 3px rgba(128, 237, 153, 0.2); }

        .asp-fileupload {
            color: var(--text-light); background-color: rgba(33, 58, 87, 0.7); border: 1px solid var(--accent-teal);
            border-radius: 8px; padding: 8px 15px; width: 100%; box-sizing: border-box;
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--accent-green), var(--accent-light-green));
            color: var(--primary-dark); padding: 15px 30px; border: none; border-radius: 50px; font-weight: 800; cursor: pointer;
            transition: all 0.3s ease; font-size: 1.1rem; width: 100%; display: block; margin-top: 30px;
        }
        .btn-submit:hover {
            transform: translateY(-3px); box-shadow: 0 10px 30px rgba(69, 223, 177, 0.4);
            background: linear-gradient(135deg, var(--accent-light-green), var(--accent-green));
        }

        .status-message { margin-top: 20px; padding: 15px; border-radius: 8px; font-weight: 600; text-align: center; font-size: 1rem; }
        .status-message.success { background-color: rgba(69, 223, 177, 0.2); color: var(--accent-green); border: 1px solid var(--accent-green); }
        .status-message.error { background-color: rgba(230, 57, 70, 0.2); color: #E63946; border: 1px solid #E63946; }
        .status-message.info { background-color: rgba(20, 145, 155, 0.2); color: var(--accent-teal); border: 1px solid var(--accent-teal); }

        /* Responsive */
        @media (max-width: 992px) {
            .student-sidebar { width: 240px; padding: 1.5rem 0.75rem; }
            .student-content { margin-left: 240px; padding: 1.5rem; }
        }
        @media (max-width: 767px) {
            .student-sidebar { transform: translateX(-100%); width: 280px; }
            .student-sidebar.active { transform: translateX(0); }
            .student-content { margin-left: 0; padding: 1rem; }
            .page-container { padding: 20px; margin-top: 20px; }
            .page-title { font-size: 2rem; }
            .filter-section { flex-direction: column; gap: 10px; }
            .filter-section label { margin-bottom: 5px; }
            .btn-submit { padding: 12px 20px; font-size: 1rem; }
        }
        @media (max-width: 576px) {
            .student-menu a { padding: 0.5rem; font-size: 0.9rem; }
        }

        /* Optional: dim gated links when not premium */
        .disabled { opacity: 0.5; pointer-events: none; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="student-dashboard">
        <!-- Student Sidebar -->
        <div class="student-sidebar">
            <div class="student-profile">
                <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
                <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server"></asp:Literal></h3>
                <p class="student-status">Active Student</p>
                <!-- Optional plan badge -->
                <div style="margin-top:8px;"><asp:Literal ID="litPlanBadge" runat="server" /></div>
            </div>

            <ul class="student-menu">
                <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>

                <!-- Premium-gated actions -->
                <li>
                    <asp:LinkButton ID="lnkUploadReport" runat="server"
                        CssClass="student-menu-link"
                        OnClick="RestrictedNav_Click"
                        CommandArgument="StudentMark.aspx">
                        <i class="fas fa-marker"></i> Upload School Report
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton ID="lnkScholarships" runat="server"
                        CssClass="student-menu-link"
                        OnClick="RestrictedNav_Click"
                        CommandArgument="Scholarships.aspx">
                        <i class="fas fa-money-check-alt"></i> Scholarships
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton ID="lnkCareer" runat="server"
                        CssClass="student-menu-link"
                        OnClick="RestrictedNav_Click"
                        CommandArgument="CareerGuidance.aspx">
                        <i class="fas fa-compass"></i> Career Guidance
                    </asp:LinkButton>
                </li>
                <li>
                    <asp:LinkButton ID="lnkMaterials" runat="server"
                        CssClass="student-menu-link"
                        OnClick="RestrictedNav_Click"
                        CommandArgument="StudentMaterials.aspx">
                        <i class="fas fa-book-open"></i> Study Materials
                    </asp:LinkButton>
                </li>

                <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="student-content">
            <div class="page-container">
                <h1 class="page-title">My Activities & Submissions <i class="fas fa-tasks"></i></h1>

                <asp:Literal ID="litStudentInfo" runat="server"></asp:Literal>

                <div class="filter-section">
                    <label for="<%= ddlSubjects.ClientID %>">Filter by Subject:</label>
                    <asp:DropDownList ID="ddlSubjects" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlSubjects_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <!-- IMPORTANT: UpdatePanel tuned to avoid duplicate renders -->
                <asp:UpdatePanel ID="updActivities" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="false">
                    <ContentTemplate>
                        <div class="section-header">Assignments from Teachers</div>
                        <asp:Repeater ID="rptTeacherActivities" runat="server" EnableViewState="false">
                            <ItemTemplate>
                                <div class="uploaded-file-item">
                                    <p><strong>Subject:</strong> <%# Eval("SubjectName") %> (<%# Eval("SubjectCode") %>)</p>
                                    <p><strong>Uploaded by:</strong> <%# Eval("TeacherFullName") %></p>
                                    <p><strong>File:</strong> <a href='<%# Eval("FilePath") %>' target="_blank" class="file-link"><%# Eval("FileName") %></a></p>
                                    <p><strong>Message:</strong> <%# Eval("Message") %></p>
                                    <p class="file-details">Uploaded on: <%# Eval("UploadDate", "{0:yyyy-MM-dd HH:mm}") %></p>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoTeacherActivities" runat="server" Visible="false" CssClass="no-activities-message">
                            No assignments found for this subject yet.
                        </asp:Panel>

                        <div class="section-header">Submit Your Work</div>
                        <div class="submission-form-container">
                            <h3>New Submission</h3>
                            <div class="form-group">
                                <label for="<%= FileUploadControl.ClientID %>">Select File for Submission:</label>
                                <asp:FileUpload ID="FileUploadControl" runat="server" CssClass="asp-fileupload" />
                            </div>
                            <div class="form-group">
                                <label for="<%= txtSubmissionMessage.ClientID %>">Message to Teacher (Optional):</label>
                                <asp:TextBox ID="txtSubmissionMessage" runat="server" TextMode="MultiLine" placeholder="Enter a message for your teacher..."></asp:TextBox>
                            </div>
                            <asp:Button ID="btnSubmitWork" runat="server" Text="Submit Work" OnClick="btnSubmitWork_Click" CssClass="btn-submit" />
                        </div>
                        <asp:Literal ID="litSubmissionStatus" runat="server"></asp:Literal>

                        <div class="section-header">Your Past Submissions</div>
                        <asp:Repeater ID="rptStudentSubmissions" runat="server" EnableViewState="false">
                            <ItemTemplate>
                                <div class="submission-item">
                                    <p><strong>Subject:</strong> <%# Eval("SubjectName") %> (<%# Eval("SubjectCode") %>)</p>
                                    <p><strong>Your File:</strong> <a href='<%# Eval("SubmittedFilePath") %>' target="_blank" class="file-link"><%# Eval("OriginalFileName") %></a></p>
                                    <p><strong>Your Message:</strong> <%# Eval("SubmissionMessage") %></p>
                                    <p class="submission-details">Submitted on: <%# Eval("SubmissionDate", "{0:yyyy-MM-dd HH:mm}") %></p>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoStudentSubmissions" runat="server" Visible="false" CssClass="no-submissions-message">
                            You haven't submitted any work for this subject yet.
                        </asp:Panel>
                    </ContentTemplate>
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlSubjects" EventName="SelectedIndexChanged" />
                        <asp:PostBackTrigger ControlID="btnSubmitWork" />
                    </Triggers>
                </asp:UpdatePanel>
            </div>
        </div>
    </div>
</asp:Content>
