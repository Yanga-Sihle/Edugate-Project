<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TakeQuiz.aspx.cs" Inherits="Edugate_Project.TakeQuiz" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Take Quiz</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <style>
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
            --card-bg: rgba(33, 58, 87, 0.7);
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, var(--primary-dark) 60%, var(--accent-teal) 100%);
            min-height: 100vh;
            color: var(--text-light);
        }
        
        /* General styles for quiz container */
        .quiz-container {
            background: var(--card-bg);
            backdrop-filter: blur(15px);
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            margin-top: 50px;
            max-width: 800px;
            margin-left: auto;
            margin-right: auto;
            text-align: center;
            border: 2px solid var(--accent-teal);
        }

        .quiz-header {
            color: var(--accent-green);
            margin-bottom: 30px;
            font-size: 1.5rem;
            font-weight: 800;
        }

        /* Form group styling for dropdowns */
        .form-group {
            margin-bottom: 25px;
            text-align: left;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--accent-light-green);
            font-size: 1.1rem;
        }

        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            font-size: 1rem;
            color: var(--text-light);
            background: rgba(33, 58, 87, 0.5);
            transition: all 0.3s ease;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
            background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3e%3cpath fill='none' stroke='%2380ED99' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M2 5l6 6 6-6'/%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 0.75rem center;
            background-size: 16px 12px;
        }

        .form-control:focus {
            border-color: var(--accent-teal);
            outline: none;
            box-shadow: 0 0 0 3px rgba(20, 145, 155, 0.2);
        }

        /* Quiz List for subject selection */
        .quiz-list {
            list-style: none;
            padding: 0;
            margin-top: 20px;
        }

        .quiz-item {
            background: rgba(33, 58, 87, 0.5);
            padding: 15px 20px;
            margin-bottom: 12px;
            border-radius: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 1.1rem;
            color: var(--text-light);
            box-shadow: 0 1px 5px rgba(0,0,0,0.05);
            border: 1px solid rgba(20, 145, 155, 0.3);
        }

        .quiz-item strong {
            color: var(--accent-green);
            margin-right: 10px;
        }

        .quiz-item span {
            font-size: 0.95rem;
            color: var(--accent-light-green);
            flex-grow: 1;
            text-align: left;
        }

        /* Quiz Question Area */
        .quiz-question-area {
            background: rgba(33, 58, 87, 0.5);
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.05);
            text-align: left;
            border: 1px solid rgba(20, 145, 155, 0.3);
        }

        .question-number {
            display: block;
            font-size: 1.2rem;
            font-weight: 600;
            color: var(--accent-green);
            margin-bottom: 15px;
            text-align: center;
        }

        .question-text {
            font-size: 1.5rem;
            color: var(--text-light);
            margin-bottom: 25px;
            line-height: 1.6;
        }

        /* Radio button list styling */
        .answer-options {
            list-style: none;
            padding: 0;
            margin-top: 20px;
        }

        .answer-options label {
            display: block;
            background: rgba(33, 58, 87, 0.5);
            padding: 15px 20px;
            margin-bottom: 10px;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.2s ease;
            font-size: 1.1rem;
            color: var(--text-light);
            border: 1px solid rgba(20, 145, 155, 0.3);
            display: flex;
            align-items: center;
        }

        .answer-options input[type="radio"] {
            display: none;
        }

        .answer-options label::before {
            content: '';
            display: inline-block;
            width: 20px;
            height: 20px;
            border: 2px solid var(--accent-teal);
            border-radius: 50%;
            margin-right: 15px;
            vertical-align: middle;
            transition: background-color 0.2s ease, border-color 0.2s ease;
            flex-shrink: 0;
        }

        .answer-options input[type="radio"]:checked + label {
            background: rgba(20, 145, 155, 0.2);
            border-color: var(--accent-teal);
            box-shadow: 0 0 0 3px rgba(20, 145, 155, 0.2);
        }

        .answer-options input[type="radio"]:checked + label::before {
            background-color: var(--accent-teal);
            border-color: var(--accent-teal);
            box-shadow: inset 0 0 0 4px rgba(33, 58, 87, 0.5);
        }

        .answer-options label:hover {
            background: rgba(20, 145, 155, 0.3);
            border-color: var(--accent-teal);
        }

        /* Navigation buttons */
        .quiz-navigation {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
        }

        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1rem;
            position: relative;
            overflow: hidden;
        }

        .btn-primary {
            background: var(--accent-teal);
            color: var(--text-light);
        }

        .btn-primary:hover {
            background: var(--primary-orange);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(20, 145, 155, 0.4);
        }

        .btn-secondary {
            background: rgba(149, 165, 166, 0.5);
            color: white;
        }

        .btn-secondary:hover {
            background: rgba(127, 140, 141, 0.7);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(149, 165, 166, 0.4);
        }

        .btn-success {
            background: var(--accent-green);
            color: var(--primary-dark);
        }

        .btn-success:hover {
            background: var(--accent-light-green);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(69, 223, 177, 0.4);
        }

        .btn-info {
            background: var(--accent-teal);
            color: var(--text-light);
        }

        .btn-info:hover {
            background: var(--primary-orange);
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(20, 145, 155, 0.4);
        }

        /* Quiz Results */
        .quiz-results {
            text-align: center;
            margin-top: 30px;
            padding: 30px;
            background: rgba(33, 58, 87, 0.5);
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border: 1px solid rgba(20, 145, 155, 0.3);
        }

        .quiz-results h3 {
            color: var(--accent-green);
            font-size: 2rem;
            margin-bottom: 20px;
        }

        .quiz-results p {
            font-size: 1.5rem;
            color: var(--text-light);
            margin-bottom: 30px;
            font-weight: 600;
        }

        /* Status Message Styling */
        .status-message {
            margin-top: 20px;
            padding: 15px;
            border-radius: 8px;
            font-weight: 600;
            text-align: center;
        }

        .status-message.success {
            background-color: rgba(69, 223, 177, 0.2);
            color: var(--accent-green);
            border: 1px solid var(--accent-green);
        }

        .status-message.error {
            background-color: rgba(248, 215, 218, 0.2);
            color: #ff6b6b;
            border: 1px solid #ff6b6b;
        }

        .status-message.info {
            background-color: rgba(20, 145, 155, 0.2);
            color: var(--accent-teal);
            border: 1px solid var(--accent-teal);
        }

        /* Floating Shapes */
        .floating-shape {
            position: fixed;
            border-radius: 50%;
            opacity: 0.18;
            z-index: -1;
            animation: floatShape 8s ease-in-out infinite alternate;
        }
        .shape1 { width: 180px; height: 180px; background: var(--accent-green); top: 10%; left: 5%; animation-delay: 0s; }
        .shape2 { width: 120px; height: 120px; background: var(--primary-orange); top: 70%; left: 60%; animation-delay: 2s; }
        .shape3 { width: 90px; height: 90px; background: var(--accent-light-green); top: 40%; left: 80%; animation-delay: 4s; }

        /* Animations */
        @keyframes floatShape {
            0% { transform: translateY(0) scale(1); }
            100% { transform: translateY(-30px) scale(1.1); }
        }

        /* Responsive adjustments */
        @media (max-width: 767px) {
            .quiz-container {
                padding: 20px;
                margin-top: 30px;
            }

            .quiz-header {
                font-size: 2rem;
            }

            .quiz-question-area {
                padding: 20px;
            }

            .question-text {
                font-size: 1.2rem;
            }

            .answer-options label {
                padding: 12px 15px;
                font-size: 1rem;
            }

            .btn {
                padding: 10px 20px;
                font-size: 0.9rem;
            }

            .quiz-navigation {
                flex-direction: column;
                gap: 15px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="floating-shape shape1"></div>
    <div class="floating-shape shape2"></div>
    <div class="floating-shape shape3"></div>
    
    <div class="container">
        <div class="quiz-container">
            <h1 class="quiz-header">Take Quiz 🧠</h1>

            <%-- Panel for Subject and Quiz Selection --%>
            <asp:Panel ID="pnlSubjectAndQuizSelection" runat="server">
                <h3 style="color: var(--accent-light-green);">Select a Subject and Quiz</h3>
                <div class="form-group">
                    <label for="<%= ddlSubjects.ClientID %>">Choose Subject:</label>
                    <asp:DropDownList ID="ddlSubjects" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlSubjects_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <%-- Panel to display available quizzes for the selected subject --%>
                <asp:Panel ID="pnlAvailableQuizzes" runat="server" Visible="false">
                    <h4 style="color: var(--accent-light-green);">Available Quizzes for <asp:Literal ID="litSelectedSubjectName" runat="server"></asp:Literal></h4>
                    <asp:Repeater ID="rptAvailableQuizzes" runat="server" OnItemCommand="rptAvailableQuizzes_ItemCommand">
                        <HeaderTemplate>
                            <ul class="quiz-list">
                        </HeaderTemplate>
                       <ItemTemplate>
                           <asp:HiddenField ID="hidIsLocked" runat="server" Value='<%# (bool)Eval("IsLocked") ? "1" : "0" %>' />

    <li class="quiz-item">
        <div style="display:flex; flex-direction:column; flex:1;">
            <div>
                <strong><%# Eval("Title") %></strong>
                <span>(<%# Eval("QuestionCount") %> Questions)</span>
            </div>
            <div style="font-size:0.95rem; margin-top:6px;">
                <%# Eval("DueDateDisplay") %> &nbsp;|&nbsp;
                <%# Eval("AttemptsDisplay") %>
                <%# Eval("LockReason") != null && Eval("LockReason").ToString() != "" 
                        ? " &nbsp;|&nbsp; <span style='color:#E63946;font-weight:700;'>Locked: " + Eval("LockReason") + "</span>" 
                        : "" %>
            </div>
        </div>

        <asp:LinkButton ID="btnStartSpecificQuiz" runat="server"
            CommandName="StartQuiz" CommandArgument='<%# Eval("QuizID") %>'
            CssClass="btn btn-sm btn-primary"
            Enabled='<%# !(bool)Eval("IsLocked") %>'>
            <%# (bool)Eval("IsLocked") ? "Locked" : "Start Quiz" %>
        </asp:LinkButton>
    </li>
</ItemTemplate>

                        <FooterTemplate>
                            </ul>
                        </FooterTemplate>
                    </asp:Repeater>
                    <asp:Literal ID="litNoQuizzesForSubject" runat="server" Visible="false" Text="<p style='color: var(--accent-light-green);'>No quizzes available for this subject.</p>"></asp:Literal>
                </asp:Panel>
            </asp:Panel>

            <%-- Panel for Taking the Quiz (single question display) --%>
            <asp:Panel ID="QuizPanel" runat="server" Visible="false">
                <div class="quiz-question-area">
                    <%-- Removed CssClass from Literal. If styling is needed, wrap in a span or use asp:Label. --%>
                    <span class="question-number"><asp:Literal ID="lblQuestionNumber" runat="server"></asp:Literal></span>
                    <p class="question-text"><asp:Literal ID="lblQuestionText" runat="server"></asp:Literal></p>
                    <asp:RadioButtonList ID="rblAnswerOptions" runat="server" CssClass="answer-options"></asp:RadioButtonList>
                </div>
                <div class="quiz-navigation">
                    <asp:Button ID="btnPrevious" runat="server" Text="Previous" OnClick="btnPrevious_Click" CssClass="btn btn-secondary" Visible="false" />
                    <asp:Button ID="btnNext" runat="server" Text="Next" OnClick="btnNext_Click" CssClass="btn btn-primary" Visible="false" />
                    <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" OnClick="btnSubmitQuiz_Click" CssClass="btn btn-success" Visible="false" />
                </div>
            </asp:Panel>

            <%-- Panel for Quiz Results --%>
            <asp:Panel ID="ResultPanel" runat="server" Visible="false">
                <div class="quiz-results">
                    <h3>Quiz Completed!</h3>
                    <p>Your Score: <asp:Literal ID="lblScore" runat="server"></asp:Literal></p>
                    <%-- Added litResultDetails for a more descriptive message --%>
                    <asp:Literal ID="litResultDetails" runat="server"></asp:Literal>
                    <asp:Button ID="btnRestartQuiz" runat="server" Text="Try Another Quiz" OnClick="btnRestartQuiz_Click" CssClass="btn btn-info" />
                </div>
            </asp:Panel>

            <%-- Status Message Literal --%>
            <asp:Literal ID="litStatusMessage" runat="server"></asp:Literal>
        </div>
    </div>

    <script>
        // Custom JavaScript function to apply styling to RadioButtonList items
        // This function is called on Page_Load from the code-behind to ensure styling persists after postbacks.
        function applyRadioButtonStyling() {
            const radioButtons = document.querySelectorAll('.answer-options input[type="radio"]');
            radioButtons.forEach(radio => {
                const label = radio.nextElementSibling; // Get the label associated with the radio button
                if (label && label.tagName === 'LABEL') {
                    // Check if the label already has the class to prevent duplicates
                    if (!label.classList.contains('answer-label')) {
                        label.classList.add('answer-label'); // Add the custom class for styling
                    }
                }
            });
        }

        // Call the styling function when the DOM is initially loaded
        document.addEventListener('DOMContentLoaded', applyRadioButtonStyling);

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