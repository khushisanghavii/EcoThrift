<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Success | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .success-container {
            text-align: center;
            margin-top: 100px;
            color: #2e7d32;
        }
        .success-container h2 {
            font-size: 28px;
        }
        .success-container p {
            font-size: 18px;
            color: #444;
        }
        .back-btn {
            margin-top: 30px;
            display: inline-block;
            background: #4CAF50;
            color: white;
            padding: 10px 25px;
            border-radius: 8px;
            text-decoration: none;
            transition: 0.3s;
        }
        .back-btn:hover {
            background: #388e3c;
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
            <a href="orders.jsp" class="btn">My Orders</a>   <!-- ? NEW LINK ADDED -->
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% 
        } 
    %>
</nav>

</header>

<!-- ? MAIN WRAPPER ? required for sticky footer -->
<main>
    <div class="success-container">
        <h2>Thank you for your purchase!</h2>
        <p>Your order has been placed successfully.</p>
        <p>Together we are making the planet greener ?</p>
        <a href="products.jsp" class="back-btn">Continue Shopping</a>
    </div>
</main>

<footer>
    <p>© 2025 EcoThrift | Fashion with a purpose</p>
</footer>

</body>
</html>
