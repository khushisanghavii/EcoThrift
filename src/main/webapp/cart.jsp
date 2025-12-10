<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Your Cart | EcoThrift</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .cart-container { width: 80%; margin: 50px auto; background: #f9fff9; border-radius: 10px; padding: 20px; box-shadow: 0 0 15px rgba(0, 100, 0, 0.1); }
        .cart-item { display:flex; justify-content:space-between; align-items:center; background:#fff; margin-bottom:15px; padding:10px 20px; border-radius:10px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
        .cart-item .left { display:flex; align-items:center; gap:15px; }
        .cart-item img { width:90px; height:90px; object-fit:cover; border-radius:8px; border:1px solid #eee; }
        .cart-summary { text-align:right; margin-top:20px; font-size:18px; font-weight:bold; }
        .checkout-btn { padding:10px 20px; background:#4CAF50; color:white; text-decoration:none; border-radius:8px; border:none; cursor:pointer; }
        .remove-btn { padding:8px 14px; background:#e53935; color:white; border-radius:8px; border:none; cursor:pointer; }
        .empty-cart { text-align:center; font-size:18px; color:#555; margin-top:40px; }
    </style>
</head>
<body>

<header>
    <div class="logo">EcoThrift</div>
   <nav>
  <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
  <a href="${pageContext.request.contextPath}/products">Shop</a>
  <a href="${pageContext.request.contextPath}/donate.jsp">Donate</a>
  <a href="${pageContext.request.contextPath}/about.jsp">About</a>
  <a href="${pageContext.request.contextPath}/cart.jsp">Cart</a>

  <%
    // use a different name than the implicit 'session'
    HttpSession sess = request.getSession(false);
    String user = (sess == null) ? null : (String) sess.getAttribute("username");
  %>

  <% if (user == null) { %>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn">Login</a>
      <a href="${pageContext.request.contextPath}/register.jsp" class="btn">Register</a>
  <% } else { %>
      <a href="${pageContext.request.contextPath}/orders.jsp">My Orders</a>
      <a href="${pageContext.request.contextPath}/DonationListServlet">My Donations</a>
      <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
      <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn">Logout</a>
  <% } %>
</nav>
</header>

<%
    // safe session read (no duplicate variable name)
    HttpSession sess2 = request.getSession(false);
    Integer userId = null;
    if (sess2 != null) {
        Object uid = sess2.getAttribute("userId");
        if (uid instanceof Integer) userId = (Integer) uid;
        else if (uid instanceof Number) userId = (uid == null) ? null : ((Number) uid).intValue();
    }
%>

<main>
    <div class="cart-container">
        <h2>Your Shopping Cart</h2>
        <hr><br>

        <%
            // cart items: if logged in, load from DB; else from session cart (guest)
            List<Map<String, String>> cart = new ArrayList<>();

            if (userId != null) {
                // DB connection settings
                String dbUrl = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
                String dbUser = "root";
                String dbPass = "";

                String sql = "SELECT id, name, price, size, image_url FROM cart WHERE user_id=?";
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                } catch (ClassNotFoundException cnfe) {
                    out.println("<p style='color:red;text-align:center;'>Driver not found.</p>");
                }

                try (Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
                     PreparedStatement pst = con.prepareStatement(sql)) {

                    pst.setInt(1, userId);
                    try (ResultSet rs = pst.executeQuery()) {
                        while (rs.next()) {
                            Map<String, String> item = new HashMap<>();
                            item.put("id", rs.getString("id"));
                            item.put("name", rs.getString("name"));
                            item.put("price", rs.getString("price"));
                            item.put("size", rs.getString("size"));
                            item.put("image", rs.getString("image_url"));
                            cart.add(item);
                        }
                    }

                } catch (SQLException e) {
                    e.printStackTrace();
                    out.println("<p style='color:red;text-align:center;'>Error loading cart.</p>");
                }

            } else {
                // guest cart from session (if any)
                Object sc = (sess2 == null) ? null : sess2.getAttribute("cart");
                if (sc instanceof List) {
                    try {
                        cart = (List<Map<String, String>>) sc;
                    } catch (ClassCastException cce) {
                        cart = new ArrayList<>();
                    }
                } else {
                    cart = new ArrayList<>();
                }
            }

            if (cart.isEmpty()) {
        %>

        <div class="empty-cart">
            <p>Your cart is empty</p>
            <a href="${pageContext.request.contextPath}/products" class="checkout-btn">Shop Now</a>
        </div>

        <%
            } else {
                double total = 0.0;
                int idx = 0;
                for (Map<String, String> item : cart) {
                    String name = item.get("name");
                    double price = 0.0;
                    try { price = Double.parseDouble(item.get("price")); } catch (Exception ignore) {}
                    String size = item.get("size");
                    String image = item.get("image");
                    total += price;

                    String imgSrc = (image == null || image.trim().isEmpty()) ? (request.getContextPath() + "/images/placeholder.png") : image;
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
                <p>₹<%= String.format("%.2f", price) %></p>

                <% if (userId != null) { %>
                    <form action="${pageContext.request.contextPath}/RemoveFromCartServlet" method="post" style="display:inline;">
                        <input type="hidden" name="cartId" value="<%= item.get("id") %>">
                        <button type="submit" class="remove-btn">Remove</button>
                    </form>
                <% } else { %>
                    <form action="${pageContext.request.contextPath}/RemoveFromCartServlet" method="post" style="display:inline;">
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
            Total: ₹<%= String.format("%.2f", total) %>
        </div><br>

        <!-- Automatic Donation Feature -->
        <form method="post" action="${pageContext.request.contextPath}/CheckoutServlet">
            <div style="text-align:right; margin-bottom: 15px;">
                <input type="checkbox" name="donation" value="10" id="donationBox" checked>
                <label for="donationBox" style="font-size:17px;">
                    Add ₹10 as a small donation to support NGOs (optional)
                </label><br><br>

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
