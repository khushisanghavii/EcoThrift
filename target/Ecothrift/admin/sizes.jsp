<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
  if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
      response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
  }
  Map<String,Object> product = (Map<String,Object>) request.getAttribute("product");
  List<Map<String,Object>> sizes = (List<Map<String,Object>>) request.getAttribute("sizes");
  if (product == null) { response.sendRedirect(request.getContextPath()+"/admin/products"); return; }
  if (sizes == null) sizes = new ArrayList<>();
%>
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Manage Sizes • <%= product.get("name") %></title>
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
      <div>
        <h2 style="margin:0"><%= product.get("name") %></h2>
        <div class="small">Product ID: <%= product.get("id") %> — Manage sizes & stock</div>
      </div>
      <div>
        <a class="btn ghost" href="<%=request.getContextPath()%>/admin/products">Back</a>
      </div>
    </div>

    <div class="panel">
      <form action="<%=request.getContextPath()%>/admin/updateSizes" method="post">
        <input type="hidden" name="productId" value="<%= product.get("id") %>">

        <h3>Existing sizes</h3>
        <div id="existing">
          <% for (Map<String,Object> s : sizes) { %>
            <div class="row">
              <input type="hidden" name="sizeId[]" value="<%= s.get("id") %>">
              <input name="sizeExisting[]" value="<%= s.get("size") %>" style="width:220px" required>
              <input name="qtyExisting[]" value="<%= s.get("quantity") %>" style="width:120px" required>
              <button type="button" onclick="this.parentElement.remove()" class="btn ghost">Remove</button>
            </div>
          <% } %>
          <% if (sizes.isEmpty()) { %>
            <div class="small" style="margin-bottom:10px;color:#666">No sizes yet. Add new below.</div>
          <% } %>
        </div>

        <hr style="margin:12px 0">

        <h3>Add new sizes</h3>
        <div id="newRows"></div>
        <div style="margin-top:8px">
          <button type="button" onclick="addNew()" class="btn ghost">+ Add new size</button>
        </div>

        <div style="margin-top:16px; display:flex; gap:8px;">
          <button type="submit" class="btn">Save sizes</button>
          <a class="btn ghost" href="<%=request.getContextPath()%>/admin/products">Cancel</a>
        </div>
      </form>
    </div>
  </main>
</div>

<script>
function addNew(){
  const container = document.getElementById('newRows');
  const div = document.createElement('div');
  div.className = 'row';
  div.innerHTML = '<input name="sizeNew[]" placeholder="Size (XS or 28)" style="width:220px" required> <input name="qtyNew[]" placeholder="Qty" style="width:120px" required> <button type="button" onclick="this.parentElement.remove()" class="btn ghost">Remove</button>';
  container.appendChild(div);
}
</script>
</body>
</html>
