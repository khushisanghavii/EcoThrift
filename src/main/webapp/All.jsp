<!DOCTYPE html>
<html>
<head>
    <title>All Products | EcoThrift</title>
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
            <a href="orders.jsp" class="btn">My Orders</a>   <!-- ? NEW LINK ADDED -->
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% 
        } 
    %>
</nav>

</header>


<h1 class="page-title">ALL PRODUCTS</h1>

<!-- ==================== MEN ==================== -->
<section class="products">
    <h2>Men's Collection</h2>

    <h3>Shirts</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-shirt1.jpg">
            <h4>Casual Checked Shirt</h4>
            <p>350</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Casual Checked Shirt">
                <input type="hidden" name="price" value="350">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-shirt2.jpg">
            <h4>Formal White Shirt</h4>
            <p>300</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Formal White Shirt">
                <input type="hidden" name="price" value="300">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>Bottoms</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-jeans.jpg">
            <h4>Blue Denim Jeans</h4>
            <p>400</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Blue Denim Jeans">
                <input type="hidden" name="price" value="400">
                <label>Waist:</label>
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option><option>36</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-trousers.jpg">
            <h4>Khaki Cotton Trousers</h4>
            <p>350</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Khaki Cotton Trousers">
                <input type="hidden" name="price" value="350">
                <label>Waist:</label>
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option><option>36</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>T-Shirts</h3>
    <div class="grid">

        <div class="product">
            <img src="images/mens-tshirt1.jpg">
            <h4>Graphic Tee</h4>
            <p>250</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Graphic Tee">
                <input type="hidden" name="price" value="250">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/mens-tshirt2.jpg">
            <h4>Plain Black T-Shirt</h4>
            <p>200</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Plain Black T-Shirt">
                <input type="hidden" name="price" value="200">
                <label>Size:</label>
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>
</section>

<!-- ==================== WOMEN ==================== -->
<section class="products">
    <h2>Women's Collection</h2>

    <h3>Tops</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-top1.jpg">
            <h4>Floral Crop Top</h4>
            <p>280</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Floral Crop Top">
                <input type="hidden" name="price" value="280">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-top2.jpg">
            <h4>White Blouse</h4>
            <p>300</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="White Blouse">
                <input type="hidden" name="price" value="300">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>Bottoms</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-jeans.jpg">
            <h4>High Waist Jeans</h4>
            <p>450</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="High Waist Jeans">
                <input type="hidden" name="price" value="450">
                <select name="size">
                    <option>28</option><option>30</option><option>32</option><option>34</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-skirt.jpg">
            <h4>Denim Skirt</h4>
            <p>320</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Denim Skirt">
                <input type="hidden" name="price" value="320">
                <select name="size">
                    <option>26</option><option>28</option><option>30</option><option>32</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>Dresses</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-dress1.jpg">
            <h4>Summer Floral Dress</h4>
            <p>500</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Summer Floral Dress">
                <input type="hidden" name="price" value="500">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-dress2.jpg">
            <h4>Black Evening Dress</h4>
            <p>550</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Black Evening Dress">
                <input type="hidden" name="price" value="550">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>Co-ords</h3>
    <div class="grid">

        <div class="product">
            <img src="images/women-coord1.jpg">
            <h4>Pastel Co-ord Set</h4>
            <p>600</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Pastel Co-ord Set">
                <input type="hidden" name="price" value="600">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/women-coord2.jpg">
            <h4>Striped Co-ord Set</h4>
            <p>580</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Striped Co-ord Set">
                <input type="hidden" name="price" value="580">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option><option>L</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>
</section>

<!-- ==================== KIDS ==================== -->
<section class="products">
    <h2>Kids' Collection</h2>

    <h3>Tops</h3>
    <div class="grid">

        <div class="product">
            <img src="images/kids-top1.jpg">
            <h4>Cartoon Print T-Shirt</h4>
            <p>180</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Cartoon Print T-Shirt">
                <input type="hidden" name="price" value="180">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/kids-top2.jpg">
            <h4>Colorful Polo Shirt</h4>
            <p>200</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Colorful Polo Shirt">
                <input type="hidden" name="price" value="200">
                <select name="size">
                    <option>XS</option><option>S</option><option>M</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

    <h3>Bottoms</h3>
    <div class="grid">

        <div class="product">
            <img src="images/kids-bottom1.jpg">
            <h4>Blue Shorts</h4>
            <p>150</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Blue Shorts">
                <input type="hidden" name="price" value="150">
                <select name="size">
                    <option>20</option><option>22</option><option>24</option><option>26</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <div class="product">
            <img src="images/kids-bottom2.jpg">
            <h4>Cotton Trousers</h4>
            <p>170</p>
            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="name" value="Cotton Trousers">
                <input type="hidden" name="price" value="170">
                <select name="size">
                    <option>20</option><option>22</option><option>24</option><option>26</option>
                </select>
                <button type="submit">Add to Cart</button>
            </form>
        </div>

    </div>

</section>

</body>
</html>
