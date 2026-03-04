<%@ Page Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="StudentMaterials.aspx.cs" Inherits="Edugate_Project.StudentMaterials" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Study Materials</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        /* Custom color palette variables */
        :root {
            --primary-dark: #213A57;
            --primary-orange: #0B6477;
            --accent-teal: #14919B;
            --text-light: #DAD1CB;
            --accent-green: #45DFB1;
            --accent-light-green: #80ED99;
        }

        /* Student Dashboard Layout */
        .student-dashboard {
            display: flex;
            min-height: 100vh;
            background-color: var(--primary-dark);
            color: var(--text-light);
            font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        /* Sidebar Styling */
        .student-sidebar {
            width: 280px;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            color: white;
            padding: 2rem 1rem;
            position: fixed;
            height: 100vh;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border-right: 2px solid var(--accent-green);
            z-index: 1000;
            animation: fadeInLeft 0.8s ease-out forwards;
        }

        @keyframes fadeInLeft {
            from {
                opacity: 0;
                transform: translateX(-20px);
            }
            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        .student-profile {
            text-align: center;
            padding: 1rem 0 2rem;
            border-bottom: 1px solid rgba(255,255,255,0.1);
            margin-bottom: 1.5rem;
        }

        .student-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            object-fit: cover;
            border: 3px solid var(--accent-green);
            margin-bottom: 1rem;
        }

        .student-name {
            font-size: 1.2rem;
            margin: 0.5rem 0;
            font-weight: 700;
            color: var(--text-light);
            text-shadow: 0 1px 2px rgba(0,0,0,0.2);
        }

        .student-status {
            font-size: 0.85rem;
            color: var(--accent-light-green);
            margin: 0;
        }

        .student-menu {
            list-style: none;
            padding: 0;
            margin: 0;
        }

        .student-menu li {
            margin-bottom: 0.5rem;
        }

        .student-menu a {
            display: flex;
            align-items: center;
            color: rgba(255,255,255,0.8);
            padding: 0.75rem 1rem;
            border-radius: 6px;
            text-decoration: none;
            transition: all 0.2s;
        }

        .student-menu a:hover, .student-menu a.active {
            background-color: rgba(69, 223, 177, 0.2);
            color: var(--text-light);
        }

        .student-menu a i {
            margin-right: 0.75rem;
            width: 20px;
            text-align: center;
        }

        /* Main Content Area */
        .student-content {
            flex: 1;
            margin-left: 280px;
            padding: 2rem;
            background-color: rgba(33, 58, 87, 0.7);
            min-height: 100vh;
            backdrop-filter: blur(5px);
            border-left: 1px solid var(--accent-teal);
        }

        /* Materials Content Styling */
        .materials-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2.5rem 2rem;
            background: linear-gradient(135deg, var(--primary-orange) 60%, var(--accent-teal) 100%);
            border-radius: 24px;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border: 2px solid var(--accent-green);
            animation: fadeInUp 0.8s ease-out forwards;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* Header and Hero Section */
        .materials-hero {
            text-align: center;
            margin-bottom: 3rem;
        }

        .materials-hero h1 {
            font-size: 2.8rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: var(--text-light);
        }

        .materials-hero p {
            font-size: 1.2rem;
            color: var(--accent-light-green);
            opacity: 0.95;
        }

        /* Filter Section */
        .filter-section {
            background-color: rgba(33, 58, 87, 0.7);
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 3rem;
            border: 1px solid var(--accent-teal);
            backdrop-filter: blur(5px);
        }

        .filter-section h2 {
            color: var(--text-light);
            font-size: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-bottom: 1.5rem;
        }

        .filter-group label {
            display: block;
            font-weight: 600;
            margin-bottom: 0.5rem;
            color: var(--text-light);
        }

        .filter-control {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 2px solid var(--accent-teal);
            border-radius: 10px;
            font-size: 1rem;
            background-color: var(--primary-dark);
            color: var(--text-light);
            transition: all 0.3s ease;
        }

        .filter-control:focus {
            outline: none;
            border-color: var(--accent-green);
            box-shadow: 0 0 0 3px rgba(69, 223, 177, 0.2);
        }

        .filter-actions {
            display: flex;
            gap: 1rem;
            justify-content: flex-end;
        }

        .btn-filter {
            padding: 0.8rem 1.5rem;
            background-color: var(--accent-green);
            color: var(--primary-dark);
            border-radius: 50px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .btn-filter:hover {
            background-color: var(--primary-dark);
            color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
            transform: translateY(-3px);
        }

        .btn-filter-clear {
            background-color: transparent;
            color: var(--accent-green);
            border: 1px solid var(--accent-green);
        }

        /* Materials Grid and Cards */
        .materials-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 2rem;
        }

        .material-card {
            background-color: rgba(33, 58, 87, 0.7);
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            transition: all 0.3s ease;
            border: 1px solid var(--accent-teal);
            backdrop-filter: blur(5px);
        }

        .material-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            border-color: var(--accent-green);
        }

        .material-header {
            background: rgba(20, 145, 155, 0.3);
            color: var(--text-light);
            padding: 1.5rem;
            border-bottom: 1px solid var(--accent-teal);
        }

        .material-type {
            display: inline-block;
            background-color: rgba(69, 223, 177, 0.2);
            color: var(--accent-green);
            padding: 0.3rem 0.8rem;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            margin-bottom: 0.8rem;
        }

        .material-header h3 {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: var(--text-light);
        }

        .material-meta {
            display: flex;
            justify-content: space-between;
            margin-top: 1rem;
            font-size: 0.9rem;
        }

        .material-meta span {
            display: flex;
            align-items: center;
            gap: 0.3rem;
        }

        .material-body {
            padding: 1.5rem;
        }

        .material-description {
            color: var(--text-light);
            opacity: 0.8;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }

        .material-actions {
            display: flex;
            gap: 1rem;
        }

        .btn-download, .btn-preview {
            flex: 1;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0.8rem 1rem;
            background-color: var(--accent-green);
            color: var(--primary-dark);
            border-radius: 50px;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }

        .btn-preview {
            background-color: transparent;
            color: var(--accent-green);
            border: 1px solid var(--accent-green);
        }

        .btn-download:hover, .btn-preview:hover {
            background-color: var(--primary-dark);
            color: var(--accent-green);
            box-shadow: 0 0 0 1px var(--accent-green);
            transform: translateY(-3px);
        }

        /* No Results Styling */
        .no-results {
            grid-column: 1 / -1;
            text-align: center;
            padding: 3rem;
            background-color: rgba(33, 58, 87, 0.5);
            border-radius: 16px;
            border: 1px solid var(--accent-teal);
        }

        /* Alert Styling */
        .alert {
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
        }
        
        .alert-error {
            background-color: #ffebee;
            color: #c62828;
            border: 1px solid #ef9a9a;
        }
        
        .alert-success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border: 1px solid #a5d6a7;
        }

        /* Modal Styling */
        .modal {
            display: none;
            position: fixed;
            z-index: 2000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.7);
            animation: fadeIn 0.3s ease-out forwards;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: var(--primary-dark);
            margin: 5% auto;
            padding: 2rem;
            border-radius: 16px;
            width: 80%;
            max-width: 900px;
            box-shadow: 0 8px 32px 0 rgba(33, 58, 87, 0.25);
            border: 2px solid var(--accent-green);
            position: relative;
            animation: slideIn 0.3s ease-out forwards;
        }

        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .close-modal {
            position: absolute;
            top: 1rem;
            right: 1.5rem;
            color: var(--text-light);
            font-size: 1.8rem;
            font-weight: bold;
            cursor: pointer;
            transition: color 0.3s;
        }

        .close-modal:hover {
            color: var(--accent-green);
        }

        .preview-container {
            margin: 1.5rem 0;
            height: 60vh;
            border: 1px solid var(--accent-teal);
            border-radius: 8px;
            overflow: hidden;
        }

        .preview-iframe {
            width: 100%;
            height: 100%;
            border: none;
        }

        .preview-actions {
            display: flex;
            justify-content: center;
        }

        /* Responsive adjustments */
        @media (max-width: 992px) {
            .student-sidebar {
                width: 240px;
                padding: 1.5rem 0.75rem;
            }
            
            .student-content {
                margin-left: 240px;
                padding: 1.5rem;
            }
        }

        @media (max-width: 768px) {
            .student-sidebar {
                transform: translateX(-100%);
                width: 280px;
            }
            
            .student-sidebar.active {
                transform: translateX(0);
            }
            
            .student-content {
                margin-left: 0;
                padding: 1rem;
            }
            
            .filter-grid, .materials-grid {
                grid-template-columns: 1fr;
            }
            
            .materials-container {
                padding: 20px;
            }
            
            .materials-hero h1 {
                font-size: 2.2rem;
            }

            .material-actions {
                flex-direction: column;
            }
        }

        @media (max-width: 576px) {
            .student-menu a {
                padding: 0.5rem;
                font-size: 0.9rem;
            }
            
            .materials-hero h1 {
                font-size: 1.8rem;
            }

            .filter-grid {
                grid-template-columns: 1fr;
            }

            .filter-actions {
                flex-direction: column;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="student-dashboard">
        <!-- Student Sidebar -->
        <div class="student-sidebar">
            <div class="student-profile">
                <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
                <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server"></asp:Literal></h3>
                <p class="student-status">Active Student</p>
            </div>
            
            <ul class="student-menu">
                <li><a href="StudentDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="StudentMark.aspx"><i class="fas fa-marker"></i> Upload School Report</a></li>
                <li><a href="Scholarships.aspx"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
                <li><a href="CareerGuidance.aspx"><i class="fas fa-compass"></i> Career Guidance</a></li>
                <li><a href="StudentMaterials.aspx" class="active"><i class="fas fa-book-open"></i> Study Materials</a></li>
                <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>
        
        <!-- Main Content -->
        <div class="student-content">
            <!-- Alert container for messages -->
            <div id="alertContainer" runat="server" class="alert" style="display: none;">
                <span id="alertMessage" runat="server"></span>
                <button type="button" class="close-alert" onclick="closeAlert()" style="float: right; background: none; border: none; color: inherit; cursor: pointer;">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            
            <div class="materials-container">
                <div class="materials-hero">
                    <h1>Study Materials 📚</h1>
                    <p>Access a wide range of educational resources to support your learning journey</p>
                </div>

                <!-- Filter Section -->
                <div class="filter-section">
                    <h2>🔍 Filter Materials</h2>
                    <div class="filter-grid">
                        <div class="filter-group">
                            <label>Subject</label>
                            <asp:DropDownList ID="ddlSubjectFilter" runat="server" CssClass="filter-control">
                                <asp:ListItem Value="">All Subjects</asp:ListItem>
                                <asp:ListItem Value="Mathematics">Mathematics</asp:ListItem>
                                <asp:ListItem Value="Physical Sciences">Physical Sciences</asp:ListItem>
                                <asp:ListItem Value="Life Sciences">Life Sciences</asp:ListItem>
                                <asp:ListItem Value="Information Technology">Information Technology</asp:ListItem>
                                <asp:ListItem Value="Engineering">Engineering</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        
                        <div class="filter-group">
                            <label>Grade</label>
                            <asp:DropDownList ID="ddlGradeFilter" runat="server" CssClass="filter-control">
                                <asp:ListItem Value="">All Grades</asp:ListItem>
                               
                                <asp:ListItem Value="10">Grade 10</asp:ListItem>
                                <asp:ListItem Value="11">Grade 11</asp:ListItem>
                                <asp:ListItem Value="12">Grade 12</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        
                        <div class="filter-group">
                            <label>Material Type</label>
                            <asp:DropDownList ID="ddlTypeFilter" runat="server" CssClass="filter-control">
                                <asp:ListItem Value="">All Types</asp:ListItem>
                                <asp:ListItem Value="Question Paper">Question Paper</asp:ListItem>
                                <asp:ListItem Value="Textbook">Textbook</asp:ListItem>
                                <asp:ListItem Value="Video">Video Lesson</asp:ListItem>
                                <asp:ListItem Value="Notes">Study Notes</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        
                        <div class="filter-group">
                            <label>Sort By</label>
                            <asp:DropDownList ID="ddlSortFilter" runat="server" CssClass="filter-control">
                                <asp:ListItem Value="UploadDate DESC">Newest First</asp:ListItem>
                                <asp:ListItem Value="UploadDate ASC">Oldest First</asp:ListItem>
                                <asp:ListItem Value="Title ASC">Title (A-Z)</asp:ListItem>
                                <asp:ListItem Value="Title DESC">Title (Z-A)</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    
                    <div class="filter-actions">
                        <asp:Button ID="btnApplyFilters" runat="server" Text="Apply Filters" CssClass="btn-filter" OnClick="btnApplyFilters_Click" />
                        <asp:Button ID="btnClearFilters" runat="server" Text="Clear Filters" CssClass="btn-filter btn-filter-clear" OnClick="btnClearFilters_Click" />
                    </div>
                </div>
                
                <!-- Materials Grid -->
                <div class="materials-grid">
                    <asp:Repeater ID="rptMaterials" runat="server" OnItemDataBound="rptMaterials_ItemDataBound">
                        <ItemTemplate>
                            <div class="material-card">
                                <div class="material-header">
                                    <div class="material-type">
                                        <asp:Literal ID="litMaterialType" runat="server"></asp:Literal>
                                    </div>
                                    <h3 class="material-title">
                                        <asp:Literal ID="litTitle" runat="server" Text='<%# Eval("Title") %>'></asp:Literal>
                                    </h3>
                                    <div class="material-meta">
                                        <span>
                                            <i class="fas fa-book-open"></i> 
                                            <asp:Literal ID="litSubject" runat="server" Text='<%# Eval("Subject") %>'></asp:Literal>
                                        </span>
                                        <span>
                                            <i class="fas fa-graduation-cap"></i> 
                                            Grade <asp:Literal ID="litGrade" runat="server" Text='<%# Eval("Grade") %>'></asp:Literal>
                                        </span>
                                    </div>
                                </div>
                                <div class="material-body">
                                    <div class="material-description">
                                        <asp:Literal ID="litDescription" runat="server" Text='<%# Eval("Description") %>'></asp:Literal>
                                    </div>
                                    <div class="material-actions">
                                     <a href='<%# "DownloadFile.ashx?file="
          + Server.UrlEncode(System.IO.Path.GetFileName(Eval("FileName").ToString()))
          + "&original="
          + Server.UrlEncode(Eval("OriginalFileName").ToString()) %>'
   class="btn-download"
   onclick='<%# "logMaterialAccess(" + Eval("MaterialId") + ", true);" %>'>
   <i class="fas fa-download"></i> Download
</a>



                                        <asp:HyperLink ID="btnPreview" runat="server" CssClass="btn-preview" Visible="false">
                                            <i class="fas fa-eye"></i> Preview
                                        </asp:HyperLink>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoResults" runat="server" CssClass="no-results" Visible="false">
                        <i class="fas fa-search" style="font-size: 2rem; margin-bottom: 1rem;"></i>
                        <p>No materials found matching your criteria.</p>
                        <p>Try adjusting your filters or check back later.</p>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <!-- Preview Modal -->
    <div id="previewModal" class="modal" runat="server" visible="false">
        <div class="modal-content">
            <span class="close-modal" onclick="closePreview()">&times;</span>
            <h2 style="color: var(--accent-green);">Material Preview</h2>
            
            <div class="preview-container">
                <iframe id="previewFrame" class="preview-iframe" runat="server"></iframe>
            </div>
            
            <div class="preview-actions">
                <a id="lnkModalDownload" runat="server" class="btn-download">
                    <i class="fas fa-download"></i> Download
                </a>
            </div>
        </div>
    </div>

    <script>
        // Close the preview modal
        function closePreview() {
            document.getElementById('<%= previewModal.ClientID %>').style.display = 'none';
        }

        // Close modal when clicking outside content
        window.onclick = function (event) {
            var modal = document.getElementById('<%= previewModal.ClientID %>');
            if (event.target == modal) {
                modal.style.display = 'none';
            }
        }

        // Show alert message
        function showAlert(message, type) {
            var alertContainer = document.getElementById('<%= alertContainer.ClientID %>');
            var alertMessage = document.getElementById('<%= alertMessage.ClientID %>');

            alertContainer.className = 'alert alert-' + type;
            alertMessage.innerHTML = message;
            alertContainer.style.display = 'block';

            // Auto-hide after 5 seconds
            setTimeout(closeAlert, 5000);
        }

        // Close alert message
        function closeAlert() {
            var alertContainer = document.getElementById('<%= alertContainer.ClientID %>');
            alertContainer.style.display = 'none';
        }

        // Log material access (for download tracking)
        function logMaterialAccess(materialId, isDownload) {
            // Use AJAX to log the access without interrupting the download
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "LogMaterialAccess.ashx", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.send("materialId=" + materialId + "&isDownload=" + isDownload);
        }

        // Check if there's a message to display on page load
        window.onload = function () {
            <% if (!string.IsNullOrEmpty(AlertMessage)) { %>
            showAlert('<%= AlertMessage %>', '<%= AlertType %>');
            <% } %>
        };
    </script>
</asp:Content>