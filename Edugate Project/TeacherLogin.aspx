<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherLogin.aspx.cs" Inherits="Edugate_Project.TeacherLogin" MasterPageFile="~/Site1.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Teacher Login</title>
    <style>
        /* General form container styling */
        .login-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            margin-top: 80px; /* Adjusted for master page header */
            animation: fadeInUp 0.8s ease-out forwards;
            max-width: 450px; /* Limit width for login form */
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        /* Animated border for main container */
        .login-container::before {
            content: '';
            position: absolute;
            top: -3px;
            left: -3px;
            right: -3px;
            bottom: -3px;
            background: linear-gradient(45deg, #3498db, #2ecc71, #3498db, #2ecc71);
            background-size: 400% 400%;
            border-radius: 13px;
            z-index: -1;
            animation: logoGradientBorder 4s ease infinite;
        }

        .login-container::after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: #fff;
            border-radius: 10px;
            z-index: -1;
        }

        /* Animated border panel */
        .animated-border-panel {
            position: relative;
            padding: 30px;
            border-radius: 12px;
            background: #fff;
            margin: 20px 0;
            overflow: hidden;
        }

        .animated-border-panel::before {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(45deg, #3498db, #2ecc71, #3498db, #2ecc71);
            background-size: 400% 400%;
            border-radius: 12px;
            z-index: -1;
            animation: logoGradientBorder 3s ease infinite;
        }

        .animated-border-panel::after {
            content: '';
            position: absolute;
            top: 2px;
            left: 2px;
            right: 2px;
            bottom: 2px;
            background: #fff;
            border-radius: 10px;
            z-index: -1;
        }

        /* Glowing effect on hover */
        .animated-border-panel:hover::before {
            animation: logoGradientBorder 1.5s ease infinite;
            box-shadow: 0 0 20px rgba(52, 152, 219, 0.5);
        }

        .login-title {
            background: linear-gradient(135deg, #3498db, #2ecc71);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 30px;
            font-size: 2.5rem;
            font-weight: 700;
            animation: titleGlow 2s ease-in-out infinite alternate;
        }

        /* Form group styling */
        .form-group {
            margin-bottom: 25px;
            text-align: left; /* Align labels and inputs to the left within the group */
        }

        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: #2c3e50;
            font-size: 1.1rem;
        }

        .form-group input[type="text"],
        .form-group input[type="password"] {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            color: #333;
            box-sizing: border-box; /* Include padding in width */
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-group input[type="text"]:focus,
        .form-group input[type="password"]:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
        }

        /* Button styling */
        .btn-login {
            background: linear-gradient(135deg, #3498db, #2ecc71);
            color: white;
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            width: 100%;
            display: block; /* Make it a block element to take full width */
            margin-top: 30px;
        }

        .btn-login:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(52, 152, 219, 0.4);
        }

        .register-link {
            display: block;
            margin-top: 20px;
            font-size: 1rem;
            color: #555;
            text-decoration: none;
            transition: color 0.3s ease;
        }

        .register-link a {
            color: #3498db;
            font-weight: 600;
            text-decoration: none;
        }

        .register-link a:hover {
            text-decoration: underline;
        }

        /* Message/Error display */
        .status-message {
            margin-top: 20px;
            padding: 15px;
            border-radius: 8px;
            font-weight: 600;
            text-align: center;
        }

        .status-message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .status-message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
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

        @keyframes logoGradientBorder {
            0% {
                background-position: 0% 50%;
            }
            50% {
                background-position: 100% 50%;
            }
            100% {
                background-position: 0% 50%;
            }
        }

        @keyframes titleGlow {
            0% {
                filter: drop-shadow(0 0 5px rgba(52, 152, 219, 0.3));
            }
            100% {
                filter: drop-shadow(0 0 15px rgba(46, 204, 113, 0.4));
            }
        }

        /* Responsive adjustments */
        @media (max-width: 600px) {
            .login-container {
                padding: 20px;
                margin-top: 50px;
            }

            .login-title {
                font-size: 2rem;
            }

            .btn-login {
                padding: 12px 20px;
                font-size: 1rem;
            }

            .animated-border-panel {
                padding: 20px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <div class="login-container">
            <h1 class="login-title">Teacher Login 🔑</h1>

            <div class="animated-border-panel">
                <asp:Panel ID="LoginPanel" runat="server">
                    <div class="form-group">
                        <label for="<%= txtUsername.ClientID %>">Username:</label>
                        <asp:TextBox ID="txtUsername" runat="server" placeholder="Enter your username"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtPassword.ClientID %>">Password:</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" placeholder="Enter your password"></asp:TextBox>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn-login" />

                    <p class="register-link">Don't have an account? <a href="TeacherRegistration.aspx">Register here</a></p>
                </asp:Panel>
            </div>

            <asp:Literal ID="litStatusMessage" runat="server"></asp:Literal>
        </div>
    </div>
</asp:Content>