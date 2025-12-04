<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f9f9f9;
            color: #333;
        }

        header {
                     background-color: #ffffff;
                     color: #2e7d32;
                     display: flex;
                     justify-content: space-between;
                     align-items: center;
                     padding: 15px 60px;
                     box-shadow: 0 2px 6px rgba(0, 0, 0, 0.1);
                }


        .logo {
            font-size: 1.8rem;
            font-weight: bold;
        }

        nav a {
                 color: #2e7d32;
                 text-decoration: none;
                 margin: 0 15px;
                 font-weight: 500;
               }

        nav a:hover, nav a.active {
            text-decoration: underline;
            color: #1b5e20;
        }   

        nav .btn {
                    background-color: #2e7d32;
                    color: #fff;
                    padding: 8px 14px;
                    border-radius: 5px;
                    font-weight: bold;
                  }


        .about {
            padding: 60px 100px;
            text-align: center;
            background-color: #ffffff;
        }

        .about h1 {
            font-size: 2.5rem;
            color: #1b5e20;
            margin-bottom: 20px;
        }

        .about p {
            font-size: 1.1rem;
            line-height: 1.8;
            max-width: 900px;
            margin: 0 auto;
        }

        .ngo-section {
            background-color: #f0f4f0;
            padding: 60px 80px;
        }

        .ngo-section h2 {
            text-align: center;
            color: #1b5e20;
            font-size: 2rem;
            margin-bottom: 30px;
        }

        .ngo-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            gap: 25px;
        }

        .ngo-card {
            background: #fff;
            border-radius: 15px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            width: 260px;
            text-align: center;
            padding: 20px;
            transition: transform 0.3s ease;
        }

        .ngo-card:hover {
            transform: translateY(-5px);
        }

        .ngo-card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
            border-radius: 10px;
        }

        .ngo-card h3 {
            color: #2e7d32;
            margin-top: 15px;
        }

        .ngo-card p {
            font-size: 0.95rem;
            color: #555;
        }

        .email-section {
            text-align: center;
            padding: 50px 40px;
            background-color: #e8f5e9;
        }

        .email-section h3 {
            color: #1b5e20;
        }

        .email-section a {
            color: #2e7d32;
            font-weight: bold;
            text-decoration: none;
        }

        footer {
            background-color: #2e7d32;
            color: white;
            text-align: center;
            padding: 15px 0;
        }
    </style>
</head>
<body>

    <header>
    <div class="logo">EcoThrift</div>
    <nav>
        <a href="index.jsp">Home</a>
        <a href="products.jsp">Shop</a>
        <a href="donate.jsp">Donate</a>
        <a href="about.jsp">About</a>
        <a href="cart.jsp">Cart</a>

        <% 
            String user = (String) session.getAttribute("username"); 
            if (user == null) { 
        %>
                <a href="login.jsp" class="btn">Login</a>
                <a href="register.jsp" class="btn">Register</a>
        <% 
            } else { 
        %>
                <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
                <a href="LogoutServlet" class="btn">Logout</a>
        <% 
            } 
        %>
    </nav>
</header>


    <section class="about">
        <h1>Our Story</h1>
        <p>
            EcoThrift began with a simple idea ? that the things we no longer need can still bring joy and hope to others.
            In a world driven by fast fashion and constant consumption, we wanted to create a space where every item gets a
            <strong>second chance</strong> ? helping both the planet and people. <br><br>
            Every purchase and donation through EcoThrift supports sustainability, empowers communities, and gives pre-loved
            items a new purpose. Together, we can make sustainable living a way of life ? not just a choice.
        </p>
    </section>

    <section class="ngo-section">
        <h2>Our NGO Partners</h2>
        <div class="ngo-container">
            <div class="ngo-card">
                <img src="images/goonj.jpg" alt="Goonj NGO">
                <h3>Goonj</h3>
                <p>Transforms urban waste into resources for rural development and disaster relief efforts.</p>
            </div>

            <div class="ngo-card">
                <img src="images/udayfoundation.jpg" alt="Uday Foundation">
                <h3>Uday Foundation</h3>
                <p>Provides food, clothes, and essentials to children and families in need.</p>
            </div>

            <div class="ngo-card">
                <img src="images/sads.jpg" alt="Share At Doorstep">
                <h3>Share At Doorstep (SADS)</h3>
                <p>Encourages responsible donation and rewards individuals for sustainable actions.</p>
            </div>

            <div class="ngo-card">
                <img src="images/clothesbox.jpg" alt="Clothes Box Foundation">
                <h3>Clothes Box Foundation</h3>
                <p>Distributes donated clothes to rural and tribal communities across India.</p>
            </div>

            <div class="ngo-card">
                <img src="images/greenyatra.jpg" alt="Green Yatra">
                <h3>Green Yatra</h3>
                <p>Promotes waste management, recycling, and environmental awareness initiatives.</p>
            </div>
        </div>
    </section>

    <section class="email-section">
        <h3>Want to Recommend an NGO?</h3>
        <p>
            We?re always looking to collaborate with organizations that share our vision of sustainability and care.
            If you know an NGO that we should connect with, email us at:
        </p>
        <p><a href="mailto:connect@ecothrift.org">connect@ecothrift.org</a></p>
    </section>

    <footer>
        <p>© 2025 EcoThrift | Made with love for sustainability </p>
    </footer>

</body>
</html> 
