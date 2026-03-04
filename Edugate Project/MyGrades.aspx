<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyGrades.aspx.cs" Inherits="Edugate_Project.MyGrades" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - My Marks</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        :root { --primary-dark:#213A57; --primary-orange:#0B6477; --accent-teal:#14919B; --text-light:#DAD1CB; --accent-green:#45DFB1; --accent-light-green:#80ED99; }
        .student-dashboard { display:flex; min-height:100vh; background-color:var(--primary-dark); color:var(--text-light); font-family:'Inter','Segoe UI',Tahoma,Geneva,Verdana,sans-serif; }
        .student-sidebar { width:280px; background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%); color:white; padding:2rem 1rem; position:fixed; height:100vh; box-shadow:0 8px 32px 0 rgba(33,58,87,0.25); border-right:2px solid var(--accent-green); z-index:1000; animation:fadeInLeft 0.8s ease-out forwards; }
        @keyframes fadeInLeft { from{opacity:0; transform:translateX(-20px);} to{opacity:1; transform:translateX(0);} }
        .student-profile { text-align:center; padding:1rem 0 2rem; border-bottom:1px solid rgba(255,255,255,0.1); margin-bottom:1.5rem; }
        .student-avatar { width:80px; height:80px; border-radius:50%; object-fit:cover; border:3px solid var(--accent-green); margin-bottom:1rem; }
        .student-name { font-size:1.2rem; margin:0.5rem 0; font-weight:700; color:var(--text-light); }
        .student-status { font-size:0.85rem; color:var(--accent-light-green); margin:0; }
        .student-menu { list-style:none; padding:0; margin:0; }
        .student-menu li { margin-bottom:0.5rem; }
        .student-menu a { display:flex; align-items:center; color:rgba(255,255,255,0.8); padding:0.75rem 1rem; border-radius:6px; text-decoration:none; transition:all 0.2s; }
        .student-menu a:hover, .student-menu a.active { background-color:rgba(69,223,177,0.2); color:var(--text-light); }
        .student-menu a i { margin-right:0.75rem; width:20px; text-align:center; }
        .student-content { flex:1; margin-left:280px; padding:2rem; background-color:rgba(33,58,87,0.7); min-height:100vh; backdrop-filter:blur(5px); border-left:1px solid var(--accent-teal); }
        .marks-container { max-width:1200px; margin:0 auto; padding:2.5rem 2rem 2rem; background:linear-gradient(135deg,var(--primary-orange) 60%, var(--accent-teal) 100%); border-radius:24px; box-shadow:0 8px 32px 0 rgba(33,58,87,0.25); border:2px solid var(--accent-green); animation:fadeInUp 0.8s ease-out forwards; }
        @keyframes fadeInUp { from{opacity:0; transform:translateY(20px);} to{opacity:1; transform:translateY(0);} }
        .marks-header { text-align:center; margin-bottom:30px; color:var(--text-light); }
        .marks-header h1 { color:var(--text-light); font-weight:800; }
        .marks-header p { color:var(--accent-light-green); opacity:0.95; }
        .filter-label { font-weight:600; color:var(--text-light); }
        .filter-control { padding:8px 12px; border-radius:5px; border:1px solid var(--accent-green); background-color:var(--primary-dark); color:var(--text-light); font-family:inherit; }
        .btn-action { background-color:var(--accent-green); color:var(--primary-dark); border:none; padding:8px 20px; border-radius:25px; cursor:pointer; transition:all 0.3s ease; font-weight:700; margin:5px; }
        .btn-action:hover { background-color:var(--primary-dark); color:var(--text-light); }
        .marks-tabs { display:flex; border-bottom:1px solid var(--accent-green); margin-bottom:20px; }
        .tab-btn { padding:10px 20px; background:none; border:none; border-bottom:3px solid transparent; cursor:pointer; font-weight:600; color:var(--text-light); transition:all 0.3s; }
        .tab-btn.active { color:var(--accent-green); border-bottom-color:var(--accent-green); }
        .tab-content { display:none; }
        .tab-content.active { display:block; }
        .marks-table { width:100%; border-collapse:collapse; margin-bottom:30px; color:var(--text-light); }
        .marks-table th { background-color:var(--primary-dark); color:var(--text-light); padding:12px; text-align:left; }
        .marks-table td { padding:12px; border-bottom:1px solid var(--primary-dark); }
        .marks-table tr:nth-child(even) { background-color:var(--primary-dark); opacity:0.8; }
        .marks-table tr:hover { background-color:rgba(69,223,177,0.2); }
        .grade-pass { color:#45DFB1; font-weight:600; }
        .grade-fail { color:#E63946; font-weight:600; }
        .grade-average { color:#FFC04D; font-weight:600; }
        .grade-A { color:#45DFB1; font-weight:700; }
        .grade-B { color:#80ED99; font-weight:600; }
        .grade-C { color:#FFC04D; font-weight:600; }
        .grade-D { color:#FF9F4D; font-weight:600; }
        .grade-F { color:#E63946; font-weight:600; }
        .marks-summary { display:flex; flex-direction:row; flex-wrap:wrap; gap:20px; margin-bottom:30px; justify-content:space-between; }
        .summary-card { background:linear-gradient(135deg, rgba(11,100,119,0.7) 60%, rgba(20,145,155,0.7) 100%); border-radius:8px; padding:20px; box-shadow:0 2px 10px rgba(0,0,0,0.05); border-left:4px solid var(--accent-green); color:var(--text-light); flex:1; min-width:200px; }
        .summary-card h3 { margin-top:0; color:var(--accent-green); font-size:1.1rem; }
        .summary-value { font-size:1.8rem; font-weight:700; color:var(--text-light); margin:10px 0; }
        .summary-description { color:var(--accent-light-green); font-size:0.9rem; }
        .no-marks { text-align:center; padding:40px; color:var(--text-light); font-size:1.1rem; }
        .view-link a { color:var(--accent-light-green); text-decoration:none; }
        .view-link a:hover { text-decoration:underline; }
        .chart-container { margin-top:30px; background-color:var(--primary-dark); padding:20px; border-radius:8px; box-shadow:inset 0 0 10px rgba(0,0,0,0.05); border:1px solid var(--accent-teal); }
        .marks-filter { display:flex; gap:15px; margin-bottom:20px; flex-wrap:wrap; }
        .filter-group { display:flex; flex-direction:column; gap:5px; }
        @media (max-width:992px){ .student-sidebar{width:240px; padding:1.5rem 0.75rem;} .student-content{margin-left:240px; padding:1.5rem;} }
        @media (max-width:1024px){ .marks-summary{gap:15px;} .summary-card{min-width:180px;} }
        @media (max-width:767px){
            .student-sidebar{transform:translateX(-100%); width:280px;} .student-sidebar.active{transform:translateX(0);}
            .student-content{margin-left:0; padding:1rem;} .marks-container{padding:20px; margin-top:20px;}
            .marks-summary{flex-direction:column;} .marks-filter{flex-direction:column;} .filter-group{flex-direction:column; align-items:flex-start;}
            .marks-table{font-size:0.9rem;} .marks-table th,.marks-table td{padding:8px;} .summary-card{min-width:auto;}
            .marks-tabs{flex-wrap:wrap;} .tab-btn{flex:1; text-align:center;}
        }
        @media (max-width:576px){ .student-menu a{padding:0.5rem; font-size:0.9rem;} }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="student-dashboard">
        <div class="student-sidebar">
            <div class="student-profile">
                <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
                <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server"></asp:Literal></h3>
                <p class="student-status">Active Student</p>
            </div>
           <ul class="student-menu">
    <li><a href="#" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>

    <!-- Premium-gated actions -->
    <li>
        <asp:LinkButton ID="lnkUploadReport" runat="server"
            CssClass="student-menu-link"
            OnClick="RestrictedNav_Click"
            CommandArgument="StudentMark.aspx">
            <i class="fas fa-marker"></i> Upload School Report
        </asp:LinkButton>
    </li>
    <li>
        <asp:LinkButton ID="lnkScholarships" runat="server"
            CssClass="student-menu-link"
            OnClick="RestrictedNav_Click"
            CommandArgument="Scholarships.aspx">
            <i class="fas fa-money-check-alt"></i> Scholarships
        </asp:LinkButton>
    </li>
    <li>
        <asp:LinkButton ID="lnkCareer" runat="server"
            CssClass="student-menu-link"
            OnClick="RestrictedNav_Click"
            CommandArgument="CareerGuidance.aspx">
            <i class="fas fa-compass"></i> Career Guidance
        </asp:LinkButton>
    </li>
    <li>
        <asp:LinkButton ID="lnkMaterials" runat="server"
            CssClass="student-menu-link"
            OnClick="RestrictedNav_Click"
            CommandArgument="StudentMaterials.aspx">
            <i class="fas fa-book-open"></i> Study Materials
        </asp:LinkButton>
    </li>

    <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
</ul>

        </div>
        
        <div class="student-content">
            <div class="marks-container">
                <div class="marks-header">
                    <h1>My Academic Progress</h1>
                    <p>View your marks for assignments and quizzes</p>
                    <div>
                        <asp:Button ID="btnExport" runat="server" Text="Export All to CSV" CssClass="btn-action" OnClick="ExportMarksToCsv" />
                        <asp:Button ID="btnExportQuiz" runat="server" Text="Export Quiz Results" CssClass="btn-action" OnClick="ExportQuizResultsToCsv" />
                    </div>
                </div>

                <div class="marks-summary">
                    <div class="summary-card">
                        <h3>Overall Average</h3>
                        <div class="summary-value"><asp:Literal ID="litOverallAverage" runat="server" Text="--" />%</div>
                        <div class="summary-description">Across assignments and quizzes</div>
                    </div>
                    <div class="summary-card">
                        <h3>Quizzes Average</h3>
                        <div class="summary-value"><asp:Literal ID="litQuizAverage2" runat="server" Text="--" />%</div>
                        <div class="summary-description">Based on <asp:Literal ID="litQuizCount2" runat="server" Text="0" /> quizzes</div>
                    </div>
                    <div class="summary-card">
                        <h3>Assignments Average</h3>
                        <div class="summary-value"><asp:Literal ID="litAssignmentAverage" runat="server" Text="--" />%</div>
                        <div class="summary-description">Based on <asp:Literal ID="litAssignmentCount" runat="server" Text="0" /> assignments</div>
                    </div>
                </div>

                <div class="chart-container">
                    <h3>Performance Trends</h3>
                    <canvas id="marksChart"></canvas>
                </div>

                <div class="marks-filter">
                    <div class="filter-group">
                        <span class="filter-label">Subject:</span>
                        <asp:DropDownList ID="ddlSubjects" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterMarks">
                            <asp:ListItem Value="all" Text="All Subjects" Selected="True"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="filter-group">
                        <span class="filter-label">Assessment Type:</span>
                        <asp:DropDownList ID="ddlAssessmentType" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterMarks">
                            <asp:ListItem Value="all" Text="All Types" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="quiz" Text="Quizzes"></asp:ListItem>
                            <asp:ListItem Value="assignment" Text="Assignments"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="filter-group">
                        <span class="filter-label">Time Period:</span>
                        <asp:DropDownList ID="ddlTimePeriod" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterMarks">
                            <asp:ListItem Value="all" Text="All Time" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="current" Text="Current Term"></asp:ListItem>
                            <asp:ListItem Value="last" Text="Last Term"></asp:ListItem>
                            <asp:ListItem Value="month" Text="Last 30 Days"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <div class="marks-tabs">
                    <asp:Button ID="btnTabAll" runat="server" Text="All Marks" CssClass="tab-btn active" OnClick="ChangeTab" CommandArgument="all" />
                    <asp:Button ID="btnTabQuizzes" runat="server" Text="Quizzes" CssClass="tab-btn" OnClick="ChangeTab" CommandArgument="quiz" />
                    <asp:Button ID="btnTabAssignments" runat="server" Text="Assignments" CssClass="tab-btn" OnClick="ChangeTab" CommandArgument="assignment" />
                </div>

                <div class="tab-content active" id="tabAll" runat="server">
                    <asp:GridView ID="gvAllMarks" runat="server" AutoGenerateColumns="False" CssClass="marks-table"
                        EmptyDataText="No marks found for the selected criteria" ShowHeaderWhenEmpty="True">
                        <Columns>
                            <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
                            <asp:BoundField DataField="AssessmentType" HeaderText="Type" />
                            <asp:BoundField DataField="Title" HeaderText="Assessment" />
                            <asp:BoundField DataField="DateSubmitted" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="Score" HeaderText="Score" DataFormatString="{0}%" />
                            <asp:BoundField DataField="Grade" HeaderText="Grade" />
                            <asp:BoundField DataField="Feedback" HeaderText="Feedback" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="tab-content" id="tabQuizzes" runat="server">
                    <asp:GridView ID="gvQuizzes" runat="server" AutoGenerateColumns="False" CssClass="marks-table"
                        EmptyDataText="No quiz marks found" ShowHeaderWhenEmpty="True">
                        <Columns>
                            <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
                            <asp:BoundField DataField="Title" HeaderText="Quiz" />
                            <asp:BoundField DataField="CompletionDate" HeaderText="Completed On" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="Score" HeaderText="Score" DataFormatString="{0}%" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class='<%# Eval("Status").ToString() == "Pass" ? "grade-pass" : "grade-fail" %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Details">
                                <ItemTemplate>
                                    <asp:HyperLink ID="hlQuizDetails" runat="server" Text="View Details" 
                                        NavigateUrl='<%# "QuizDetails.aspx?id=" + Eval("QuizId") %>' 
                                        CssClass="view-link" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="tab-content" id="tabAssignments" runat="server">
                    <asp:GridView ID="gvAssignments" runat="server" AutoGenerateColumns="False" CssClass="marks-table"
                        EmptyDataText="No assignment marks found" ShowHeaderWhenEmpty="True">
                        <Columns>
                            <asp:BoundField DataField="SubjectName" HeaderText="Subject" />
                            <asp:BoundField DataField="Title" HeaderText="Assignment" />
                            <asp:BoundField DataField="DateSubmitted" HeaderText="Submitted" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="DateGraded" HeaderText="Graded" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="Score" HeaderText="Score" DataFormatString="{0}%" />
                            <asp:TemplateField HeaderText="Grade">
                                <ItemTemplate>
                                    <span class='<%# GetGradeCssClass(Convert.ToInt32(Eval("Score"))) %>'>
                                        <%# CalculateGrade(Convert.ToInt32(Eval("Score"))) %>
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="Feedback" HeaderText="Feedback" />
                            <asp:HyperLinkField DataNavigateUrlFields="AssessmentId"
                                DataNavigateUrlFormatString="AssignmentDetails.aspx?id={0}"
                                Text="View Details" HeaderText="" ItemStyle-CssClass="view-link" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const tabButtons = document.querySelectorAll('.marks-tabs .tab-btn');
            const tabContents = document.querySelectorAll('.marks-container .tab-content');

            tabButtons.forEach(button => {
                button.addEventListener('click', function () {
                    const tabName = this.getAttribute('CommandArgument');

                    tabButtons.forEach(btn => btn.classList.remove('active'));
                    this.classList.add('active');

                    tabContents.forEach(content => {
                        if (content.id === `tab${tabName.charAt(0).toUpperCase() + tabName.slice(1)}`) {
                            content.style.display = 'block';
                        } else {
                            content.style.display = 'none';
                        }
                    });
                });
            });
        });
    </script>
</asp:Content>
