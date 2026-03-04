<%@ Page Language="C#" MasterPageFile="~/Student.Master" AutoEventWireup="true" CodeBehind="CareerGuidance.aspx.cs" Inherits="Edugate_Project.CareerGuidance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <title>Edugate - Career Guidance</title>
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

        /* Career Guidance Content Styling */
        .guidance-container {
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
        .guidance-hero {
            text-align: center;
            margin-bottom: 3rem;
        }

        .guidance-hero h1 {
            font-size: 2.8rem;
            font-weight: 800;
            margin-bottom: 1rem;
            color: var(--text-light);
        }

        .guidance-hero p {
            font-size: 1.2rem;
            color: var(--accent-light-green);
            opacity: 0.95;
        }

        /* Form Styling */
        .form-section {
            background-color: rgba(33, 58, 87, 0.7);
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            margin-bottom: 3rem;
            border: 1px solid var(--accent-teal);
            backdrop-filter: blur(5px);
        }

        .form-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .form-header h3 {
            font-size: 1.8rem;
            color: var(--accent-green);
            margin-bottom: 0.5rem;
            font-weight: 700;
        }

        .form-header p {
            color: var(--text-light);
            opacity: 0.9;
        }

        .progress-container {
            width: 100%;
            background-color: rgba(218, 209, 203, 0.2);
            border-radius: 10px;
            margin: 1.5rem 0;
            overflow: hidden;
            height: 20px;
        }

        .progress-bar {
            height: 100%;
            background: linear-gradient(to right, var(--primary-orange), var(--accent-teal));
            border-radius: 10px;
            width: 0%;
            transition: width 0.5s ease;
        }

        .question {
            margin-bottom: 2rem;
            padding: 1.5rem;
            border-radius: 16px;
            background-color: rgba(33, 58, 87, 0.5);
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
            display: none;
            border: 1px solid var(--accent-teal);
        }

        .question.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }

        .question h4 {
            font-size: 1.3rem;
            color: var(--accent-green);
            margin-bottom: 1rem;
        }

        .options {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }

        .option {
            padding: 1.2rem;
            background-color: rgba(33, 58, 87, 0.7);
            border: 2px solid var(--accent-teal);
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.3s ease;
            color: var(--text-light);
        }

        .option:hover {
            border-color: var(--accent-green);
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .option.selected {
            border-color: var(--accent-green);
            background-color: rgba(69, 223, 177, 0.2);
        }

        .navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 2rem;
        }

        .btn {
            padding: 0.8rem 1.5rem;
            background: linear-gradient(to right, var(--primary-orange), var(--accent-teal));
            color: white;
            border: none;
            border-radius: 25px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            box-shadow: 0 2px 8px 0 rgba(20,145,155,0.10);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
            background: linear-gradient(to right, var(--accent-teal), var(--accent-green));
        }

        .btn:disabled {
            background: #cccccc;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        .result-section {
            display: none;
            text-align: center;
            padding: 2rem;
            animation: fadeIn 1s ease;
        }

        .career-card {
            background: rgba(33, 58, 87, 0.7);
            border-radius: 16px;
            padding: 2.5rem;
            margin: 2rem auto;
            max-width: 700px;
            box-shadow: 0 8px 32px 0 rgba(33,58,87,0.25);
            text-align: left;
            border: 2px solid var(--accent-green);
        }

        .career-card h3 {
            color: var(--accent-green);
            font-size: 1.8rem;
            margin-bottom: 1rem;
            font-weight: 700;
        }

        .career-card p {
            line-height: 1.6;
            margin-bottom: 1.5rem;
            color: var(--text-light);
        }

        .career-card ul {
            list-style-type: none;
            margin-bottom: 1.5rem;
        }

        .career-card li {
            padding: 0.5rem 0;
            border-bottom: 1px solid rgba(218, 209, 203, 0.2);
            color: var(--text-light);
        }

        .career-card li:last-child {
            border-bottom: none;
        }

        .career-card li i {
            color: var(--accent-green);
            margin-right: 0.5rem;
        }

        .restart-btn {
            margin-top: 1rem;
            background: linear-gradient(to right, var(--primary-orange), var(--accent-teal));
        }

        .floating-shape {
            position: absolute;
            border-radius: 50%;
            opacity: 0.18;
            z-index: 0;
            animation: floatShape 8s ease-in-out infinite alternate;
        }

        .shape1 { width: 180px; height: 180px; background: var(--accent-green); top: 10%; left: 5%; animation-delay: 0s; }
        .shape2 { width: 120px; height: 120px; background: var(--primary-orange); top: 70%; left: 60%; animation-delay: 2s; }
        .shape3 { width: 90px; height: 90px; background: var(--accent-light-green); top: 40%; left: 80%; animation-delay: 4s; }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes floatShape {
            0% { transform: translateY(0) scale(1); }
            100% { transform: translateY(-30px) scale(1.1); }
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
            
            .options {
                grid-template-columns: 1fr;
            }
            
            .guidance-container {
                padding: 1.5rem;
            }
            
            .guidance-hero h1 {
                font-size: 2.2rem;
            }
            
            .guidance-hero p {
                font-size: 1rem;
            }
        }

        @media (max-width: 576px) {
            .student-menu a {
                padding: 0.5rem;
                font-size: 0.9rem;
            }
            
            .guidance-hero h1 {
                font-size: 1.8rem;
            }
            
            .navigation {
                flex-direction: column;
                gap: 1rem;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
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
                <li><a href="CareerGuidance.aspx" class="active"><i class="fas fa-compass"></i> Career Guidance</a></li>
                <li><a href="StudentMaterials.aspx"><i class="fas fa-book-open"></i> Study Materials</a></li>
                <li><a href="Default.aspx"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </div>
        
        <!-- Main Content -->
        <div class="student-content">
            <div class="floating-shape shape1"></div>
            <div class="floating-shape shape2"></div>
            <div class="floating-shape shape3"></div>

            <div class="guidance-container">
                <div class="guidance-hero">
                    <h1>Discover Your Future Career ✨</h1>
                    <p>Take our short assessment to find out which career path aligns with your interests, skills, and preferences.</p>
                </div>

                <div class="form-section">
                    <div class="form-header">
                        <h3>Career Assessment Questionnaire</h3>
                        <p>Answer honestly based on your interests and preferences</p>
                    </div>

                    <div class="progress-container">
                        <div class="progress-bar" id="progress-bar"></div>
                    </div>

                    <div class="question active" id="question-1">
                        <h4>Which school subject do you find most engaging?</h4>
                        <div class="options">
                            <div class="option" data-value="a">Mathematics & Statistics</div>
                            <div class="option" data-value="b">Computer Science & IT</div>
                            <div class="option" data-value="c">Physics & Calculus</div>
                            <div class="option" data-value="d">Chemistry & Biology</div>
                        </div>
                    </div>

                    <div class="question" id="question-2">
                        <h4>How do you prefer to solve problems?</h4>
                        <div class="options">
                            <div class="option" data-value="a">Analyzing data and finding patterns</div>
                            <div class="option" data-value="b">Building things and creating solutions</div>
                            <div class="option" data-value="c">Theoretical reasoning and calculations</div>
                            <div class="option" data-value="d">Experimentation and research</div>
                        </div>
                    </div>

                    <div class="question" id="question-3">
                        <h4>What kind of work environment appeals to you most?</h4>
                        <div class="options">
                            <div class="option" data-value="a">Office with cutting-edge technology</div>
                            <div class="option" data-value="b">Dynamic team-based projects</div>
                            <div class="option" data-value="c">Research laboratory</div>
                            <div class="option" data-value="d">Outdoor or field work</div>
                        </div>
                    </div>

                    <div class="question" id="question-4">
                        <h4>Which activity sounds most interesting to you?</h4>
                        <div class="options">
                            <div class="option" data-value="a">Predicting trends from data</div>
                            <div class="option" data-value="b">Designing intelligent systems</div>
                            <div class="option" data-value="c">Developing software applications</div>
                            <div class="option" data-value="d">Securing digital information</div>
                        </div>
                    </div>

                    <div class="question" id="question-5">
                        <h4>What are you most curious about?</h4>
                        <div class="options">
                            <div class="option" data-value="a">How things work and are constructed</div>
                            <div class="option" data-value="b">Chemical processes and reactions</div>
                            <div class="option" data-value="c">Medical technology and human health</div>
                            <div class="option" data-value="d">Living organisms and ecosystems</div>
                        </div>
                    </div>

                    <div class="navigation">
                        <button type="button" class="btn" id="prev-btn" disabled>
                            <i class="fas fa-arrow-left"></i> Previous
                        </button>
                        <button type="button" class="btn" id="next-btn">
                            Next <i class="fas fa-arrow-right"></i>
                        </button>
                        <button type="button" class="btn" id="submit-btn" style="display: none;">
                            See Results <i class="fas fa-chart-line"></i>
                        </button>
                    </div>
                </div>

                <div class="result-section" id="result-section">
                    <h2>Your Career Recommendation</h2>
                    <div class="career-card">
                        <h3 id="career-title">Career Title</h3>
                        <p id="career-description">Career description will appear here.</p>
                        <h4>Recommended Subjects to Focus On:</h4>
                        <ul id="career-subjects">
                            <li><i class="fas fa-check-circle"></i> Subject 1</li>
                            <li><i class="fas fa-check-circle"></i> Subject 2</li>
                            <li><i class="fas fa-check-circle"></i> Subject 3</li>
                        </ul>
                        <h4>Potential Career Paths:</h4>
                        <ul id="career-paths">
                            <li><i class="fas fa-arrow-right"></i> Path 1</li>
                            <li><i class="fas fa-arrow-right"></i> Path 2</li>
                            <li><i class="fas fa-arrow-right"></i> Path 3</li>
                        </ul>
                    </div>
                    <button type="button" class="btn restart-btn" id="restart-btn">
                        <i class="fas fa-redo"></i> Take Again
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // DOM elements
            const progressBar = document.getElementById('progress-bar');
            const prevBtn = document.getElementById('prev-btn');
            const nextBtn = document.getElementById('next-btn');
            const submitBtn = document.getElementById('submit-btn');
            const restartBtn = document.getElementById('restart-btn');
            const questions = document.querySelectorAll('.question');
            const options = document.querySelectorAll('.option');
            const resultSection = document.getElementById('result-section');
            const formSection = document.querySelector('.form-section');

            // Career information
            const careerInfo = {
                'Data Scientist': {
                    title: 'Data Scientist',
                    description: 'Data scientists analyze and interpret complex data to help organizations make informed decisions. They use statistical methods, machine learning, and programming to extract insights from data.',
                    subjects: ['Mathematics', 'Statistics', 'Computer Science', 'Programming'],
                    paths: ['Data Analyst', 'Machine Learning Engineer', 'Data Engineer', 'Business Intelligence Analyst']
                },
                'AI Developer': {
                    title: 'AI Developer',
                    description: 'AI developers create intelligent systems and algorithms that can learn, predict, and automate tasks. They work on cutting-edge technologies like machine learning, neural networks, and natural language processing.',
                    subjects: ['Mathematics', 'Computer Science', 'Statistics', 'Logic'],
                    paths: ['Machine Learning Engineer', 'AI Research Scientist', 'NLP Specialist', 'Computer Vision Engineer']
                },
                'Software Developer': {
                    title: 'Software Developer',
                    description: 'Software developers design, code, test, and maintain applications and systems. They solve problems through programming and create the digital tools we use every day.',
                    subjects: ['Computer Science', 'Mathematics', 'Logic', 'Programming'],
                    paths: ['Web Developer', 'Mobile App Developer', 'Systems Architect', 'DevOps Engineer']
                },
                'Data and Security Analysis': {
                    title: 'Data and Security Analyst',
                    description: 'Data and security analysts protect organizational data and systems from cyber threats. They implement security measures, monitor for breaches, and develop strategies to prevent attacks.',
                    subjects: ['Computer Science', 'Information Technology', 'Mathematics', 'Networking'],
                    paths: ['Cybersecurity Specialist', 'Information Security Analyst', 'Security Architect', 'Penetration Tester']
                },
                'Civil Engineering': {
                    title: 'Civil Engineer',
                    description: 'Civil engineers design, build, and maintain infrastructure projects like roads, bridges, buildings, and water systems. They ensure structures are safe, functional, and sustainable.',
                    subjects: ['Mathematics', 'Physics', 'Design', 'Materials Science'],
                    paths: ['Structural Engineer', 'Transportation Engineer', 'Geotechnical Engineer', 'Construction Manager']
                },
                'Chemical Engineering': {
                    title: 'Chemical Engineer',
                    description: 'Chemical engineers apply principles of chemistry, physics, and mathematics to solve problems involving the production or use of chemicals, fuel, drugs, food, and many other products.',
                    subjects: ['Chemistry', 'Mathematics', 'Physics', 'Biology'],
                    paths: ['Process Engineer', 'Product Engineer', 'Research Scientist', 'Plant Manager']
                },
                'Biomedical Engineer': {
                    title: 'Biomedical Engineer',
                    description: 'Biomedical engineers combine engineering principles with medical sciences to design and create equipment, devices, computer systems, and software used in healthcare.',
                    subjects: ['Biology', 'Chemistry', 'Mathematics', 'Physics'],
                    paths: ['Medical Device Developer', 'Clinical Engineer', 'Biomechanics Engineer', 'Rehabilitation Engineer']
                },
                'Biologist': {
                    title: 'Biologist',
                    description: 'Biologists study living organisms and their relationship to the environment. They conduct research to understand fundamental life processes and apply that knowledge to solving health and environmental problems.',
                    subjects: ['Biology', 'Chemistry', 'Mathematics', 'Ecology'],
                    paths: ['Research Scientist', 'Wildlife Biologist', 'Microbiologist', 'Geneticist']
                },
                'Astronomer': {
                    title: 'Astronomer',
                    description: 'Astronomers study celestial objects and phenomena beyond Earth\'s atmosphere. They use principles of physics and mathematics to research the universe, including stars, planets, galaxies, and cosmic events.',
                    subjects: ['Physics', 'Mathematics', 'Chemistry', 'Computer Science'],
                    paths: ['Research Astronomer', 'Planetary Scientist', 'Astrophysicist', 'Observatory Scientist']
                },
                'Industrial Engineering': {
                    title: 'Industrial Engineer',
                    description: 'Industrial engineers optimize complex processes, systems, or organizations by developing, improving, and implementing integrated systems of people, money, knowledge, information, and equipment.',
                    subjects: ['Mathematics', 'Physics', 'Statistics', 'Business'],
                    paths: ['Process Engineer', 'Quality Engineer', 'Operations Analyst', 'Supply Chain Manager']
                }
            };

            // Career mapping based on answer patterns
            const careerMapping = {
                // Data Scientist pattern: Strong in math, data analysis, tech environment
                'a,a,a,a': 'Data Scientist',
                'a,a,a,b': 'Data Scientist',
                'a,a,a,c': 'Data Scientist',
                'a,b,a,a': 'Data Scientist',

                // AI Developer pattern: Combines math, building solutions, intelligent systems
                'a,b,a,b': 'AI Developer',
                'a,b,b,b': 'AI Developer',
                'b,b,a,b': 'AI Developer',
                'a,c,a,b': 'AI Developer',

                // Software Developer pattern: Computer science, building solutions, software development
                'b,b,b,c': 'Software Developer',
                'b,b,a,c': 'Software Developer',
                'b,a,b,c': 'Software Developer',
                'b,c,b,c': 'Software Developer',

                // Data and Security Analysis pattern: IT, securing information, tech environment
                'b,a,a,d': 'Data and Security Analysis',
                'b,b,a,d': 'Data and Security Analysis',
                'b,c,a,d': 'Data and Security Analysis',
                'b,d,a,d': 'Data and Security Analysis',

                // Civil Engineering pattern: Physics, building things, construction
                'c,b,b,a': 'Civil Engineering',
                'c,a,b,a': 'Civil Engineering',
                'c,c,b,a': 'Civil Engineering',
                'a,b,b,a': 'Civil Engineering',

                // Chemical Engineering pattern: Chemistry, experimentation, processes
                'd,d,c,b': 'Chemical Engineering',
                'd,b,c,b': 'Chemical Engineering',
                'd,a,c,b': 'Chemical Engineering',
                'b,d,c,b': 'Chemical Engineering',

                // Biomedical Engineer pattern: Biology/chemistry, medical technology, building solutions
                'd,c,c,c': 'Biomedical Engineer',
                'd,b,c,c': 'Biomedical Engineer',
                'c,c,c,c': 'Biomedical Engineer',
                'd,d,c,c': 'Biomedical Engineer',

                // Biologist pattern: Biology, experimentation, living organisms
                'd,d,d,d': 'Biologist',
                'd,c,d,d': 'Biologist',
                'd,b,d,d': 'Biologist',
                'c,d,d,d': 'Biologist',

                // Astronomer pattern: Physics, theoretical reasoning, curiosity about universe
                'c,c,a,c': 'Astronomer',
                'c,a,a,c': 'Astronomer',
                'a,c,a,c': 'Astronomer',
                'c,d,a,c': 'Astronomer',

                // Industrial Engineering pattern: Math, problem-solving, optimizing systems
                'a,a,b,a': 'Industrial Engineering',
                'a,b,b,a': 'Industrial Engineering',
                'b,a,b,a': 'Industrial Engineering',
                'a,c,b,a': 'Industrial Engineering'
            };

            let currentQuestion = 0;
            const totalQuestions = questions.length;
            const userAnswers = [];

            // Initialize progress bar
            updateProgressBar();

            // Event listeners
            options.forEach(option => {
                option.addEventListener('click', function () {
                    const parentQuestion = this.closest('.question');
                    const questionIndex = Array.from(questions).indexOf(parentQuestion);

                    // Remove previous selection for this question
                    const selected = parentQuestion.querySelector('.option.selected');
                    if (selected) {
                        selected.classList.remove('selected');
                    }

                    // Select current option
                    this.classList.add('selected');

                    // Store answer
                    userAnswers[questionIndex] = this.getAttribute('data-value');

                    // Enable next button
                    if (questionIndex === currentQuestion) {
                        nextBtn.disabled = false;
                    }

                    // Enable submit button if on last question
                    if (currentQuestion === totalQuestions - 1) {
                        submitBtn.disabled = false;
                    }
                });
            });

            nextBtn.addEventListener('click', function (e) {
                e.preventDefault(); // Prevent form submission
                if (currentQuestion < totalQuestions - 1) {
                    questions[currentQuestion].classList.remove('active');
                    currentQuestion++;
                    questions[currentQuestion].classList.add('active');
                    updateProgressBar();
                    updateNavigation();

                    // Check if there's a previously selected answer for this question
                    if (userAnswers[currentQuestion]) {
                        const currentOptions = questions[currentQuestion].querySelectorAll('.option');
                        currentOptions.forEach(option => {
                            if (option.getAttribute('data-value') === userAnswers[currentQuestion]) {
                                option.classList.add('selected');
                            }
                        });
                        nextBtn.disabled = false;
                    } else {
                        nextBtn.disabled = true;
                    }
                }
            });

            prevBtn.addEventListener('click', function (e) {
                e.preventDefault(); // Prevent form submission
                if (currentQuestion > 0) {
                    questions[currentQuestion].classList.remove('active');
                    currentQuestion--;
                    questions[currentQuestion].classList.add('active');
                    updateProgressBar();
                    updateNavigation();
                }
            });

            submitBtn.addEventListener('click', function (e) {
                e.preventDefault(); // Prevent form submission

                // Check if all questions are answered
                if (userAnswers.length < totalQuestions) {
                    alert('Please answer all questions before submitting.');
                    return;
                }

                // Determine career based on answers
                const answerPattern = userAnswers.join(',');
                let career;

                // Check if we have a direct match
                if (careerMapping[answerPattern]) {
                    career = careerMapping[answerPattern];
                } else {
                    // Find the closest match by comparing answer patterns
                    career = findClosestCareer(answerPattern);
                }

                // Display the result
                displayResult(career);
            });

            restartBtn.addEventListener('click', function (e) {
                e.preventDefault(); // Prevent form submission

                resultSection.style.display = 'none';
                formSection.style.display = 'block';

                // Reset form
                currentQuestion = 0;
                userAnswers.length = 0;

                questions.forEach((question, index) => {
                    question.classList.remove('active');
                    const selected = question.querySelector('.option.selected');
                    if (selected) {
                        selected.classList.remove('selected');
                    }
                });

                questions[0].classList.add('active');
                updateProgressBar();
                updateNavigation();
            });

            function updateProgressBar() {
                const progress = ((currentQuestion + 1) / totalQuestions) * 100;
                progressBar.style.width = `${progress}%`;
            }

            function updateNavigation() {
                // Show/hide previous button
                prevBtn.disabled = currentQuestion === 0;

                // Show next or submit button
                if (currentQuestion === totalQuestions - 1) {
                    nextBtn.style.display = 'none';
                    submitBtn.style.display = 'flex';
                    // Check if answer is selected for current question to enable submit
                    submitBtn.disabled = !userAnswers[currentQuestion];
                } else {
                    nextBtn.style.display = 'flex';
                    submitBtn.style.display = 'none';
                    // Check if answer is selected for current question to enable next
                    nextBtn.disabled = !userAnswers[currentQuestion];
                }
            }

            function findClosestCareer(answerPattern) {
                // Convert the answer pattern to an array
                const userAnswerArray = answerPattern.split(',');
                let bestMatch = '';
                let highestScore = 0;

                // Compare against all mapped patterns
                for (const [pattern, career] of Object.entries(careerMapping)) {
                    const patternArray = pattern.split(',');
                    let score = 0;

                    // Calculate similarity score
                    for (let i = 0; i < userAnswerArray.length; i++) {
                        if (userAnswerArray[i] === patternArray[i]) {
                            score++;
                        }
                    }

                    // Update best match if this pattern has a higher score
                    if (score > highestScore) {
                        highestScore = score;
                        bestMatch = career;
                    }
                }

                return bestMatch || 'Data Scientist'; // Default fallback
            }

            function displayResult(careerKey) {
                const career = careerInfo[careerKey];

                if (!career) {
                    console.error('Career not found:', careerKey);
                    return;
                }

                document.getElementById('career-title').textContent = career.title;
                document.getElementById('career-description').textContent = career.description;

                const subjectsList = document.getElementById('career-subjects');
                subjectsList.innerHTML = '';
                career.subjects.forEach(subject => {
                    const li = document.createElement('li');
                    li.innerHTML = `<i class="fas fa-check-circle"></i> ${subject}`;
                    subjectsList.appendChild(li);
                });

                const pathsList = document.getElementById('career-paths');
                pathsList.innerHTML = '';
                career.paths.forEach(path => {
                    const li = document.createElement('li');
                    li.innerHTML = `<i class="fas fa-arrow-right"></i> ${path}`;
                    pathsList.appendChild(li);
                });

                formSection.style.display = 'none';
                resultSection.style.display = 'block';

                // Scroll to results
                resultSection.scrollIntoView({ behavior: 'smooth' });
            }
        });
    </script>
</asp:Content>