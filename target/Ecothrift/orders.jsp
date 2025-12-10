<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html>
<head>
    <title>My Orders | EcoThrift</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .order-box { width: 70%; margin: 25px auto; background: #fff; padding: 20px; border-radius: 12px; box-shadow: 0 0 12px rgba(0,0,0,0.1); }
        .order-item { display:flex; gap:15px; align-items:center; padding:8px 0; }
        .order-item img { width:70px; border-radius:8px; }
        hr { margin-top:15px; }
        .status-badge {
            display:inline-block;
            padding:6px 10px;
            border-radius:12px;
            font-weight:600;
            font-size:0.9rem;
            color:#fff;
        }
        .status-PLACED { background:#2f9d3e; }     /* green */
        .status-SHIPPED { background:#007bff; }    /* blue */
        .status-COMPLETED { background:#6f42c1; }  /* purple */
        .status-CANCELLED { background:#d9534f; }  /* red */
        .status-OTHER { background:#666; }         /* default */
        .order-meta { display:flex; justify-content:space-between; align-items:center; gap:16px; flex-wrap:wrap; }
        .order-meta .left { display:flex; gap:12px; align-items:center; }
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
        HttpSession __s = request.getSession(false);
        String user = null;
        Integer userId = null;
        if (__s != null) {
            Object u = __s.getAttribute("username");
            user = (u == null) ? null : u.toString();
            Object uid = __s.getAttribute("userId");
            if (uid instanceof Integer) userId = (Integer) uid;
            else if (uid instanceof Number) userId = ((Number) uid).intValue();
        }

        if (user == null) {
    %>
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

<main>
    <h2 style="text-align:center; margin-top:30px;">Your Orders</h2>

    <%
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // DB connection settings (you can move these to a common config)
        String dbUrl = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
        String dbUser = "root";
        String dbPass = "";

        // Fetch orders (added status)
        String ordersSql = "SELECT id, total, donation_amount, created_at, status FROM orders WHERE user_id=? ORDER BY created_at DESC";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException cnfe) {
            out.println("<p style='color:red;text-align:center;'>Driver not found.</p>");
        }

        boolean hasOrders = false;
        try (Connection con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
             PreparedStatement pst = con.prepareStatement(ordersSql)) {

            pst.setInt(1, userId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    hasOrders = true;
                    int orderId = rs.getInt("id");
                    double total = rs.getDouble("total");
                    double donation = rs.getDouble("donation_amount");
                    Timestamp date = rs.getTimestamp("created_at");
                    String status = rs.getString("status");
                    if (status == null) status = "OTHER";

                    // choose css class for badge
                    String statusClass = "status-" + (status != null ? status.toUpperCase() : "OTHER");
    %>

    <div class="order-box">
        <div class="order-meta">
            <div class="left">
                <h3 style="margin:0">Order #<%= orderId %></h3>
                <div style="color:#666">• <%= date %></div>
            </div>
            <div>
                <span class="status-badge <%= statusClass %>"><%= status %></span>
            </div>
        </div>

        <p style="margin-top:12px;"><b>Total Paid:</b> ₹<%= String.format("%.2f", total) %> &nbsp; <b>Donation:</b> ₹<%= String.format("%.2f", donation) %></p>

        <h4>Items:</h4>

        <%
            String itemsSql = "SELECT name, price, size, quantity, image_url FROM order_items WHERE order_id=?";
            try (PreparedStatement items = con.prepareStatement(itemsSql)) {
                items.setInt(1, orderId);
                try (ResultSet irs = items.executeQuery()) {
                    while (irs.next()) {
                        String rawImg = irs.getString("image_url");
                        String imgSrc;
                        if (rawImg == null || rawImg.trim().isEmpty()) {
                            imgSrc = request.getContextPath() + "/images/placeholder.png";
                        } else {
                            rawImg = rawImg.trim();
                            if (rawImg.startsWith("http://") || rawImg.startsWith("https://")) {
                                imgSrc = rawImg;
                            } else if (rawImg.startsWith("/")) {
                                imgSrc = request.getContextPath() + rawImg;
                            } else {
                                // assume relative path already like "uploads/..." or "images/..."
                                imgSrc = request.getContextPath() + "/" + rawImg;
                            }
                        }
        %>

        <div class="order-item">
            <img src="<%= imgSrc %>" alt="product">
            <div>
                <p><b><%= irs.getString("name") %></b></p>
                <p>Price: ₹<%= String.format("%.2f", irs.getDouble("price")) %></p>
                <p>Size: <%= irs.getString("size") %></p>
                <p>Qty: <%= irs.getInt("quantity") %></p>
            </div>
        </div>

        <%      } // items loop
                } // items rs
            } catch (SQLException ie) {
                ie.printStackTrace();
                out.println("<p style='color:red;text-align:center;'>Error loading items for order " + orderId + ".</p>");
            }
        %>

        <hr>
    </div>

    <%      } // orders loop
            } // rs try
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p style='text-align:center;color:red;'>Error loading orders.</p>");
        }

        if (!hasOrders) { %>
            <p style="text-align:center; margin-top:40px;">You have not placed any orders yet.</p>
    <% } %>

</main>

</body>
</html>
