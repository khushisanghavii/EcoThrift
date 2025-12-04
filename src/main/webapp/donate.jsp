<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Donate | EcoThrift</title>
  <link rel="stylesheet" href="css/style.css">
  <style>
    body {
      font-family: 'Poppins', sans-serif;
      margin: 0;
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
      color: #2e7d32;
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

    .form-container {
      max-width: 650px;
      margin: 70px auto;
      background-color: #fff;
      padding: 40px 50px;
      border-radius: 12px;
      box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    }

    .form-container h2 {
      text-align: center;
      color: #1b5e20;
      margin-bottom: 25px;
    }

    form {
      display: flex;
      flex-direction: column;
    }

    input, select, textarea {
      margin: 10px 0;
      padding: 12px;
      font-size: 1rem;
      border: 1px solid #ccc;
      border-radius: 8px;
      outline: none;
    }

    input:focus, select:focus, textarea:focus {
      border-color: #2e7d32;
    }

    textarea {
      resize: vertical;
      min-height: 100px;
    }

    button {
      background-color: #2e7d32;
      color: white;
      border: none;
      padding: 12px;
      border-radius: 8px;
      font-size: 1rem;
      cursor: pointer;
      margin-top: 10px;
      transition: 0.3s ease;
    }

    button:hover {
      background-color: #1b5e20;
    }

    footer {
      background-color: #2e7d32;
      color: white;
      text-align: center;
      padding: 15px 0;
      margin-top: 50px;
    }

    .note {
      font-size: 0.9rem;
      color: #666;
      margin-top: 5px;
    }

    @media (max-width: 768px) {
      header {
        flex-direction: column;
        text-align: center;
        padding: 10px 20px;
      }

      .form-container {
        padding: 25px;
      }
    }
  </style>
</head>

<body>
  <!-- Header -->
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
            <a href="orders.jsp" class="btn">My Orders</a>   <!-- ? NEW LINK ADDED -->
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% 
        } 
    %>
</nav>

</header>

  <!-- Donation Form -->
  <div class="form-container">
    <h2>Donate Clothes or Items</h2>
    <form action="DonateServlet" method="post" enctype="multipart/form-data">
      <input type="text" name="name" placeholder="Full Name" required>
      <input type="email" name="email" placeholder="Email Address" required>
      <input type="text" name="phone" placeholder="Phone Number" required>
      <input type="text" name="address" placeholder="Pickup Address" required>

      <!-- Donation Type -->
      <label for="donation_type"><strong>Type of Donation:</strong></label>
      <select name="donation_type" id="donation_type" required>
        <option value="" disabled selected>-- Select Type --</option>
        <option value="Clothes for women">Clothes for women</option>
        <option value="Clothes foe men">Clothes for men</option>
        <option value="Clothes for kids">Clothes for kids</option>
        <option value="Accessories">Accessories</option>
        <option value="Mixed">Mixed Items</option>
      </select>

      <!-- NGO Selection -->
      <label for="ngo_name"><strong>Select NGO to Donate To:</strong></label>
      <select name="ngo_name" id="ngo_name" required>
        <option value="" disabled selected>-- Select NGO --</option>
        <option value="Goonj">Goonj</option>
        <option value="Uday Foundation">Uday Foundation</option>
        <option value="Share At Doorstep">Share At Doorstep (SADS)</option>
        <option value="Clothes Box Foundation">Clothes Box Foundation</option>
        <option value="Green Yatra">Green Yatra</option>
        <option value="Other">Other (Specify below)</option>
      </select>

      <input type="text" name="other_ngo" placeholder="If Other, Enter NGO Name">

      <textarea name="donated_items" placeholder="Items you wish to donate (e.g., type of clothes  etc.)" required></textarea>

      <!-- Upload Photo -->
      <label><strong>Upload a Picture (optional):</strong></label>
      <input type="file" name="donation_photo" accept="image/*">

      <!-- Pickup Scheduling -->
      <label><strong>Preferred Pickup Date & Time:</strong></label>
      <input type="date" name="pickup_date" required>
      <input type="time" name="pickup_time" required>

      <p class="note">Note: Our team or the selected NGO will contact you to coordinate pickup.</p>

      <button type="submit">Submit Donation</button>
    </form>
  </div>

  <footer>
    <p>© 2025 EcoThrift | Making giving easy and meaningful ??</p>
  </footer>

</body>
</html>
