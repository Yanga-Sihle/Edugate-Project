<%@ Page Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true"
    CodeBehind="Research.aspx.cs" Inherits="Edugate_Project.Research" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Your CSS styles here (omitted for brevity) */
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="research-container">
        <div class="container">
            <div class="research-hero">
                <h1>Research Opportunities</h1>
                <p>Discover hands-on research experiences to enhance your academic journey</p>
            </div>

            <%-- IMPORTANT: Add this form tag --%>
            

                <div class="filter-section">
                    <h2>🔍 Filter Research Opportunities</h2>
                    <div class="filter-grid">
                        <div class="filter-group">
                            <label for="ddlField">Research Area</label>
                            <asp:DropDownList ID="ddlField" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterResearch">
                                <asp:ListItem Text="All Areas" Value="" />
                                <asp:ListItem Text="Artificial Intelligence" Value="Artificial Intelligence" />
                                <asp:ListItem Text="Biotechnology" Value="Biotechnology" />
                                <asp:ListItem Text="Environmental Science" Value="Environmental Science" />
                                <asp:ListItem Text="Quantum Computing" Value="Quantum Computing" />
                                <asp:ListItem Text="Renewable Energy" Value="Renewable Energy" />
                                <asp:ListItem Text="Data Science" Value="Data Science" />
                                <asp:ListItem Text="Neuroscience" Value="Neuroscience" />
                            </asp:DropDownList>
                        </div>
                        <div class="filter-group">
                            <label for="ddlType">Opportunity Type</label>
                            <asp:DropDownList ID="ddlType" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterResearch">
                                <asp:ListItem Text="All Types" Value="" />
                                <asp:ListItem Text="Summer Research" Value="Summer" />
                                <asp:ListItem Text="Academic Year" Value="Academic Year" />
                                <asp:ListItem Text="Paid Internship" Value="Paid Internship" />
                                <asp:ListItem Text="Volunteer" Value="Volunteer" />
                                <asp:ListItem Text="Remote" Value="Remote" />
                            </asp:DropDownList>
                        </div>
                        <div class="filter-group">
                            <label for="ddlDeadline">Application Deadline</label>
                            <asp:DropDownList ID="ddlDeadline" runat="server" CssClass="filter-control" AutoPostBack="true" OnSelectedIndexChanged="FilterResearch">
                                <asp:ListItem Text="All Deadlines" Value="" />
                                <asp:ListItem Text="Next 30 Days" Value="30" />
                                <asp:ListItem Text="Next 60 Days" Value="60" />
                                <asp:ListItem Text="Next 90 Days" Value="90" />
                                <asp:ListItem Text="Rolling Basis" Value="rolling" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <asp:Panel ID="pnlNoResults" runat="server" CssClass="no-results" Visible="false">
                    <p>No research opportunities match your current filters. Try adjusting your search criteria.</p>
                </asp:Panel>

                <div class="research-grid">
                    <asp:Repeater ID="rptResearch" runat="server">
                        <ItemTemplate>
                            <div class="research-card">
                                <div class="research-header">
                                    <h3><%# Eval("Title") %></h3>
                                    <div class="research-meta">
                                        <span><i class="fas fa-university"></i> <%# Eval("Institution") %></span>
                                        <span class="research-deadline">
                                            <i class="far fa-calendar-alt"></i> <%# Eval("Deadline", "{0:MMM dd,yyyy}") %>
                                        </span>
                                    </div>
                                </div>
                                <div class="research-body">
                                    <div class="research-description">
                                        <%# Eval("Description") %>
                                    </div>
                                    <div class="research-tags">
                                        <span class="research-tag"><i class="fas fa-flask"></i> <%# Eval("Field") %></span>
                                        <span class="research-tag"><i class="fas fa-clock"></i> <%# Eval("Duration") %></span>
                                        <span class="research-tag"><i class="fas fa-map-marker-alt"></i> <%# Eval("Location") %></span>
                                    </div>
                                    <div class="button-group">
                                        <a href='<%# Eval("ApplicationUrl") %>' class="cta-btn" target="_blank">
                                            <i class="fas fa-external-link-alt"></i> Apply Now
                                        </a>
                                        <asp:Button ID="btnSave" runat="server" Text="Save Opportunity"
                                            CssClass="cta-btn" style="background: #95a5a6; margin-top: 0.5rem;"
                                            CommandArgument='<%# Eval("Id") %>' OnCommand="SaveOpportunity" />
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <div class="pagination" id="paginationContainer" runat="server" visible="false">
                    <asp:Button ID="btnPrev" runat="server" Text="Previous" CssClass="page-btn" OnClick="PageChange" CommandArgument="prev" />
                    <asp:Repeater ID="rptPageNumbers" runat="server">
                        <ItemTemplate>
                            <asp:Button ID="btnPage" runat="server" Text='<%# Container.DataItem %>'
                                CssClass='<%# (Container.DataItem.ToString() == CurrentPage.ToString()) ? "page-btn active" : "page-btn" %>'
                                OnClick="PageChange" CommandArgument='<%# Container.DataItem %>' />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Button ID="btnNext" runat="server" Text="Next" CssClass="page-btn" OnClick="PageChange" CommandArgument="next" />
                </div>



        </div>
    </div>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" />
</asp:Content>