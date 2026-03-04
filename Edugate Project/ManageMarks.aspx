<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManageMarks.aspx.cs" Inherits="Edugate_Project.ManageMarks" MasterPageFile="~/Site1.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Manage Marks</title>
    <style>
        .marks-management-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 30px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
        }

        .marks-header {
            text-align: center;
            margin-bottom: 30px;
            color: #2c3e50;
        }

        .marks-controls {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 30px;
            align-items: flex-end;
        }

        .control-group {
            flex: 1;
            min-width: 200px;
        }

        .control-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #34495e;
        }

        .control-input {
            width: 100%;
            padding: 10px;
            border-radius: 5px;
            border: 1px solid #ddd;
            background-color: #f8f9fa;
        }

        .btn-submit {
            background-color: #27ae60;
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 5px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
        }

        .btn-submit:hover {
            background-color: #219653;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(39, 174, 96, 0.3);
        }

        .marks-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 30px;
        }

        .marks-table th {
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
        }

        .marks-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }

        .marks-table tr:nth-child(even) {
            background-color: #f8f9fa;
        }

        .marks-table tr:hover {
            background-color: #eaf2f8;
        }

        .text-center {
            text-align: center;
        }

        .no-marks {
            text-align: center;
            padding: 40px;
            color: #7f8c8d;
            font-size: 1.1rem;
        }

        @media (max-width: 768px) {
            .marks-controls {
                flex-direction: column;
            }
            
            .control-group {
                width: 100%;
            }
            
            .marks-table {
                font-size: 0.9rem;
            }
            
            .marks-table th, 
            .marks-table td {
                padding: 8px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="marks-management-container">
        <div class="marks-header">
            <h1>Manage Student Marks</h1>
            <p>Record and update marks for your students</p>
        </div>

        <div class="marks-controls">
            <div class="control-group">
                <label class="control-label">Class</label>
                <asp:DropDownList ID="ddlClass" runat="server" CssClass="control-input" AutoPostBack="true" OnSelectedIndexChanged="LoadStudents">
                </asp:DropDownList>
            </div>
            
            <div class="control-group">
                <label class="control-label">Subject</label>
                <asp:DropDownList ID="ddlSubject" runat="server" CssClass="control-input" AutoPostBack="true" OnSelectedIndexChanged="LoadAssessments">
                </asp:DropDownList>
            </div>
            
            <div class="control-group">
                <label class="control-label">Assessment</label>
                <asp:DropDownList ID="ddlAssessment" runat="server" CssClass="control-input">
                    <asp:ListItem Value="">-- Select Assessment --</asp:ListItem>
                </asp:DropDownList>
            </div>
            
            <div class="control-group">
                <asp:Button ID="btnLoad" runat="server" Text="Load Students" CssClass="btn-submit" OnClick="LoadStudentMarks" />
            </div>
        </div>

        <asp:Panel ID="pnlMarksEntry" runat="server" Visible="false">
            <asp:GridView ID="gvStudentMarks" runat="server" AutoGenerateColumns="False" CssClass="marks-table"
                EmptyDataText="No students found for the selected criteria" ShowHeaderWhenEmpty="True">
                <Columns>
                    <asp:BoundField DataField="StudentID" HeaderText="ID" Visible="false" />
                    <asp:BoundField DataField="FullName" HeaderText="Student Name" />
                    <asp:TemplateField HeaderText="Mark (%)">
                        <ItemTemplate>
                            <asp:TextBox ID="txtMark" runat="server" TextMode="Number" min="0" max="100" 
                                Text='<%# Eval("Mark") %>' CssClass="control-input" Width="80px"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Feedback">
                        <ItemTemplate>
                            <asp:TextBox ID="txtFeedback" runat="server" TextMode="MultiLine" Rows="2"
                                Text='<%# Eval("Feedback") %>' CssClass="control-input"></asp:TextBox>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            
            <div class="text-center" style="margin-top: 20px;">
                <asp:Button ID="btnSubmitMarks" runat="server" Text="Submit Marks" CssClass="btn-submit" OnClick="SubmitMarks" />
            </div>
        </asp:Panel>
        
        <asp:Label ID="lblMessage" runat="server" CssClass="no-marks"></asp:Label>
    </div>
</asp:Content>