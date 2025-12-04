<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Women | EcoThrift</title>
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
    <h2>Women's Collection</h2>

    <!-- TOPS -->
    <h3>Tops</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-top1.jpg" alt="Floral Crop Top">
            <h4>Floral Crop Top</h4>
            <p>280</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="201">
                <input type="hidden" name="name" value="Floral Crop Top">
                <input type="hidden" name="price" value="280">
                <input type="hidden" name="image" value="images/women-top1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-top2.jpg" alt="White Blouse">
            <h4>White Blouse</h4>
            <p>300</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="202">
                <input type="hidden" name="name" value="White Blouse">
                <input type="hidden" name="price" value="300">
                <input type="hidden" name="image" value="images/women-top2.jpg">
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
            <img src="images/women-jeans.jpg" alt="High Waist Jeans">
            <h4>High Waist Jeans</h4>
            <p>450</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="203">
                <input type="hidden" name="name" value="High Waist Jeans">
                <input type="hidden" name="price" value="450">
                <input type="hidden" name="image" value="images/women-jeans.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-skirt.jpg" alt="Denim Skirt">
            <h4>Denim Skirt</h4>
            <p>320</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="204">
                <input type="hidden" name="name" value="Denim Skirt">
                <input type="hidden" name="price" value="320">
                <input type="hidden" name="image" value="images/women-skirt.jpg">
                <label>Waist:</label>
                <select name="size">
                    <option>26</option><option>28</option><option>30</option><option>32</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <!-- DRESSES -->
    <h3>Dresses</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-dress1.jpg" alt="Summer Floral Dress">
            <h4>Summer Floral Dress</h4>
            <p>500</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="205">
                <input type="hidden" name="name" value="Summer Floral Dress">
                <input type="hidden" name="price" value="500">
                <input type="hidden" name="image" value="images/women-dress1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-dress2.jpg" alt="Black Evening Dress">
            <h4>Black Evening Dress</h4>
            <p>550</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="206">
                <input type="hidden" name="name" value="Black Evening Dress">
                <input type="hidden" name="price" value="550">
                <input type="hidden" name="image" value="images/women-dress2.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <!-- CO-ORDS -->
    <h3>Co-ords</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-coord1.jpg" alt="Pastel Co-ord Set">
            <h4>Pastel Co-ord Set</h4>
            <p>600</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="207">
                <input type="hidden" name="name" value="Pastel Co-ord Set">
                <input type="hidden" name="price" value="600">
                <input type="hidden" name="image" value="images/women-coord1.jpg">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-coord2.jpg" alt="Striped Co-ord Set">
            <h4>Striped Co-ord Set</h4>
            <p>580</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="208">
                <input type="hidden" name="name" value="Striped Co-ord Set">
                <input type="hidden" name="price" value="580">
                <input type="hidden" name="image" value="images/women-coord2.jpg">
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
