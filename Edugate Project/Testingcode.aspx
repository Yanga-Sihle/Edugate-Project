<%@ Page Language="C#" MasterPageFile="~/Admin.Master" AutoEventWireup="true"
    CodeBehind="Testingcode.aspx.cs" Inherits="Edugate_Project.Testingcode" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.3/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.3/font/bootstrap-icons.min.css"/>

    <style>
        :root{
            --bg:#0e0f13;
            --panel:#151822;
            --panel-2:#1b1f2d;
            --text:#e7e9ee;
            --muted:#a3a7b3;
            --brand:#8c73ff;
            --accent:#7d5cff;
            --border:#2a2f40;
            --good:#27c498;
            --warn:#ffb020;
            --bad:#ff597a;
        }
        html, body{height:100%;}
        body{
            background: radial-gradient(1200px 600px at -15% -10%, #1a1f33 0%, var(--bg) 50%) fixed;
            color:var(--text);
            font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial, "Apple Color Emoji","Segoe UI Emoji";
        }

        /* Layout */
        .app{
            display:flex;
            min-height: calc(100vh - 0px);
        }
        .sidebar{
            width:280px;
            background: linear-gradient(180deg, #121422 0%, #0e0f13 100%);
            border-right:1px solid var(--border);
            padding:22px 16px;
            position:sticky; top:0; height:100vh;
        }
        .brand{
            display:flex; align-items:center; gap:10px;
            font-weight:800; letter-spacing:.3px; color:var(--text); margin-bottom:20px;
        }
        .brand i{
            background:linear-gradient(135deg,var(--brand),#5ee7ff);
            color:#0e0f13; border-radius:12px; width:40px; height:40px; display:grid; place-items:center; font-size:1.2rem;
        }
        .side-section-title{
            color:var(--muted); font-size:.78rem; letter-spacing:.12em; text-transform:uppercase; margin:14px 10px 8px;
        }
        .nav-vertical .nav-link{
            color:var(--muted);
            padding:10px 12px; border-radius:10px;
            display:flex; align-items:center; gap:10px;
            transition: all .15s ease;
        }
        .nav-vertical .nav-link:hover{ color:var(--text); background:var(--panel-2); }
        .nav-vertical .nav-link.active{
            color:#fff; background:linear-gradient(180deg, #23263a 0%, #181b2a 100%);
            border:1px solid var(--border);
            box-shadow: 0 0 0 1px rgba(140,115,255,.15) inset, 0 10px 20px rgba(0,0,0,.25);
        }

        .upgrade{
            margin-top:auto; background:linear-gradient(180deg, #1d2133 0%, #121420 100%);
            border:1px dashed #2f3652; border-radius:16px; padding:16px; color:var(--muted);
        }
        .upgrade .btn{ background:var(--brand); border:none; border-radius:999px; padding:8px 14px; }

        .content{
            flex:1; padding:24px 28px 40px; min-width:0;
        }

        /* Top bar */
        .topbar{
            display:flex; align-items:center; gap:16px; justify-content:space-between; flex-wrap:wrap;
        }
        .welcome{
            font-weight:700; color:#fff; font-size:1.25rem;
        }
        .subtitle{ color:var(--muted); font-size:.9rem;}
        .search{
            display:flex; gap:8px; align-items:center;
            background:var(--panel); border:1px solid var(--border); border-radius:999px; padding:6px 10px;
            min-width:280px;
        }
        .search input{
            background:transparent; border:none; color:var(--text); outline:none; width:230px;
        }
        .btn-primary{
            --bs-btn-bg: var(--brand);
            --bs-btn-border-color: var(--brand);
            --bs-btn-hover-bg: #7a60ff;
            --bs-btn-hover-border-color: #7a60ff;
            border-radius:999px;
        }

        /* Cards */
        .card-dark{
            background: linear-gradient(180deg, #161a27 0%, #121522 100%);
            border:1px solid var(--border); border-radius:16px; color:var(--text);
        }
        .card-dark .card-header{
            background:transparent; border-bottom:1px solid var(--border); color:var(--muted); font-weight:600;
        }
        .tiny-muted{ color:var(--muted); font-size:.85rem;}

        /* Stat tiles */
        .stat-tile{
            display:flex; gap:12px; align-items:center; padding:16px;
            background: #121522; border:1px solid var(--border); border-radius:14px; height:100%;
        }
        .stat-icon{
            width:42px; height:42px; border-radius:12px; display:grid; place-items:center; font-size:1.1rem;
            background:linear-gradient(135deg, #242944 0%, #1b1f33 100%); color:var(--brand);
            box-shadow: inset 0 0 0 1px #2a2f40;
        }
        .stat-kpi{ font-weight:800; color:#fff; margin:0; line-height:1;}
        .stat-label{ color:var(--muted); font-size:.8rem; margin:0;}

        /* Risk gauge */
        .gauge{
            width:210px; aspect-ratio:1; border-radius:50%;
            display:grid; place-items:center; position:relative;
            background:
                radial-gradient(closest-side, #0e0f13 74%, transparent 75% 100%),
                conic-gradient(var(--gauge-color,#ffa756) calc(var(--val,0) * 1%), #2a2f40 0);
            border:1px solid var(--border);
        }
        .gauge::after{
            content: attr(data-label);
            position:absolute; font-size:2rem; font-weight:800; color:#fff;
        }
        .gauge-ring{
            position:absolute; inset:12px; border-radius:50%; border:8px solid #0f1322; pointer-events:none;
            box-shadow: inset 0 0 0 1px #2a2f40;
        }
        .score-scale{
            display:flex; justify-content:space-between; font-size:.75rem; color:var(--muted); margin-top:10px;
        }

        /* Charts */
        .chart-wrap{ height:280px; }
        #threatsByVirusChart, #threatsByDeviceChart{ height:240px !important; }

        /* Table */
        .table-dark{ --bs-table-bg: #0f1320; --bs-table-border-color: #27304a; --bs-table-color: #e7e9ee; }
        .table-dark thead th{ color:#9aa3b2; font-weight:600; }
        .table-dark tbody tr{ border-color:#222a40; }
        .table-dark tbody tr:hover{ background:#141a2d; }

        /* Responsive */
        @media (max-width: 1200px){
            .sidebar{width:230px;}
        }
        @media (max-width: 992px){
            .sidebar{display:none;}
            .content{padding:18px;}
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="app">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="brand">
                <i class="bi-shield-lock-fill"></i>
                <span>VertexGuard</span>
            </div>

            <div class="side-section-title">General</div>
            <nav class="nav flex-column nav-vertical">
                <a class="nav-link active" href="#"><i class="bi-grid"></i> Overview</a>
                <a class="nav-link" href="#"><i class="bi-exclamation-triangle"></i> Issues</a>
                <a class="nav-link" href="#"><i class="bi-folder2"></i> Files</a>
                <a class="nav-link" href="#"><i class="bi-graph-up"></i> Reports</a>
                <a class="nav-link" href="#"><i class="bi-shield"></i> Threats</a>
                <a class="nav-link" href="#"><i class="bi-gear"></i> Settings</a>
            </nav>

            <div class="upgrade mt-4">
                <div class="fw-semibold mb-1">Additional features</div>
                <div class="tiny-muted mb-3">Enhance your security posture with automation & analytics.</div>
                <a href="#" class="btn btn-sm btn-primary w-100">Upgrade</a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="content">
            <!-- Top bar -->
            <div class="topbar mb-3">
                <div>
                    <div class="welcome">Welcome! <asp:Label ID="lblUserName" runat="server" Text="Kathryn Murphy"></asp:Label></div>
                    <div class="subtitle">Security is a process, not a product.</div>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <div class="search">
                        <i class="bi-search tiny-muted"></i>
                        <asp:TextBox ID="txtSearch" runat="server" placeholder="Search Here"></asp:TextBox>
                    </div>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" />
                </div>
            </div>

            <!-- KPIs + Gauge -->
            <div class="row g-3 align-items-stretch">
                <div class="col-xxl-9">
                    <div class="row g-3">
                        <!-- Stat tiles -->
                        <div class="col-6 col-md-4 col-xl-2">
                            <div class="stat-tile">
                                <div class="stat-icon"><i class="bi-bug-fill"></i></div>
                                <div>
                                    <p class="stat-kpi"><asp:Label ID="lblTotalThreats" runat="server" Text="132%"></asp:Label></p>
                                    <p class="stat-label">Total Threats</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-4 col-xl-2">
                            <div class="stat-tile">
                                <div class="stat-icon"><i class="bi-camera-video"></i></div>
                                <div>
                                    <p class="stat-kpi"><asp:Label ID="lblVideoRisk" runat="server" Text="16%"></asp:Label></p>
                                    <p class="stat-label">Video File Risk</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-4 col-xl-2">
                            <div class="stat-tile">
                                <div class="stat-icon"><i class="bi-image"></i></div>
                                <div>
                                    <p class="stat-kpi">43%</p>
                                    <p class="stat-label">Image File Risk</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-4 col-xl-2">
                            <div class="stat-tile">
                                <div class="stat-icon"><i class="bi-file-earmark-richtext"></i></div>
                                <div>
                                    <p class="stat-kpi">7%</p>
                                    <p class="stat-label">Docs File Risk</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 col-md-4 col-xl-2">
                            <div class="stat-tile">
                                <div class="stat-icon"><i class="bi-folder-symlink"></i></div>
                                <div>
                                    <p class="stat-kpi">66%</p>
                                    <p class="stat-label">Folder File Risk</p>
                                </div>
                            </div>
                        </div>
                        <!-- Threat Summary -->
                        <div class="col-12">
                            <div class="card card-dark">
                                <div class="card-header d-flex align-items-center justify-content-between">
                                    <span>Threat Summary</span>
                                    <span class="tiny-muted">Yearly</span>
                                </div>
                                <div class="card-body">
                                    <div class="chart-wrap">
                                        <canvas id="threatSummaryChart"></canvas>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Risk Gauge -->
                <div class="col-xxl-3">
                    <div class="card card-dark h-100">
                        <div class="card-body d-flex flex-column align-items-center justify-content-center">
                            <div id="riskGauge" class="gauge mb-3" data-label="741">
                                <div class="gauge-ring"></div>
                            </div>
                            <div class="score-scale w-100">
                                <span>0</span><span>500</span><span>1000</span>
                            </div>
                            <div class="tiny-muted mt-2">Risk Score</div>
                            <h3 class="mt-1 fw-bold">
                                <asp:Label ID="lblRiskScore" runat="server" Text="741"></asp:Label>
                            </h3>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Donuts -->
            <div class="row g-3 mt-1">
                <div class="col-lg-6">
                    <div class="card card-dark">
                        <div class="card-header">Threats by Virus</div>
                        <div class="card-body">
                            <div class="chart-wrap" style="height:240px;">
                                <canvas id="threatsByVirusChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card card-dark">
                        <div class="card-header">Threats by Device</div>
                        <div class="card-body">
                            <div class="chart-wrap" style="height:240px;">
                                <canvas id="threatsByDeviceChart"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Table -->
            <div class="card card-dark mt-3">
                <div class="card-header">Threat Details</div>
                <div class="card-body">
                    <asp:GridView ID="gvThreatDetails" runat="server" CssClass="table table-dark table-hover"
                        GridLines="None" AutoGenerateColumns="False" HeaderStyle-Font-Bold="true">
                        <Columns>
                            <asp:BoundField DataField="Date" HeaderText="Date" DataFormatString="{0:dd-MM-yyyy}" />
                            <asp:BoundField DataField="DeviceId" HeaderText="Device ID" />
                            <asp:BoundField DataField="VirusName" HeaderText="Virus name" />
                            <asp:BoundField DataField="FilePath" HeaderText="File Path" />
                            <asp:BoundField DataField="FileType" HeaderText="File Type" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </main>
    </div>
</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="scripts" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0"></script>
    <script>
        // ====== Data from server (fallbacks if not set) ======
        const threatSummaryData = (function () {
            try { return JSON.parse('<%= threatSummaryJson %>'); } catch (e) {
                return {
                    labels: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
                    datasets: [{
                        label: "Threats",
                        data: [140, 160, 200, 230, 260, 310, 280, 260, 240, 210, 170, 150],
                        tension: .35, fill: false, borderWidth: 3,
                        borderColor: "rgba(140,115,255,1)", pointRadius: 0
                    }]
                }
            }
        })();

        const threatsByVirusData = (function () {
            try { return JSON.parse('<%= threatsByVirusJson %>'); } catch(e){
                return {
                    labels:["ECRYPTOV","WANNACRY","TRICKBOT","Other"],
                    datasets:[{ data:[35,25,20,20] }]
                }
            }
        })();

        // ====== Charts style helpers ======
        const gridColor = '#2b3248';
        const textColor = '#c6c9d3';

        // Threat Summary (line)
        const ctxSummary = document.getElementById('threatSummaryChart');
        new Chart(ctxSummary, {
            type:'line',
            data: threatSummaryData,
            options:{
                responsive:true,
                maintainAspectRatio:false,
                scales:{
                    x:{ grid:{ color:gridColor }, ticks:{ color:textColor }},
                    y:{ grid:{ color:gridColor }, ticks:{ color:textColor } }
                },
                plugins:{
                    legend:{ display:false }
                }
            }
        });

        // Donuts
        function donutColors(n){
            // nice, subdued palette
            const base = ["#8c73ff","#5ee7ff","#ffd166","#ff6b6b","#27c498","#f78c6b","#a1c45a"];
            return base.slice(0, n);
        }

        const ctxVirus = document.getElementById('threatsByVirusChart');
        new Chart(ctxVirus, {
            type:'doughnut',
            data:{
                labels: threatsByVirusData.labels,
                datasets:[{
                    data: threatsByVirusData.datasets[0].data,
                    borderWidth:0,
                    backgroundColor: donutColors(threatsByVirusData.labels.length)
                }]
            },
            options:{
                responsive:true,
                maintainAspectRatio:false,
                cutout:'65%',
                plugins:{ legend:{ labels:{ color:textColor } } }
            }
        });

        // For demo: threats by device (static unless you bind your own)
        const ctxDevice = document.getElementById('threatsByDeviceChart');
        new Chart(ctxDevice, {
            type:'doughnut',
            data:{
                labels:["crazyfla928","desktop-220","engvm-372","other"],
                datasets:[{
                    data:[40,28,22,10], borderWidth:0, backgroundColor:donutColors(4)
                }]
            },
            options:{ responsive:true, maintainAspectRatio:false, cutout:'65%',
                plugins:{ legend:{ labels:{ color:textColor } } } }
        });

        // ====== Circular Gauge ======
        (function initGauge(){
            const gauge = document.getElementById('riskGauge');
            const serverLabel = '<%= lblRiskScore.Text %>'.trim();
            const score = parseInt(serverLabel || gauge.getAttribute('data-label') || '0', 10);
            const clamped = Math.max(0, Math.min(score, 1000));
            const pctOfTurn = (clamped / 1000) * 100; // for conic-gradient %
            // color band by severity
            let color = '#27c498';
            if (clamped >= 700) color = '#ff6b6b';
            else if (clamped >= 400) color = '#ffd166';
            gauge.style.setProperty('--val', pctOfTurn);
            gauge.style.setProperty('--gauge-color', color);
            gauge.setAttribute('data-label', clamped.toString());
        })();
    </script>
</asp:Content>
