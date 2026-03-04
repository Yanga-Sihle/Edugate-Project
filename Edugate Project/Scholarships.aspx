<%@ Page Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true"
    CodeBehind="Scholarships.aspx.cs" Inherits="Edugate_Project.Scholarships" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <title>Scholarship Opportunities</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">

    <style>
        :root{--primary-dark:#213A57;--primary-orange:#0B6477;--accent-teal:#14919B;--text-light:#DAD1CB;--accent-green:#45DFB1;--accent-light-green:#80ED99;}
        body { font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .student-dashboard{display:flex;min-height:100vh;background-color:var(--primary-dark);color:var(--text-light);}
        .student-sidebar{width:280px;background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);color:#fff;padding:2rem 1rem;position:fixed;height:100vh;box-shadow:0 8px 32px 0 rgba(33,58,87,.25);border-right:2px solid var(--accent-green);z-index:1000}
        .student-profile{text-align:center;padding:1rem 0 2rem;border-bottom:1px solid rgba(255,255,255,.1);margin-bottom:1.5rem}
        .student-avatar{width:80px;height:80px;border-radius:50%;object-fit:cover;border:3px solid var(--accent-green);margin-bottom:1rem}
        .student-name{font-size:1.2rem;margin:.5rem 0;font-weight:700;color:var(--text-light)}
        .student-status{font-size:.85rem;color:var(--accent-light-green);margin:0}
        .student-menu{list-style:none;padding:0;margin:0}
        .student-menu li{margin-bottom:.5rem}
        .student-menu a{display:flex;align-items:center;color:rgba(255,255,255,.8);padding:.75rem 1rem;border-radius:6px;text-decoration:none;transition:all .2s}
        .student-menu a:hover,.student-menu a.active{background:rgba(69,223,177,.2);color:var(--text-light)}
        .student-menu a i{margin-right:.75rem;width:20px;text-align:center}

        .student-content{flex:1;margin-left:280px;padding:2rem;background:rgba(33,58,87,.7);min-height:100vh;backdrop-filter:blur(5px);border-left:1px solid var(--accent-teal)}
        .opportunities-container{max-width:1200px;margin:0 auto;padding:2.5rem 2rem;background:linear-gradient(135deg,var(--primary-orange) 60%,var(--accent-teal) 100%);border-radius:24px;box-shadow:0 8px 32px 0 rgba(33,58,87,.25);border:2px solid var(--accent-green)}
        .section-title{color:var(--text-light);margin-bottom:1.5rem;font-weight:800;position:relative;padding-bottom:.75rem;font-size:2rem}
        .section-title:after{content:'';position:absolute;bottom:0;left:0;width:50px;height:3px;background:var(--accent-green)}
        .filter-section{background:rgba(33,58,87,.7);border-radius:16px;padding:1.25rem 1.25rem 0;border:1px solid var(--accent-teal);margin-bottom:1.25rem}
        .filter-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:1rem;margin-bottom:1rem}
        .filter-control{width:100%;padding:.7rem 1rem;border:2px solid var(--accent-teal);border-radius:10px;background:var(--primary-dark);color:var(--text-light)}
        .scholarships-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(330px,1fr));gap:1.25rem}
        .scholarship-card{background:rgba(33,58,87,.7);border-radius:16px;border:1px solid var(--accent-teal);overflow:hidden}
        .scholarship-header{background:rgba(20,145,155,.3);padding:1rem 1.25rem;border-bottom:1px solid var(--accent-teal)}
        .scholarship-header h3{margin:0;font-size:1.25rem}
        .scholarship-meta{display:flex;justify-content:space-between;font-size:.9rem;margin-top:.35rem}
        .scholarship-amount{color:var(--accent-green);font-weight:700}
        .scholarship-deadline{color:var(--accent-light-green);font-weight:700}
        .scholarship-body{padding:1rem 1.25rem}
        .scholarship-description{opacity:.9;margin-bottom:1rem;line-height:1.5}
        .scholarship-tags{display:flex;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem}
        .scholarship-tag{background:rgba(69,223,177,.2);color:var(--accent-green);padding:.25rem .6rem;border-radius:999px;font-size:.75rem;font-weight:700}
        .cta-row{display:flex;gap:.75rem}
        .cta-btn{flex:1;display:inline-block;padding:.7rem 1rem;background:var(--accent-green);color:var(--primary-dark);border-radius:50px;font-weight:800;text-align:center;text-decoration:none}
        .cta-btn:hover{background:var(--primary-dark);color:var(--accent-green);outline:1px solid var(--accent-green)}

        /* Modal/panel */
        .modal-backdrop{position:fixed;inset:0;background:rgba(0,0,0,.55);display:none;align-items:center;justify-content:center;z-index:2000}
        .modal{width:min(640px,92vw);background:rgba(33,58,87,.95);border:1px solid var(--accent-teal);border-radius:16px;padding:1.25rem}
        .modal h3{margin:0 0 .5rem 0}
        .modal-actions{display:flex;gap:.75rem;margin-top:1rem}
        .btn-secondary{background:transparent;border:2px solid var(--accent-teal);color:var(--text-light);border-radius:50px;padding:.7rem 1rem;font-weight:800;flex:1;text-align:center}
        .btn-secondary:hover{border-color:var(--accent-green);color:var(--accent-green)}

        /* Assistance form */
