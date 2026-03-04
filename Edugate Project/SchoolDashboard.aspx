<%@ Page Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true" CodeBehind="SchoolDashboard.aspx.cs" Inherits="Edugate_Project.SchoolDashboard" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>School Dashboard - Edugate STEM</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap" rel="stylesheet" />
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
        .status-active{display:inline-block;padding:.25rem .75rem;background-color:rgba(69,223,177,.2);color:var(--accent-green);border-radius:9999px;font-size:.85rem;font-weight:600}
        .status-inactive{display:inline-block;padding:.25rem .75rem;background-color:rgba(108,117,125,.2);color:var(--text-light);border-radius:9999px;font-size:.85rem;font-weight:600}
        .status-pending{display:inline-block;padding:.25rem .75rem;background-color:rgba(255,193,7,.2);color:#ffc107;border-radius:9999px;font-size:.85rem;font-weight:600}
        .file-upload-input{width:.1px;height:.1px;opacity:0;overflow:hidden;position:absolute;z-index:-1}
        .status-message{display:block;margin-top:1rem;padding:.75rem;border-radius:.5rem;font-weight:600}
        .status-success{background-color:rgba(69,223,177,.2);color:var(--accent-green);border:1px solid var(--accent-green)}
        .status-error{background-color:rgba(255,107,107,.2);color:#ff6b6b;border:1px solid #ff6b6b}
        @media (max-width: 768px){
            .sidebar { transform: translateX(-100%); }
            .sidebar.open { transform: translateX(0); }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="min-h-screen flex bg-[var(--primary-dark)] text-[var(--text-light)] font-[Inter]">
        <!-- Sidebar -->
        <aside class="sidebar w-72 shrink-0 bg-gradient-to-br from-[var(--primary-orange)] to-[var(--accent-teal)] text-white p-6 border-r border-[var(--accent-green)] shadow-2xl fixed md:static inset-y-0 left-0 z-40 transition-transform duration-300">
            <div class="flex items-center gap-3 pb-6 border-b border-white/10">
                <div class="w-10 h-10 rounded-xl bg-white/10 grid place-items-center">
                    <i class="fas fa-school text-white"></i>
                </div>
                <span class="text-xl font-extrabold tracking-wide">Edugate STEM</span>
            </div>

            <div class="pt-6 pb-4">
                <div class="flex flex-col items-center text-center">
                    <asp:Image ID="imgSchoolLogo" runat="server" CssClass="w-20 h-20 rounded-full object-cover border-4 border-[var(--accent-green)] shadow" ImageUrl="~/images/school-avatar.jpg" />
                    <h3 class="mt-3 text-base font-bold text-[var(--text-light)]">
                        <asp:Label ID="lblSchoolName" runat="server" Text="School Name"></asp:Label>
                    </h3>
                    <p class="text-sm text-[var(--accent-light-green)]">
                        <asp:Label ID="lblSubscriptionStatus" runat="server" Text="Standard"></asp:Label>
                    </p>
                </div>
            </div>

            <nav class="mt-4 space-y-1">
                <a href="#" class="flex items-center gap-3 px-3 py-2 rounded-lg bg-white/10 text-white"
                   onclick="openTab(event,'overview-tab'); return false;">
                    <i class="fas fa-tachometer-alt w-5 text-center"></i><span class="font-medium">Dashboard</span>
                </a>
                <a href="#" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/10"
                   onclick="openTab(event,'learners-tab'); return false;">
                    <i class="fas fa-users w-5 text-center"></i><span>Learners</span>
                </a>
                <a href="#" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/10"
                   onclick="openTab(event,'subscription-tab'); return false;">
                    <i class="fas fa-crown w-5 text-center"></i><span>Subscription</span>
                </a>
                <a href="#" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/10"
                   onclick="openTab(event,'profile-tab'); return false;">
                    <i class="fas fa-user-edit w-5 text-center"></i><span>Edit Profile</span>
                </a>
               
                <a href="Default.aspx" class="flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-white/10">
                    <i class="fas fa-sign-out-alt w-5 text-center"></i><span>Logout</span>
                </a>
            </nav>
        </aside>

        <!-- Main content -->
        <div class="flex-1 md:ml-0 ml-0 md:pl-0 pl-0 md:static md:translate-x-0 translate-x-72 md:translate-x-0 w-full">
            <header class="sticky top-0 z-30 bg-[rgba(33,58,87,0.7)] backdrop-blur border-b border-[var(--accent-teal)] px-6 py-4 flex items-center justify-between">
                <h1 class="text-2xl font-extrabold tracking-tight">School Dashboard</h1>
                <button class="md:hidden inline-flex items-center gap-2 rounded-lg px-3 py-2 bg-white/10 hover:bg-white/20"
                        onclick="document.querySelector('.sidebar').classList.toggle('open')">
                    <i class="fas fa-bars"></i><span>Menu</span>
                </button>
            </header>

            <main class="p-6 bg-[rgba(33,58,87,0.7)] min-h-screen border-l border-[var(--accent-teal)]">
                <!-- Tabs -->
                <div class="border-b border-[var(--accent-teal)] mb-6 flex flex-wrap">
                    <button class="tab-btn active py-3 px-4 text-sm font-semibold text-[var(--accent-green)] border-b-2 border-[var(--accent-green)] mr-2"
                            onclick="openTab(event,'overview-tab'); return false;">Overview</button>
                    <button class="tab-btn py-3 px-4 text-sm font-semibold hover:text-[var(--accent-green)] mr-2"
                            onclick="openTab(event,'learners-tab'); return false;">Learners</button>
                    <button class="tab-btn py-3 px-4 text-sm font-semibold hover:text-[var(--accent-green)] mr-2"
                            onclick="openTab(event,'subscription-tab'); return false;">Subscription</button>
                    <button class="tab-btn py-3 px-4 text-sm font-semibold hover:text-[var(--accent-green)] mr-2"
                            onclick="openTab(event,'profile-tab'); return false;">Edit Profile</button>
                </div>

                <!-- OVERVIEW -->
                <div id="overview-tab" class="tab-content active">
                    <div class="grid gap-6 grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 mb-8">
                        <div class="bg-[rgba(33,58,87,0.8)] rounded-2xl p-6 border border-[var(--accent-teal)] shadow"><div class="text-3xl font-extrabold text-[var(--accent-green)]"><asp:Label ID="lblTotalLearners" runat="server" Text="0"></asp:Label></div><div class="text-[var(--accent-light-green)]">Total Learners</div></div>
                        <div class="bg-[rgba(33,58,87,0.8)] rounded-2xl p-6 border border-[var(--accent-teal)] shadow"><div class="text-3xl font-extrabold text-[var(--accent-green)]"><asp:Label ID="lblActiveLearners" runat="server" Text="0"></asp:Label></div><div class="text-[var(--accent-light-green)]">Active Learners</div></div>
                        <div class="bg-[rgba(33,58,87,0.8)] rounded-2xl p-6 border border-[var(--accent-teal)] shadow"><div class="text-3xl font-extrabold text-[var(--accent-green)]"><asp:Label ID="lblTeachers" runat="server" Text="0"></asp:Label></div><div class="text-[var(--accent-light-green)]">Teachers</div></div>
                        <div class="bg-[rgba(33,58,87,0.8)] rounded-2xl p-6 border border-[var(--accent-teal)] shadow"><div class="text-3xl font-extrabold text-[var(--accent-green)]"><asp:Label ID="lblSubjects" runat="server" Text="0"></asp:Label></div><div class="text-[var(--accent-light-green)]">Subjects</div></div>
                    </div>

                    <h3 class="text-xl font-bold mb-4">Recent Activity</h3>
                    <div class="overflow-x-auto rounded-2xl border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.8)]">
                        <asp:GridView ID="gvRecentActivity" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="min-w-full"
                            AllowPaging="true" PageSize="5" OnPageIndexChanging="gvRecentActivity_PageIndexChanging">
                            <Columns>
                                <asp:BoundField DataField="ActivityDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                                <asp:BoundField DataField="ActivityType" HeaderText="Activity" />
                                <asp:BoundField DataField="Description" HeaderText="Details" />
                                <asp:BoundField DataField="User" HeaderText="User" />
                            </Columns>
                            <HeaderStyle CssClass="text-left bg-[rgba(20,145,155,0.3)] text-[var(--text-light)] font-bold" />
                            <RowStyle CssClass="border-b border-white/10" />
                            <PagerStyle CssClass="p-3" />
                            <EmptyDataTemplate><div class="text-center p-6 text-[var(--accent-green)]">No recent activity found.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

                <!-- LEARNERS -->
                <div id="learners-tab" class="tab-content hidden">
                    <div class="overflow-x-auto rounded-2xl border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.8)]">
                        <asp:GridView ID="gvLearners" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="min-w-full"
                            AllowPaging="true" PageSize="10" OnPageIndexChanging="gvLearners_PageIndexChanging">
                            <Columns>
                                <asp:BoundField DataField="StudentId" HeaderText="ID" />
                                <asp:BoundField DataField="FullName" HeaderText="Full Name" />
                                <asp:BoundField DataField="Email" HeaderText="Email" />
                                <asp:BoundField DataField="Grade" HeaderText="Grade" />
                                <asp:BoundField DataField="LastLogin" HeaderText="Last Login" DataFormatString="{0:dd MMM yyyy}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='<%# Eval("IsActive").ToString() == "1" ? "status-active" : "status-inactive" %>'>
                                            <%# Eval("IsActive").ToString() == "1" ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <HeaderStyle CssClass="text-left bg-[rgba(20,145,155,0.3)] text-[var(--text-light)] font-bold" />
                            <RowStyle CssClass="border-b border-white/10" />
                            <PagerStyle CssClass="p-3" />
                            <EmptyDataTemplate><div class="text-center p-6 text-[var(--accent-green)]">No learners found.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>

                <!-- SUBSCRIPTION -->
                <asp:UpdatePanel ID="upSubscription" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div id="subscription-tab" class="tab-content hidden">
                            <div class="rounded-2xl border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.8)] p-6 shadow">
                                <div id="subscriptionStatus" runat="server"
                                     class="inline-flex items-center px-4 py-2 rounded-full bg-[rgba(69,223,177,.2)] text-[var(--accent-green)] font-bold mb-4">
                                    <i class="fas fa-crown mr-2"></i>
                                    <asp:Label ID="lblCurrentSubscription" runat="server" Text="Standard Subscription"></asp:Label>
                                </div>

                                <h3 class="text-lg font-bold mb-3">
                                    <asp:Label ID="lblSubscriptionTitle" runat="server" Text="Subscription Benefits"></asp:Label>
                                </h3>

                                <div class="grid sm:grid-cols-2 gap-3 mb-6">
                                    <div class="flex items-center gap-3"><i class="fas fa-check-circle text-[var(--accent-green)]"></i><span>Access to study materials</span></div>
                                    <div class="flex items-center gap-3"><i class="fas fa-check-circle text-[var(--accent-green)]"></i><span>Reports & analytics</span></div>
                                    <div class="flex items-center gap-3"><i class="fas fa-check-circle text-[var(--accent-green)]"></i><span>Priority support</span></div>
                                    <div class="flex items-center gap-3"><i class="fas fa-check-circle text-[var(--accent-green)]"></i><span>Custom branding</span></div>
                                </div>

                                <div id="subscriptionActions" runat="server" class="flex flex-wrap gap-3">
                                    <asp:Button ID="btnUpgrade" runat="server" Text="Upgrade to Premium"
                                        CssClass="px-5 py-2 rounded-full font-bold bg-[var(--accent-green)] text-[var(--primary-dark)] hover:bg-[var(--primary-dark)] hover:text-[var(--accent-green)] transition"
                                        OnClick="btnUpgrade_Click"
                                        OnClientClick="return confirm('Are you sure you want to upgrade to Premium?');" />
                                    <asp:Button ID="btnDowngrade" runat="server" Text="Downgrade to Standard"
                                        CssClass="px-5 py-2 rounded-full font-bold border border-[var(--accent-green)] text-[var(--accent-green)] hover:bg-[rgba(69,223,177,.1)] transition"
                                        OnClick="btnDowngrade_Click"
                                        OnClientClick="return confirm('Are you sure you want to downgrade to Standard?');" />
                                </div>

                                <!-- Payment Upload -->
                                <div id="paymentUploadSection" runat="server" visible="True" class="mt-6 pt-6 border-t border-[var(--accent-teal)]">
                                    <h4 class="font-bold mb-1">Upload Proof of Payment</h4>
                                    <p class="text-sm opacity-80">Please upload your bank transfer confirmation or payment receipt (PDF, JPG, PNG).</p>

                                    <div class="mt-4">
                                        <asp:FileUpload ID="fileProofOfPayment" runat="server" CssClass="file-upload-input" onchange="updateFileName(this)" />
                                        <label for="<%= fileProofOfPayment.ClientID %>"
                                               class="block w-full text-center p-6 border-2 border-dashed rounded-xl cursor-pointer transition
                                                      border-[var(--accent-teal)] hover:border-[var(--accent-green)] bg-[rgba(33,58,87,0.5)] hover:bg-[rgba(69,223,177,0.1)]">
                                            <i class="fas fa-cloud-upload-alt text-2xl text-[var(--accent-green)] mb-2 block"></i>
                                            <span class="font-semibold">Choose payment proof document</span>
                                            <small class="block opacity-80">(Max 5MB - PDF, JPG, PNG)</small>
                                        </label>
                                        <div class="mt-2 text-sm text-[var(--accent-light-green)]">
                                            <asp:Label ID="lblPaymentFileName" runat="server" Text="No file selected"></asp:Label>
                                        </div>
                                    </div>

                                    <asp:Button ID="btnUploadPayment" runat="server" Text="Submit Payment Proof"
                                        CssClass="mt-4 px-5 py-2 rounded-full font-bold bg-[var(--accent-green)] text-[var(--primary-dark)] hover:bg-[var(--primary-dark)] hover:text-[var(--accent-green)] transition"
                                        OnClick="btnUploadPayment_Click" />

                                    <asp:Label ID="lblUploadMessage" runat="server" Text="" CssClass="status-message hidden" Visible="false"></asp:Label>
                                </div>

                                <!-- Payment Status -->
                                <div id="paymentStatusSection" runat="server" class="mt-6">
                                    <h4 class="font-bold">Payment Status</h4>
                                    <div class="mt-1 mb-3"><asp:Label ID="lblPaymentStatus" runat="server" Text=""></asp:Label></div>

                                    <div class="overflow-x-auto rounded-2xl border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.8)]">
                                        <asp:GridView ID="gvPaymentHistory" runat="server" AutoGenerateColumns="false" GridLines="None" CssClass="min-w-full">
                                            <Columns>
                                                <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice #" />
                                                <asp:BoundField DataField="OriginalFileName" HeaderText="File Name" />
                                                <asp:BoundField DataField="SubmissionDate" HeaderText="Date" DataFormatString="{0:dd MMM yyyy}" />
                                                <asp:BoundField DataField="PaymentMethod" HeaderText="Method" />
                                                <asp:TemplateField HeaderText="Status">
                                                    <ItemTemplate>
                                                        <span class='<%# Eval("Status").ToString() == "Verified" ? "status-active" : "status-pending" %>'>
                                                            <%# Eval("Status") %>
                                                        </span>
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                                <asp:BoundField DataField="VerificationDate" HeaderText="Verified On" DataFormatString="{0:dd MMM yyyy}" />
                                            </Columns>
                                            <HeaderStyle CssClass="text-left bg-[rgba(20,145,155,0.3)] text-[var(--text-light)] font-bold" />
                                            <RowStyle CssClass="border-b border-white/10" />
                                            <EmptyDataTemplate><div class="text-center p-6 text-[var(--accent-green)]">No payment history found.</div></EmptyDataTemplate>
                                        </asp:GridView>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnUploadPayment" />
                    </Triggers>
                </asp:UpdatePanel>

                <!-- PROFILE -->
                <asp:UpdatePanel ID="upProfile" runat="server" UpdateMode="Conditional">
                    <ContentTemplate>
                        <div id="profile-tab" class="tab-content hidden">
                            <div class="rounded-2xl border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.8)] p-6 shadow">
                                <h3 class="text-lg font-bold mb-4">Edit School Profile</h3>

                                <div class="grid md:grid-cols-2 gap-6">
                                    <div class="space-y-4">
                                        <div>
                                            <label for="txtSchoolName" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">School Name</label>
                                            <asp:TextBox ID="txtSchoolName" runat="server" CssClass="w-full rounded-lg border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.5)] px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--accent-green)]" MaxLength="100"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="rfvSchoolName" runat="server" ControlToValidate="txtSchoolName"
                                                ErrorMessage="School name is required" Display="Dynamic" CssClass="status-error mt-2 block" ValidationGroup="Profile"></asp:RequiredFieldValidator>
                                        </div>

                                        <div>
                                            <label for="txtEmail" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">Email Address</label>
                                            <asp:TextBox ID="txtEmail" runat="server" CssClass="w-full rounded-lg border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.5)] px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--accent-green)]" TextMode="Email" MaxLength="100"></asp:TextBox>
                                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                                ErrorMessage="Email is required" Display="Dynamic" CssClass="status-error mt-2 block" ValidationGroup="Profile"></asp:RequiredFieldValidator>
                                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                                ErrorMessage="Please enter a valid email address" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                                Display="Dynamic" CssClass="status-error mt-2 block" ValidationGroup="Profile"></asp:RegularExpressionValidator>
                                        </div>

                                        <div>
                                            <label for="txtPhone" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">Phone Number</label>
                                            <asp:TextBox ID="txtPhone" runat="server" CssClass="w-full rounded-lg border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.5)] px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--accent-green)]" MaxLength="20"></asp:TextBox>
                                        </div>
                                    </div>

                                    <div class="space-y-4">
                                        <div>
                                            <label for="txtAddress" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">Address</label>
                                            <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3"
                                                CssClass="w-full rounded-lg border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.5)] px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--accent-green)]" MaxLength="200"></asp:TextBox>
                                        </div>

                                        <div>
                                            <label for="ddlGradeLevel" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">Grade Level</label>
                                            <asp:DropDownList ID="ddlGradeLevel" runat="server"
                                                CssClass="w-full rounded-lg border border-[var(--accent-teal)] bg-[rgba(33,58,87,0.5)] px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[var(--accent-green)]">
                                                <asp:ListItem Value="">Select Grade Level</asp:ListItem>
                                                <asp:ListItem Value="Primary">Primary School</asp:ListItem>
                                                <asp:ListItem Value="Secondary">Secondary School</asp:ListItem>
                                                <asp:ListItem Value="High">High School</asp:ListItem>
                                                <asp:ListItem Value="Combined">Combined School</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>

                                        <div>
                                            <label for="fileSchoolLogo" class="block text-sm font-semibold text-[var(--accent-light-green)] mb-1">School Logo</label>
                                            <asp:FileUpload ID="fileSchoolLogo" runat="server" CssClass="file-upload-input" onchange="previewLogo(this)" />
                                            <label for="<%= fileSchoolLogo.ClientID %>"
                                                   class="block w-full text-center p-6 border-2 border-dashed rounded-xl cursor-pointer transition
                                                          border-[var(--accent-teal)] hover:border-[var(--accent-green)] bg-[rgba(33,58,87,0.5)] hover:bg-[rgba(69,223,177,0.1)]">
                                                <i class="fas fa-image text-2xl text-[var(--accent-green)] mb-2 block"></i>
                                                <span class="font-semibold">Upload School Logo</span>
                                                <small class="block opacity-80">(Max 2MB - JPG, PNG)</small>
                                            </label>
                                            <asp:Image ID="imgLogoPreview" runat="server" CssClass="w-30 h-30 rounded-lg object-cover border-2 border-[var(--accent-teal)] mt-2 hidden" Visible="false" />
                                            <asp:HiddenField ID="hfLogoChanged" runat="server" Value="false" />
                                        </div>
                                    </div>
                                </div>

                                <div class="mt-6 pt-6 border-t border-[var(--accent-teal)] flex flex-wrap gap-3">
                                    <asp:Button ID="btnSaveProfile" runat="server" Text="Save Changes"
                                        CssClass="px-5 py-2 rounded-full font-bold bg-[var(--accent-green)] text-[var(--primary-dark)] hover:bg-[var(--primary-dark)] hover:text-[var(--accent-green)] transition"
                                        OnClick="btnSaveProfile_Click" ValidationGroup="Profile" />
                                    <asp:Button ID="btnCancel" runat="server" Text="Cancel"
                                        CssClass="px-5 py-2 rounded-full font-bold border border-[var(--accent-green)] text-[var(--accent-green)] hover:bg-[rgba(69,223,177,.1)] transition"
                                        OnClick="btnCancel_Click" CausesValidation="false" />
                                </div>

                                <asp:Label ID="lblProfileMessage" runat="server" Text="" CssClass="status-message hidden" Visible="false"></asp:Label>
                            </div>
                        </div>
                    </ContentTemplate>
                    <Triggers>
                        <asp:PostBackTrigger ControlID="btnSaveProfile" />
                    </Triggers>
                </asp:UpdatePanel>
            </main>
        </div>
    </div>

    <script>
        function openTab(evt, tabId) {
            const contents = document.querySelectorAll('.tab-content');
            const tabs = document.querySelectorAll('.tab-btn');
            contents.forEach(el => el.classList.add('hidden'));
            tabs.forEach(el => { el.classList.remove('active','text-[var(--accent-green)]','border-b-2','border-[var(--accent-green)]'); });
            document.getElementById(tabId).classList.remove('hidden');
            evt.currentTarget.classList.add('active','text-[var(--accent-green)]','border-b-2','border-[var(--accent-green)]');
            // remember tab
            try { sessionStorage.setItem('activeTab', tabId); } catch(e){}
        }
        function updateFileName(input) {
            var fileName = input.files.length > 0 ? input.files[0].name : "No file selected";
            var lbl = document.getElementById("<%= lblPaymentFileName.ClientID %>");
            if (lbl) lbl.innerText = fileName;
        }
        function previewLogo(input) {
            var preview = document.getElementById("<%= imgLogoPreview.ClientID %>");
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    preview.src = e.target.result;
                    preview.style.display = "block";
                    preview.classList.remove('hidden');
                }
                reader.readAsDataURL(input.files[0]);
            } else {
                preview.style.display = "none";
                preview.classList.add('hidden');
            }
        }
    </script>
</asp:Content>
