<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ScheduleRecording.aspx.cs" Inherits="Edugate_Project.ScheduleRecording" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Set Live Recording Session</title>
    <%-- <link href="Styles/Main.css" rel="stylesheet" />  --%>
    <!-- Using inline styles for direct portability. Ideally, this would be in Styles/Main.css -->
    <style>
        body { font-family: Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 20px; }
        .container { max-width: 800px; margin: 30px auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); }
        h1, h2 { color: #333; text-align: center; margin-bottom: 25px; }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: bold; color: #555; }
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="time"],
        .form-group select,
        .form-group textarea {
            width: calc(100% - 20px);
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            box-sizing: border-box;
            transition: border-color 0.3s ease;
        }
        .form-group input[type="text"]:focus,
        .form-group input[type="date"]:focus,
        .form-group input[type="time"]:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #007bff;
            outline: none;
        }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .btn-primary {
            display: block;
            width: 100%;
            padding: 15px;
            background-color: #28a745; /* Green for success/scheduling */
            color: #fff;
            border: none;
            border-radius: 5px;
            font-size: 18px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            margin-top: 20px;
        }
        .btn-primary:hover { background-color: #218838; }
        .validation-message { color: #dc3545; font-size: 0.9em; margin-top: 5px; display: block; }
        .success-message {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            text-align: left;
        }
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
            padding: 15px;
            border-radius: 5px;
            margin-top: 20px;
            text-align: left;
        }
        .info-message {
            color: #007bff;
            font-size: 0.9em;
            margin-top: -10px;
            margin-bottom: 10px;
            text-align: center;
        }
        /* Checkbox list styling for better readability */
        .checkbox-list {
            display: flex;
            flex-wrap: wrap;
            gap: 15px; /* Space between checkboxes */
            justify-content: center;
            padding: 10px 0;
            border: 1px solid #eee;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .checkbox-list label {
            display: flex;
            align-items: center;
            margin-bottom: 0; /* Override default label margin */
            font-weight: normal; /* Override default label font-weight */
            cursor: pointer;
        }
        .checkbox-list input[type="checkbox"] {
            margin-right: 8px;
            transform: scale(1.2); /* Slightly larger checkboxes */
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server"></asp:ScriptManager>
        <div class="container">
            <h1>Set Live Recording Session</h1>
            <p class="info-message">
                <%-- Corrected: Use span for styling within Literal control --%>
                <asp:Literal ID="litSchoolCodeReminder" runat="server" Text="<span style='color: #007bff;'><b>**Important:**</b> When entering the Subject, please include the school code prefix, e.g., 'EDG-Mathematics'.</span>"></asp:Literal>
            </p>

            <div class="form-group">
                <label for="<%= txtSubject.ClientID %>">Subject:</label>
                <asp:TextBox ID="txtSubject" runat="server" CssClass="form-control" Placeholder="e.g., EDG-Mathematics"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" ErrorMessage="Subject is required." CssClass="validation-message" Display="Dynamic"></asp:RequiredFieldValidator>
                <asp:CustomValidator ID="cvSchoolCode" runat="server" ControlToValidate="txtSubject" OnServerValidate="cvSchoolCode_ServerValidate" ErrorMessage="Subject must start with 'EDG-' followed by subject name." CssClass="validation-message" Display="Dynamic"></asp:CustomValidator>
            </div>

           <div class="form-group">
                <label for="<%= txtDate.ClientID %>">Date:</label>
                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvDate" runat="server" ControlToValidate="txtDate" ErrorMessage="Date is required." CssClass="validation-message" Display="Dynamic"></asp:RequiredFieldValidator>
                <%-- CompareValidator to ensure date is not in the past --%>
                <asp:CompareValidator ID="cmpDate" runat="server" ControlToValidate="txtDate" Operator="GreaterThanEqual" Type="Date" ErrorMessage="Date cannot be in the past." CssClass="validation-message" Display="Dynamic"></asp:CompareValidator>
            </div>

            <div class="form-group">
                <label for="<%= txtTime.ClientID %>">Time:</label>
                <asp:TextBox ID="txtTime" runat="server" TextMode="Time" CssClass="form-control"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvTime" runat="server" ControlToValidate="txtTime" ErrorMessage="Time is required." CssClass="validation-message" Display="Dynamic"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label for="<%= ddlDuration.ClientID %>">Duration:</label>
                <asp:DropDownList ID="ddlDuration" runat="server" CssClass="form-control">
                    <asp:ListItem Text="30 Minutes" Value="30"></asp:ListItem>
                    <asp:ListItem Text="45 Minutes" Value="45"></asp:ListItem>
                    <asp:ListItem Text="60 Minutes" Value="60" Selected="True"></asp:ListItem>
                    <asp:ListItem Text="90 Minutes" Value="90"></asp:ListItem>
                    <asp:ListItem Text="120 Minutes" Value="120"></asp:ListItem>
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label for="<%= txtTopic.ClientID %>">Topic:</label>
                <asp:TextBox ID="txtTopic" runat="server" CssClass="form-control" Placeholder="e.g., Algebra Fundamentals"></asp:TextBox>
                <asp:RequiredFieldValidator ID="rfvTopic" runat="server" ControlToValidate="txtTopic" ErrorMessage="Topic is required." CssClass="validation-message" Display="Dynamic"></asp:RequiredFieldValidator>
            </div>

            <div class="form-group">
                <label for="<%= txtDescription.ClientID %>">Description:</label>
                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control" Placeholder="Provide a brief description of the session content."></asp:TextBox>
            </div>

            <div class="form-group">
                <label>Target Audience:</label>
                <asp:CheckBoxList ID="cblTargetAudience" runat="server" RepeatDirection="Horizontal" CssClass="checkbox-list">
                    <asp:ListItem Text="Grade 8" Value="Grade8"></asp:ListItem>
                    <asp:ListItem Text="Grade 9" Value="Grade9"></asp:ListItem>
                    <asp:ListItem Text="Grade 10" Value="Grade10"></asp:ListItem>
                    <asp:ListItem Text="Grade 11" Value="Grade11"></asp:ListItem>
                    <asp:ListItem Text="Grade 12" Value="Grade12"></asp:ListItem>
                    <asp:ListItem Text="All Students" Value="All"></asp:ListItem>
                </asp:CheckBoxList>
                <asp:CustomValidator ID="cvTargetAudience" runat="server" OnServerValidate="cvTargetAudience_ServerValidate" ErrorMessage="Please select at least one target audience." CssClass="validation-message" Display="Dynamic"></asp:CustomValidator>
            </div>
            
            <asp:Button ID="btnScheduleSession" runat="server" Text="Schedule Session" OnClick="btnScheduleSession_Click" CssClass="btn-primary" />

            <%-- litMessage is used to display success/error messages dynamically --%>
            <asp:Literal ID="litMessage" runat="server" EnableViewState="false" Visible="false"></asp:Literal>
        </div>
    </form>
</body>
</html>