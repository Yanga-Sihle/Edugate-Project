<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Quizzes.aspx.cs" Inherits="Edugate_Project.Quizzes" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - STEM Quizzes</title>
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

        /* General Container and Background */
        .quiz-page-container {
            min-height: 100vh;
            background: linear-gradient(135deg, var(--primary-dark) 60%, var(--accent-teal) 100%);
            padding: 80px 0;
            display: flex;
            align-items: center;
        }

        /* Quiz Card Styling */
        .quiz-container {
            background: rgba(33, 58, 87, 0.7); /* Dark semi-transparent background */
            backdrop-filter: blur(15px);
            padding: 40px;
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border: 2px solid var(--accent-teal);
            animation: fadeInUp 0.8s ease-out forwards;
            min-height: 500px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        .quiz-title {
            text-align: center;
            color: var(--accent-green);
            margin-bottom: 30px;
            font-size: 2.5rem;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .question-section {
            margin-bottom: 30px;
        }

        .question-number {
            font-size: 1.2rem;
            color: var(--accent-light-green);
            margin-bottom: 10px;
        }

        .question-text {
            font-size: 1.8rem;
            color: var(--text-light);
            margin-bottom: 25px;
            line-height: 1.4;
            font-weight: 600;
        }

        /* Answer Options - Updated to match card style */
        .answer-options {
            list-style: none;
            padding: 0;
        }

        .answer-options li {
            margin-bottom: 15px;
        }

        .answer-radio {
            display: none;
        }

        .answer-label {
            display: block;
            background-color: var(--primary-dark);
            padding: 20px 25px;
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            color: var(--text-light);
            border: 2px solid var(--primary-dark);
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .answer-label:hover {
            background-color: #2b4969; /* Slightly lighter dark shade */
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.2);
        }

        .answer-radio:checked + .answer-label {
            background: linear-gradient(135deg, var(--accent-green), var(--accent-light-green));
            border-color: var(--accent-teal);
            color: var(--primary-dark);
            font-weight: 700;
            box-shadow: 0 8px 20px rgba(69, 223, 177, 0.3);
        }

        /* Navigation Buttons */
        .quiz-navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
            gap: 20px;
        }

        .btn-quiz {
            background: linear-gradient(135deg, var(--primary-orange), var(--accent-teal));
            color: var(--text-light);
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            flex-grow: 1;
            text-align: center;
        }

        .btn-quiz:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(11, 100, 119, 0.4);
        }

        .btn-quiz.submit {
            background: linear-gradient(135deg, var(--accent-green), var(--accent-light-green));
        }

        .btn-quiz.submit:hover {
            box-shadow: 0 10px 30px rgba(69, 223, 177, 0.4);
        }

        /* Result Section */
        .result-section {
            text-align: center;
            margin-top: 50px;
        }

        .result-section h2 {
            color: var(--accent-green);
            font-size: 2.8rem;
            font-weight: 800;
            margin-bottom: 20px;
        }

        .feedback-message {
            font-size: 1.3rem;
            color: var(--text-light);
            margin-bottom: 40px;
        }

        .score-display {
            font-size: 3.5rem;
            font-weight: 800;
            color: var(--primary-orange);
            margin-bottom: 30px;
            text-shadow: 2px 2px 5px rgba(0, 0, 0, 0.1);
            animation: pulse 1s ease-in-out infinite alternate;
        }

        .restart-button {
            background: linear-gradient(135deg, var(--primary-orange), var(--accent-teal));
            color: var(--text-light);
            padding: 15px 30px;
            border: none;
            border-radius: 50px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1.1rem;
            text-decoration: none;
            display: inline-block;
        }

        .restart-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(11, 100, 119, 0.4);
        }

        /* Keyframes */
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(50px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes pulse {
            from { transform: scale(1); opacity: 1; }
            to { transform: scale(1.05); opacity: 0.8; }
        }

        /* Responsive adjustments */
        @media (max-width: 600px) {
            .quiz-container {
                padding: 20px;
            }

            .quiz-title {
                font-size: 2rem;
            }

            .question-text {
                font-size: 1.5rem;
            }

            .answer-label {
                padding: 15px 20px;
                font-size: 1rem;
            }

            .quiz-navigation {
                flex-direction: column;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="quiz-page-container">
        <div class="container">
            <div class="quiz-container">
                <h1 class="quiz-title">Test Your STEM Knowledge! </h1>
                <asp:Panel ID="QuizPanel" runat="server" Visible="true">
                    <div class="question-section">
                        <asp:Label ID="lblQuestionNumber" runat="server" CssClass="question-number"></asp:Label>
                        <asp:Label ID="lblQuestionText" runat="server" CssClass="question-text"></asp:Label>
                    </div>

                    <asp:RadioButtonList ID="rblAnswerOptions" runat="server" CssClass="answer-options" RepeatDirection="Vertical" />

                    <div class="quiz-navigation">
                        <asp:Button ID="btnPrevious" runat="server" Text="Previous" OnClick="btnPrevious_Click" CssClass="btn-quiz" Visible="false" />
                        <asp:Button ID="btnNext" runat="server" Text="Next" OnClick="btnNext_Click" CssClass="btn-quiz" />
                        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" OnClick="btnSubmitQuiz_Click" CssClass="btn-quiz submit" Visible="false" />
                    </div>
                </asp:Panel>

                <asp:Panel ID="ResultPanel" runat="server" Visible="false" CssClass="result-section">
                    <h2>Quiz Complete! 🎉</h2>
                    <p class="feedback-message">You did great! Here's your score:</p>
                    <p class="score-display">
                        <asp:Label ID="lblScore" runat="server"></asp:Label>
                    </p>
                    <asp:Button ID="btnRestartQuiz" runat="server" Text="Try Again!" OnClick="btnRestartQuiz_Click" CssClass="restart-button" />
                </asp:Panel>
            </div>
        </div>
    </div>
    
    <script>
        // Custom JavaScript to handle the RadioButtonList styling
        function applyRadioButtonStyling() {
            // Find the RadioButtonList and its inner table
            const rbl = document.getElementById('<%= rblAnswerOptions.ClientID %>');
            if (rbl) {
                const radios = rbl.querySelectorAll('input[type="radio"]');
                radios.forEach(radio => {
                    // Check if the next sibling is a label
                    const label = radio.nextElementSibling;
                    if (label && label.tagName === 'LABEL') {
                        // Apply the custom class to the label for styling
                        label.classList.add('answer-label');
                    }
                });
            }
        }

        // Call the function on initial load and after every postback
        window.addEventListener('load', applyRadioButtonStyling);

        // This is a bit of a hack for ASP.NET postbacks
        const prm = Sys.WebForms.PageRequestManager.getInstance();
        if (prm) {
            prm.add_endRequest(applyRadioButtonStyling);
        }
    </script>
</asp:Content>