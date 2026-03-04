<%@ Page Language="C#" MasterPageFile="~/Site1.Master" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Edugate_Project.About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="head" runat="server">
    <title>About Us - Edugate</title>
    <style>
        .about-container {
            padding: 120px 0 80px;
            background: linear-gradient(135deg, #2c3e50 0%, #4ca1af 100%);
            min-height: 100vh;
            color: white;
        }

        .about-hero {
            text-align: center;
            margin-bottom: 4rem;
            animation: fadeInUp 1s ease;
        }

        .about-hero h1 {
            font-size: 3rem;
            font-weight: 800;
            margin-bottom: 1rem;
        }

        .about-hero p {
            font-size: 1.2rem;
            opacity: 0.9;
            max-width: 800px;
            margin: 0 auto;
            animation: fadeInUp 1s ease 0.2s both;
        }

        .mission-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 4rem;
            animation: fadeInUp 1s ease 0.4s both;
        }

        .mission-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2.5rem 2rem;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
            color: #333;
        }

        .mission-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
        }

        .mission-card h2 {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            padding-bottom: 0.5rem;
            border-bottom: 2px solid #3498db;
            display: inline-block;
        }

        .mission-card p {
            line-height: 1.6;
            color: #555;
        }

        .stats-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1.5rem;
            margin-bottom: 4rem;
            animation: fadeInUp 1s ease 0.6s both;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 2rem;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.2);
            transition: all 0.3s ease;
        }

        .stat-card:hover {
            background: rgba(255, 255, 255, 0.15);
            transform: translateY(-5px);
        }

        .stat-number {
            font-size: 2.5rem;
            font-weight: 800;
            margin-bottom: 0.5rem;
            background: linear-gradient(135deg, #3498db, #2ecc71);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }

        .stat-label {
            font-size: 1rem;
            opacity: 0.9;
        }

        .team-section {
            margin-bottom: 4rem;
            animation: fadeInUp 1s ease 0.8s both;
        }

        .section-title {
            text-align: center;
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: 3rem;
        }

        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
        }

        .team-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2rem;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
            text-align: center;
            transition: all 0.3s ease;
            color: #333;
        }

        .team-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.2);
        }

        .team-photo {
            width: 150px;
            height: 150px;
            object-fit: cover;
            border-radius: 50%;
            margin: 0 auto 1.5rem;
            border: 5px solid rgba(52, 152, 219, 0.3);
            transition: all 0.3s ease;
        }

        .team-card:hover .team-photo {
            border-color: #3498db;
            transform: scale(1.05);
        }

        .team-name {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
            color: #2c3e50;
        }

        .team-role {
            font-size: 1rem;
            color: #3498db;
            font-weight: 600;
            margin-bottom: 1.5rem;
        }

        .team-bio {
            color: #555;
            line-height: 1.6;
            margin-bottom: 1.5rem;
        }

        .social-links {
            display: flex;
            justify-content: center;
            gap: 1rem;
        }

        .social-links a {
            color: #7f8c8d;
            font-size: 1.2rem;
            transition: all 0.3s ease;
        }

        .social-links a:hover {
            color: #3498db;
            transform: translateY(-3px);
        }

        .contact-section {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(20px);
            border-radius: 25px;
            padding: 3rem;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.15);
            color: #333;
            animation: fadeInUp 1s ease 1s both;
        }

        .contact-container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 3rem;
        }

        .contact-info h2 {
            font-size: 1.8rem;
            font-weight: 700;
            margin-bottom: 1.5rem;
            color: #2c3e50;
        }

        .contact-details {
            margin-bottom: 2rem;
        }

        .contact-item {
            display: flex;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .contact-icon {
            width: 40px;
            height: 40px;
            background: linear-gradient(135deg, #3498db, #2ecc71);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            font-size: 1rem;
        }

        .contact-text {
            font-size: 1rem;
            color: #555;
        }

        .contact-text a {
            color: #3498db;
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .contact-text a:hover {
            color: #2ecc71;
            text-decoration: underline;
        }

        .contact-social {
            display: flex;
            gap: 1rem;
            margin-top: 2rem;
        }

        .contact-social a {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 40px;
            height: 40px;
            background: #f8f9fa;
            border-radius: 50%;
            color: #7f8c8d;
            transition: all 0.3s ease;
        }

        .contact-social a:hover {
            background: #3498db;
            color: white;
            transform: translateY(-3px);
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 0.5rem;
        }

        .form-control {
            width: 100%;
            padding: 0.8rem 1rem;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: white;
        }

        .form-control:focus {
            outline: none;
            border-color: #3498db;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
            transform: translateY(-2px);
        }

        textarea.form-control {
            min-height: 150px;
            resize: vertical;
        }

        .submit-btn {
            background: linear-gradient(135deg, #3498db, #2ecc71);
            color: white;
            padding: 1rem 2rem;
            border: none;
            border-radius: 50px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
        }

        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(52, 152, 219, 0.4);
        }

        @media (max-width: 768px) {
            .about-hero h1 {
                font-size: 2.2rem;
            }
            
            .about-hero p {
                font-size: 1rem;
            }
            
            .contact-container {
                grid-template-columns: 1fr;
            }
            
            .mission-card, .team-card, .contact-section {
                padding: 1.5rem;
            }
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="about-container"/>
        <!-- Hero Section -->
        <section class="about-hero">
            <h1>Transforming Education Through Innovation</h1>
            <p>Edugate is revolutionizing the way students track their academic progress and plan their futures with our cutting-edge education technology platform.</p>
        </section>

        <!-- Mission Section -->
        <section class="mission-section">
            <div class="mission-card">
                <h2>Our Mission</h2>
                <p>To democratize education by providing accessible, intuitive tools that help students of all backgrounds track their progress, discover career paths, and achieve their academic goals through personalized learning experiences.</p>
            </div>
            <div class="mission-card">
                <h2>Our Vision</h2>
                <p>We envision a world where every student has the tools and support they need to navigate their educational journey with confidence, clarity, and continuous motivation.</p>
            </div>
            <div class="mission-card">
                <h2>Our Values</h2>
                <p>Innovation, Accessibility, Student-Centric Design, Data Privacy, and Educational Equity drive everything we do at Edugate.</p>
            </div>
        </section>

        <!-- Stats Section -->
        <section class="stats-section">
            <div class="stat-card">
                <div class="stat-number">50,000+</div>
                <div class="stat-label">Active Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">95%</div>
                <div class="stat-label">User Satisfaction</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">120+</div>
                <div class="stat-label">Educational Partners</div>
            </div>
            <div class="stat-card">
                <div class="stat-number">24/7</div>
                <div class="stat-label">Support Available</div>
            </div>
        </section>

        <!-- Team Section -->
        <section class="team-section">
            <h2 class="section-title">Meet Our Team</h2>
            <div class="team-grid">
                <div class="team-card">
                    <img src="images/team/alice.jpg" alt="Alice Johnson" class="team-photo" />
                    <h3 class="team-name">Alice Johnson</h3>
                    <div class="team-role">Founder & CEO</div>
                    <p class="team-bio">With 15+ years in edtech, Alice founded Edugate to bridge the gap between education and technology. She holds a PhD in Educational Psychology.</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fas fa-envelope"></i></a>
                    </div>
                </div>

                <div class="team-card">
                    <img src="images/team/brian.jpg" alt="Brian Smith" class="team-photo" />
                    <h3 class="team-name">Brian Smith</h3>
                    <div class="team-role">CTO</div>
                    <p class="team-bio">Brian leads our technical vision with expertise in scalable systems. Formerly at Google Education, he ensures Edugate remains cutting-edge.</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#"><i class="fab fa-github"></i></a>
                        <a href="#"><i class="fas fa-code"></i></a>
                    </div>
                </div>

                <div class="team-card">
                    <img src="images/team/carla.jpg" alt="Carla Williams" class="team-photo" />
                    <h3 class="team-name">Carla Williams</h3>
                    <div class="team-role">Head of Design</div>
                    <p class="team-bio">Carla's human-centered design approach makes complex educational data intuitive and actionable for students and educators.</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-behance"></i></a>
                        <a href="#"><i class="fab fa-dribbble"></i></a>
                        <a href="#"><i class="fas fa-palette"></i></a>
                    </div>
                </div>

                <div class="team-card">
                    <img src="images/team/daniel.jpg" alt="Daniel Kim" class="team-photo" />
                    <h3 class="team-name">Daniel Kim</h3>
                    <div class="team-role">Head of Education</div>
                    <p class="team-bio">Daniel ensures our content meets educational standards and truly benefits learners, drawing on his experience as a former university professor.</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#"><i class="fas fa-graduation-cap"></i></a>
                        <a href="#"><i class="fas fa-book"></i></a>
                    </div>
                </div>
            </div>
        </section>

        <!-- Contact Section -->
        <section class="contact-section">
            <div class="contact-container">
                <div class="contact-info">
                    <h2>Contact Information</h2>
                    <div class="contact-details">
                        <div class="contact-item">
                            <div class="contact-icon">
                                <i class="fas fa-map-marker-alt"></i>
                            </div>
                            <div class="contact-text">
                                123 Education Ave<br>
                                Tech City, SV 94000
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="contact-icon">
                                <i class="fas fa-phone-alt"></i>
                            </div>
                            <div class="contact-text">
                                <a href="tel:+18005551234">+1 (800) 555-1234</a>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="contact-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <div class="contact-text">
                                <a href="mailto:support@edugate.com">support@edugate.com</a>
                            </div>
                        </div>
                    </div>
                    <div class="contact-social">
                        <a href="#"><i class="fab fa-facebook-f"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-linkedin-in"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                    </div>
                </div>
                <div class="contact-form">
                    <form id="contactForm" method="post" action="ContactHandler.aspx"/>
                        <div class="form-group">
                            <label for="name">Full Name</label>
                            <input type="text" id="name" name="name" class="form-control" placeholder="Your name" required />
                        </div>
                        <div class="form-group">
                            <label></label>
                            </div>
                        </div>
                </div>
                </section>
        </asp:Content>