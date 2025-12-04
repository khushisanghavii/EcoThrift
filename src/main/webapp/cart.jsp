<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Your Cart | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">

    <style>
        .cart-container {
            width: 80%;
            margin: 50px auto;
            background: #f9fff9;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 0 15px rgba(0, 100, 0, 0.1);
        }
        .cart-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: #fff;
            margin-bottom: 15px;
            padding: 10px 20px;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        .cart-item .left {
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .cart-item img {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #eee;
        }
        .cart-item p {
            margin: 5px;
            font-size: 16px;
        }
        .cart-summary {
            text-align: right;
            margin-top: 20px;
            font-size: 18px;
            font-weight: bold;
        }
        .checkout-btn {
            padding: 10px 20px;
            background: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            transition: 0.3s;
            border: none;
            cursor: pointer;
        }
        .checkout-btn:hover {
            background: #3e8e41;
        }
        .remove-btn {
            padding: 8px 14px;
            background: #e53935;
            color: white;
            border-radius: 8px;
            border: none;
            cursor: pointer;
        }
        .empty-cart {
            text-align: center;
            font-size: 18px;
            color: #555;
            margin-top: 40px;
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
            <a href="orders.jsp" class="btn">My Orders</a>   <!-- ⭐ NEW LINK ADDED -->
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% 
        } 
    %>
</nav>

</header>
<%
    // Ensure userId is available for DB cart logic
    Integer userId = (Integer) session.getAttribute("userId");
%>

<!-- ⭐ MAIN WRAPPER (needed for sticky footer) -->
<main>

    <div class="cart-container">
        <h2>Your Shopping Cart</h2>
        <hr><br>

        <%
            List<Map<String, String>> cart = new ArrayList<>();

            if (userId != null) {
                // Load cart from ecothrift database (including image_url)
                Connection con = null;
                PreparedStatement pst = null;
                ResultSet rs = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection(
                        "jdbc:mysql://localhost:3306/ecothrift", "root", "");

                    pst = con.prepareStatement(
                        "SELECT id, name, price, size, image_url FROM cart WHERE user_id=?"
                    );
                    pst.setInt(1, userId);
                    rs = pst.executeQuery();

                    while (rs.next()) {
                        Map<String, String> item = new HashMap<>();
                        item.put("id", rs.getString("id"));
                        item.put("name", rs.getString("name"));
                        item.put("price", rs.getString("price"));
                        item.put("size", rs.getString("size"));
                        item.put("image", rs.getString("image_url")); // key: image
                        cart.add(item);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                    try { if (pst != null) pst.close(); } catch (Exception ignored) {}
                    try { if (con != null) con.close(); } catch (Exception ignored) {}
                }

            } else {
                // Guest cart (session)
                cart = (List<Map<String, String>>) session.getAttribute("cart");
                if (cart == null) cart = new ArrayList<>();
            }

            if (cart.isEmpty()) {
        %>

        <div class="empty-cart">
            <p>Your cart is empty</p>
            <a href="products.jsp" class="checkout-btn">Shop Now</a>
        </div>

        <%
            } else {
                double total = 0;
                int idx = 0; // index for guest removal

                for (Map<String, String> item : cart) {
                    String name = item.get("name");
                    double price = Double.parseDouble(item.get("price"));
                    String size = item.get("size");
                    String image = item.get("image"); // may be null
                    total += price;

                    String imgSrc = (image == null || image.trim().isEmpty()) ? "images/placeholder.png" : image;
        %>

        <div class="cart-item">
            <div class="left">
                <img src="<%= imgSrc %>" alt="<%= name.replaceAll("\"","'") %>">
                <div>
                    <p><strong><%= name %></strong></p>
                    <p>Size: <%= size %></p>
                </div>
            </div>

            <div style="text-align:right;">
                <p>₹<%= price %></p>

                <% if (userId != null) { %>
                    <form action="RemoveFromCartServlet" method="post" style="display:inline;">
                        <input type="hidden" name="cartId" value="<%= item.get("id") %>">
                        <button type="submit" class="remove-btn">Remove</button>
                    </form>
                <% } else { %>
                    <form action="RemoveFromCartServlet" method="post" style="display:inline;">
                        <input type="hidden" name="index" value="<%= idx %>">
                        <button type="submit" class="remove-btn">Remove</button>
                    </form>
                <% } %>
            </div>
        </div>

        <%
                    idx++;
                } // end for
        %>

       <div class="cart-summary">
            Total: ₹<%= total %>
        </div><br>

        <!-- ⭐ Automatic Donation Feature -->
        <form method="post" action="CheckoutServlet">
    <div style="text-align:right; margin-bottom: 15px;">
        <input type="checkbox" name="donation" value="10" id="donationBox" checked>
        <label for="donationBox" style="font-size:17px;">
            Add ₹10 as a small donation to support NGOs (optional)
        </label><br><br>

        <!-- optional client total (ignored by servlet) -->
        <input type="hidden" name="cartTotal" value="<%= total %>">

        <button type="submit" class="checkout-btn">Proceed to Checkout</button>
    </div>
</form>


        <% } %>

    </div>

</main>

<footer>
    <p>© 2025 EcoThrift | Sustainable fashion for all ages</p>
</footer>

</body>
</html>
