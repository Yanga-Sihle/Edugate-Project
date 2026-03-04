<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherRegistration.aspx.cs" Inherits="Edugate_Project.TeacherRegistration" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Edugate - Registration Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"/>
    <style>
        /* Color Variables */
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            line-height: 1.6;
            overflow-x: hidden;
            background: var(--primary-dark);
            color: var(--text-light);
            padding: 0;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 100px 20px 60px;
        }

        /* Header */
        header {
            position: fixed;
            top: 0;
            width: 100%;
            background: var(--primary-dark);
            z-index: 1000;
            transition: all 0.3s ease;
            border-bottom: 1px solid rgba(218, 209, 203, 0.1);
            height: 90px;
            box-shadow: 0 4px 24px 0 rgba(20,145,155,0.10);
        }

        nav {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1.2rem 20px;
            height: 100%;
            max-width: 1200px;
            margin: 0 auto;
        }

        .logo {
            font-size: 2.6rem;
            font-weight: 900;
            letter-spacing: 2px;
            background: linear-gradient(90deg, #45DFB1 0%, #0B6477 50%, #80ED99 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-fill-color: transparent;
            text-shadow: 0 2px 16px rgba(20,145,155,0.18);
            padding-left: 10px;
            transition: transform 0.2s;
            display: flex;
            align-items: center;
            gap: 0.7rem;
            animation: logoFloat 3s ease-in-out infinite alternate;
        }

        .logo:hover {
            transform: scale(1.07) rotate(-2deg);
            filter: brightness(1.15);
        }

        .nav-links {
            display: flex;
            list-style: none;
            gap: 2rem;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--accent-light-green);
            font-weight: 700;
            font-size: 0.85rem;
            letter-spacing: 1px;
            padding: 0.25rem 0.6rem;
            border-radius: 30px;
            transition: background 0.3s, color 0.3s, box-shadow 0.3s, transform 0.2s;
            position: relative;
            display: flex;
            align-items: center;
            gap: 0.4rem;
        }

        .nav-links a i {
            font-size: 0.9rem;
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #45DFB1, #14919B);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-links a:hover, .nav-links a:focus {
            background: linear-gradient(90deg, #14919B 0%, #45DFB1 100%);
            color: var(--primary-dark);
            box-shadow: 0 2px 12px 0 rgba(20,145,155,0.15);
            transform: translateY(-2px) scale(1.07);
        }

        .nav-links a:hover i {
            transform: scale(1.1);
            background: linear-gradient(135deg, #14919B, #45DFB1);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .nav-links a::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -5px;
            left: 0;
            background: var(--accent-teal);
            transition: width 0.3s ease;
        }

        .nav-links a:hover::after {
            width: 100%;
        }

        /* Form Styles */
        .auth-card {
            background: rgba(33, 58, 87, 0.9);
            backdrop-filter: blur(15px);
            padding: 2.5rem 3rem;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(20, 145, 155, 0.15);
            width: 100%;
            border: 1px solid rgba(218, 209, 203, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .auth-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 60px rgba(20, 145, 155, 0.25);
        }

        .form-title {
            text-align: center;
            margin-bottom: 1.5rem;
            font-size: 2rem;
            font-weight: 700;
            color: var(--accent-light-green);
            background: linear-gradient(135deg, var(--accent-green), var(--accent-teal));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--accent-light-green);
            font-size: 0.95rem;
        }

        input[type="text"],
        input[type="password"],
        input[type="email"],
        select,
        textarea,
        .readonly-textbox {
            width: 100%;
            padding: 0.9rem 1rem;
            border: 2px solid rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(33, 58, 87, 0.5);
            color: var(--text-light);
            box-sizing: border-box;
        }

        input[type="text"]:focus,
        input[type="password"]:focus,
        input[type="email"]:focus,
        select:focus,
        textarea:focus {
            border-color: var(--accent-teal);
            outline: none;
            box-shadow: 0 0 0 3px rgba(20, 145, 155, 0.2);
            background: rgba(33, 58, 87, 0.7);
        }

        .readonly-textbox {
            background-color: rgba(33, 58, 87, 0.3);
            font-weight: bold;
            color: var(--accent-green);
            cursor: not-allowed;
        }

        select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="%2380ED99" height="24" viewBox="0 0 24 24" width="24" xmlns="http://www.w3.org/2000/svg"><path d="M7 10l5 5 5-5z"/><path d="M0 0h24v24H0z" fill="none"/></svg>');
            background-repeat: no-repeat;
            background-position: right 0.7rem center;
            background-size: 1.2em;
            padding-right: 2.5rem;
        }

        .btn-register {
            width: 100%;
            padding: 1rem;
            font-size: 1rem;
            border: none;
            border-radius: 50px;
            background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
            color: var(--primary-dark);
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 0.5rem;
            position: relative;
            overflow: hidden;
        }

        .btn-register:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(20, 145, 155, 0.4);
        }

        .validation-message {
            color: #ff6b6b;
            font-size: 0.85rem;
            margin-top: 0.3rem;
            display: block;
        }

        .registration-type {
            display: flex;
            justify-content: center;
            margin-bottom: 30px;
            gap: 10px;
        }

        .type-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            background: rgba(33, 58, 87, 0.5);
            color: var(--accent-light-green);
            transition: all 0.3s ease;
            border: 2px solid rgba(218, 209, 203, 0.2);
        }

        .type-btn.active {
            background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
            color: var(--primary-dark);
            box-shadow: 0 4px 15px rgba(20, 145, 155, 0.2);
        }

        .type-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(20, 145, 155, 0.3);
        }

        .form-container {
            display: none;
        }

        .form-container.active {
            display: block;
        }

        .status-message {
            margin-top: 20px;
            padding: 10px;
            border-radius: 5px;
            text-align: center;
        }

        .success {
            background: rgba(20, 145, 155, 0.2);
            color: var(--accent-green);
            border: 1px solid var(--accent-green);
        }

        .error {
            background: rgba(255, 107, 107, 0.2);
            color: #ff6b6b;
            border: 1px solid #ff6b6b;
        }

        .password-hint {
            font-size: 12px;
            color: var(--accent-light-green);
            margin-top: 5px;
            opacity: 0.8;
        }

        .subject-management {
            display: flex;
            gap: 10px;
            margin-bottom: 10px;
        }

        .subject-management > select {
            flex-grow: 1;
        }

        .subject-management .btn-register {
            width: auto;
            padding: 12px 20px;
        }

        .listbox {
            width: 100%;
            height: 100px;
            border: 2px solid rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            background: rgba(33, 58, 87, 0.5);
            color: var(--text-light);
            padding: 8px;
        }

        .grade-selector {
            width: 120px;
        }

        .debug-info {
            font-size: 12px;
            color: var(--accent-light-green);
            margin-top: 5px;
            font-family: monospace;
            opacity: 0.7;
        }

        #schoolCodeGroup {
            margin-top: 20px;
            padding: 15px;
            background-color: rgba(20, 145, 155, 0.1);
            border-radius: 10px;
            border-left: 4px solid var(--accent-teal);
        }

        /* Footer */
        footer {
            background: #1a1a1a;
            color: var(--text-light);
            padding: 60px 0 30px;
            margin-top: 60px;
        }

        .footer-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 3rem;
            margin-bottom: 2rem;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
        }

        .footer-section h3 {
            margin-bottom: 1rem;
            color: var(--accent-green);
        }

        .footer-section ul {
            list-style: none;
        }

        .footer-section ul li {
            margin-bottom: 0.5rem;
        }

        .footer-section ul li a {
            color: #ccc;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .footer-section ul li a:hover {
            color: var(--accent-teal);
        }

        .footer-bottom {
            text-align: center;
            padding-top: 2rem;
            border-top: 1px solid #333;
            color: #999;
            max-width: 1200px;
            margin: 0 auto;
        }

        /* Animations */
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes logoFloat {
            0% { transform: translateY(0) scale(1);}
            100% { transform: translateY(-10px) scale(1.05);}
        }

        @keyframes ripple {
            to {
                transform: scale(2);
                opacity: 0;
            }
        }

        /* Responsive */
        @media (max-width: 900px) {
            .logo { font-size: 2rem; }
            .nav-links { gap: 1.5rem; }
            nav { padding: 1rem 20px; }
            header { height: 70px; }
        }

        @media (max-width: 768px) {
            .nav-links {
                display: none;
            }

            .container {
                padding: 80px 20px 40px;
            }

            .auth-card {
                padding: 2rem;
            }

            .footer-content {
                grid-template-columns: 1fr;
                text-align: center;
            }

            .registration-type {
                flex-direction: column;
            }
        }

        /* ===== Result Card (teal/green theme to match form) ===== */
        .result-overlay{
          position:fixed; inset:0;
          display:none; align-items:center; justify-content:center;
          background:rgba(10,18,28,.55);
          backdrop-filter: blur(4px);
          z-index:9999;
        }
        .result-card{
          width:min(520px,94%);
          background: rgba(33,58,87,.95);
          color: var(--text-light);
          border: 1px solid rgba(128,237,153,.18);
          border-radius: 20px;
          padding: 28px 26px 22px;
          box-shadow: 0 18px 55px rgba(20,145,155,.25);
          text-align: center;
          backdrop-filter: blur(10px);
        }
        .result-icon{
          width:96px; height:96px; margin:0 auto 16px;
          display:grid; place-items:center;
          border-radius:50%;
          border:4px solid currentColor;
          color: var(--accent-green);
          background: radial-gradient(transparent, rgba(20,145,155,.10));
        }
        .result-icon svg{ width:46px; height:46px }
        .result-title{
          font-weight:900; letter-spacing:.04em;
          font-size:1.35rem; margin:4px 0 6px;
          background: linear-gradient(135deg, var(--accent-green), var(--accent-teal));
          -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }
        .result-sub{ color: rgba(218,209,203,.92); font-size: .98rem; margin-bottom:18px; }
        .result-actions .btn{
          width:100%; border:0; border-radius:14px; padding:12px 18px; font-weight:800; letter-spacing:.3px;
          background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
          color: var(--primary-dark);
          box-shadow: 0 10px 28px rgba(20,145,155,.35);
          cursor:pointer; transition: transform .15s ease, box-shadow .15s ease;
        }
        .result-actions .btn:hover{ transform: translateY(-2px); box-shadow: 0 12px 34px rgba(20,145,155,.45) }
        .result-actions .btn:active{ transform:none }

        .result-card.error  .result-icon{ color:#ff6b6b; background: radial-gradient(transparent, rgba(255,107,107,.10)) }
        .result-card.error  .result-title{
          background: linear-gradient(135deg, #ff6b6b, #f87171);
          -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
        }
        .result-card.error  .result-actions .btn{
          background: linear-gradient(135deg, #f87171, #ff6b6b);
          color:#1b263b; box-shadow: 0 10px 28px rgba(255,107,107,.35);
        }
        .result-icon svg path{ stroke-dasharray:48; stroke-dashoffset:48; animation:drawCheck .55s .15s ease-out forwards; }
        @keyframes drawCheck { to { stroke-dashoffset:0; } }
    </style>
</head>
<body>
    <header>
        <nav>
            <div class="logo">Edugate</div>
            <ul class="nav-links">
                <li><a href="Default.aspx"><i class="fas fa-home"></i> Home</a></li>
                <li><a href="Login.aspx"><i class="fas fa-marker"></i> Mark Tracking</a></li>
                <li><a href="Login.aspx"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
                <li><a href="Login.aspx"><i class="fas fa-briefcase"></i> Career Guidance</a></li>
                <li><a href="Login.aspx"><i class="fas fa-info-circle"></i> About Us</a></li>
                <li><a href="Login.aspx"><i class="fas fa-phone-alt"></i> Contact Us</a></li>
            </ul>
        </nav>
    </header>

    <form id="form1" runat="server">
        <!-- ScriptManager is required for RegisterStartupScript to fire reliably -->
        <asp:ScriptManager ID="sm" runat="server" />

        <div class="container">
            <div class="auth-card">
                <div class="registration-type">
                    <asp:Button ID="btnTeacherForm" runat="server" Text="Teacher Registration" CssClass="type-btn active" OnClick="btnTeacherForm_Click" CausesValidation="false" />
                    <asp:Button ID="btnSchoolForm" runat="server" Text="School Registration" CssClass="type-btn" OnClick="btnSchoolForm_Click" CausesValidation="false" />
                </div>

                <asp:Panel ID="TeacherForm" runat="server" CssClass="form-container active">
                    <h1 class="form-title">Teacher Registration</h1>
                    <div class="form-group">
                        <label>Full Name:</label>
                        <asp:TextBox ID="txtFullName" runat="server" placeholder="Enter your full name"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ErrorMessage="Full Name is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Email:</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="Enter your email"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ErrorMessage="Invalid email format" CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                    </div>
                   
                    <div class="form-group">
                        <label>Username:</label>
                        <asp:TextBox ID="txtUsername" runat="server" placeholder="Choose a username"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername" ErrorMessage="Username is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Password:</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Create password (min 8 chars)"></asp:TextBox>
                        <div class="password-hint">Must be at least 8 characters with letters and numbers</div>
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                        <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationExpression="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$" ErrorMessage="Password must be at least 8 characters with letters and numbers" CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Confirm Password:</label>
                        <asp:TextBox ID="txtTeacherConfirmPassword" runat="server" TextMode="Password" placeholder="Confirm password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTeacherConfirmPassword" runat="server" ControlToValidate="txtTeacherConfirmPassword" ErrorMessage="Confirm Password is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                        <asp:CompareValidator ID="cvTeacherPassword" runat="server" ControlToValidate="txtTeacherConfirmPassword" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>School Code:</label>
                        <asp:TextBox ID="txtSchoolCode" runat="server" placeholder="Enter 5-digit school code" AutoPostBack="true" OnTextChanged="txtSchoolCode_TextChanged"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSchoolCode" runat="server" ControlToValidate="txtSchoolCode" ErrorMessage="School Code is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                        <asp:RegularExpressionValidator ID="revSchoolCode" runat="server" ControlToValidate="txtSchoolCode" ValidationExpression="^\d{5}$" ErrorMessage="School code must be 5 digits" CssClass="validation-message" Display="Dynamic" ValidationGroup="TeacherValidationGroup" />
                        <asp:CustomValidator ID="cvSchoolCode" runat="server" ControlToValidate="txtSchoolCode" ErrorMessage="Invalid school code" CssClass="validation-message" Display="Dynamic" OnServerValidate="ValidateSchoolCode" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group" id="gradeGroup" runat="server" visible="false">
                        <label>Grade:</label>
                        <asp:DropDownList ID="ddlGrade" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlGrade_SelectedIndexChanged">
                            <asp:ListItem Value="">-- Select Grade --</asp:ListItem>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvGrade" runat="server" ControlToValidate="ddlGrade" 
                            ErrorMessage="Grade is required." CssClass="validation-message" Display="Dynamic" 
                            InitialValue="" ValidationGroup="TeacherValidationGroup" />
                    </div>
                    <div class="form-group" id="subjectGroup" runat="server" visible="false">
                        <label>Subject:</label>
                        <asp:DropDownList ID="ddlSubjects" runat="server" AutoPostBack="true">
                            <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="ddlSubjects" ErrorMessage="Subject is required." CssClass="validation-message" Display="Dynamic" InitialValue="" ValidationGroup="TeacherValidationGroup" />
                        <div class="debug-info" id="debugSubjects" runat="server" visible="false"></div>
                    </div>
                    <asp:Button ID="btnTeacherRegister" runat="server" Text="Register" OnClick="btnTeacherRegister_Click" CssClass="btn-register" ValidationGroup="TeacherValidationGroup" />
                    <asp:Literal ID="litTeacherStatus" runat="server"></asp:Literal>
                </asp:Panel>

               <asp:Panel ID="SchoolForm" runat="server" CssClass="form-container">
                    <h1 class="form-title">School Registration</h1>
                    <div class="form-group">
                        <label>School Subjects and Grades:</label>
                        <div class="subject-management">
                            <asp:DropDownList ID="ddlSystemSubjects" runat="server">
                                <asp:ListItem Value="">-- Select Subject --</asp:ListItem>
                                <asp:ListItem Value="PHYS">Physics</asp:ListItem>
                                <asp:ListItem Value="CAT">CAT/IT</asp:ListItem>
                                <asp:ListItem Value="EGD">EGD</asp:ListItem>
                                <asp:ListItem Value="MATH">Mathematics</asp:ListItem>
                                <asp:ListItem Value="GEOG">Geography</asp:ListItem>
                                <asp:ListItem Value="LIFE">Life Science</asp:ListItem>
                                <asp:ListItem Value="ACCT">Accounting</asp:ListItem>
                                <asp:ListItem Value="AGRI">Agriculture</asp:ListItem>
                                <asp:ListItem Value="ENGL">English</asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="ddlSubjectGrade" runat="server" CssClass="grade-selector">
                                <asp:ListItem Value="10">Grade 10</asp:ListItem>
                                <asp:ListItem Value="11">Grade 11</asp:ListItem>
                                <asp:ListItem Value="12">Grade 12</asp:ListItem>
                            </asp:DropDownList>
                            <asp:Button ID="btnAddSubject" runat="server" Text="Add" CssClass="btn-register" CausesValidation="false" OnClick="btnAddSubject_Click" />
                        </div>
                        <asp:ListBox ID="lstSchoolSubjects" runat="server" SelectionMode="Single" CssClass="listbox"></asp:ListBox>
                        <asp:Button ID="btnRemoveSubject" runat="server" Text="Remove Selected" CssClass="btn-register" CausesValidation="false" OnClick="btnRemoveSubject_Click" />
                    </div>
                    <div class="form-group">
                        <label>School Name:</label>
                        <asp:TextBox ID="txtSchoolName" runat="server" placeholder="Enter school name"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSchoolName" runat="server" ControlToValidate="txtSchoolName" ErrorMessage="School Name is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Address:</label>
                        <asp:TextBox ID="txtSchoolAddress" runat="server" TextMode="MultiLine" Rows="3" placeholder="Enter school address"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSchoolAddress" runat="server" ControlToValidate="txtSchoolAddress" ErrorMessage="Address is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Email:</label>
                        <asp:TextBox ID="txtSchoolEmail" runat="server" TextMode="Email" placeholder="Enter school email"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSchoolEmail" runat="server" ControlToValidate="txtSchoolEmail" ErrorMessage="Email is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                        <asp:RegularExpressionValidator ID="revSchoolEmail" runat="server" ControlToValidate="txtSchoolEmail" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" ErrorMessage="Invalid email format" CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                        <asp:CustomValidator ID="cvSchoolEmail" runat="server" ControlToValidate="txtSchoolEmail" ErrorMessage="This email is already registered" CssClass="validation-message" Display="Dynamic" OnServerValidate="ValidateSchoolEmail" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Phone Number:</label>
                        <asp:TextBox ID="txtSchoolPhone" runat="server" placeholder="Enter school phone number"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvSchoolPhone" runat="server" ControlToValidate="txtSchoolPhone" ErrorMessage="Phone number is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                        <asp:RegularExpressionValidator ID="revSchoolPhone" runat="server" ControlToValidate="txtSchoolPhone" ValidationExpression="^[0-9]{10,15}$" ErrorMessage="Please enter a valid phone number (10-15 digits)" CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>School Logo:</label>
                        <asp:FileUpload ID="fileSchoolLogo" runat="server" CssClass="file-upload-input" onchange="previewLogo(this)" />
                        <label for="<%= fileSchoolLogo.ClientID %>" class="file-upload-label">
                            <i class="fas fa-image"></i>
                            <span>Upload School Logo</span>
                            <small>(Max 2MB - JPG, PNG)</small>
                        </label>
                        <asp:Image ID="imgLogoPreview" runat="server" CssClass="logo-preview" Visible="false" />
                        <asp:HiddenField ID="hfLogoChanged" runat="server" Value="false" />
                    </div>
                    <div class="form-group">
                        <label>Password:</label>
                        <asp:TextBox ID="txtSchoolPassword" runat="server" TextMode="Password" placeholder="Create password (min 8 chars)"></asp:TextBox>
                        <div class="password-hint">Must be at least 8 characters with letters and numbers</div>
                        <asp:RequiredFieldValidator ID="rfvSchoolPassword" runat="server" ControlToValidate="txtSchoolPassword" ErrorMessage="Password is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                        <asp:RegularExpressionValidator ID="revSchoolPassword" runat="server" ControlToValidate="txtSchoolPassword" ValidationExpression="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$" ErrorMessage="Password must be at least 8 characters with letters and numbers" CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    <div class="form-group">
                        <label>Confirm Password:</label>
                        <asp:TextBox ID="txtSchoolConfirmPassword" runat="server" TextMode="Password" placeholder="Confirm password"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtSchoolConfirmPassword" ErrorMessage="Confirm Password is required." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                        <asp:CompareValidator ID="CompareValidator1" runat="server" ControlToValidate="txtSchoolConfirmPassword" ControlToCompare="txtSchoolPassword" ErrorMessage="Passwords do not match." CssClass="validation-message" Display="Dynamic" ValidationGroup="SchoolValidationGroup" />
                    </div>
                    
                    <div class="form-group">
                        <label>Subscription Plan:</label>
                        <asp:DropDownList ID="ddlSubscriptionPlan" runat="server">
                            <asp:ListItem Text="Free" Value="Free" Selected="True" />
                            <asp:ListItem Text="Premium" Value="Premium" />
                        </asp:DropDownList>
                    </div>
                    
                    <div class="form-group" id="schoolCodeGroup" runat="server" visible="false">
                        <label>Your School Code:</label>
                        <asp:TextBox ID="txtGeneratedSchoolCode" runat="server" ReadOnly="true" CssClass="readonly-textbox"></asp:TextBox>
                        <small>Give this 5-digit code to your teachers for registration</small>
                    </div>
                    
                    <asp:Button ID="btnSchoolRegister" runat="server" Text="Register" CssClass="btn-register" ValidationGroup="SchoolValidationGroup" OnClick="btnSchoolRegister_Click" />
                    <asp:Literal ID="litSchoolStatus" runat="server"></asp:Literal>
                </asp:Panel>
            </div>
        </div>

        <!-- ===== Result Card (success/error) ===== -->
        <div id="resultOverlay" class="result-overlay" aria-hidden="true">
            <div id="resultCard" class="result-card" role="dialog" aria-live="assertive" aria-modal="true">
                <div class="result-icon" id="resultIcon">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20 6L9 17l-5-5"></path>
                    </svg>
                </div>
                <div class="result-title" id="resultTitle">SUCCESS</div>
                <div class="result-sub" id="resultSub">Registration successful!</div>
                <div class="result-actions">
                    <button type="button" id="resultBtn" class="btn">CONTINUE</button>
                </div>
            </div>
        </div>
    </form>

    <footer>
        <div class="footer-content">
            <div class="footer-section">
                <h3>Edugate STEM</h3>
                <p>Empowering the next generation of scientists, technologists, engineers, and mathematicians through innovative education.</p>
            </div>
            <div class="footer-section">
                <h3>STEM Fields</h3>
                <ul>
                    <li><a href="#">Computer Science</a></li>
                    <li><a href="#">Engineering</a></li>
                    <li><a href="#">Biotechnology</a></li>
                    <li><a href="#">Mathematics</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h3>Resources</h3>
                <ul>
                    <li><a href="#">STEM Careers</a></li>
                    <li><a href="#">Research Opportunities</a></li>
                    <li><a href="#">Internships</a></li>
                    <li><a href="#">Scholarships</a></li>
                </ul>
            </div>
            <div class="footer-section">
                <h3>Support</h3>
                <ul>
                    <li><a href="#">Help Center</a></li>
                    <li><a href="#">Privacy Policy</a></li>
                    <li><a href="#">Terms of Service</a></li>
                    <li><a href="#">Contact STEM Advisors</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-bottom">
            <p>&copy; 2025 Edugate STEM. All rights reserved.</p>
        </div>
    </footer>

    <script>
        // Smooth scrolling for navigation links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Header background on scroll
        window.addEventListener('scroll', () => {
            const header = document.querySelector('header');
            if (window.scrollY > 100) {
                header.style.background = 'rgba(33, 58, 87, 0.98)';
                header.style.boxShadow = '0 2px 20px rgba(0, 0, 0, 0.3)';
            } else {
                header.style.background = 'var(--primary-dark)';
                header.style.boxShadow = 'none';
            }
        });

        // Interactive button effects
        document.querySelectorAll('.btn-register').forEach(btn => {
            btn.addEventListener('click', (e) => {
                if (!btn.hasAttribute('type') || btn.getAttribute('type') !== 'submit') {
                    e.preventDefault();
                }

                const ripple = document.createElement('span');
                const rect = btn.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                const x = e.clientX - rect.left - size / 2;
                const y = e.clientY - rect.top - size / 2;

                ripple.style.cssText = `
                    position: absolute;
                    width: ${size}px;
                    height: ${size}px;
                    left: ${x}px;
                    top: ${y}px;
                    background: rgba(255, 255, 255, 0.3);
                    border-radius: 50%;
                    transform: scale(0);
                    animation: ripple 0.6s ease-out;
                    pointer-events: none;
                `;

                const originalPosition = btn.style.position;
                const originalOverflow = btn.style.overflow;

                btn.style.position = 'relative';
                btn.style.overflow = 'hidden';
                btn.appendChild(ripple);

                setTimeout(() => {
                    ripple.remove();
                    btn.style.position = originalPosition;
                    btn.style.overflow = originalOverflow;
                }, 600);
            });
        });

        /* ===== Success / Error popup helpers ===== */
        function showSuccessCard(opts) {
            _showResult({
                mode: 'success',
                title: opts?.title || 'SUCCESS',
                message: opts?.message || 'Registration successful!',
                buttonText: opts?.buttonText || 'CONTINUE',
                redirectUrl: opts?.redirectUrl || null,
                autoCloseMs: opts?.autoCloseMs || 2200
            });
        }
        function showErrorCard(opts) {
            _showResult({
                mode: 'error',
                title: opts?.title || 'ERROR',
                message: opts?.message || 'Something went wrong!',
                buttonText: opts?.buttonText || 'TRY AGAIN',
                redirectUrl: null,
                autoCloseMs: 0
            });
        }
        function _showResult(cfg) {
            const overlay = document.getElementById('resultOverlay');
            const card = document.getElementById('resultCard');
            const icon = document.getElementById('resultIcon');
            const titleEl = document.getElementById('resultTitle');
            const subEl = document.getElementById('resultSub');
            const btn = document.getElementById('resultBtn');

            if (cfg.mode === 'error') {
                card.classList.add('error');
                icon.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>';
            } else {
                card.classList.remove('error');
                icon.innerHTML = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"></path></svg>';
            }

            titleEl.textContent = cfg.title;
            subEl.textContent = cfg.message;
            btn.textContent = cfg.buttonText;
            btn.onclick = function () { if (cfg.redirectUrl) window.location.href = cfg.redirectUrl; hideResult(); };
            overlay.style.display = 'flex';

            if (cfg.autoCloseMs && cfg.autoCloseMs > 0) {
                setTimeout(function () {
                    if (cfg.redirectUrl) window.location.href = cfg.redirectUrl;
                    else hideResult();
                }, cfg.autoCloseMs);
            }
        }
        function hideResult() { document.getElementById('resultOverlay').style.display = 'none'; }

        // Can be called from server after success
        function showSuccessAndRedirect(message, redirectUrl) {
            showSuccessCard({
                title: 'SUCCESS',
                message: message || 'You have successfully registered.',
                buttonText: 'CONTINUE',
                redirectUrl: redirectUrl || 'Default.aspx',
                autoCloseMs: 2200
            });
        }
    </script>
</body>
</html>
