<%@ Page Title="Student Registration" Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="StudentRegistration.aspx.cs" Inherits="Edugate_Project.StudentRegistration" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;900&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"/>
    <style>
        /* ====== Palette (matches TeacherRegistration) ====== */
        :root{
            --primary-dark:#213A57;
            --primary-orange:#0B6477;
            --accent-teal:#14919B;
            --text-light:#DAD1CB;
            --accent-green:#45DFB1;
            --accent-light-green:#80ED99;
        }
        *{box-sizing:border-box}
        body{font-family:'Inter',system-ui,Segoe UI,Roboto,Helvetica,Arial,sans-serif;color:var(--text-light)}

        /* Page container inside master */
        .container-page{
            max-width:1200px;
            margin:0 auto;
            padding:30px 20px 70px;
        }

        /* Card look (copied style language from TeacherRegistration) */
        .auth-card{
            background:rgba(33,58,87,.9);
            backdrop-filter:blur(15px);
            padding:2.5rem 3rem;
            border-radius:20px;
            border:1px solid rgba(218,209,203,.1);
            box-shadow:0 15px 50px rgba(20,145,155,.15);
            transition:transform .3s, box-shadow .3s;
        }
        .auth-card:hover{ transform:translateY(-4px); box-shadow:0 20px 60px rgba(20,145,155,.25) }

        .form-title{
            text-align:center;margin:0 0 1.5rem;
            font-size:2rem;font-weight:900;letter-spacing:.2px;
            background:linear-gradient(135deg,var(--accent-green),var(--accent-teal));
            -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
        }

        /* Simple responsive grid (12 cols) */
        .grid{display:grid;gap:14px}
        .grid-12{grid-template-columns:repeat(12,1fr)}
        .col-12{grid-column:span 12}
        .col-6{grid-column:span 6}
        .col-4{grid-column:span 4}
        .col-3{grid-column:span 3}
        @media (max-width:1024px){ .col-3,.col-4{grid-column:span 6} .col-6{grid-column:span 12} }
        @media (max-width:640px){ .col-3,.col-4,.col-6,.col-12{grid-column:span 12} }

        .form-group{display:flex;flex-direction:column;margin-bottom:.8rem}
        .form-group label{font-weight:700;margin-bottom:.45rem;color:var(--accent-light-green);font-size:.95rem}

        .form-control,
        .auth-card select,
        .auth-card textarea{
            width:100%;padding:.9rem 1rem;
            border:2px solid rgba(218,209,203,.2);
            border-radius:10px;font-size:1rem;
            background:rgba(33,58,87,.5); color:var(--text-light);
            transition:border-color .2s, box-shadow .2s, background .2s;
        }
        .form-control:focus,
        .auth-card select:focus,
        .auth-card textarea:focus{
            border-color:var(--accent-teal);
            box-shadow:0 0 0 3px rgba(20,145,155,.2);
            outline:0;background:rgba(33,58,87,.7);
        }
        .validation-message{color:#ff6b6b;font-size:.85rem;margin-top:.35rem}

        /* Subject panel */
        .subject-box{
            border:1px dashed rgba(218,209,203,.25);
            border-radius:10px;padding:12px;background:rgba(33,58,87,.45)
        }
        .subject-checkbox-list{display:flex;flex-wrap:wrap;gap:10px}
        .subject-checkbox-list label{white-space:nowrap}

        /* Submit button */
        .cta{display:flex;justify-content:flex-end;margin-top:10px}
        .cta-btn{
            border:none;border-radius:50px;padding:1rem 1.4rem;font-weight:800;letter-spacing:.3px;
            background:linear-gradient(135deg,var(--accent-teal),var(--accent-green));
            color:var(--primary-dark);cursor:pointer;
            box-shadow:0 10px 30px rgba(20,145,155,.4);
            transition:transform .2s, box-shadow .2s;
        }
        .cta-btn:hover{ transform:translateY(-3px) }

        /* Status literal quick style (optional) */
        .status span{display:block;padding:.6rem .8rem;border-radius:8px;margin-bottom:10px}
        .status .ok{background:rgba(20,145,155,.2);color:var(--accent-green);border:1px solid var(--accent-green)}
        .status .err{background:rgba(255,107,107,.15);color:#ff6b6b;border:1px solid #ff6b6b}
        .status .info{background:rgba(20,145,155,.15);color:var(--accent-teal);border:1px solid var(--accent-teal)}

        /* ===== Success / Error result card (shared) ===== */
       /* ===== Result Card (teal/green theme to match form) ===== */
.result-overlay{
  position:fixed; inset:0;
  display:none; align-items:center; justify-content:center;
  background:rgba(10,18,28,.55);               /* darker overlay */
  backdrop-filter: blur(4px);
  z-index:9999;
}

.result-card{
  width:min(520px,94%);
  background: rgba(33,58,87,.95);              /* same glass card base */
  color: var(--text-light);
  border: 1px solid rgba(128,237,153,.18);     /* soft green edge */
  border-radius: 20px;
  padding: 28px 26px 22px;
  box-shadow: 0 18px 55px rgba(20,145,155,.25);/* teal shadow */
  text-align: center;
  backdrop-filter: blur(10px);
}

.result-icon{
  width:96px; height:96px; margin:0 auto 16px;
  display:grid; place-items:center;
  border-radius:50%;
  border:4px solid currentColor;
  color: var(--accent-green);                  /* green ring & icon */
  background: radial-gradient(transparent, rgba(20,145,155,.10));
}
.result-icon svg{ width:46px; height:46px }

.result-title{
  font-weight:900; letter-spacing:.04em;
  font-size:1.35rem; margin:4px 0 6px;
  background: linear-gradient(135deg, var(--accent-green), var(--accent-teal));
  -webkit-background-clip:text; -webkit-text-fill-color:transparent;
  background-clip:text;
}
.result-sub{
  color: rgba(218,209,203,.92);
  font-size: .98rem; margin-bottom:18px;
}

/* Match the form’s gradient CTA */
.result-actions .btn{
  width:100%;
  border:0; border-radius:14px;
  padding:12px 18px; font-weight:800; letter-spacing:.3px;
  background: linear-gradient(135deg, var(--accent-teal), var(--accent-green));
  color: var(--primary-dark);
  box-shadow: 0 10px 28px rgba(20,145,155,.35);
  cursor:pointer; transition: transform .15s ease, box-shadow .15s ease;
}
.result-actions .btn:hover{ transform: translateY(-2px); box-shadow: 0 12px 34px rgba(20,145,155,.45) }
.result-actions .btn:active{ transform:none }

/* Error variant keeps same card but swaps accent to red */
.result-card.error  .result-icon{ color:#ff6b6b; background: radial-gradient(transparent, rgba(255,107,107,.10)) }
.result-card.error  .result-title{
  background: linear-gradient(135deg, #ff6b6b, #f87171);
  -webkit-background-clip:text; -webkit-text-fill-color:transparent; background-clip:text;
}
.result-card.error  .result-actions .btn{
  background: linear-gradient(135deg, #f87171, #ff6b6b);
  color:#1b263b;
  box-shadow: 0 10px 28px rgba(255,107,107,.35);
}

.result-icon svg path{
  stroke-dasharray: 48;
  stroke-dashoffset: 48;
  animation: drawCheck .55s .15s ease-out forwards;
}
@keyframes drawCheck { to { stroke-dashoffset: 0; } }

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManagerProxy ID="smp" runat="server" />

    <div class="container-page">
        <div class="auth-card">

            <h1 class="form-title">Student Registration</h1>

            <div class="status">
                <asp:Literal ID="lblMessage" runat="server" EnableViewState="false" />
            </div>

            <!-- ========= Student Information (grid) ========= -->
            <div class="grid grid-12">
                <!-- First / Middle / Last -->
                <div class="form-group col-4">
                    <label for="txtFullName">First Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="First name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                        ErrorMessage="First Name is required" CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-4">
                    <label>Middle Name (optional)</label>
                    <input type="text" class="form-control" placeholder="Middle name (optional)" />
                </div>

                <div class="form-group col-4">
                    <label for="txtLastName">Last Name</label>
                    <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control" placeholder="Last name" />
                    <asp:RequiredFieldValidator ID="rfvLastName" runat="server" ControlToValidate="txtLastName"
                        ErrorMessage="Last Name is required" CssClass="validation-message" Display="Dynamic" />
                </div>

                <!-- Email / Gender / Passwords -->
                <div class="form-group col-6">
                    <label for="txtEmail">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required" CssClass="validation-message" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                        ErrorMessage="Invalid email format" CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-3">
                    <label for="ddlGender">Sex</label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                        <asp:ListItem Text="-- Select Gender --" Value="" />
                        <asp:ListItem Text="Male" Value="Male" />
                        <asp:ListItem Text="Female" Value="Female" />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvGender" runat="server" ControlToValidate="ddlGender"
                        ErrorMessage="Gender is required" InitialValue="" CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-3">
                    <label for="txtPassword">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Password" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                        ErrorMessage="Password is required" CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-3">
                    <label for="txtConfirmPassword">Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Confirm password" />
                    <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword"
                        ErrorMessage="Confirm Password is required" CssClass="validation-message" Display="Dynamic" />
                    <asp:CompareValidator ID="cmpPassword" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                        ErrorMessage="Passwords do not match" CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-12">
                    <label for="txtAddress">Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"
                        placeholder="Street, City, State/Province, Country, ZIP" />
                    <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress"
                        ErrorMessage="Address is required" CssClass="validation-message" Display="Dynamic" />
                </div>
            </div>

            <!-- ========= School Information ========= -->
            <div style="height:10px"></div>
            <h3 class="form-title" style="font-size:1.2rem;margin-top:.6rem;margin-bottom:1rem">School Information</h3>

            <div class="grid grid-12">
                <div class="form-group col-4">
                    <label for="txtSchoolCode">School Code</label>
                    <asp:TextBox ID="txtSchoolCode" runat="server" CssClass="form-control"
                        placeholder="Numeric code" AutoPostBack="true" OnTextChanged="txtSchoolCode_TextChanged" />
                    <asp:RequiredFieldValidator ID="rfvSchoolCode" runat="server" ControlToValidate="txtSchoolCode"
                        ErrorMessage="School Code is required" CssClass="validation-message" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revSchoolCode" runat="server" ControlToValidate="txtSchoolCode"
                        ValidationExpression="^\d+$" ErrorMessage="School Code must be a number."
                        CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-4">
                    <label for="ddlGradeLevel">Grade Level</label>
                    <asp:DropDownList ID="ddlGradeLevel" runat="server" CssClass="form-control"
                        AutoPostBack="true" OnSelectedIndexChanged="ddlGradeLevel_SelectedIndexChanged">
                        <asp:ListItem Text="-- Select Grade Level --" Value="" />
                        <asp:ListItem Text="Grade 10" Value="10" />
                        <asp:ListItem Text="Grade 11" Value="11" />
                        <asp:ListItem Text="Grade 12" Value="12" />
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvGradeLevel" runat="server" ControlToValidate="ddlGradeLevel"
                        ErrorMessage="Grade Level is required" InitialValue=""
                        CssClass="validation-message" Display="Dynamic" />
                </div>

                <div class="form-group col-12">
                    <asp:Panel ID="pnlSubjectSelection" runat="server" CssClass="subject-box" Visible="false">
                        <label>Select Subjects (Optional)</label>
                        <asp:CheckBoxList ID="cblSubjects" runat="server" CssClass="subject-checkbox-list"
                            RepeatColumns="4" RepeatDirection="Horizontal" />
                    </asp:Panel>
                </div>
            </div>

            <div class="cta">
                <asp:Button ID="btnRegister" runat="server" Text="Register Account"
                    CssClass="cta-btn" OnClick="btnRegister_Click" />
            </div>
        </div>
    </div>

    <!-- ===== Result Card (success/error) ===== -->
    <div id="resultOverlay" class="result-overlay" aria-hidden="true">
        <div id="resultCard" class="result-card" role="dialog" aria-live="assertive" aria-modal="true">
            <div class="result-icon" id="resultIcon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M20 6L9 17l-5-5"/>
                </svg>
            </div>
            <div class="result-title" id="resultTitle">SUCCESS</div>
            <div class="result-sub" id="resultSub">Registration successful!</div>
            <div class="result-actions">
                <button type="button" id="resultBtn" class="btn">CONTINUE</button>
            </div>
        </div>
    </div>

    <!-- tiny placeholder; used by code-behind fallback -->
    <div id="successModal" style="display:none"></div>

    <script>
        // -------- Result card helpers (success/error) ----------
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

            titleEl.textContent = cfg.title; subEl.textContent = cfg.message;
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

        // Called by code-behind after successful registration
        function showSuccessAndRedirect() {
            showSuccessCard({
                title: 'SUCCESS',
                message: 'You have successfully registered.',
                buttonText: 'CONTINUE',
                redirectUrl: 'Default.aspx',
                autoCloseMs: 2200
            });
        }
    </script>
</asp:Content>
