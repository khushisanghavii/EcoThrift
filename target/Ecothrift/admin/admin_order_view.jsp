<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    Map<String,Object> order = (Map<String,Object>) request.getAttribute("order");
    List<Map<String,Object>> items = (List<Map<String,Object>>) request.getAttribute("items");
    if (order == null) order = new HashMap<>();
    if (items == null) items = new ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Admin • Order View</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin.css">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    .container { padding:20px; }
    .btn { background:#2f9d3e; color:#fff; padding:6px 10px; border-radius:8px; text-decoration:none; display:inline-block;}
    .btn.ghost { background:transparent; color:#2f9d3e; border:1px solid #2f9d3e; }
    table.table { width:100%; border-collapse: collapse; }
    table.table th, table.table td { padding:8px 10px; border-bottom:1px solid #eee; text-align:left; vertical-align:middle; }
  </style>
</head>
<body>
<div class="admin-wrap">
  <aside class="sidebar" role="navigation">
    <div class="brand">EcoThrift Admin</div>
    <a href="<%=request.getContextPath()%>/admin/dashboard" class="nav-item">Dashboard</a>
    <a href="<%=request.getContextPath()%>/admin/products" class="nav-item">Products</a>
    <a href="<%=request.getContextPath()%>/admin/orders" class="nav-item active">Orders</a>
    <a href="<%=request.getContextPath()%>/admin/donations" class="nav-item">Donations</a>
    <a href="<%=request.getContextPath()%>/admin/users" class="nav-item">Users</a>
    <a href="<%=request.getContextPath()%>/admin/reports" class="nav-item">Reports</a>

    <div style="margin-top:18px;">
      <span class="small">Logged in as</span>
      <div style="font-weight:700;margin-top:6px;"><%= session.getAttribute("username") %></div>
      <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-item" style="margin-top:10px;background:#d9534f;color:#fff;">Logout</a>
    </div>
  </aside>

  <main class="main">
    <div class="container">
      <h1>Order #<%= order.get("id") %></h1>
      <div><strong>Status:</strong> <%= order.get("status") %></div>
      <div><strong>Placed:</strong> <%= order.get("created_at") %></div>
      <div><strong>Shipping address:</strong> <pre><%= order.get("shipping_address") %></pre></div>
      <div><strong>Payment:</strong> <%= order.get("payment_method") %></div>

      <form method="post" style="margin:12px 0;">
        <input type="hidden" name="id" value="<%= order.get("id") %>">
        <select name="status">
          <option value="PLACED" <%= "PLACED".equals(order.get("status")) ? "selected" : "" %>>PLACED</option>
          <option value="SHIPPED" <%= "SHIPPED".equals(order.get("status")) ? "selected" : "" %>>SHIPPED</option>
          <option value="COMPLETED" <%= "COMPLETED".equals(order.get("status")) ? "selected" : "" %>>COMPLETED</option>
          <option value="CANCELLED" <%= "CANCELLED".equals(order.get("status")) ? "selected" : "" %>>CANCELLED</option>
        </select>
        <button class="btn" type="submit">Update Status</button>
      </form>

      <h3>Items</h3>
      <table class="table">
        <thead><tr><th>Product</th><th>Size</th><th>Qty</th><th>Price</th></tr></thead>
        <tbody>
          <% for (Map<String,Object> it : items) {
               String name = (String) it.get("name");
               String size = (String) it.get("size");
               Object qtyObj = it.get("quantity");
               String qty = qtyObj==null ? "0" : qtyObj.toString();
               Object priceObj = it.get("price");
               String price = priceObj==null ? "0" : priceObj.toString();
               String img = (String) it.get("image_url");
          %>
            <tr>
              <td>
                <% if (img != null && !img.isEmpty()) { %>
                  <img src="<%= img %>" style="width:60px;height:60px;object-fit:cover;margin-right:8px;" />
                <% } %>
                <%= name %>
              </td>
              <td><%= size %></td>
              <td><%= qty %></td>
              <td>₹<%= price %></td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
