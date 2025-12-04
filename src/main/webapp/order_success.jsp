<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>

<%! 
    // small helper to escape HTML (no external libraries needed)
    public static String esc(Object o) {
        if (o == null) return "";
        String s = String.valueOf(o);
        StringBuilder out = new StringBuilder(Math.max(16, s.length()));
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '<': out.append("&lt;"); break;
                case '>': out.append("&gt;"); break;
                case '&': out.append("&amp;"); break;
                case '"': out.append("&quot;"); break;
                case '\'': out.append("&#x27;"); break;
                case '/': out.append("&#x2F;"); break;
                default: out.append(c);
            }
        }
        return out.toString();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Success | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        /* Small local tweaks (won't conflict if you already define them) */
        .order-container { max-width: 980px; margin: 48px auto; padding: 28px; background:#fff; border-radius:12px; box-shadow:0 8px 30px rgba(0,0,0,0.06); }
        .order-heading { color:#2e7d32; margin-bottom:6px; }
        .order-meta { color:#555; margin-bottom:18px; }
        .order-summary { display:flex; justify-content:space-between; align-items:center; gap:18px; margin-bottom:18px; }
        .order-table { width:100%; border-collapse:collapse; margin-top:12px; }
        .order-table th, .order-table td { padding:10px 8px; border-bottom:1px solid #eee; text-align:left; }
        .order-table th { background:#f7fff7; }
        .order-total { font-weight:700; }
        .order-note { color:#666; margin-top:10px; font-size:14px; }
        .btn-primary { background:#2e7d32; color:#fff; padding:10px 16px; border-radius:8px; text-decoration:none; display:inline-block; }
    </style>
</head>
<body>

<%
    // Read orderId from request and validate
    String orderIdParam = request.getParameter("orderId");
    Integer orderId = null;
    try { if (orderIdParam != null) orderId = Integer.parseInt(orderIdParam); } catch (NumberFormatException ignored) {}

    if (orderId == null) {
%>
    <div class="order-container">
        <h1 class="order-heading">Order not found</h1>
        <p class="order-meta">No valid order id was provided.</p>
        <a class="btn-primary" href="products.jsp">Continue Shopping</a>
    </div>
<%
        return;
    }

    // DB config
    final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift";
    final String DB_USER = "root";
    final String DB_PASS = ""; // change if needed

    Connection con = null;
    PreparedStatement pstOrder = null;
    PreparedStatement pstItems = null;
    ResultSet rsOrder = null;
    ResultSet rsItems = null;

    double orderTotal = 0.0;
    double donationAmount = 0.0;
    String status = "";
    Timestamp createdAt = null;
    Integer userId = null;

    List<Map<String,Object>> items = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        pstOrder = con.prepareStatement("SELECT id, user_id, total, donation_amount, status, created_at FROM orders WHERE id = ?");
        pstOrder.setInt(1, orderId);
        rsOrder = pstOrder.executeQuery();

        if (!rsOrder.next()) {
%>
    <div class="order-container">
        <h1 class="order-heading">Order not found</h1>
        <p class="order-meta">We couldn't find order #<%= esc(orderId) %>.</p>
        <a class="btn-primary" href="products.jsp">Continue Shopping</a>
    </div>
<%
            return;
        } else {
            userId = rsOrder.getObject("user_id") == null ? null : rsOrder.getInt("user_id");
            orderTotal = rsOrder.getDouble("total");
            donationAmount = rsOrder.getDouble("donation_amount");
            status = rsOrder.getString("status");
            createdAt = rsOrder.getTimestamp("created_at");
        }

        pstItems = con.prepareStatement("SELECT name, price, size, quantity, image_url FROM order_items WHERE order_id = ?");
        pstItems.setInt(1, orderId);
        rsItems = pstItems.executeQuery();
        while (rsItems.next()) {
            Map<String,Object> it = new HashMap<>();
            it.put("name", rsItems.getString("name"));
            it.put("price", rsItems.getDouble("price"));
            it.put("size", rsItems.getString("size"));
            it.put("quantity", rsItems.getInt("quantity"));
            it.put("image", rsItems.getString("image_url"));
            items.add(it);
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
    <div class="order-container">
        <h1 class="order-heading">Something went wrong</h1>
        <p class="order-meta">There was an error loading your order details. Please contact support if this persists.</p>
        <a class="btn-primary" href="products.jsp">Continue Shopping</a>
    </div>
<%
        return;
    } finally {
        try { if (rsItems != null) rsItems.close(); } catch (Exception ignored) {}
        try { if (pstItems != null) pstItems.close(); } catch (Exception ignored) {}
        try { if (rsOrder != null) rsOrder.close(); } catch (Exception ignored) {}
        try { if (pstOrder != null) pstOrder.close(); } catch (Exception ignored) {}
        try { if (con != null) con.close(); } catch (Exception ignored) {}
    }
%>

<div class="order-container">
    <h1 class="order-heading">🎉 Order #<%= esc(orderId) %> Placed</h1>

    <div class="order-meta">
        <div>Placed on: <strong><%= esc(createdAt) %></strong></div>
        <div>Order status: <strong><%= esc(status) %></strong></div>
        <div><%= (userId == null ? "Guest order" : "Account order: User ID " + esc(userId)) %></div>
    </div>

    <div class="order-summary">
        <div>
            <p><strong>Items</strong></p>
            <p class="order-note">Below is a summary of items in your order.</p>
        </div>
        <div style="text-align:right;">
            <p><strong>Order Total</strong></p>
            <p style="font-size:20px; color:#2e7d32;">₹<%= String.format("%.2f", orderTotal) %></p>
        </div>
    </div>

    <table class="order-table">
        <thead>
            <tr>
                <th>Product</th>
                <th>Size</th>
                <th>Qty</th>
                <th>Price</th>
                <th>Subtotal</th>
            </tr>
        </thead>
        <tbody>
        <%
            double itemsSum = 0.0;
            for (Map<String,Object> it : items) {
                String itName = String.valueOf(it.getOrDefault("name", ""));
                String itSize = String.valueOf(it.getOrDefault("size", ""));
                int qty = ((Number) it.getOrDefault("quantity", 1)).intValue();
                double p = ((Number) it.getOrDefault("price", 0.0)).doubleValue();
                double sub = p * qty;
                itemsSum += sub;
        %>
            <tr>
                <td><%= esc(itName) %></td>
                <td><%= esc(itSize) %></td>
                <td><%= qty %></td>
                <td>₹<%= String.format("%.2f", p) %></td>
                <td>₹<%= String.format("%.2f", sub) %></td>
            </tr>
        <%
            }
        %>
        </tbody>
        <tfoot>
            <tr class="order-total">
                <td colspan="4" style="text-align:right;">Items total:</td>
                <td>₹<%= String.format("%.2f", itemsSum) %></td>
            </tr>
            <tr class="order-total">
                <td colspan="4" style="text-align:right;">Donation:</td>
                <td>₹<%= String.format("%.2f", donationAmount) %></td>
            </tr>
            <tr class="order-total">
                <td colspan="4" style="text-align:right;">Grand total:</td>
                <td>₹<%= String.format("%.2f", orderTotal) %></td>
            </tr>
        </tfoot>
    </table>

    <div style="margin-top:14px;">
        <% if (donationAmount > 0) { %>
            <p class="order-note">Thank you for contributing ₹<%= String.format("%.2f", donationAmount) %> to our partner NGOs — your support matters!</p>
        <% } else { %>
            <p class="order-note">You did not add a donation to this order. You can add donations anytime from the Donate page.</p>
        <% } %>

        <a class="btn-primary" href="products.jsp">Continue Shopping</a>
    </div>
</div>

</body>
</html>
