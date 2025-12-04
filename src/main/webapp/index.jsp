<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>EcoThrift | Home</title>
    <link rel="stylesheet" href="css/style.css">
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
            <a href="orders.jsp" class="btn">My Orders</a>   <!-- ⭐ NEW LINK ADDED -->
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% 
        } 
    %>
</nav>

</header>


<main>
    <section class="hero">
        <div class="hero-text">
            <h1>Thrift. Donate. Sustain.</h1>
            <p>Buy second-hand treasures or donate what you don’t use anymore — for a greener tomorrow.</p>
            <a href="products.jsp" class="cta">Start Shopping</a>
        </div>
    </section>
</main>

<footer>
    <p>© 2025 EcoThrift | Made with love for sustainability</p>
</footer>

</body>
</html>
