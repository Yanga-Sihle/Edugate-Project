<%@ Page Title="Login" Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Edugate_Project.Login" MasterPageFile="~/Site1.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <%-- This content placeholder is typically for <head> elements like title, meta, and styles --%>
    <style>
        /* --- Styles for the form card --- */
        .auth-container {
            /* padding adjusted to work with main-content padding-top from Master Page */
            padding: 60px 0; /* Adjusted for vertical centering within main-content */
            display: flex;
            justify-content: center;
            align-items: center;
            /* min-height and background are typically handled by the Master Page body */
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
            box-sizing: border-box;
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

        /* Responsive adjustments */
        @media (max-width: 768px) {
            .auth-container {
                padding: 100px 20px 40px;
            }

            .auth-card {
                padding: 2rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <%-- This content placeholder is typically for the main body content --%>
    <%-- Removed ScriptManager from here as it should be in the Master Page --%>

    <div class="auth-container">
        <div class="auth-card">
            <h2>Edugate Student Login</h2>
            <asp:Literal ID="lblMessage" runat="server" EnableViewState="false" />

            <div class="form-group">
                <label for="txtEmail">Email (Username)</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Your Email Address" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail" ErrorMessage="Email is required."
                    CssClass="validation-message" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                    ErrorMessage="Please enter a valid email address."
                    CssClass="validation-message" Display="Dynamic" />
            </div>

            <div class="form-group">
                <label for="txtPassword">Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Enter your password" />
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword" ErrorMessage="Password is required."
                    CssClass="validation-message" Display="Dynamic" />
            </div>

            <asp:Button ID="btnLOGIN" runat="server" Text="Login" CssClass="cta-btn" OnClick="btnLOGIN_Click" />

            <div class="auth-footer">
                <p>New to our STEM community? <a href="StudentRegistration.aspx">Register now</a></p>
            </div>
        </div>
    </div>

    <%-- JavaScript for interactive effects --%>
    <script>
        // Smooth scrolling for navigation links (if any on this page)
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

        // Interactive button effects
        document.querySelectorAll('.cta-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                // Only prevent default if it's not an ASP.NET postback button
                if (!btn.hasAttribute('type') || btn.getAttribute('type') !== 'submit') {
                    e.preventDefault();
                }

                // Create ripple effect
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

        const style = document.createElement('style');
        style.textContent = `
            @keyframes ripple {
                to {
                    transform: scale(2);
                    opacity: 0;
                }
            }
        `;
        document.head.appendChild(style);
    </script>
</asp:Content>