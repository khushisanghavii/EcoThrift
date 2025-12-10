<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
  if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
      response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  Map<String,Object> product = (Map<String,Object>) request.getAttribute("product");
  if (product == null) { response.sendRedirect(request.getContextPath()+"/admin/products"); return; }
%>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Edit Product • Admin</title>
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
      <h2 style="margin:0">Edit: <%= product.get("name") %></h2>
      <a class="btn ghost" href="<%=request.getContextPath()%>/admin/products">Back</a>
    </div>

    <div class="panel">
      <form action="<%=request.getContextPath()%>/admin/editProduct" method="post" accept-charset="utf-8">
        <input type="hidden" name="productId" value="<%= product.get("id") %>">

        <div style="margin-bottom:12px">
          <label>Name</label>
          <input name="name" value="<%= product.get("name") %>" required style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
        </div>

        <div style="margin-bottom:12px">
          <label>Description</label>
          <textarea name="description" rows="4" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd"><%= product.get("description")==null?"":product.get("description") %></textarea>
        </div>

        <div style="display:flex;gap:12px;margin-bottom:12px">
          <div style="flex:1">
            <label>Price (₹)</label>
            <input name="price" type="number" step="0.01" value="<%= product.get("price") %>" required style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
          </div>
          <div style="width:220px">
            <label>Category</label>
            <select name="category" style="width:100%;padding:8px;border-radius:8px;border:1px solid #ddd">
              <option <%= "men".equals(product.get("category"))? "selected":"" %>>men</option>
              <option <%= "women".equals(product.get("category"))? "selected":"" %>>women</option>
              <option <%= "kids".equals(product.get("category"))? "selected":"" %>>kids</option>
              <option <%= "other".equals(product.get("category"))? "selected":"" %>>other</option>
            </select>
          </div>
        </div>

        <div style="margin-bottom:12px">
          <label>Active</label>
          <input type="checkbox" name="active" <%= ((Integer)product.get("active"))==1 ? "checked":"" %> >
        </div>

        <div style="margin-top:10px">
          <button class="btn" type="submit">Save changes</button>
          <a class="btn ghost" href="<%=request.getContextPath()%>/admin/sizes?productId=<%=product.get("id")%>">Manage sizes</a>
        </div>
      </form>
    </div>
  </main>
</div>
</body>
</html>
