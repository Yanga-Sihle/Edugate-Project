<%@ Page Title="Student Mark Tracking" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true"
    CodeBehind="StudentMark.aspx.cs" Inherits="Edugate_Project.MarkTracking" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style type="text/css">
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
            --card-bg: rgba(33, 58, 87, 0.7);
        }
        
        /* Student Dashboard Layout */
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
        
        .mark-container {
            padding: 20px 0;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--primary-dark) 60%, var(--accent-teal) 100%);
            color: var(--text-light);
            font-family: 'Inter', sans-serif;
        }

        .mark-container h1, 
        .mark-container h2 {
            color: var(--text-light);
            font-weight: 700;
        }

        .mark-container h1 {
            font-size: 2.5rem;
            margin-bottom: 2rem;
            text-align: center;
        }

        .mark-container h2 {
            font-size: 1.8rem;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent-teal);
            display: inline-block;
        }

        .summary-panel {
            background: var(--card-bg);
            border-radius: 24px;
            padding: 2.5rem;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            border: 2px solid var(--accent-green);
            margin: 2rem 0;
            backdrop-filter: blur(10px);
        }

        .summary-items {
            display: flex;
            flex-wrap: wrap;
            gap: 2rem;
        }

        .summary-item {
            text-align: center;
            flex: 1;
            min-width: 150px;
            padding: 1.5rem;
            background: rgba(20, 145, 155, 0.2);
            border-radius: 16px;
            transition: transform 0.3s ease;
        }

        .summary-item:hover {
            transform: translateY(-5px);
        }

        .summary-value {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--accent-green);
            display: block;
            margin-bottom: 0.5rem;
        }

        .summary-item span:not(.summary-value) {
            color: var(--text-light);
            font-size: 1.1rem;
        }

        .grid-view {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
            overflow: hidden;
            background: var(--card-bg);
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            margin: 2rem 0;
            border: 2px solid var(--accent-teal);
            backdrop-filter: blur(10px);
        }

        .grid-view th, .grid-view td {
            padding: 1.2rem 1.5rem;
            text-align: left;
            border-bottom: 1px solid rgba(218, 209, 203, 0.2);
            color: var(--text-light);
        }

        .grid-view th {
            background: rgba(11, 100, 119, 0.3);
            color: var(--accent-light-green);
            font-weight: 600;
            text-transform: uppercase;
            font-size: 0.9rem;
            letter-spacing: 0.5px;
        }

        .grid-view tr:last-child td {
            border-bottom: none;
        }

        .grid-view tr:hover {
            background-color: rgba(20, 145, 155, 0.1);
        }

        .status-badge {
            display: inline-block;
            padding: 0.5em 1.2em;
            border-radius: 25px;
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: capitalize;
        }

        .status-passed {
            background-color: var(--accent-green);
            color: var(--primary-dark);
        }

        .status-failed {
            background-color: #e74c3c;
            color: white;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-control {
            width: 100%;
            padding: 0.9rem 1rem;
            border: 2px solid rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            font-size: 1rem;
            background: var(--card-bg);
            color: var(--text-light);
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--accent-teal);
            outline: none;
            box-shadow: 0 0 0 3px rgba(20, 145, 155, 0.2);
        }

        .btn {
            background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
            color: var(--primary-dark);
            padding: 1rem 2rem;
            border: none;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-right: 1rem;
            margin-bottom: 1rem;
            font-size: 1rem;
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(20, 145, 155, 0.3);
        }

        .btn-secondary {
            background: transparent;
            border: 2px solid var(--accent-teal);
            color: var(--text-light);
        }

        .qualification-results {
            padding: 2rem;
            border-radius: 24px;
            margin: 2rem 0;
            display: none;
            background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
            color: var(--primary-dark);
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            border: 2px solid var(--accent-green);
        }

        .qualification-results h3 {
            color: var(--primary-dark);
            border-bottom: 2px solid var(--primary-dark);
        }

        .qualification-results.show {
            display: block;
            animation: fadeInUp 0.5s ease;
        }

        .floating-shape {
            position: absolute;
            border-radius: 50%;
            opacity: 0.18;
            z-index: 0;
            animation: floatShape 8s ease-in-out infinite alternate;
        }
        
        .shape1 { width: 180px; height: 180px; background: var(--accent-green); top: 10%; left: 5%; animation-delay: 0s; }
        .shape2 { width: 120px; height: 120px; background: var(--primary-orange); top: 70%; left: 60%; animation-delay: 2s; }
        .shape3 { width: 90px; height: 90px; background: var(--accent-light-green); top: 40%; left: 80%; animation-delay: 4s; }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        @keyframes floatShape {
            0% { transform: translateY(0) scale(1); }
            100% { transform: translateY(-30px) scale(1.1); }
        }

        @media screen and (max-width: 768px) {
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
            
            .summary-items {
                flex-direction: column;
                gap: 1rem;
            }

            .summary-item {
                min-width: 100%;
            }

            .grid-view td {
                display: block;
                text-align: right;
                padding-left: 50%;
                position: relative;
            }

            .grid-view td::before {
                content: attr(data-label);
                position: absolute;
                left: 1rem;
                width: calc(50% - 1.5rem);
                text-align: left;
                font-weight: 600;
                color: var(--accent-light-green);
            }

            .grid-view th {
                display: none;
            }

            .grid-view tr {
                margin-bottom: 1rem;
                display: block;
                border: 1px solid rgba(218, 209, 203, 0.2);
                border-radius: 10px;
                overflow: hidden;
            }
            
            .mark-container h1 {
                font-size: 2rem;
            }
            
            .mark-container h2 {
                font-size: 1.5rem;
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
                <p class="student-status">Active Student</p>
            </div>
            
            <ul class="student-menu">
                <li><a href="StudentDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="StudentMark.aspx" class="active"><i class="fas fa-marker"></i> Upload School Report</a></li>
                <li><a href="Scholarships.aspx"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
                <li><a href="CareerGuidance.aspx"><i class="fas fa-compass"></i> Career Guidance</a></li>
                <li><a href="StudentMaterials.aspx"><i class="fas fa-book-open"></i> Study Materials</a></li>
                <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>
        
        <!-- Main Content -->
        <div class="student-content">
            <div class="mark-container">
                <div class="floating-shape shape1"></div>
                <div class="floating-shape shape2"></div>
                <div class="floating-shape shape3"></div>
                <div class="container">
                    <h1 aria-label="Student Academic Dashboard">Student Academic Dashboard</h1>

                    <div class="summary-panel" role="region" aria-labelledby="summaryHeading">
                        <h2 id="summaryHeading">Academic Summary</h2>
                        <div class="summary-items">
                            <div class="summary-item" aria-label="Total Subjects">
                                <span class="summary-value" runat="server" id="lblTotalSubjects" aria-live="polite">0</span>
                                <span>Total Subjects</span>
                            </div>
                            <div class="summary-item" aria-label="Overall Average">
                                <span class="summary-value" runat="server" id="lblOverallAverage" aria-live="polite">0%</span>
                                <span>Overall Average</span>
                            </div>
                            <div class="summary-item" aria-label="Passed Subjects">
                                <span class="summary-value" runat="server" id="lblPassedSubjects" aria-live="polite">0</span>
                                <span>Passed Subjects</span>
                            </div>
                        </div>
                    </div>

                    <h2 id="performanceHeading">Subject Performance</h2>
                    <asp:GridView ID="gvMarks" runat="server" CssClass="grid-view" AutoGenerateColumns="False"
                        OnRowDataBound="gvMarks_RowDataBound" aria-describedby="performanceHeading">
                        <Columns>
                            <asp:TemplateField HeaderText="Subject">
                                <HeaderTemplate>
                                    <span aria-label="Subject">Subject</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <span aria-label='<%# "Subject: " + Eval("Subject") %>'>
                                        <%# Eval("Subject") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Mark (%)">
                                <HeaderTemplate>
                                    <span aria-label="Mark percentage">Mark (%)</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <span aria-label='<%# "Mark percentage: " + Eval("Mark") %>'>
                                        <%# Eval("Mark") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Grade">
                                <HeaderTemplate>
                                    <span aria-label="Grade">Grade</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <span aria-label='<%# "Grade: " + Eval("Grade") %>'>
                                        <%# Eval("Grade") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status">
                                <HeaderTemplate>
                                    <span aria-label="Status">Status</span>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'
                                        CssClass='<%# Eval("Status").ToString() == "Passed" ? "status-badge status-passed" : "status-badge status-failed" %>'
                                        aria-label='<%# "Status: " + Eval("Status") %>'>
                                    </asp:Label>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                    
                    <div class="summary-panel">
                        <h2 id="updateHeading">Add/Update Marks</h2>
                        <div class="form-group">
                            <asp:Label ID="lblSubject" runat="server" AssociatedControlID="ddlNewSubject">Subject</asp:Label>
                            <asp:DropDownList ID="ddlNewSubject" runat="server" CssClass="form-control"
                                aria-labelledby="updateHeading lblSubject" aria-required="true">
                                <asp:ListItem Value="" aria-label="Select subject">-- Select Subject --</asp:ListItem>
                                <asp:ListItem Value="Mathematics" aria-label="Mathematics">Mathematics</asp:ListItem>
                                <asp:ListItem Value="Physics" aria-label="Physics">Physics</asp:ListItem>
                                <asp:ListItem Value="Chemistry" aria-label="Chemistry">Chemistry</asp:ListItem>
                                <asp:ListItem Value="Life Science" aria-label="Life Science">Life Science</asp:ListItem>
                                <asp:ListItem Value="Computer Application Technology" aria-label="Computer Application Technology">Computer Application Technology</asp:ListItem>
                                <asp:ListItem Value="Engineering Graphic Design" aria-label="Engineering Graphic Design">Engineering Graphic Design</asp:ListItem>
                                <asp:ListItem Value="English" aria-label="English">English</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-group">
                            <asp:Label ID="lblMark" runat="server" AssociatedControlID="txtNewMark">Mark (0-100)</asp:Label>
                            <asp:TextBox ID="txtNewMark" runat="server" CssClass="form-control" TextMode="Number" min="0" max="100"
                                placeholder="Enter mark percentage" aria-labelledby="updateHeading lblMark" aria-required="true"></asp:TextBox>
                        </div>
                        <asp:Button ID="btnAddMark" runat="server" Text="Add/Update Mark" CssClass="btn"
                            OnClick="btnAddMark_Click" aria-label="Add or update mark" />
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh Data" CssClass="btn btn-secondary"
                            OnClick="btnRefresh_Click" aria-label="Refresh data" />
                    </div>

                    <div class="summary-panel">
                        <h2 id="careerHeading">STEM Career Qualification Check</h2>
                        <div class="form-group">
                            <asp:Label ID="lblCareer" runat="server" AssociatedControlID="ddlCareer">Select STEM Career</asp:Label>
                            <asp:DropDownList ID="ddlCareer" runat="server" CssClass="form-control"
                                aria-labelledby="careerHeading lblCareer" aria-required="true">
                                <asp:ListItem Value="" aria-label="Select career">-- Select Career --</asp:ListItem>
                                <asp:ListItem Value="Data Scientist" aria-label="Data Scientist">Data Scientist</asp:ListItem>
                                <asp:ListItem Value="AI Developer" aria-label="AI Developer">AI Developer</asp:ListItem>
                                <asp:ListItem Value="Software Developer" aria-label="Software Developer">Software Developer</asp:ListItem>
                                <asp:ListItem Value="Data and Security Analysis" aria-label="Data and Security Analysis">Data and Security Analysis</asp:ListItem>
                                <asp:ListItem Value="Civil Engineering" aria-label="Civil Engineering">Civil Engineering</asp:ListItem>
                                <asp:ListItem Value="Chemical Engineering" aria-label="Chemical Engineering">Chemical Engineering</asp:ListItem>
                                <asp:ListItem Value="Biomedical Engineer" aria-label="Biomedical Engineer">Biomedical Engineer</asp:ListItem>
                                <asp:ListItem Value="Biologist" aria-label="Biologist">Biologist</asp:ListItem>
                                <asp:ListItem Value="Astronomer" aria-label="Astronomer">Astronomer</asp:ListItem>
                                <asp:ListItem Value="Industrial Engineering" aria-label="Industrial Engineering">Industrial Engineering</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <asp:Button ID="btnCheckQualification" runat="server" Text="Check Qualification" CssClass="btn"
                            OnClick="btnCheckQualification_Click" aria-label="Check career qualification" />

                        <div id="qualificationResults" runat="server" class="qualification-results" role="status">
                            <h3 id="lblQualificationStatus" runat="server"></h3>
                            <p id="lblQualificationDetails" runat="server"></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        // Button ripple effect (same as homepage)
        function addRippleEffect(e) {
            const btn = e.currentTarget;
            const circle = document.createElement('span');
            const diameter = Math.max(btn.clientWidth, btn.clientHeight);
            const radius = diameter / 2;
            circle.style.width = circle.style.height = `${diameter}px`;
            circle.style.left = `${e.clientX - btn.getBoundingClientRect().left - radius}px`;
            circle.style.top = `${e.clientY - btn.getBoundingClientRect().top - radius}px`;
            circle.classList.add('ripple');
            btn.appendChild(circle);
            setTimeout(() => circle.remove(), 600);
        }

        // Apply ripple effect to all buttons
        document.querySelectorAll('.btn').forEach(btn => {
            btn.addEventListener('click', addRippleEffect);
        });

        // Ripple CSS
        const rippleStyle = document.createElement('style');
        rippleStyle.textContent = `
            .ripple {
                position: absolute;
                border-radius: 50%;
                transform: scale(0);
                animation: ripple-anim 0.6s linear;
                background: rgba(218,209,203,0.5);
                pointer-events: none;
                z-index: 2;
            }
            @keyframes ripple-anim {
                to {
                    transform: scale(2.5);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(rippleStyle);
    </script>
</asp:Content>