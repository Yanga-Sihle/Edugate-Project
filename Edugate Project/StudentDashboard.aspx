<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentDashboard.aspx.cs" Inherits="Edugate_Project.StudentDashboard" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Student Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
        }

       
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
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
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

        .student-name {
            font-size: 1.2rem;
            margin: 0.5rem 0;
            font-weight: 700;
            color: var(--text-light);
        }

        .student-status {
            font-size: 0.85rem;
            color: var(--accent-light-green);
            margin: 0;
        }

        .student-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .student-menu li {
            margin-bottom: 0.5rem;
        }

        .student-menu a {
            display: flex;
            align-items: center;
            color: rgba(255,255,255,0.8);
            padding: 0.75rem 1rem;
            border-radius: 6px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .student-menu a:hover, .student-menu a.active {
            background-color: rgba(69, 223, 177, 0.2);
            color: var(--text-light);
        }

        .student-menu a i {
            margin-right: 0.75rem;
            width: 20px;
            text-align: center;
        }

        /* Main Content Area */
        .student-content {
            flex: 1;
            margin-left: 280px;
            padding: 2rem;
            background-color: rgba(33, 58, 87, 0.7);
            min-height: 100vh;
            backdrop-filter: blur(5px);
            border-left: 1px solid var(--accent-teal);
        }

        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2.5rem 2rem 2rem 2rem;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border: 2px solid var(--accent-green);
            animation: fadeInUp 0.8s ease-out forwards;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Header and Welcome Message */
        .dashboard-header {
            text-align: center;
            margin-bottom: 20px;
            color: var(--text-light);
            font-size: 2.5rem;
            font-weight: 800;
        }

        .welcome-message {
            font-size: 1.2rem;
            text-align: center;
            color: var(--accent-light-green);
            margin-bottom: 40px;
            opacity: 0.95;
        }

        /* Profile Section */
        .profile-section {
            background: rgba(33, 58, 87, 0.7);
            backdrop-filter: blur(5px);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: left;
            border: 1px solid var(--accent-teal);
            margin-bottom: 30px;
        }

        .profile-section h3 {
            color: var(--accent-green);
            font-size: 1.5rem;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .profile-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .info-group {
            margin-bottom: 15px;
        }

        .info-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            color: var(--accent-light-green);
        }

        .info-group .value {
            padding: 10px;
            background: rgba(33, 58, 87, 0.5);
            border-radius: 8px;
            border: 1px solid var(--accent-teal);
            min-height: 20px;
        }

        .edit-btn {
            background-color: var(--accent-green);
            color: var(--primary-dark);
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            margin-top: 20px;
            display: block;
            margin-left: auto;
            margin-right: auto;
            transition: all 0.3s ease;
        }

        .edit-btn:hover {
            background-color: var(--primary-dark);
            color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
        }

        /* Edit Form */
        .edit-form {
            display: none;
            background: rgba(33, 58, 87, 0.9);
            padding: 25px;
            border-radius: 16px;
            margin-top: 20px;
            border: 1px solid var(--accent-green);
        }

        .form-group {
            margin-bottom: 15px;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 5px;
            color: var(--accent-light-green);
        }

        .form-group input,
        .form-group select {
            width: 100%;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid var(--accent-teal);
            background: rgba(33, 58, 87, 0.7);
            color: var(--text-light);
            box-sizing: border-box;
        }

        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }

        .save-btn {
            background-color: var(--accent-green);
            color: var(--primary-dark);
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

        .cancel-btn {
            background-color: transparent;
            color: var(--text-light);
            border: 1px solid var(--accent-teal);
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
        }

        .save-btn:hover {
            background-color: var(--primary-dark);
            color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
        }

        .cancel-btn:hover {
            background-color: rgba(230, 57, 70, 0.2);
            border-color: #E63946;
        }

        /* Dashboard Options Grid */
        .dashboard-options-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }

        .option-card {
            background-color: rgba(33, 58, 87, 0.7);
            padding: 25px 20px;
            border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            text-decoration: none;
            color: var(--text-light);
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            border: 1px solid var(--accent-teal);
            backdrop-filter: blur(5px);
        }

        .option-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            background-color: rgba(20, 145, 155, 0.3);
            border-color: var(--accent-green);
        }

        .option-card .icon {
            font-size: 2.2rem;
            color: var(--accent-green);
            margin-bottom: 15px;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: rgba(69, 223, 177, 0.1);
            border-radius: 50%;
            border: 2px solid var(--accent-green);
            transition: all 0.3s ease;
        }

        .option-card:hover .icon {
            background: var(--accent-green);
            color: var(--primary-dark);
            transform: scale(1.1) rotate(5deg);
        }

        .option-card h4 {
            font-size: 1.2rem;
            font-weight: 700;
            margin-bottom: 10px;
            color: var(--text-light);
        }

        .option-card p {
            font-size: 0.9rem;
            color: var(--accent-light-green);
            opacity: 0.8;
            margin: 0;
            line-height: 1.4;
        }

        /* Dashboard Sections Layout */
        .dashboard-sections {
            display: grid;
            grid-template-columns: 1fr;
            gap: 25px;
            margin-bottom: 40px;
        }

        @media (min-width: 768px) {
            .dashboard-sections {
                grid-template-columns: 1fr 1fr;
            }
            .section-card[style*="grid-column"] {
                grid-column: 1 / -1;
            }
        }

        .section-card {
            background: rgba(33, 58, 87, 0.7);
            backdrop-filter: blur(5px);
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            text-align: left;
            border: 1px solid var(--accent-teal);
            transition: transform 0.3s ease;
        }
        
        .section-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.2);
        }

        .section-card h3 {
            color: var(--accent-green);
            font-size: 1.5rem;
            margin-bottom: 20px;
            text-align: center;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }

        .section-card h3 i {
            font-size: 1.3rem;
        }

        /* List Items (Subjects, Grades, Sessions, Messages) */
        .section-list {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .section-list li {
            background-color: rgba(33, 58, 87, 0.5);
            padding: 15px 20px;
            margin-bottom: 12px;
            border-radius: 10px;
            box-shadow: 0 1px 5px rgba(0,0,0,0.1);
            font-size: 1rem;
            color: var(--text-light);
            transition: all 0.3s ease;
            border: 1px solid rgba(20, 145, 155, 0.2);
        }
        
        .section-list li:hover {
            background-color: rgba(20, 145, 155, 0.3);
            transform: translateX(5px);
            border-color: var(--accent-green);
        }

        .section-list li a,
        .section-list li strong {
            color: var(--text-light);
            text-decoration: none;
            font-weight: 600;
        }

        .section-list li a:hover {
            color: var(--accent-light-green);
        }
        
        .section-list li span {
            color: var(--accent-light-green);
            display: block;
            font-size: 0.9rem;
            margin-top: 5px;
        }

        /* No Data Text */
        .no-data-text {
            text-align: center;
            color: var(--accent-light-green);
            font-style: italic;
            margin: 20px 0;
        }

        /* Logout Button */
        .logout-section {
            text-align: center;
            margin-top: 50px;
        }

        .btn-logout {
            background-color: rgba(230, 57, 70, 0.8);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 700;
            transition: all 0.3s ease;
            font-size: 1rem;
            box-shadow: 0 2px 8px rgba(230, 57, 70, 0.3);
        }

        .btn-logout:hover {
            background-color: #E63946;
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(230, 57, 70, 0.4);
        }
        
        /* Responsive adjustments */
        @media (max-width: 992px) {
            .dashboard-options-grid {
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            }
            
            .student-sidebar {
                width: 240px;
                padding: 1.5rem 0.75rem;
            }
            
            .student-content {
                margin-left: 240px;
                padding: 1.5rem;
            }
            
            .profile-info {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 767px) {
            .student-sidebar {
                transform: translateX(-100%);
                width: 280px;
            }
            
            .student-sidebar.active {
                transform: translateX(0);
            }
            
            .student-content {
                margin-left: 0;
                padding: 1rem;
            }
            
            .dashboard-container {
                padding: 20px;
                margin-top: 20px;
            }

            .dashboard-header {
                font-size: 2rem;
            }

            .welcome-message {
                font-size: 1.1rem;
                margin-bottom: 30px;
            }

            .dashboard-options-grid {
                grid-template-columns: 1fr 1fr;
                gap: 15px;
            }

            .section-card {
                padding: 20px;
            }
        }

        @media (max-width: 576px) {
            .student-menu a {
                padding: 0.5rem;
                font-size: 0.9rem;
            }
            
            .dashboard-options-grid {
                grid-template-columns: 1fr;
            }

            .dashboard-header {
                font-size: 1.8rem;
            }

            .option-card {
                padding: 20px 15px;
            }

            .option-card .icon {
                font-size: 1.8rem;
                width: 50px;
                height: 50px;
            }

            .section-card h3 {
                font-size: 1.3rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="student-dashboard">
        <!-- Student Sidebar -->
        <div class="student-sidebar">
            <div class="student-profile">
                <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
                <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server"></asp:Literal></h3>
               <p class="student-status">
    <asp:Literal ID="litPlanBadge" runat="server" />
</p>

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
            <div class="dashboard-container">
                <h1 class="dashboard-header">Student Dashboard <i class="fas fa-graduation-cap"></i></h1>
                <p class="welcome-message">Welcome, <asp:Literal ID="litStudentFullName2" runat="server"></asp:Literal>! Here's an overview of your academic journey.</p>

                <!-- Student Profile Section -->
                <div class="profile-section">
                    <h3><i class="fas fa-user-circle"></i> My Profile</h3>
                    <div class="profile-info">
                        <div class="info-group">
                            <label>Full Name</label>
                            <div class="value"><asp:Literal ID="litFullName" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Student ID</label>
                            <div class="value"><asp:Literal ID="litStudentId" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Email</label>
                            <div class="value"><asp:Literal ID="litEmail" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Gender</label>
                            <div class="value"><asp:Literal ID="litGender" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Address</label>
                            <div class="value"><asp:Literal ID="litAddress" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>School Code</label>
                            <div class="value"><asp:Literal ID="litSchoolCode" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Grade</label>
                            <div class="value"><asp:Literal ID="litGrade" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Grade Level</label>
                            <div class="value"><asp:Literal ID="litGradeLevel" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Registration Date</label>
                            <div class="value"><asp:Literal ID="litRegistrationDate" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Last Login</label>
                            <div class="value"><asp:Literal ID="litLastLogin" runat="server"></asp:Literal></div>
                        </div>
                        <div class="info-group">
                            <label>Status</label>
                            <div class="value"><asp:Literal ID="litStatus" runat="server"></asp:Literal></div>
                        </div>
                    </div>
                    <button id="btnEditProfile" class="edit-btn" onclick="toggleEditForm(); return false;">
                        <i class="fas fa-edit"></i> Edit Profile
                    </button>
                    
                  
                    <div id="editProfileForm" class="edit-form" runat="server">
                        <div class="form-group">
                            <label for="txtFullName">Full Name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label for="txtEmail">Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label for="ddlGender">Gender</label>
                            <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Male" Value="Male"></asp:ListItem>
                                <asp:ListItem Text="Female" Value="Female"></asp:ListItem>
                                <asp:ListItem Text="Other" Value="Other"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <label for="txtAddress">Address</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label for="txtGrade">Grade</label>
                            <asp:TextBox ID="txtGrade" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label for="txtGradeLevel">Grade Level</label>
                            <asp:TextBox ID="txtGradeLevel" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        <div class="form-actions">
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="cancel-btn" OnClientClick="toggleEditForm(); return false;" />
                            <asp:Button ID="btnSave" runat="server" Text="Save Changes" CssClass="save-btn" OnClick="btnSave_Click" />
                        </div>
                    </div>
                </div>


                <div class="dashboard-sections">
                    <div class="section-card">
                        <h3><i class="fas fa-book"></i> My Subjects</h3>
                        <asp:Repeater ID="rptSubjects" runat="server">
                            <HeaderTemplate>
                                <ul class="section-list">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <li>
                                    <a href='<%# "TakeQuiz.aspx?subjectCode=" + Eval("SubjectCode") %>'>
                                        <strong><%# Eval("SubjectName") %></strong>
                                        <span>(<%# Eval("SubjectCode") %>)</span>
                                    </a>
                                </li>
                            </ItemTemplate>
                            <FooterTemplate>
                                </ul>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Literal ID="litNoSubjects" runat="server" Visible="false" Text="<p class='no-data-text'>No subjects found.</p>"></asp:Literal>
                    </div>

                    <div class="section-card">
                        <h3><i class="fas fa-star"></i> My Grades</h3>
                        <asp:Repeater ID="rptGrades" runat="server">
                            <HeaderTemplate>
                                <ul class="section-list">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <li>
                                    <strong><%# Eval("Subject") %>:</strong>
                                    <span class="grade <%# GetGradeCssClass(Convert.ToInt32(Eval("Mark"))) %>">
                                        <%# Eval("Mark") %>% (<%# Eval("Grade") %>)
                                        <small>(<%# Eval("Status") %>)</small>
                                    </span>
                                </li>
                            </ItemTemplate>
                            <FooterTemplate>
                                </ul>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Literal ID="litNoGrades" runat="server" Visible="false" Text="<p class='no-data-text'>No grades recorded yet.</p>"></asp:Literal>
                    </div>

                    <div class="section-card" style="grid-column: 1 / -1;">
                        <h3><i class="fas fa-poll"></i> My Quiz Results</h3>
                        <asp:Repeater ID="rptQuizResults" runat="server">
                            <HeaderTemplate>
                                <div class="quiz-results-container">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="quiz-result-item">
                                    <div class="quiz-result-header">
                                        <span class="quiz-result-title"><%# Eval("QuizTitle") %></span>
                                        <span class="quiz-result-date">Completed on <%# Eval("CompletionDate", "{0:dd MMM yyyy}") %></span>
                                    </div>
                                    <div class="quiz-result-details">
                                        <div class="quiz-result-info">
                                            <span class="quiz-result-subject">Subject: <%# Eval("SubjectName") %></span>
                                            <span>Score: <span class='quiz-result-score <%# (int)Eval("Score") >= 50 ? "passed" : "failed" %>'><%# Eval("Score") %>%</span></span>
                                        </div>
                                        <asp:HyperLink ID="hlViewDetails" runat="server"
                                            NavigateUrl='<%# "QuizResultDetails.aspx?resultId=" + Eval("ResultId") %>'
                                            CssClass="quiz-result-view-btn">
                                            
                                        </asp:HyperLink>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>
                        <asp:Literal ID="litNoQuizResults" runat="server" Visible="false" Text="<p class='no-data-text'>No quiz results found. Take some quizzes to see your results here!</p>"></asp:Literal>
                    </div>
                </div>

                <div class="logout-section">
                    <asp:Button ID="btnLogout" runat="server" Text="Logout" OnClick="btnLogout_Click" CssClass="btn-logout" />
                </div>
            </div>
        </div>
    </div>

    <script>
        function toggleEditForm() {
            var form = document.getElementById('<%= editProfileForm.ClientID %>');
            var btn = document.getElementById('btnEditProfile');
            
            if (form.style.display === 'none' || form.style.display === '') {
                form.style.display = 'block';
                btn.innerHTML = '<i class="fas fa-times"></i> Cancel Editing';
                btn.style.backgroundColor = '#E63946';
            } else {
                form.style.display = 'none';
                btn.innerHTML = '<i class="fas fa-edit"></i> Edit Profile';
                btn.style.backgroundColor = '';
            }
        }
    </script>
</asp:Content>