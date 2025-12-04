<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Kids | EcoThrift</title>
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

<section class="products">
    <h2>Kids' Collection</h2>

    <!-- TOPS -->
    <h3>Tops</h3>
    <div class="grid">
        <div class="product">
            <img src="images/kids-top1.jpg" alt="Cartoon Print T-Shirt">
            <h4>Cartoon Print T-Shirt</h4>
            <p>180</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="301">
                <input type="hidden" name="name" value="Cartoon Print T-Shirt">
                <input type="hidden" name="price" value="180">
                <input type="hidden" name="image" value="images/kids-top1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/kids-top2.jpg" alt="Colorful Polo Shirt">
            <h4>Colorful Polo Shirt</h4>
            <p>200</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="302">
                <input type="hidden" name="name" value="Colorful Polo Shirt">
                <input type="hidden" name="price" value="200">
                <input type="hidden" name="image" value="images/kids-top2.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>
    </div>

    <!-- BOTTOMS -->
    <h3>Bottoms</h3>
    <div class="grid">
        <div class="product">
            <img src="images/kids-bottom1.jpg" alt="Blue Shorts">
            <h4>Blue Shorts</h4>
            <p>150</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="303">
                <input type="hidden" name="name" value="Blue Shorts">
                <input type="hidden" name="price" value="150">
                <input type="hidden" name="image" value="images/kids-bottom1.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>20</option><option>22</option><option>24</option><option>26</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/kids-bottom2.jpg" alt="Cotton Trousers">
            <h4>Cotton Trousers</h4>
            <p>170</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="304">
                <input type="hidden" name="name" value="Cotton Trousers">
                <input type="hidden" name="price" value="170">
                <input type="hidden" name="image" value="images/kids-bottom2.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>20</option><option>22</option><option>24</option><option>26</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>
    </div>
</section>

<footer>
    <p>© 2025 EcoThrift | Sustainable fashion for all ages</p>
</footer>

</body>
</html>
