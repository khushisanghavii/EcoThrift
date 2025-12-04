<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Products | EcoThrift</title>
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
    <section class="products">
        <h2>Shop by Category</h2>

        <div class="grid">
            <div class="product">
                <a href="men.jsp"><h4>Men</h4></a>
            </div>
            <div class="product">
                <a href="women.jsp"><h4>Women</h4></a>
            </div>
            <div class="product">
                <a href="kids.jsp"><h4>Kids</h4></a>
            </div>
            <div class="product">
                <a href="All.jsp"><h4>All Products</h4></a>
            </div>
        </div>
    </section>
</main>

<footer>
    <p>© 2025 EcoThrift | Sustainable fashion for all ages</p>
</footer>

</body>
</html>
