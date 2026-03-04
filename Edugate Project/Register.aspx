<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="Edugate_Project.Register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .auth-container {
            padding: 120px 0 60px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        }

        .auth-card {
            background: rgba(255, 255, 255, 0.98);
            backdrop-filter: blur(15px);
            padding: 2.5rem 3rem;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.08);
            width: 100%;
            max-width: 450px;
            border: 1px solid rgba(0, 0, 0, 0.05);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .auth-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.12);
        }

        .auth-card h2 {
            text-align: center;
            margin-bottom: 1.5rem;
            font-size: 2rem;
            font-weight: 700;
            color: #2c3e50;
            background: linear-gradient(135deg, #3498db, #2ecc71);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .form-group {
            margin-bottom: 1.5rem;
            position: relative;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: #2c3e50;
            font-size: 0.95rem;
        }

        .form-control {
            width: 100%;
            padding: 0.9rem 1rem;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: #f8f9fa;
        }

        .form-control:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
            background: white;
        }

        .cta-btn {
            width: 100%;
            padding: 1rem;
            font-size: 1rem;
            border: none;
            border-radius: 50px;
            background: linear-gradient(135deg, #3498db, #2ecc71);
            color: white;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 0.5rem;
        }

        .cta-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(52, 152, 219, 0.3);
        }

        .auth-footer {
            text-align: center;
            margin-top: 1.5rem;
            color: #7f8c8d;
            font-size: 0.95rem;
        }

        .auth-footer a {
            color: #3498db;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            position: relative;
        }

        .auth-footer a:hover {
            color: #2ecc71;
        }

        .auth-footer a::after {
            content: '';
            position: absolute;
            width: 0;
            height: 2px;
            bottom: -2px;
            left: 0;
            background: linear-gradient(135deg, #3498db, #2ecc71);
            transition: width 0.3s ease;
        }

        .auth-footer a:hover::after {
            width: 100%;
        }

        .validation-message {
            color: #e74c3c;
            font-size: 0.85rem;
            margin-top: 0.3rem;
            display: block;
        }

        /* STEM Field Selection */
        .stem-fields {
            margin: 1.5rem 0;
        }

        .stem-fields h4 {
            font-size: 1rem;
            color: #2c3e50;
            margin-bottom: 0.8rem;
        }

        .checkbox-group {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 0.8rem;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
        }

        .checkbox-item input[type="checkbox"] {
            margin-right: 0.5rem;
            accent-color: #3498db;
        }

        @media (max-width: 768px) {
            .auth-container {
                padding: 100px 20px 40px;
            }
            
            .auth-card {
                padding: 2rem;
            }
            
            .checkbox-group {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="auth-container">
        <div class="auth-card">
            <h2>Create Your STEM Account</h2>
            <asp:Literal ID="lblRegMessage" runat="server" EnableViewState="false" />

            <div class="form-group">
                <label for="txtName">Full Name</label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter your full name" />
                <asp:RequiredFieldValidator ID="rfvName" runat="server" 
                    ControlToValidate="txtName" ErrorMessage="Name is required" 
                    CssClass="validation-message" Display="Dynamic" />
            </div>
            
            <div class="form-group">
                <label for="txtEmail">Email Address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="your@email.com" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                    ControlToValidate="txtEmail" ErrorMessage="Email is required" 
                    CssClass="validation-message" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server" 
                    ControlToValidate="txtEmail" ErrorMessage="Invalid email format" 
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*" 
                    CssClass="validation-message" Display="Dynamic" />
            </div>
            
            <div class="form-group">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Create a password" />
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                    ControlToValidate="txtPassword" ErrorMessage="Password is required" 
                    CssClass="validation-message" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revPassword" runat="server" 
                    ControlToValidate="txtPassword" ErrorMessage="Minimum 8 characters with at least 1 number and 1 special character" 
                    ValidationExpression="^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$" 
                    CssClass="validation-message" Display="Dynamic" />
            </div>
            
            <div class="form-group">
                <label for="txtConfirmPassword">Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm your password" />
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                    ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm password" 
                    CssClass="validation-message" Display="Dynamic" />
                <asp:CompareValidator ID="cvPasswords" runat="server" 
                    ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword" 
                    ErrorMessage="Passwords don't match" CssClass="validation-message" Display="Dynamic" />
            </div>
            
            <!-- STEM Interest Selection -->
            <div class="stem-fields">
                <h4>Which STEM fields interest you? (Optional)</h4>
                <div class="checkbox-group">
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkComputerScience" runat="server" />
                        <label for="chkComputerScience">Computer Science</label>
                    </div>
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkEngineering" runat="server" />
                        <label for="chkEngineering">Engineering</label>
                    </div>
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkBiotech" runat="server" />
                        <label for="chkBiotech">Biotechnology</label>
                    </div>
                    <div class="checkbox-item">
                        <asp:CheckBox ID="chkMathematics" runat="server" />
                        <label for="chkMathematics">Mathematics</label>
                    </div>
                </div>
            </div>

            <asp:Button ID="btnRegister" runat="server" Text="Join STEM Community" CssClass="cta-btn" OnClick="btnRegister_Click" />

            <div class="auth-footer">
                <p>Already part of our STEM community? <a href="Login.aspx">Sign in here</a></p>
            </div>
        </div>
    </div>
</asp:Content>