<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherViewStudents.aspx.cs" Inherits="Edugate_Project.TeacherViewStudents" MasterPageFile="~/Site1.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Grade Students</title>
    <style>
        .grading-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
        }
        .filter-panel {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .grading-grid {
            width: 100%;
            border-collapse: collapse;
        }
        .grading-grid th {
            background: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
        }
        .grading-grid td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .grading-grid tr:nth-child(even) {
            background: #f8f9fa;
        }
        .grade-input {
            width: 60px;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        .btn-save {
            background: #27ae60;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 20px;
        }
        .submission-link {
            color: #3498db;
            text-decoration: none;
        }
        .no-submissions {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="grading-container">
        <h1>Grade Student Submissions</h1>
        
        <div class="filter-panel">
            <div style="display: flex; gap: 20px; flex-wrap: wrap;">
                <div>
                    <label>Subject</label>
                    <asp:DropDownList ID="ddlSubject" runat="server" AutoPostBack="true" 
                        OnSelectedIndexChanged="FilterSubmissions" CssClass="form-control">
                    </asp:DropDownList>
                </div>
                <div>
                    <label>Assessment Type</label>
                    <asp:DropDownList ID="ddlAssessmentType" runat="server" AutoPostBack="true" 
                        OnSelectedIndexChanged="FilterSubmissions" CssClass="form-control">
                        <asp:ListItem Value="assignment">Assignments</asp:ListItem>
                        <asp:ListItem Value="test">Tests</asp:ListItem>
                        <asp:ListItem Value="quiz">Quizzes</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <div>
                    <label>Assessment</label>
                    <asp:DropDownList ID="ddlAssessment" runat="server" AutoPostBack="true" 
                        OnSelectedIndexChanged="FilterSubmissions" CssClass="form-control">
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <asp:GridView ID="gvSubmissions" runat="server" AutoGenerateColumns="false" 
            CssClass="grading-grid" DataKeyNames="SubmissionId" OnRowDataBound="GvSubmissions_RowDataBound">
            <Columns>
                <asp:BoundField DataField="StudentId" HeaderText="ID" />
                <asp:BoundField DataField="FullName" HeaderText="Student Name" />
                <asp:TemplateField HeaderText="Submission">
                    <ItemTemplate>
                        <a href='<%# "~/Submissions/" + Eval("FilePath") %>' target="_blank" 
                            class="submission-link" runat="server">
                            View Submission
                        </a>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="SubmissionDate" HeaderText="Submitted On" 
                    DataFormatString="{0:dd MMM yyyy}" />
                <asp:TemplateField HeaderText="Grade (%)">
                    <ItemTemplate>
                        <asp:TextBox ID="txtGrade" runat="server" CssClass="grade-input" 
                            TextMode="Number" min="0" max="100" Text='<%# Eval("Score") %>'></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Feedback">
                    <ItemTemplate>
                        <asp:TextBox ID="txtFeedback" runat="server" TextMode="MultiLine" 
                            Rows="2" Text='<%# Eval("Feedback") %>'></asp:TextBox>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div class="no-submissions">No submissions found for the selected criteria</div>
            </EmptyDataTemplate>
        </asp:GridView>

        <div style="text-align: right;">
            <asp:Button ID="btnSaveGrades" runat="server" Text="Save All Grades" 
                CssClass="btn-save" OnClick="BtnSaveGrades_Click" />
        </div>
    </div>
</asp:Content>