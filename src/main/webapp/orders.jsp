<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Orders | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .order-box { width: 70%; margin: 25px auto; background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.1); }
        .order-item { display:flex; gap:15px; align-items:center; padding:8px 0; }
        .order-item img { width:70px; border-radius:8px; }
        hr { margin-top:15px; }
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
        Integer userId = (Integer) session.getAttribute("userId");

        if (user == null) {
    %>
            <a href="login.jsp" class="btn">Login</a>
            <a href="register.jsp" class="btn">Register</a>
    <% } else { %>
            <a href="orders.jsp" class="btn">My Orders</a>
            <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
            <a href="LogoutServlet" class="btn">Logout</a>
    <% } %>
</nav>
</header>

<main>
    <h2 style="text-align:center; margin-top:30px;">Your Orders</h2>

    <%
        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/ecothrift", "root", "")) {

                PreparedStatement pst = con.prepareStatement(
                    "SELECT * FROM orders WHERE user_id=? ORDER BY created_at DESC"
                );
                pst.setInt(1, userId);
                ResultSet rs = pst.executeQuery();

                boolean hasOrders = false;

                while (rs.next()) {
                    hasOrders = true;
                    int orderId = rs.getInt("id");
                    double total = rs.getDouble("total");            // <-- correct column name
                    double donation = rs.getDouble("donation_amount");
                    Timestamp date = rs.getTimestamp("created_at");
    %>

    <div class="order-box">
        <h3>Order #<%= orderId %></h3>
        <p><b>Total Paid:</b> ₹<%= total %></p>
        <p><b>Donation:</b> ₹<%= donation %></p>
        <p><b>Date:</b> <%= date %></p>

        <h4>Items:</h4>

        <%
            PreparedStatement items = con.prepareStatement(
                "SELECT name, price, size, quantity, image_url FROM order_items WHERE order_id=?"
            );
            items.setInt(1, orderId);
            ResultSet irs = items.executeQuery();

            while (irs.next()) {
        %>

        <div class="order-item">
            <img src="<%= irs.getString("image_url") %>" alt="product">
            <div>
                <p><b><%= irs.getString("name") %></b></p>
                <p>Price: ₹<%= irs.getDouble("price") %></p>
                <p>Size: <%= irs.getString("size") %></p>
                <p>Qty: <%= irs.getInt("quantity") %></p>
            </div>
        </div>

        <% } /* items */ %>

        <hr>
    </div>

    <% } /* orders loop */ 

       if (!hasOrders) { %>
        <p style="text-align:center; margin-top:40px;">You have no placed orders yet.</p>
    <% } 

    } } catch (Exception e) {
        e.printStackTrace();
        out.println("<p style='text-align:center;color:red;'>Error loading orders.</p>");
    }
    %>

</main>

</body>
</html>
