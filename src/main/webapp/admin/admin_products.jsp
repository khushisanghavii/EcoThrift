<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    List<Map<String,Object>> products = (List<Map<String,Object>>) request.getAttribute("products");
    if (products == null) products = new ArrayList<>();
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Admin • Products</title>
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
  <link rel="stylesheet" href="<%=request.getContextPath()%>/css/admin.css">
  <meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
<div class="admin-wrap">
  <aside class="sidebar" role="navigation">
    <div class="brand">EcoThrift Admin</div>
    <a href="<%=request.getContextPath()%>/admin/dashboard" class="nav-item">Dashboard</a>
    <a href="<%=request.getContextPath()%>/admin/products" class="nav-item active">Products</a>
    <a href="<%=request.getContextPath()%>/admin/orders" class="nav-item">Orders</a>
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
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
      <div>
        <h1 style="margin:0 0 6px 0;">Products</h1>
        <div style="color:#666;font-size:14px;">Manage products, inventory and sizes</div>
      </div>
      <div style="display:flex;gap:8px;align-items:center;">
        <a class="btn" href="<%=request.getContextPath()%>/admin/addProduct.jsp">+ Add Product</a>
      </div>
    </div>

    <div class="kpis">
      <div class="kpi"><div style="font-size:18px;font-weight:700;"><%= products.size() %></div><div style="color:#666;font-size:12px;">Total</div></div>
      <div class="kpi"><div style="font-size:18px;font-weight:700;"><%= products.stream().filter(p->(Integer)p.get("active")==1).count() %></div><div style="color:#666;font-size:12px;">Active</div></div>
      <div class="kpi"><div style="font-size:18px;font-weight:700;"><%= products.stream().filter(p->(Integer)p.get("active")==0).count() %></div><div style="color:#666;font-size:12px;">Inactive</div></div>
    </div>

    <div class="panel">
      <strong>All products</strong>
      <div style="float:right;color:#666">Total: <%= products.size() %></div>
      <div style="clear:both"></div>

      <div class="products-grid">
        <% for (Map<String,Object> p : products) {
             int id = (Integer)p.get("id");
             String name = (String)p.get("name");
             String cat = (String)p.get("category");
             Object priceObj = p.get("price");
             double price = priceObj==null?0: (priceObj instanceof Double ? (Double)priceObj : ((Number)priceObj).doubleValue());
             String img = (String)p.get("image");
             int active = p.get("active") == null ? 1 : (Integer)p.get("active");
        %>
          <div class="prod">
            <img src="<%= (img != null && !img.isEmpty()) ? (request.getContextPath() + "/" + img) : (request.getContextPath() + "/images/placeholder.png") %>" alt="<%=name%>">
            <div style="flex:1">
              <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                <div>
                  <strong style="font-size:15px;"><%=name%></strong><br/>
                  <small style="color:#666;"><%= (cat==null? "uncategorized" : cat) %></small>
                </div>
                <div style="text-align:right;">
                  <div style="font-weight:700">₹<%= String.format("%.0f", price) %></div>
                  <div style="color:#999;font-size:12px;"><%= active==1 ? "Active" : "Inactive" %></div>
                </div>
              </div>

              <div class="actions" style="margin-top:10px;">
                <a class="btn ghost" href="<%=request.getContextPath()%>/admin/editProduct?productId=<%=id%>">Edit</a>
                <a class="btn ghost" href="<%=request.getContextPath()%>/admin/sizes?productId=<%=id%>">Sizes</a>

                <form action="<%=request.getContextPath()%>/admin/deleteProduct" method="post" style="display:inline" onsubmit="return confirm('Deactivate product?');">
                  <input type="hidden" name="productId" value="<%=id%>">
                  <button class="btn danger" style="border:none;padding:8px 10px;border-radius:8px;color:#fff">Delete</button>
                </form>
              </div>
            </div>
          </div>
        <% } %>
      </div>
    </div>

  </main>
</div>
</body>
</html>
