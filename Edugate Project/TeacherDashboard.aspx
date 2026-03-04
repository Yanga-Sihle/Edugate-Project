<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherDashboard.aspx.cs" Inherits="Edugate_Project.TeacherDashboard" MasterPageFile="~/Admin.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Teacher Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        /* =========================
           Palette (unchanged)
        ==========================*/
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
        }

        /* =========================
           Base Typography (match StudentDashboard)
        ==========================*/
        html { font-size: 16px; } /* consistent root */
        body {
            background-color: var(--primary-dark);
            color: var(--text-light);
            font-family: 'Inter','Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-weight: 400;
            line-height: 1.55;
            margin: 0;
            min-height: 100vh;
        }

        /* A small, consistent type scale */
        .text-xs   { font-size: 0.75rem; }   /* 12px */
        .text-sm   { font-size: 0.875rem; }  /* 14px */
        .text-base { font-size: 1rem; }      /* 16px */
        .text-lg   { font-size: 1.125rem; }  /* 18px */
        .text-xl   { font-size: 1.25rem; }   /* 20px */
        .text-2xl  { font-size: 1.5rem; }    /* 24px */
        .text-3xl  { font-size: 2rem; }      /* 32px */
        .text-4xl  { font-size: 2.5rem; }    /* 40px */

        .fw-600 { font-weight: 600; }
        .fw-700 { font-weight: 700; }
        .fw-800 { font-weight: 800; }

        /* =========================
           Layout
        ==========================*/
        .dashboard-wrapper { display:flex; min-height:100vh; }

        /* Sidebar */
        .sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            padding: 2rem 1rem;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            border-right: 2px solid var(--accent-green);
            z-index: 1000;
        }

        .sidebar-header {
            text-align: center;
            padding-bottom: 1.25rem;
            border-bottom: 1px solid rgba(255, 255, 255, 0.2);
            margin-bottom: 1.25rem;
        }

        .teacher-avatar {
            width: 80px; height: 80px; border-radius: 50%;
            border: 3px solid var(--accent-green);
            margin: 0 auto 0.75rem auto;
            background-color: var(--primary-dark);
            display:flex; align-items:center; justify-content:center;
            font-size: 2rem; color: var(--accent-green);
        }

        .sidebar-header h3 {
            color: #fff;
            margin: 0.5rem 0 0.25rem;
            font-weight: 700;
            font-size: 1.2rem; /* = student .student-name 1.2rem */
        }

        .sidebar-header p {
            color: var(--accent-light-green);
            margin: 0;
            font-size: 0.85rem; /* = student status size */
        }

        .sidebar-nav { list-style:none; padding:0; margin:0; }
        .sidebar-nav li { margin-bottom: 0.5rem; }

        .nav-item {
            display:flex; align-items:center;
            padding: 0.75rem 1rem;
            color: rgba(255,255,255,0.9);
            text-decoration:none;
            border-radius: 6px;
            transition: all 0.2s ease;
            font-size: 1rem; /* match student menu */
            font-weight: 600;
        }
        .nav-item:hover, .nav-item.active {
            background-color: rgba(69,223,177,0.2);
            color: var(--text-light);
        }
        .nav-item i { margin-right: 0.75rem; width: 20px; text-align:center; font-size: 1.1rem; }

        /* Main */
        .main-content {
            flex:1;
            margin-left: 280px;
            padding: 2rem;
            background-color: rgba(33,58,87,0.7);
            min-height: 100vh;
            backdrop-filter: blur(5px);
            border-left: 1px solid var(--accent-teal);
        }

        .dashboard-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2.5rem 2rem 2rem;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            border: 2px solid var(--accent-green);
        }

        /* =========================
           Headings & Text (match Student)
        ==========================*/
        .dashboard-header {
            text-align: center;
            margin-bottom: 1.25rem;
            color: var(--text-light);
            font-size: 2.5rem;   /* Student .dashboard-header */
            font-weight: 800;
        }

        .welcome-message {
            font-size: 1.2rem;   /* Student welcome-message */
            text-align: center;
            color: var(--accent-light-green);
            margin-bottom: 2.5rem;
            opacity: 0.95;
            font-weight: 600;
        }

        /* Teacher info */
        .teacher-info {
            background: rgba(33,58,87,0.7);
            backdrop-filter: blur(5px);
            border-radius: 16px;
            padding: 1.25rem;
            margin-bottom: 1.875rem;
            border: 1px solid var(--accent-teal);
            text-align: center;
        }
        .teacher-info-item {
            margin: 0.6rem 0;
            font-size: 1rem; /* unify */
        }
        .teacher-info-item strong { color: var(--accent-green); font-weight: 700; }

        /* Profile Edit Form (match sizes from student) */
        .profile-edit-form {
            background: rgba(33,58,87,0.7);
            backdrop-filter: blur(5px);
            border-radius: 16px;
            padding: 1.5rem;
            margin-bottom: 1.875rem;
            border: 1px solid var(--accent-teal);
        }
        .form-title {
            color: var(--accent-green);
            font-size: 1.5rem;  /* Student section titles */
            margin-bottom: 1.25rem;
            text-align: center;
            font-weight: 700;
            display:flex; align-items:center; justify-content:center; gap: 0.5rem;
        }

        .form-group { margin-bottom: 1rem; }
        .form-group label {
            display:block; margin-bottom: 0.4rem;
            color: var(--accent-light-green);
            font-weight: 600;
            font-size: 0.95rem;
        }
        .form-control {
            width: 100%;
            padding: 0.75rem;
            border-radius: 8px;
            border: 1px solid var(--accent-teal);
            background: rgba(33,58,87,0.7);
            color: var(--text-light);
            font-size: 1rem;
            transition: all .2s ease;
            box-sizing: border-box;
        }
        .form-control:focus {
            outline: none;
            border-color: var(--accent-green);
            box-shadow: 0 0 0 2px rgba(69,223,177,0.3);
        }

        .btn-update {
            background-color: var(--accent-green);
            color: var(--primary-dark);
            border: none;
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 700;
            transition: all 0.2s ease;
            font-size: 1rem;
            display:block; margin: 1.25rem auto 0; min-width: 160px;
        }
        .btn-update:hover {
            background-color: var(--primary-dark);
            color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
            transform: translateY(-2px);
        }

        /* Stats */
        .stats-section {
            background: rgba(33,58,87,0.7);
            backdrop-filter: blur(5px);
            border-radius: 16px;
            padding: 1.25rem;
            margin-bottom: 1.875rem;
            border: 1px solid var(--accent-teal);
            text-align:center;
        }
        .stat-item { display:inline-block; margin: 0 1rem; }
        .stat-number {
            font-size: 2.5rem;  /* match student big numbers */
            font-weight: 800;
            color: var(--accent-green);
            display:block;
            line-height: 1.1;
        }
        .stat-label {
            font-size: 1rem;
            color: var(--accent-light-green);
            font-weight: 600;
        }

        /* Logout */
        .logout-section { text-align:center; margin-top: 3rem; }
        .btn-logout {
            background-color: rgba(230,57,70,0.8);
            color: #fff;
            border: none;
            padding: 0.75rem 1.875rem;
            border-radius: 25px;
            cursor: pointer;
            font-weight: 700;
            transition: all .2s ease;
            font-size: 1rem;
            box-shadow: 0 2px 8px rgba(230,57,70,0.3);
        }
        .btn-logout:hover {
            background-color: #E63946;
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(230,57,70,0.4);
        }

        /* =========================
           Responsive (aligned to student)
        ==========================*/
        @media (max-width: 992px) {
            .sidebar { width: 240px; padding: 1.5rem 0.75rem; }
            .main-content { margin-left: 240px; padding: 1.5rem; }
        }
        @media (max-width: 767px) {
            .dashboard-wrapper { flex-direction: column; }
            .sidebar { width: 100%; height:auto; position:relative; }
            .main-content { margin-left: 0; padding: 1rem; }
            .dashboard-container { padding: 1.25rem; margin-top: 1.25rem; }
            .dashboard-header { font-size: 2rem; }
            .welcome-message { font-size: 1.1rem; margin-bottom: 1.875rem; }
            .stat-item { display:block; margin: 0.9rem 0; }
        }
        @media (max-width: 480px) {
            .dashboard-header { font-size: 1.8rem; }
            .profile-edit-form { padding: 1rem; }
            .nav-item { font-size: 0.95rem; }
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
                <li><a href="#dashboard" class="nav-item active"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
                <li><a href="#profile" class="nav-item"><i class="fas fa-user-edit"></i><span>Edit Profile</span></a></li>
                <li><a href="QuizManagement.aspx" class="nav-item"><i class="fas fa-question-circle"></i><span>Manage Quizzes</span></a></li>
                <li><a href="TeacherFileUpload.aspx" class="nav-item"><i class="fas fa-tasks"></i><span>Student Assessments</span></a></li>
                <li><a href="TeacherSendMessage.aspx" class="nav-item"><i class="fas fa-envelope"></i><span>Messages</span></a></li>
                <li><a href="UploadMarks.aspx" class="nav-item"><i class="fas fa-chart-bar"></i><span>Manage Marks</span></a></li>
                <li>
                    <a href="Default.aspx" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
                </li>
            </ul>
        </div>

        <!-- Main -->
        <div class="main-content">
            <div class="dashboard-container">
                <h1 class="dashboard-header">Teacher Dashboard <i class="fas fa-chalkboard-teacher"></i></h1>
                <p class="welcome-message">
                    Welcome, <asp:Label ID="lblTeacherName" runat="server" Font-Bold="true"></asp:Label>!
                </p>

                <div class="teacher-info">
                    <div class="teacher-info-item"><strong>School:</strong> <asp:Label ID="lblSchoolName" runat="server"></asp:Label></div>
                    <div class="teacher-info-item"><strong>Subject:</strong> <asp:Label ID="lblSubject" runat="server"></asp:Label></div>
                    <div class="teacher-info-item"><strong>Email:</strong> <asp:Label ID="lblEmail" runat="server"></asp:Label></div>
                </div>

                <div class="stats-section">
                    <div class="stat-item">
                        <span class="stat-number"><asp:Label ID="lblStudentCount" runat="server" Text="0"></asp:Label></span>
                        <span class="stat-label">Students</span>
                    </div>
                </div>

                <!-- Profile Edit -->
                <div class="profile-edit-form" id="profile">
                    <h3 class="form-title">Edit Your Profile</h3>

                    <div class="form-group">
                        <label for="txtFullName">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                            ErrorMessage="Full name is required" Display="Dynamic" ForeColor="#E63946" ValidationGroup="ProfileUpdate"></asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label for="txtEmail">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Enter your email"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                            ErrorMessage="Email is required" Display="Dynamic" ForeColor="#E63946" ValidationGroup="ProfileUpdate"></asp:RequiredFieldValidator>
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                            ErrorMessage="Invalid email format"
                            ValidationExpression="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
                            Display="Dynamic" ForeColor="#E63946" ValidationGroup="ProfileUpdate"></asp:RegularExpressionValidator>
                    </div>

                    <div class="form-group">
                        <label for="txtSubject">Subject</label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" placeholder="Enter your subject"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject"
                            ErrorMessage="Subject is required" Display="Dynamic" ForeColor="#E63946" ValidationGroup="ProfileUpdate"></asp:RequiredFieldValidator>
                    </div>

                    <div class="form-group">
                        <label for="txtPassword">New Password (leave blank to keep current)</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter new password"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label for="txtConfirmPassword">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm new password"></asp:TextBox>
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtPassword" Operator="Equal" Type="String"
                            ErrorMessage="Passwords do not match" Display="Dynamic" ForeColor="#E63946" ValidationGroup="ProfileUpdate"></asp:CompareValidator>
                    </div>

                    <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Profile"
                        CssClass="btn-update" OnClick="btnUpdateProfile_Click" ValidationGroup="ProfileUpdate" />
                </div>

                <div class="logout-section">
                    <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn-logout" OnClick="btnLogout_Click" />
                </div>
            </div>
        </div>
    </div>

    <script>
        // make sidebar nav active + smooth scroll to profile
        document.addEventListener('DOMContentLoaded', function () {
            const navItems = document.querySelectorAll('.nav-item');
            navItems.forEach(item => {
                item.addEventListener('click', function (e) {
                    // remove active from all
                    navItems.forEach(i => i.classList.remove('active'));
                    // add active to clicked
                    this.classList.add('active');

                    // scroll to profile section when needed
                    const text = this.querySelector('span')?.textContent?.trim();
                    if (text === 'Edit Profile') {
                        e.preventDefault();
                        document.getElementById('profile').scrollIntoView({ behavior: 'smooth' });
                    }
                });
            });
        });
    </script>
</asp:Content>
