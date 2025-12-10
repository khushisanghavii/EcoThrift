<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>

<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    List<Map<String,Object>> donations = (List<Map<String,Object>>) request.getAttribute("donations");
    if (donations == null) donations = new ArrayList<>();
    String err = (String) request.getAttribute("error");
    String ctx = request.getContextPath();
    String placeholder = ctx + "/images/placeholder.png";
%>
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Admin • Donations</title>
  <link rel="stylesheet" href="<%=ctx%>/css/style.css">
  <link rel="stylesheet" href="<%=ctx%>/css/admin.css">
  <style>
    .container { padding:20px; }
    table.table { width:100%; border-collapse: collapse; }
    table.table th, table.table td { padding:8px 10px; border-bottom:1px solid #eee; text-align:left; vertical-align:middle; }
    .btn { background:#2f9d3e; color:#fff; padding:6px 10px; border-radius:8px; text-decoration:none; display:inline-block;}
    .btn.ghost { background:transparent; color:#2f9d3e; border:1px solid #2f9d3e; }
    .thumb { max-width:80px; max-height:80px; object-fit:cover; border-radius:6px; cursor:pointer; }
    .actions form { display:inline-block; margin-right:6px; }
    .error-box { background:#ffdede;padding:10px;border-radius:6px;margin-bottom:10px;color:#900; }
  </style>
</head>
<body>
<div class="admin-wrap">
  <aside class="sidebar">
    <div class="brand">EcoThrift Admin</div>
    <a href="<%=ctx%>/admin/dashboard" class="nav-item">Dashboard</a>
    <a href="<%=ctx%>/admin/products" class="nav-item">Products</a>
    <a href="<%=ctx%>/admin/orders" class="nav-item">Orders</a>
    <a href="<%=ctx%>/admin/donations" class="nav-item active">Donations</a>
    <a href="<%=ctx%>/admin/users" class="nav-item">Users</a>
    <a href="<%=ctx%>/admin/reports" class="nav-item">Reports</a>
    <div style="margin-top:18px;">
      <span class="small">Logged in as</span>
      <div style="font-weight:700;margin-top:6px;"><%= session.getAttribute("username") %></div>
      <a href="<%=ctx%>/LogoutServlet" class="nav-item" style="margin-top:10px;background:#d9534f;color:#fff;">Logout</a>
    </div>
  </aside>

  <main class="main">
    <div class="container">
      <h1>Donations</h1>
      <p style="color:#666">Manage donation requests and mark them completed after pickup.</p>
      <% if (err != null) { %>
        <div class="error-box"><%= err %></div>
      <% } %>

      <table class="table">
        <thead>
          <tr><th>#</th><th>Donor</th><th>Pickup</th><th>NGO</th><th>Item</th><th>Photo</th><th>Status</th><th>Notes</th><th>Actions</th></tr>
        </thead>
        <tbody>
        <% if (donations.isEmpty()) { %>
          <tr><td colspan="9" style="padding:20px;text-align:center;color:#666;">No donations to show.</td></tr>
        <% } else {
             int idx = 1;
             for (Map<String,Object> d : donations) {
               String id = (d.get("id") == null ? "" : d.get("id").toString());
               String name = d.get("name") == null ? "-" : d.get("name").toString();
               String email = d.get("email") == null ? "" : d.get("email").toString();
               String pickup = (d.get("pickup_datetime") == null ? "-" : d.get("pickup_datetime").toString());
               String ngo = d.get("ngo_name") == null ? "-" : d.get("ngo_name").toString();
               String item = (d.get("donated_item") != null) ? d.get("donated_item").toString() : (d.get("donation_type") == null ? "-" : d.get("donation_type").toString());
               String rawPhoto = (d.get("donation_photo_path") == null ? "" : d.get("donation_photo_path").toString());
               String imageUrl = (d.get("imageUrl") == null ? "" : d.get("imageUrl").toString());
               String status = d.get("status") == null ? "-" : d.get("status").toString();
               String notes = d.get("notes") == null ? "" : d.get("notes").toString();

               String finalSrc = null;
               if (imageUrl != null && !imageUrl.trim().isEmpty()) finalSrc = imageUrl.trim();
               else if (rawPhoto != null && !rawPhoto.trim().isEmpty()) {
                   String clean = rawPhoto.replace("\\","/").trim();
                   if (clean.contains("EcothriftUploads")) clean = clean.substring(clean.lastIndexOf('/') + 1);
                   while (clean.startsWith("/")) clean = clean.substring(1);
                   if (!clean.isEmpty()) finalSrc = ctx + "/uploads/" + clean;
               }
               if (finalSrc == null || finalSrc.trim().isEmpty()) finalSrc = placeholder;
               String linkId = "imgLink_" + id + "_" + idx;
        %>

          <tr>
            <td><%= idx++ %></td>
            <td><strong><%= name %></strong><br/><small><%= email %></small></td>
            <td><%= pickup %></td>
            <td><%= ngo %></td>
            <td><%= item %></td>

            <td>
              <a id="<%=linkId%>" href="<%=finalSrc%>" target="_blank" rel="noopener noreferrer">
                <img class="thumb" src="<%=finalSrc%>" alt="Donation photo" title="<%=finalSrc%>"
                     onerror="this.onerror=null; this.src='<%=placeholder%>'; document.getElementById('<%=linkId%>').href='<%=placeholder%>';">
              </a>
            </td>

            <td><%= status %></td>
            <td><%= notes %></td>

            <td class="actions">
              <form method="post" action="<%=ctx%>/admin/donations" style="display:inline">
                <input type="hidden" name="id" value="<%= id %>">
                <input type="hidden" name="action" value="approve">
                <button class="btn" type="submit">Accept</button>
              </form>

              <form method="post" action="<%=ctx%>/admin/donations" style="display:inline">
                <input type="hidden" name="id" value="<%= id %>">
                <input type="hidden" name="action" value="reject">
                <button class="btn ghost" type="submit">Reject</button>
              </form>

              <form method="post" action="<%=ctx%>/admin/donations" style="display:inline">
                <input type="hidden" name="id" value="<%= id %>">
                <input type="hidden" name="action" value="complete">
                <button class="btn ghost" type="submit">Complete</button>
              </form>
            </td>
          </tr>

        <%  } } %>
        </tbody>
      </table>
    </div>
  </main>
</div>
</body>
</html>
