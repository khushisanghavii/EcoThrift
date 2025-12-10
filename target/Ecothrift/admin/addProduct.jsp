<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
  if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
      response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
%>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Add Product • Admin</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin.css">
  <meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
<div class="admin-wrap">
  <aside class="sidebar">
    <div class="brand">EcoThrift Admin</div>
    <a href="<%=request.getContextPath()%>/admin/products" class="nav-item">Products</a>
    <a href="<%=request.getContextPath()%>/admin/orders" class="nav-item">Orders</a>
    <a href="<%=request.getContextPath()%>/LogoutServlet" class="nav-item" style="margin-top:16px;background:#d9534f;color:#fff">Logout</a>
  </aside>

  <main class="main">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px">
      <h2 style="margin:0">Add Product</h2>
      <a class="btn ghost" href="<%=request.getContextPath()%>/admin/products">Back</a>
    </div>

    <div class="panel">
      <form action="<%=request.getContextPath()%>/admin/addProduct" method="post" accept-charset="utf-8">
        <div style="margin-bottom:12px">
          <label>Name</label>
          <input name="name" required style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
        </div>

        <div style="margin-bottom:12px">
          <label>Description</label>
          <textarea name="description" rows="4" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd"></textarea>
        </div>

        <div style="display:flex;gap:12px;margin-bottom:12px">
          <div style="flex:1">
            <label>Price (₹)</label>
            <input name="price" type="number" step="0.01" required style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
          </div>
          <div style="width:220px">
            <label>Category</label>
            <select name="category" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
              <option>men</option><option>women</option><option>kids</option><option>other</option>
            </select>
          </div>
        </div>

        <div style="margin-bottom:12px">
          <label>Image URL</label>
          <input name="image_url" placeholder="images/example.jpg" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
        </div>

        <div style="margin-top:12px">
          <button class="btn" type="submit">Create product</button>
          <a class="btn ghost" href="<%=request.getContextPath()%>/admin/products">Cancel</a>
        </div>
      </form>
    </div>
  </main>
</div>
</body>
</html>