.assist-panel{
    display:none;
    margin: 1.25rem auto 2rem;
    background:rgba(33,58,87,.7);
    border:1px solid var(--accent-teal);
    border-radius:16px;
    padding:1rem 1.25rem;
    max-width: 1200px;        /* match container width */
    box-shadow:0 8px 24px rgba(0,0,0,.18);
}

/* Make the grid responsive and prevent tiny columns */
.assist-panel .form-row{
    display:grid;
    grid-template-columns: repeat(2, minmax(260px, 1fr));
    gap:1rem;
}
.assist-panel .form-row-1{
    display:grid;
    grid-template-columns: 1fr;
    gap:1rem;
}

/* Inputs and files */
.assist-panel .form-control{
    width:100%;
    padding:.7rem 1rem;
    border:2px solid var(--accent-teal);
    border-radius:10px;
    background:var(--primary-dark);
    color:var(--text-light);
}
.assist-panel .file{
    width:100%;
    padding:.9rem 1rem;
    border:2px dashed var(--accent-teal);
    border-radius:10px;
    background:rgba(33,58,87,.5);
    color:var(--text-light);
}
.assist-panel label{
    display:block;
    font-weight:700;
    margin:0 0 .35rem;
    color:var(--text-light);
}
@media(max-width:992px){
    .assist-panel .form-row{
        grid-template-columns: 1fr; /* stack on smaller screens */
    }
}

    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
<div class="student-dashboard">
    <!-- Sidebar -->
    <div class="student-sidebar">
        <div class="student-profile">
            <asp:Image ID="imgStudentAvatar" runat="server" CssClass="student-avatar" ImageUrl="~/images/student-avatar.jpg" />
            <h3 class="student-name"><asp:Literal ID="litStudentFullName" runat="server" /></h3>
            <p class="student-status">Active Student</p>
        </div>
        <ul class="student-menu">
            <li><a href="StudentDashboard.aspx"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
            <li><a href="StudentMark.aspx"><i class="fas fa-marker"></i> Upload School Report</a></li>
            <li><a href="Scholarships.aspx" class="active"><i class="fas fa-money-check-alt"></i> Scholarships</a></li>
            <li><a href="CareerGuidance.aspx"><i class="fas fa-compass"></i> Career Guidance</a></li>
            <li><a href="StudentMaterials.aspx"><i class="fas fa-book-open"></i> Study Materials</a></li>
            <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
        </ul>
    </div>

    <!-- Content -->
    <div class="student-content">
        <div class="opportunities-container">
            <h2 class="section-title">Scholarship Opportunities</h2>

            <!-- Filters -->
            <div class="filter-section">
                <div class="filter-grid">
                    <asp:DropDownList ID="ddlField" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterScholarships">
                        <asp:ListItem Text="All Fields" Value="" />
                        <asp:ListItem Text="Computer Science" Value="Computer Science" />
                        <asp:ListItem Text="Engineering" Value="Engineering" />
                        <asp:ListItem Text="Biology" Value="Biology" />
                        <asp:ListItem Text="Mathematics" Value="Mathematics" />
                        <asp:ListItem Text="Environmental Science" Value="Environmental Science" />
                    </asp:DropDownList>

                    <asp:DropDownList ID="ddlAmount" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterScholarships">
                        <asp:ListItem Text="Any Amount" Value="" />
                        <asp:ListItem Text="R 1,000+" Value="1000" />
                        <asp:ListItem Text="R 2,500+" Value="2500" />
                        <asp:ListItem Text="R 5,000+" Value="5000" />
                    </asp:DropDownList>

                    <asp:DropDownList ID="ddlDeadline" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterScholarships">
                        <asp:ListItem Text="All Deadlines" Value="" />
                        <asp:ListItem Text="Next 30 Days" Value="30" />
                        <asp:ListItem Text="Next 60 Days" Value="60" />
                        <asp:ListItem Text="Next 90 Days" Value="90" />
                    </asp:DropDownList>
                </div>
            </div>

            <!-- Scholarships list -->
            <div class="scholarships-grid">
                <asp:Repeater ID="rptScholarships" runat="server">
                    <ItemTemplate>
                        <div class="scholarship-card">
                            <div class="scholarship-header">
                                <h3><%# Eval("Name") %></h3>
                                <div class="scholarship-meta">
                                    <span class="scholarship-amount">Amount: <%# Eval("Amount", "{0:C0}") %></span>
                                    <span class="scholarship-deadline">Due: <%# Eval("Deadline", "{0:MMM dd, yyyy}") %></span>
                                </div>
                            </div>
                            <div class="scholarship-body">
                                <div class="scholarship-description"><%# Eval("Description") %></div>
                                <div class="scholarship-tags">
                                    <span class="scholarship-tag"><%# Eval("Field") %></span>
                                    <span class="scholarship-tag"><%# Eval("Type") %></span>
                                </div>
                                <div class="cta-row">
                                    <!-- Opens modal with options -->
                                    <asp:LinkButton ID="btnApply" runat="server" CssClass="cta-btn" Text="Apply"
    OnClientClick='<%# "showApplyModal("
        + Eval("ScholarshipId")
        + ", \"" 
        + HttpUtility.JavaScriptStringEncode(Convert.ToString(Eval("ApplicationUrl") ?? ""))
        + "\"); return false;" %>' />

                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </div>
   <!-- Assistance form panel -->
