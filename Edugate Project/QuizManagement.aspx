<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="QuizManagement.aspx.cs" Inherits="Edugate_Project.QuizManagement" MasterPageFile="~/Admin.master" %>
<%@ Import Namespace="Edugate_Project.Models" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Quiz Management</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        
        :root{
            --primary-dark:#213A57;
            --primary-orange:#0B6477;
            --accent-teal:#14919B;
            --text-light:#DAD1CB;
            --accent-green:#45DFB1;
            --accent-light-green:#80ED99;
        }

        
        html{ font-size:16px; }
        body{
            background-color:var(--primary-dark);
            color:var(--text-light);
            font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif;
            font-weight:400;
            line-height:1.55;
            margin:0;
            min-height:100vh;
        }

        .text-xs{font-size:.75rem}.text-sm{font-size:.875rem}.text-base{font-size:1rem}
        .text-lg{font-size:1.125rem}.text-xl{font-size:1.25rem}.text-2xl{font-size:1.5rem}
        .text-3xl{font-size:2rem}.text-4xl{font-size:2.5rem}
        .fw-600{font-weight:600}.fw-700{font-weight:700}.fw-800{font-weight:800}

        .dashboard-wrapper{display:flex;min-height:100vh;}

        .sidebar{
            width:280px;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            padding:2rem 1rem;
            box-shadow:0 8px 32px 0 rgba(33,58,87,.25);
            position:fixed; height:100vh; overflow-y:auto;
            border-right:2px solid var(--accent-green);
            z-index:1000;
        }
        .sidebar-header{
            text-align:center; padding-bottom:1.25rem;
            border-bottom:1px solid rgba(255,255,255,.2); margin-bottom:1.25rem;
        }
        .teacher-avatar{
            width:80px;height:80px;border-radius:50%;border:3px solid var(--accent-green);
            margin:0 auto .75rem;background:var(--primary-dark);
            display:flex;align-items:center;justify-content:center;color:var(--accent-green);font-size:2rem;
        }
        .sidebar-header h3{color:#fff;margin:.5rem 0 .25rem;font-weight:700;font-size:1.2rem;}
        .sidebar-header p{color:var(--accent-light-green);margin:0;font-size:.85rem;}

        .sidebar-nav{list-style:none;padding:0;margin:0;}
        .sidebar-nav li{margin-bottom:.5rem;}
        .nav-item{
            display:flex;align-items:center;padding:.75rem 1rem;border-radius:6px;
            text-decoration:none;color:rgba(255,255,255,.9);
            transition:all .2s ease;font-size:1rem;font-weight:600;
        }
        .nav-item:hover,.nav-item.active{background:rgba(69,223,177,.2);color:var(--text-light);}
        .nav-item i{margin-right:.75rem;width:20px;text-align:center;font-size:1.1rem;}


        .main-content{
            flex:1;margin-left:280px;padding:2rem;
            background-color:rgba(33,58,87,.7);min-height:100vh;
            backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal);
        }

        
        .page-container{
            max-width:1200px;margin:0 auto;
            padding:2.5rem 2rem 2rem;
            background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);
            border-radius:24px;border:2px solid var(--accent-green);
            box-shadow:0 8px 32px rgba(33,58,87,.25);
            position:relative;overflow:hidden;
        }
        .page-header{
            text-align:center;margin-bottom:1.25rem;color:var(--text-light);
            font-size:2.5rem;font-weight:800;
        }
        .page-subtitle{
            font-size:1.2rem;text-align:center;color:var(--accent-light-green);
            margin-bottom:2rem;opacity:.95;font-weight:600;
        }

       
        .form-group{margin-bottom:1rem;position:relative;}
        .form-group label{
            display:block;margin-bottom:.4rem;color:var(--accent-light-green);
            font-weight:600;font-size:.95rem;
        }
        .form-control{
            width:100%;padding:.75rem;border-radius:8px;box-sizing:border-box;
            border:1px solid var(--accent-teal);
            background:rgba(33,58,87,.7);color:var(--text-light);
            font-size:1rem;transition:all .2s ease;
        }
        .form-control:focus{outline:none;border-color:var(--accent-green);box-shadow:0 0 0 2px rgba(69,223,177,.3);}

      
        .quiz-info{
            background:rgba(33,58,87,.7);border:1px solid var(--accent-teal);
            border-radius:12px;padding:1rem;margin-bottom:1.25rem;color:var(--text-light);
        }
        .quiz-info strong{color:var(--accent-green);}

        
        .btn{
            display:inline-block; border:none; cursor:pointer; user-select:none;
            padding:.75rem 1.5rem; border-radius:8px; font-weight:700; font-size:1rem;
            transition:transform .2s ease, box-shadow .2s ease, background .2s ease, color .2s ease;
        }
        .btn:hover{transform:translateY(-2px);}
        .btn-primary{background:var(--accent-teal);color:#fff;}
        .btn-primary:hover{box-shadow:0 8px 25px rgba(20,145,155,.35);}
        .btn-success{background:linear-gradient(135deg,var(--accent-green),var(--accent-light-green));color:var(--primary-dark);}
        .btn-success:hover{box-shadow:0 8px 25px rgba(46,204,113,.35);}
        .btn-warning{background:var(--primary-orange);color:#fff;}
        .btn-warning:hover{box-shadow:0 8px 25px rgba(243,156,18,.35);}
        .btn-neutral{background:rgba(33,58,87,.7);color:var(--text-light);border:1px solid var(--accent-teal);}
        .btn-danger{background:#e74c3c;color:#fff;}
        .btn-danger:hover{background:#c0392b;box-shadow:0 8px 25px rgba(231,76,60,.35);}

        .current-questions-section{margin-top:2rem;padding-top:1.5rem;border-top:1px dashed var(--accent-teal);}
        .current-questions-section h3{
            color:var(--accent-green);text-align:center;margin-bottom:1rem;font-size:1.5rem;font-weight:700;
        }
        .question-item{
            background:rgba(33,58,87,.7);border:1px solid var(--accent-teal);
            border-radius:12px;padding:1rem;margin-bottom:1rem; color:var(--text-light);
            box-shadow:0 2px 10px rgba(0,0,0,.1);
        }
        .question-item p{margin:.25rem 0 1rem;font-size:1.05rem;}
        .question-item ul{list-style:none;padding-left:0;margin:0;}
        .question-item li{margin-bottom:.4rem;color:var(--accent-light-green);}
        .correct-answer{font-weight:700;color:var(--accent-green);}
        .delete-btn{float:right;margin-top:-.5rem;}


        .status-message{margin-top:1rem;padding:12px;border-radius:8px;font-weight:600;text-align:center;}
        .status-message.success{background:rgba(212,237,218,.2);color:#d4edda;border:1px solid #c3e6cb;}
        .status-message.error{background:rgba(248,215,218,.2);color:#f8d7da;border:1px solid #f5c6cb;}
        .status-message.info{background:rgba(209,236,241,.2);color:#d1ecf1;border:1px solid #bee5eb;}


        .floating-shape{position:absolute;border-radius:50%;opacity:.14;z-index:0;animation:floatShape 8s ease-in-out infinite alternate;}
        .shape1{width:180px;height:180px;background:var(--accent-green);top:6%;left:4%;}
        .shape2{width:120px;height:120px;background:var(--primary-orange);bottom:10%;left:60%;}
        .shape3{width:90px;height:90px;background:var(--accent-light-green);top:42%;right:6%;}
        @keyframes floatShape{0%{transform:translateY(0) scale(1)}100%{transform:translateY(-30px) scale(1.06)}}


        @media (max-width:992px){
            .sidebar{width:240px;padding:1.5rem .75rem;}
            .main-content{margin-left:240px;padding:1.5rem;}
        }
        @media (max-width:767px){
            .dashboard-wrapper{flex-direction:column;}
            .sidebar{width:100%;height:auto;position:relative;}
            .main-content{margin-left:0;padding:1rem;}
            .page-container{padding:1.5rem;margin-top:1rem;}
            .page-header{font-size:2rem;}
            .page-subtitle{font-size:1.1rem;margin-bottom:1.5rem;}
            .btn{width:100%;margin-bottom:.5rem;}
        }
        @media (max-width:480px){
            .page-header{font-size:1.8rem;}
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="dashboard-wrapper">

        <div class="sidebar">
            <div class="sidebar-header">
                <div class="teacher-avatar"><i class="fas fa-user"></i></div>
                <h3><asp:Label ID="lblSidebarTeacherName" runat="server"></asp:Label></h3>
                <p>Teacher</p>
            </div>

            <ul class="sidebar-nav">
                <li><a href="TeacherDashboard.aspx" class="nav-item"><i class="fas fa-tachometer-alt"></i><span>Dashboard</span></a></li>
                <li><a href="#profile" class="nav-item"><i class="fas fa-user-edit"></i><span>Edit Profile</span></a></li>
                <li><a href="QuizManagement.aspx" class="nav-item active"><i class="fas fa-question-circle"></i><span>Manage Quizzes</span></a></li>
                <li><a href="TeacherFileUpload.aspx" class="nav-item"><i class="fas fa-tasks"></i><span>Student Assessments</span></a></li>
                <li><a href="TeacherSendMessage.aspx" class="nav-item"><i class="fas fa-envelope"></i><span>Messages</span></a></li>
                <li><a href="UploadMarks.aspx" class="nav-item"><i class="fas fa-chart-bar"></i><span>Manage Marks</span></a></li>
                <li>
                     <a href="Default.aspx" class="nav-item"><i class="fas fa-sign-out-alt"></i><span>Logout</span></a>
                </li>
            </ul>
        </div>


        <div class="main-content">
            <div class="page-container">
                <div class="floating-shape shape1"></div>
                <div class="floating-shape shape2"></div>
                <div class="floating-shape shape3"></div>

                <h1 class="page-header">Quiz Management <i class="fas fa-clipboard-list"></i></h1>
                <p class="page-subtitle">Create and manage quizzes aligned to your subject</p>

                <!-- Subject + Title -->
                <asp:Panel ID="SubjectSelectionPanel" runat="server">
                    <asp:Literal ID="litSubjectStatus" runat="server"></asp:Literal>

                    <div class="form-group">
                        <label for="<%= ddlSubjects.ClientID %>">Select Subject</label>
                        <asp:DropDownList ID="ddlSubjects" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>

                    <div class="form-group">
                        <label for="<%= txtQuizTitle.ClientID %>">Quiz Title</label>
                        <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control"
                                     placeholder="e.g., Algebra Basics, Newton's Laws"></asp:TextBox>
                    </div>

                    <asp:Button ID="btnLoadQuizCreation" runat="server" Text="Start New Quiz for Subject"
                        OnClick="btnLoadQuizCreation_Click" CssClass="btn btn-success" />
                </asp:Panel>

                <!-- Quiz Creation -->
                <asp:Panel ID="QuizCreationPanel" runat="server" Visible="false">
                    <div class="quiz-info">
                        <p>
                            Creating Quiz for: <strong><asp:Label ID="lblSelectedSubject" runat="server"></asp:Label></strong><br />
                            Quiz Title: <strong><asp:Label ID="lblSelectedQuizTitle" runat="server"></asp:Label></strong>
                        </p>
                    </div>

                    <!-- Scheduling + Limits -->
                    <div class="form-group">
                        <label for="<%= txtDueDate.ClientID %>">Due Date (optional)</label>
                        <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" placeholder="e.g. 2025-10-31 23:59"></asp:TextBox>
                        <small style="color:var(--accent-light-green)">Leave empty for no deadline.</small>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtMaxAttempts.ClientID %>">Max Attempts (optional)</label>
                        <asp:TextBox ID="txtMaxAttempts" runat="server" CssClass="form-control" placeholder="e.g. 3"></asp:TextBox>
                        <small style="color:var(--accent-light-green)">Blank or 0 = unlimited.</small>
                    </div>

                    <!-- Question -->
                    <div class="form-group">
                        <label for="<%= txtQuestionText.ClientID %>">Question Text</label>
                        <asp:TextBox ID="txtQuestionText" runat="server" TextMode="MultiLine" Rows="3"
                                     CssClass="form-control" placeholder="Enter the question here..."></asp:TextBox>
                    </div>

                    <!-- Options -->
                    <div class="form-group" id="optionsContainer" runat="server">
                        <label>Answer Options</label>

                        <div class="question-item" style="margin-bottom:1rem;">
                            <div class="form-group" style="margin-bottom:.75rem;">
                                <asp:TextBox ID="txtOption1" runat="server" CssClass="form-control" placeholder="Option 1"></asp:TextBox>
                            </div>
                            <asp:RadioButton ID="rbCorrect1" runat="server" GroupName="CorrectOption" Text="Mark as correct" />
                        </div>

                        <div class="question-item" style="margin-bottom:1rem;">
                            <div class="form-group" style="margin-bottom:.75rem;">
                                <asp:TextBox ID="txtOption2" runat="server" CssClass="form-control" placeholder="Option 2"></asp:TextBox>
                            </div>
                            <asp:RadioButton ID="rbCorrect2" runat="server" GroupName="CorrectOption" Text="Mark as correct" />
                        </div>

                        <div class="question-item" style="margin-bottom:1rem;">
                            <div class="form-group" style="margin-bottom:.75rem;">
                                <asp:TextBox ID="txtOption3" runat="server" CssClass="form-control" placeholder="Option 3"></asp:TextBox>
                            </div>
                            <asp:RadioButton ID="rbCorrect3" runat="server" GroupName="CorrectOption" Text="Mark as correct" />
                        </div>

                        <div class="question-item" style="margin-bottom:1rem;">
                            <div class="form-group" style="margin-bottom:.75rem;">
                                <asp:TextBox ID="txtOption4" runat="server" CssClass="form-control" placeholder="Option 4"></asp:TextBox>
                            </div>
                            <asp:RadioButton ID="rbCorrect4" runat="server" GroupName="CorrectOption" Text="Mark as correct" />
                        </div>
                    </div>

                    <!-- Actions -->
                    <asp:Button ID="btnAddQuestion" runat="server" Text="Add Question to Quiz"
                        OnClick="btnAddQuestion_Click" CssClass="btn btn-warning" />
                    <asp:Button ID="btnSaveQuiz" runat="server" Text="Save Quiz"
                        OnClick="btnSaveQuiz_Click" CssClass="btn btn-success" />
                    <asp:Button ID="btnClearForm" runat="server" Text="Clear Question Form"
                        OnClick="btnClearForm_Click" CssClass="btn btn-primary" />
                    <asp:Button ID="btnCancelQuiz" runat="server" Text="Cancel Quiz Creation"
                        OnClick="btnCancelQuiz_Click" CssClass="btn btn-danger delete-btn" />
                </asp:Panel>

                <!-- Status -->
                <asp:Literal ID="litStatusMessage" runat="server"></asp:Literal>

                <!-- Current Questions -->
                <asp:Panel ID="CurrentQuestionsDisplayPanel" runat="server" CssClass="current-questions-section" Visible="false">
                    <h3>Current Questions in This Quiz</h3>
                    <asp:Repeater ID="rptCurrentQuestions" runat="server">
                        <ItemTemplate>
                            <div class="question-item">
                                <asp:Button ID="btnDeleteQuestion" runat="server" Text="Delete"
                                    CommandName="DeleteQuestion" CommandArgument='<%# Container.ItemIndex %>'
                                    OnCommand="btnDeleteQuestion_Command" CssClass="btn btn-danger delete-btn" />
                                <p><strong>Q<%# Container.ItemIndex + 1 %>:</strong> <%# Eval("QuestionText") %></p>
                                <ul>
                                    <asp:Repeater ID="rptOptions" runat="server" DataSource='<%# Eval("Options") %>'>
                                        <ItemTemplate>
                                            <li>
                                                <%# Container.DataItem %>
                                                <asp:Literal ID="litCorrectIndicator" runat="server"
                                                    Visible='<%# Container.DataItem.ToString() == ((Edugate_Project.Models.Question)((System.Web.UI.WebControls.RepeaterItem)Container.Parent.Parent).DataItem).CorrectAnswer %>'>
                                                    <span class="correct-answer"> (Correct)</span>
                                                </asp:Literal>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                    <li><span class="correct-answer">Correct Answer: <%# ((Edugate_Project.Models.Question)Container.DataItem).CorrectAnswer %></span></li>
                                </ul>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </asp:Panel>
            </div>
        </div>
    </div>

    <script>
        // Optional: small ripple effect for buttons
        function addRipple(e) {
            const btn = e.currentTarget;
            const circle = document.createElement('span');
            const d = Math.max(btn.clientWidth, btn.clientHeight);
            const r = d / 2;
            circle.style.width = circle.style.height = `${d}px`;
            circle.style.left = `${e.clientX - btn.getBoundingClientRect().left - r}px`;
            circle.style.top = `${e.clientY - btn.getBoundingClientRect().top - r}px`;
            circle.classList.add('ripple');
            btn.appendChild(circle);
            setTimeout(() => circle.remove(), 600);
        }
        document.addEventListener('DOMContentLoaded', () => {
            const style = document.createElement('style');
            style.textContent = `
                .btn{position:relative;overflow:hidden}
                .ripple{position:absolute;border-radius:50%;transform:scale(0);animation:ripple .6s linear;background:rgba(218,209,203,.5);pointer-events:none;z-index:2}
                @keyframes ripple{to{transform:scale(2.5);opacity:0}}
            `;
            document.head.appendChild(style);
            document.querySelectorAll('.btn').forEach(b => b.addEventListener('click', addRipple));
        });
    </script>
</asp:Content>
