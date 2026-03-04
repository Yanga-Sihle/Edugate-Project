<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StudentFileDownload.aspx.cs" Inherits="Edugate_Project.StudentFileDownload" MasterPageFile="~/Student.master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Activities & Submissions</title>
    <style>
        /* General container styling */
        .page-container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.08);
            margin-top: 50px;
            animation: fadeInUp 0.8s ease-out forwards;
            max-width: 1000px; /* Increased max-width for more content */
            margin-left: auto;
            margin-right: auto;
        }

        .page-header {
            text-align: center;
            color: #34495e;
            margin-bottom: 30px;
            font-size: 2.2rem;
            font-weight: 700;
        }

        /* NEW STYLE: Student Information Section */
        .student-info {
            background-color: #ecf0f1;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            border-left: 5px solid #3498db;
        }
        .student-info h2 {
            margin-top: 0;
            color: #2c3e50;
            font-size: 1.5rem;
            border-bottom: 1px solid #bdc3c7;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .student-info p {
            margin: 5px 0;
            font-size: 1rem;
            color: #34495e;
        }
        .student-info strong {
            color: #2c3e50;
        }


        .filter-section {
            padding: 20px;
            background-color: #f0f4f7;
            border-radius: 8px;
            margin-bottom: 30px;
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            align-items: center;
            justify-content: center;
        }

        .filter-section label {
            font-weight: 600;
            color: #2c3e50;
            font-size: 1.1rem;
        }

        .filter-section select {
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 1rem;
            color: #333;
            background-color: #fff;
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%23000000%22%20d%3D%22M287%2C114.1L146.2%2C254.9L5.4%2C114.1L5.4%2C114.1z%22%2F%3E%3C%2Fsvg%3E');
            background-repeat: no-repeat;
            background-position: right 10px top 50%;
            background-size: 12px auto;
            cursor: pointer;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .filter-section select:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
        }

        /* Activity List Styling */
        .activity-list {
            margin-top: 30px;
            display: grid; /* Use Grid for better layout */
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); /* Responsive grid */
            gap: 25px;
        }

        .activity-item {
            background-color: #f9f9f9;
            border: 1px solid #eee;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.07);
            display: flex;
            flex-direction: column;
            gap: 10px;
            position: relative;
            overflow: hidden; /* For pseudo-elements */
        }
        .activity-item::before { /* Subject code tag */
            content: attr(data-subject-code);
            position: absolute;
            top: 0;
            right: 0;
            background-color: #3498db;
            color: white;
            padding: 5px 15px;
            border-bottom-left-radius: 8px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .activity-item h3 {
            margin-top: 0;
            color: #2c3e50;
            font-size: 1.4rem;
            margin-bottom: 10px;
        }

        .activity-item p {
            margin: 0;
            font-size: 1rem;
            color: #333;
        }

        .activity-item .activity-details {
            font-size: 0.9rem;
            color: #666;
            margin-bottom: 5px;
        }

        .activity-item .activity-description {
            font-style: italic;
            color: #555;
            border-left: 3px solid #3498db;
            padding-left: 10px;
            margin-top: 10px;
            margin-bottom: 15px;
        }

        .activity-item .download-link {
            display: inline-block;
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
            padding: 10px 20px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
            margin-top: 15px;
            align-self: flex-start;
            text-align: center;
        }

        .activity-item .download-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(52, 152, 219, 0.3);
        }

        /* Submission Section Styling */
        .submission-section {
            border-top: 1px dashed #ccc;
            padding-top: 20px;
            margin-top: 20px;
        }

        .submission-section h4 {
            color: #2c3e50;
            margin-bottom: 15px;
            font-size: 1.2rem;
        }

        .submission-section .form-group {
            margin-bottom: 15px;
        }

        .submission-section label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #2c3e50;
            font-size: 0.95rem;
        }

        .submission-section input[type="file"],
        .submission-section textarea {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 0.95rem;
            color: #333;
            box-sizing: border-box;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .submission-section textarea {
            min-height: 80px;
            resize: vertical;
        }

        .submission-section input[type="file"]:focus,
        .submission-section textarea:focus {
            border-color: #2ecc71;
            outline: none;
            box-shadow: 0 0 0 3px rgba(46, 204, 113, 0.2);
        }

        .btn-submit-activity {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 50px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            font-size: 1rem;
            width: 100%;
            display: block;
            margin-top: 15px;
            text-align: center;
        }

        .btn-submit-activity:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(46, 204, 113, 0.4);
        }

        /* Message/Error display */
        .status-message-global { /* For overall page messages */
            margin-top: 20px;
            padding: 15px;
            border-radius: 8px;
            font-weight: 600;
            text-align: center;
        }

        .status-message-global.info {
            background-color: #d1ecf1;
            color: #0c5460;
            border: 1px solid #bee5eb;
        }

        .status-message-global.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .status-message-individual { /* For messages per activity item */
            margin-top: 10px;
            padding: 10px;
            border-radius: 6px;
            font-weight: 500;
            text-align: center;
            font-size: 0.9rem;
        }
        .status-message-individual.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .status-message-individual.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }


        /* Responsive adjustments */
        @media (max-width: 768px) {
            .page-container {
                padding: 25px;
            }
            .activity-list {
                grid-template-columns: 1fr; /* Stack columns on smaller screens */
            }
            .page-header {
                font-size: 2rem;
            }
            .filter-section {
                flex-direction: column;
                align-items: stretch;
            }
        }
        @media (max-width: 480px) {
            .page-container {
                padding: 15px;
            }
            .page-header {
                font-size: 1.8rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <div class="page-container">
            <h1 class="page-header">Activities & Submissions 📚📝</h1>
            
            <%-- NEW SECTION: Student Information --%>
            <div class="student-info">
                <h2>Student Information</h2>
                <p><strong>Name:</strong> <asp:Literal ID="litStudentFullName" runat="server" /></p>
                <p><strong>Email:</strong> <asp:Literal ID="litStudentEmail" runat="server" /></p>
                <p><strong>School Code:</strong> <asp:Literal ID="litStudentSchoolCode" runat="server" /></p>
            </div>

            <div class="filter-section">
                <label for="<%= ddlSubjectFilter.ClientID %>">Filter by Subject:</label>
                <asp:DropDownList ID="ddlSubjectFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSubjectFilter_SelectedIndexChanged"></asp:DropDownList>
            </div>

            <asp:Panel ID="ActivityListPanel" runat="server" CssClass="activity-list" Visible="false">
                <asp:Repeater ID="rptActivities" runat="server" OnItemCommand="rptActivities_ItemCommand">
                    <ItemTemplate>
                        <div class="activity-item" data-subject-code="<%# Eval("SubjectCode") %>">
                            <h3><%# Eval("ActivityTitle") %></h3>
                            <p class="activity-details">Uploaded by: <strong><%# Eval("TeacherUsername") %></strong></p>
                            <p class="activity-details">Subject: <%# Eval("SubjectName") %></p>
                            <p class="activity-details">Uploaded Date: <strong><%# Eval("UploadDate", "{0:yyyy-MM-dd HH:mm}") %></strong></p>
                            
                            <p class="activity-description"><%# Eval("Description") %></p>
                            
                            <a href='<%# Eval("ActivityFilePath") %>' class="download-link" download='<%# Eval("ActivityFileName") %>'>Download Activity: <%# Eval("ActivityFileName") %></a>

                            <div class="submission-section">
                                <h4>Submit Your Work</h4>
                                <div class="form-group">
                                    <label for="FileUploadSubmission_<%# Eval("ActivityID") %>">Select Submission File:</label>
                                    <asp:FileUpload ID="FileUploadSubmission" runat="server" />
                                </div>
                                <div class="form-group">
                                    <label for="txtSubmissionComments_<%# Eval("ActivityID") %>">Comments (Optional):</label>
                                    <asp:TextBox ID="txtSubmissionComments" runat="server" TextMode="MultiLine" placeholder="Add comments for your teacher..."></asp:TextBox>
                                </div>
                                <asp:Button ID="btnSubmitActivity" runat="server" Text="Submit Activity" 
                                    CommandName="SubmitActivity" CommandArgument='<%# Eval("ActivityID") %>' 
                                    CssClass="btn-submit-activity" />
                                <asp:Literal ID="litSubmissionStatus" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>

            <%-- Uncommented and moved to a central location for global messages --%>
            <asp:Literal ID="litStatusMessage" runat="server" CssClass="status-message-global"></asp:Literal>
        </div>
    </div>
</asp:Content>