<div id="assistPanel" class="assist-panel">
    <h3 style="margin-top:0">Assisted Application</h3>
    <p class="helper">Upload required documents and we’ll submit on your behalf.</p>

    <div class="form-row">
        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Full name *" />
        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" placeholder="Email *" />
    </div>
    <div class="form-row">
        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Phone (optional)" />
        <asp:TextBox ID="txtStudentId" runat="server" CssClass="form-control" placeholder="Student ID (optional)" />
    </div>
    <div class="form-row-1">
        <asp:TextBox ID="txtMotivation" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4"
            placeholder="Motivation / Notes (optional)"></asp:TextBox>
    </div>

    <div class="form-row">
        <div>
            <label> Documents(Please combine document into 1 file (PDF/JPG/PNG))</label>
            <asp:FileUpload ID="fuIdDoc" runat="server" CssClass="file" />
        </div>
        
    </div>
   <%-- <div class="form-row">
        <div>
            <label>CV (optional)</label>
            <asp:FileUpload ID="fuCV" runat="server" CssClass="file" />
        </div>
        <div>
            <label>Other (optional)</label>
            <asp:FileUpload ID="fuOther" runat="server" CssClass="file" />
        </div>
    </div>--%>

    <div class="modal-actions" style="margin-top:1rem">
       <asp:Button ID="btnSubmitAssist" runat="server"
    CssClass="cta-btn"
    Text="Submit Documents"
    UseSubmitBehavior="true"
    OnClick="btnSubmitAssist_Click" />

        <a href="#" class="btn-secondary" onclick="hideAssistPanel(); return false;">Cancel</a>
    </div>
</div>

</div>

<!-- Hidden fields used by modal/buttons -->
<asp:HiddenField ID="hfApplyScholarshipId" runat="server" />
<asp:HiddenField ID="hfApplyUrl" runat="server" />

<!-- Apply choice modal -->
<div id="applyModal" class="modal-backdrop">
    <div class="modal">
        <h3>How would you like to apply?</h3>
        <p class="helper">Choose to go directly to the scholarship website, or get assistance by uploading your documents here.</p>
        <div class="modal-actions">
            <button type="button" class="cta-btn" onclick="goToWebsite(); return false;">Go to Website</button>
            <asp:LinkButton ID="btnShowAssist" runat="server" CssClass="btn-secondary"
                CausesValidation="false" OnClick="btnShowAssist_Click" Text="Get Assistance (Upload Docs)" />
        </div>
        <div style="margin-top:.75rem;text-align:right">
            <a href="#" onclick="closeApplyModal(); return false;" style="color:#fff;opacity:.8">Close</a>
        </div>
    </div>
</div>



<div id="toast" class="toast"></div>

<script>
  function showApplyModal(id, url){
    document.getElementById('<%= hfApplyScholarshipId.ClientID %>').value = id || '';
    document.getElementById('<%= hfApplyUrl.ClientID %>').value = url || '';
        document.getElementById('applyModal').style.display = 'flex';
    }
    function closeApplyModal() { document.getElementById('applyModal').style.display = 'none'; }
    function showAssistPanel() {
        closeApplyModal();
        document.getElementById('assistPanel').style.display = 'block';
        window.scrollTo({ top: document.getElementById('assistPanel').offsetTop - 20, behavior: 'smooth' });
    }
    function hideAssistPanel() { document.getElementById('assistPanel').style.display = 'none'; }
    function showToast(msg) {
        const el = document.getElementById('toast');
        el.textContent = msg;
        el.style.display = 'block';
        setTimeout(() => { el.style.display = 'none'; }, 3200);
    }
    function normalizeUrl(u) {
        if (!u) return '';
        u = u.trim();
        if (!/^https?:\/\//i.test(u)) {
            u = 'https://' + u.replace(/^\/+/, '');
        }
        return u;
    }

    function goToWebsite() {
        var url = normalizeUrl(document.getElementById('<%= hfApplyUrl.ClientID %>').value || '');
      if (!url) {
          showToast('No website link for this scholarship.');
          return;
      }
      // Try a new tab; if blocked by the browser, fall back to same tab
      var win = window.open(url, '_blank', 'noopener');
      if (!win) window.location.href = url;
  }
</script>
</asp:Content>
