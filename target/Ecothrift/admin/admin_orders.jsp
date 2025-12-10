<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<Map<String,Object>> orders = (List<Map<String,Object>>) request.getAttribute("orders");
    if (orders == null) orders = new ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Admin • Orders</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin.css">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <style>
    .container { padding:20px; }
    table.table { width:100%; border-collapse: collapse; }
    table.table th, table.table td { padding:8px 10px; border-bottom:1px solid #eee; text-align:left; vertical-align:middle; }
    .btn { background:#2f9d3e; color:#fff; padding:6px 10px; border-radius:8px; text-decoration:none; display:inline-block;}
    .btn.ghost { background:transparent; color:#2f9d3e; border:1px solid #2f9d3e; }
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

    <span class="small">Quick</span>
    <a href="<%=request.getContextPath()%>/admin/addProduct.jsp" class="nav-item">+ Add Product</a>
    <a href="<%=request.getContextPath()%>/admin/products?filter=lowstock" class="nav-item">Low stock</a>

    <div style="margin-top:18px;">
      <span class="small">Logged in as</span>
      <div style="font-weight:700;margin-top:6px;"><%= session.getAttribute("username") %></div>
      <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-item" style="margin-top:10px;background:#d9534f;color:#fff;">Logout</a>
    </div>
  </aside>

  <main class="main">
    <div class="container">
      <h1>Orders</h1>
      <p style="color:#666">Manage and update order status</p>
      <%
        String err = (String) request.getAttribute("error");
        if (err != null) { %>
          <div style="background:#ffdede;padding:10px;border-radius:6px;margin-bottom:10px;"><%=err%></div>
      <% } %>

      <table class="table">
        <thead>
          <tr><th>Order</th><th>User</th><th>Total</th><th>Status</th><th>Placed</th><th>Action</th></tr>
        </thead>
        <tbody>
          <% for (Map<String,Object> o : orders) {
               int id = (Integer)o.get("id");
               String user = (String)o.get("user_name");
               String email = (String)o.get("user_email");
               Object totalObj = o.get("total");
               String total = totalObj==null? "0" : totalObj.toString();
               String status = (String)o.get("status");
               Object created = o.get("created_at");
          %>
            <tr>
              <td><%=id%></td>
              <td><%=user%><br/><small><%=email%></small></td>
              <td>₹<%=total%></td>
              <td><%=status%></td>
              <td><%=created%></td>
              <td>
                <form method="post" style="display:inline-block;">
                  <input type="hidden" name="id" value="<%=id%>">
                  <select name="status" style="padding:6px;border-radius:6px;">
                    <option value="PLACED" <%= "PLACED".equals(status) ? "selected" : "" %>>PLACED</option>
                    <option value="SHIPPED" <%= "SHIPPED".equals(status) ? "selected" : "" %>>SHIPPED</option>
                    <option value="COMPLETED" <%= "COMPLETED".equals(status) ? "selected" : "" %>>COMPLETED</option>
                    <option value="CANCELLED" <%= "CANCELLED".equals(status) ? "selected" : "" %>>CANCELLED</option>
                  </select>
                  <button class="btn" type="submit">Update</button>
                </form>
                <a class="btn ghost" href="<%=request.getContextPath()%>/admin/orders/view?id=<%=id%>">View</a>
              </td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
