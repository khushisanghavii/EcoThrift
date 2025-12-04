<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Men | EcoThrift</title>
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
    <h2>Men's Collection</h2>

    <!-- SHIRTS -->
    <h3>Shirts</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-shirt1.jpg" alt="Casual Checked Shirt">
            <h4>Casual Checked Shirt</h4>
            <p>350</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="101">
                <input type="hidden" name="name" value="Casual Checked Shirt">
                <input type="hidden" name="price" value="350">
                <input type="hidden" name="image" value="images/mens-shirt1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-shirt2.jpg" alt="Formal White Shirt">
            <h4>Formal White Shirt</h4>
            <p>300</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="102">
                <input type="hidden" name="name" value="Formal White Shirt">
                <input type="hidden" name="price" value="300">
                <input type="hidden" name="image" value="images/mens-shirt2.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <!-- BOTTOMS -->
    <h3>Bottoms</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-jeans.jpg" alt="Blue Denim Jeans">
            <h4>Blue Denim Jeans</h4>
            <p>400</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="103">
                <input type="hidden" name="name" value="Blue Denim Jeans">
                <input type="hidden" name="price" value="400">
                <input type="hidden" name="image" value="images/mens-jeans.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option><option>36</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-trousers.jpg" alt="Khaki Cotton Trousers">
            <h4>Khaki Cotton Trousers</h4>
            <p>350</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="104">
                <input type="hidden" name="name" value="Khaki Cotton Trousers">
                <input type="hidden" name="price" value="350">
                <input type="hidden" name="image" value="images/mens-trousers.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option><option>36</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <!-- TSHIRTS -->
    <h3>T-Shirts</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-tshirt1.jpg" alt="Graphic Tee">
            <h4>Graphic Tee</h4>
            <p>250</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="105">
                <input type="hidden" name="name" value="Graphic Tee">
                <input type="hidden" name="price" value="250">
                <input type="hidden" name="image" value="images/mens-tshirt1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-tshirt2.jpg" alt="Plain Black T-Shirt">
            <h4>Plain Black T-Shirt</h4>
            <p>200</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="106">
                <input type="hidden" name="name" value="Plain Black T-Shirt">
                <input type="hidden" name="price" value="200">
                <input type="hidden" name="image" value="images/mens-tshirt2.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
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
