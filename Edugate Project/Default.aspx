<%@ Page Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Edugate_Project.Default" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>Home - Edugate STEM</title>
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
        
        .home-container {
            padding: 120px 0 80px;
            min-height: 100vh;
            background: linear-gradient(135deg, var(--primary-dark) 60%, var(--accent-teal) 100%);
        }

        /* Hero Section Styles */
        .main-hero {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 2rem 0;
            position: relative;
            z-index: 2;
            margin-bottom: 4rem;
        }

        .hero-content {
            flex: 1;
            max-width: 600px;
            animation: slideInLeft 1.2s cubic-bezier(.77,0,.18,1);
            z-index: 1;
        }

        .hero-title {
            font-size: 3.2rem;
            font-weight: 800;
            margin-bottom: 1.2rem;
            color: var(--text-light);
            letter-spacing: 1px;
        }

        .hero-title .highlight { color: var(--primary-orange); }
        .hero-title .accent { color: var(--accent-green); }

        .hero-description {
            font-size: 1.25rem;
            color: var(--accent-light-green);
            margin-bottom: 2.2rem;
            line-height: 1.6;
            opacity: 0.95;
        }

        /* Login Section Styles */
        .login-section {
            flex: 0 0 370px;
            margin-left: 2rem;
            animation: slideInRight 1.2s cubic-bezier(.77,0,.18,1);
            z-index: 1;
        }

        .login-form {
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            padding: 2.5rem 2rem 2rem 2rem;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            border: 2px solid var(--accent-green);
            position: relative;
            overflow: hidden;
        }

        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        /* Underline Input Style */
        .form-input {
            width: 100%;
            background: transparent;
            border: none;
            border-bottom: 2px solid var(--accent-light-green);
            padding: 0.8rem 0;
            color: var(--text-light);
            font-size: 1.1rem;
            outline: none;
            transition: border-color 0.3s;
            box-shadow: none;
        }

        .form-input:focus {
            border-bottom-color: var(--accent-green);
            box-shadow: none;
        }

        .form-input::placeholder {
            color: var(--accent-light-green);
            opacity: 0.7;
        }

        /* Floating Labels */
        .input-label {
            position: absolute;
            left: 0;
            top: 0.8rem;
            color: var(--accent-light-green);
            transition: all 0.3s ease;
            pointer-events: none;
        }

        .form-input:focus + .input-label,
        .form-input:not(:placeholder-shown) + .input-label {
            top: -0.5rem;
            font-size: 0.8rem;
            color: var(--accent-green);
        }

        .submit-btn {
            background: var(--primary-orange);
            color: var(--text-light);
            padding: 1rem;
            border: none;
            border-radius: 25px;
            font-weight: 700;
            cursor: pointer;
            transition: background 0.3s, color 0.3s;
            width: 100%;
            margin-bottom: 1rem;
            box-shadow: 0 2px 8px 0 rgba(20,145,155,0.10);
            position: relative;
            overflow: hidden;
        }

        .submit-btn:active {
            background: var(--accent-green);
            color: var(--primary-dark);
        }

        .signup-link {
            text-align: center;
            color: var(--accent-light-green);
            margin-bottom: 1.5rem;
        }

        .signup-link a {
            color: var(--accent-green);
            text-decoration: none;
            font-weight: 700;
        }

        .signup-link a:hover {
            color: var(--primary-orange);
        }

        /* Login Toggle Styles */
        .login-toggle {
            display: flex;
            margin-bottom: 1.5rem;
            background: rgba(33, 58, 87, 0.3);
            border-radius: 50px;
            padding: 5px;
            position: relative;
        }

        .toggle-option {
            flex: 1;
            text-align: center;
            padding: 0.5rem;
            cursor: pointer;
            color: var(--text-light);
            font-weight: 600;
            z-index: 1;
            transition: color 0.3s;
        }

        .toggle-option.active {
            color: var(--primary-dark);
        }

        .toggle-slider {
            position: absolute;
            top: 5px;
            left: 5px;
            width: calc(50% - 5px);
            height: calc(100% - 10px);
            background: var(--accent-green);
            border-radius: 50px;
            transition: transform 0.3s ease;
        }

        /* Login Forms */
        .login-forms {
            position: relative;
            height: 300px;
            overflow: hidden;
        }

        .login-form-container {
            position: absolute;
            width: 100%;
            transition: all 0.3s ease;
            opacity: 0;
            transform: translateX(100%);
            pointer-events: none;
        }

        .login-form-container.active {
            opacity: 1;
            transform: translateX(0);
            pointer-events: auto;
        }

        /* School Login Styles */
        .school-login-container {
            margin-top: 2rem;
            background: rgba(33, 58, 87, 0.7);
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid var(--accent-teal);
        }

        .btn-toggle-school {
            width: 100%;
            padding: 1rem;
            background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
            color: var(--primary-dark);
            font-weight: 700;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-bottom: 1rem;
            font-size: 1rem;
        }

        .btn-toggle-school:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 20px rgba(20, 145, 155, 0.3);
        }

        .school-login-form {
            overflow: hidden;
            height: 0;
            opacity: 0;
            transition: height 0.4s ease, opacity 0.4s ease;
        }

        .school-login-form.show {
            height: 260px;
            opacity: 1;
        }

        .school-form-group {
            margin-bottom: 1.5rem;
        }

        .school-form-control {
            width: 100%;
            padding: 0.9rem 1rem;
            border: 2px solid rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            font-size: 1rem;
            background: rgba(33, 58, 87, 0.5);
            color: var(--text-light);
            transition: all 0.3s ease;
        }

        .school-form-control:focus {
            border-color: var(--accent-teal);
            outline: none;
            box-shadow: 0 0 0 3px rgba(20, 145, 155, 0.2);
        }

        /* CTA Cards - Matching Login Form Style */
        .cta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin: 2rem 0;
        }

        .cta-card {
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            padding: 2rem;
            text-align: center;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            border: 2px solid var(--accent-green);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .cta-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(20,145,155,0.4);
        }

        .cta-card .icon {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            display: inline-block;
            color: var(--text-light);
        }

        .cta-card h3 {
            font-size: 1.3rem;
            margin-bottom: 1rem;
            color: var(--text-light);
            font-weight: 700;
        }

        .cta-card p {
            color: var(--accent-light-green);
            margin-bottom: 1.5rem;
            opacity: 0.9;
        }

        .cta-btn {
            display: inline-block;
            padding: 0.8rem 1.5rem;
            background: var(--primary-dark);
            color: var(--text-light);
            border-radius: 25px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
            box-shadow: 0 2px 8px 0 rgba(20,145,155,0.10);
            position: relative;
            overflow: hidden;
            width: 100%;
        }

        .cta-btn:hover {
            background: var(--accent-green);
            color: var(--primary-dark);
            transform: translateY(-2px);
        }

        /* Benefits Section */
        .benefits-section {
            background: rgba(33, 58, 87, 0.7);
            backdrop-filter: blur(15px);
            border-radius: 20px;
            padding: 3rem;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.2);
            margin-top: 2rem;
            border: 1px solid var(--accent-teal);
            animation: fadeInUp 1s ease-out 0.4s both;
        }

        .benefits-section h3 {
            font-size: 1.6rem;
            color: var(--accent-green);
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid var(--accent-teal);
            display: inline-block;
        }

        .benefits-list {
            list-style: none;
        }

        .benefits-list li {
            margin-bottom: 1rem;
            padding-left: 2rem;
            position: relative;
            font-size: 1.1rem;
            line-height: 1.6;
            color: var(--text-light);
        }

        .benefits-list li:before {
            content: "✓";
            position: absolute;
            left: 0;
            color: var(--accent-green);
            font-weight: bold;
        }

        /* Floating Shapes */
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

        /* Animations */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slideInLeft {
            from { opacity: 0; transform: translateX(-60px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(60px); }
            to { opacity: 1; transform: translateX(0); }
        }

        @keyframes floatShape {
            0% { transform: translateY(0) scale(1); }
            100% { transform: translateY(-30px) scale(1.1); }
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .main-hero { flex-direction: column; text-align: center; gap: 3rem; }
            .login-section { flex: none; width: 100%; max-width: 400px; margin-left: 0; }
            .hero-title { font-size: 2.2rem; }
        }

        @media (max-width: 768px) {
            .hero-title { font-size: 1.8rem; }
            .main-hero { padding: 1rem 0; }
            .login-form, .features-card, .benefits-section { padding: 1.5rem; }
            .cta-grid { grid-template-columns: 1fr; }
            .school-login-container { padding: 1rem; }
        }

        @media (max-width: 480px) {
            .hero-title { font-size: 1.4rem; }
            .login-section { max-width: 100%; margin: 0 1rem; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="home-container">
        <div class="floating-shape shape1"></div>
        <div class="floating-shape shape2"></div>
        <div class="floating-shape shape3"></div>
        <div class="container">
            <!-- New Hero Section with Login Form -->
            <div class="main-hero">
                <div class="hero-content">
                    <h1 class="hero-title">
                        Where potential <span class="highlight">meets</span> <span class="accent">OPPORTUNITY</span>
                    </h1>
                    <p class="hero-description">
                        EduGate bridges the gap in education by delivering digital resources, guidance, and support to high school students across South Africa empowering the next generation to rise.
                    </p>
                </div>
                <div class="login-section">
                    <div class="login-form">
                        <!-- Login Toggle -->
                        <div class="login-toggle">
                            <div class="toggle-slider"></div>
                            <div class="toggle-option active" onclick="switchLogin('student')">Student</div>
                            <div class="toggle-option" onclick="switchLogin('admin')">Admin</div>
                        </div>
                        
                        <!-- Login Forms Container -->
                        <div class="login-forms">
                            <!-- Student Login Form -->
                            <div class="login-form-container student active">
                                <div class="form-group">
                                    <asp:TextBox ID="txtStudentEmail" runat="server" CssClass="form-input" placeholder=" " />
                                    <label class="input-label">Email</label>
                                </div>
                                <div class="form-group">
                                    <asp:TextBox ID="txtStudentPassword" runat="server" TextMode="Password" CssClass="form-input" placeholder=" " />
                                    <label class="input-label">Password</label>
                                </div>
                                <asp:Button ID="btnStudentLogin" runat="server" Text="Login" CssClass="submit-btn" OnClick="btnStudentLogin_Click" />
                                <div class="signup-link">
                                    Don't have an account? <a href="StudentRegistration.aspx">Register here</a>
                                </div>
                            </div>
                            
                            <!-- Admin Login Form -->
                            <div class="login-form-container admin">
                                <div class="form-group">
                                    <asp:TextBox ID="txtAdminUsername" runat="server" CssClass="form-input" placeholder=" " />
                                    <label class="input-label">Username</label>
                                </div>
                                <div class="form-group">
                                    <asp:TextBox ID="txtAdminPassword" runat="server" TextMode="Password" CssClass="form-input" placeholder=" " />
                                    <label class="input-label">Password</label>
                                </div>
                                <asp:Button ID="btnAdminLogin" runat="server" Text="Login" CssClass="submit-btn" OnClick="btnAdminLogin_Click" />
                                <div class="signup-link">
                                    Admin registration? <a href="TeacherRegistration.aspx">Register</a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- School Login Section -->
                    <div class="school-login-container">
                        <asp:Button ID="btnToggleSchoolLogin" runat="server" Text="School Login" 
                            CssClass="btn-toggle-school" OnClientClick="toggleSchoolLogin(); return false;" />
                        
                        <div id="schoolLoginForm" class="school-login-form">
                            <div class="school-form-group">
                                <asp:TextBox ID="txtSchoolCode" runat="server" CssClass="school-form-control" 
                                    placeholder="Enter 5-digit school code"></asp:TextBox>
                            </div>
                            <div class="school-form-group">
                                <asp:TextBox ID="txtSchoolPassword" runat="server" TextMode="Password" 
                                    CssClass="school-form-control" placeholder="Enter your password"></asp:TextBox>
                            </div>
                            <asp:Button ID="btnSchoolLogin" runat="server" Text="Login" 
                                CssClass="submit-btn" OnClick="btnSchoolLogin_Click" />
                            <div class="signup-link">
                                <p>Don't have an account? <a href="TeacherRegistration.aspx">Register your school</a></p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Features Section with Updated CTA Cards -->
            <div class="features-card">
                <h2>Launch Your STEM Journey</h2>
                <div class="cta-grid">
                    <div class="cta-card">
                        <div class="icon"><i class="fas fa-book"></i></div>
                        <h3>STEM Courses</h3>
                        <p>Explore our comprehensive collection of STEM courses tailored to your academic level</p>
                        <a href="Login.aspx" class="cta-btn">Browse Courses</a>
                    </div>
                    <div class="cta-card">
                        <div class="icon"><i class="fas fa-chart-line"></i></div>
                        <h3>Academic Tracking</h3>
                        <p>Monitor your progress and get insights to improve your STEM performance</p>
                        <a href="Login.aspx" class="cta-btn">Track Progress</a>
                    </div>
                    <div class="cta-card">
                        <div class="icon"><i class="fas fa-compass"></i></div>
                        <h3>Career Guidance</h3>
                        <p>Discover STEM career paths that match your skills and interests</p>
                        <asp:Button ID="btnguide" runat="server" Text="Explore" CssClass="cta-btn"  Height="49px" Width="100%"/>
                    </div>
                    <div class="cta-card">
                        <div class="icon"><i class="fas fa-briefcase"></i></div>
                        <h3>Internships</h3>
                        <p>Find valuable STEM internship opportunities to gain real-world experience</p>
                        <a href="Login.aspx" class="cta-btn">View Internships</a>
                    </div>
                </div>
            </div>

            <div class="benefits-section">
                <h3>💡 Why Choose Edugate STEM?</h3>
                <ul class="benefits-list">
                    <li>Personalized STEM learning paths based on your academic profile</li>
                    <li>Data-driven career recommendations for STEM fields</li>
                    <li>Comprehensive tracking of your academic progress in STEM subjects</li>
                    <li>Access to exclusive STEM internship and research opportunities</li>
                    <li>Interactive tools to help you plan your STEM education journey</li>
                    <li>Community of like-minded STEM students and professionals</li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        // Button ripple effect
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
        document.querySelectorAll('.submit-btn, .cta-btn, .btn-toggle-school').forEach(btn => {
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

        // Login toggle functionality
        function switchLogin(type) {
            const toggleOptions = document.querySelectorAll('.toggle-option');
            const slider = document.querySelector('.toggle-slider');
            const studentForm = document.querySelector('.login-form-container.student');
            const adminForm = document.querySelector('.login-form-container.admin');

            // Update toggle button states
            toggleOptions.forEach(option => option.classList.remove('active'));
            document.querySelector(`.toggle-option[onclick="switchLogin('${type}')"]`).classList.add('active');

            // Move the slider
            slider.style.transform = type === 'student' ? 'translateX(0)' : 'translateX(100%)';

            // Show/hide forms
            if (type === 'student') {
                studentForm.classList.add('active');
                adminForm.classList.remove('active');
            } else {
                studentForm.classList.remove('active');
                adminForm.classList.add('active');
            }
        }

        // School login toggle functionality
        function toggleSchoolLogin() {
            var form = document.getElementById('schoolLoginForm');
            form.classList.toggle('show');

            var button = document.getElementById('<%= btnToggleSchoolLogin.ClientID %>');
            if (form.classList.contains('show')) {
                button.textContent = 'Hide School Login';
            } else {
                button.textContent = 'School Login';
            }
        }
    </script>
</asp:Content>