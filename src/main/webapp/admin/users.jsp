<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
%>
<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Admin — Users | EcoThrift</title>

  <style>
    :root{
      --accent:#2f8f3f;
      --accent-contrast:#fff;
      --bg:#ffffff;
      --panel:#ffffff;
      --muted:#4b5563;
      --text:#0f1724;
      --glass: rgba(47,143,63,0.06);
      --danger:#ef4444;
      font-family: Inter,system-ui,Segoe UI,Roboto,Arial,Helvetica, sans-serif;
    }
    html,body{margin:0;padding:0;background:var(--bg);color:var(--text);height:100%}
    .admin-wrap{display:flex;min-height:100vh}
    .sidebar{
      width:240px;padding:18px;border-right:1px solid #eef6ee;background:var(--panel);
      box-sizing:border-box;
    }
    .brand{font-size:20px;font-weight:800;color:var(--accent);margin-bottom:12px}
    .nav-item{display:block;padding:10px 12px;color:var(--accent);text-decoration:none;border-radius:8px;margin-bottom:6px;font-weight:700}
    .nav-item:hover{background:var(--glass)}
    .nav-item.active{background:var(--accent);color:var(--accent-contrast)!important}
    .main{flex:1;padding:28px;box-sizing:border-box}
    .card,.panel{background:#fff;padding:16px;border-radius:10px;box-shadow:0 6px 18px rgba(47,143,63,0.06)}
    .search-row{display:flex;gap:8px;margin:12px 0}
    input[type=text]{padding:8px;border-radius:8px;border:1px solid #eef3ec;background:transparent;color:var(--text)}
    .btn{padding:8px 12px;border-radius:8px;background:var(--accent);border:none;color:var(--accent-contrast);text-decoration:none;font-weight:700;cursor:pointer}
    .btn.ghost{background:transparent;color:var(--accent);border:1px solid #e6efe6}
    .btn.warn{background:var(--danger);color:#fff}
    table{width:100%;border-collapse:collapse;margin-top:10px}
    thead th{padding:10px 8px;text-align:left;color:var(--muted);font-size:13px}
    tbody td{padding:10px 8px;border-top:1px solid #f3f6f4;color:var(--text)}
    .small{font-size:12px;color:var(--muted)}
    .role-badge{padding:6px 10px;border-radius:999px;background:var(--glass);font-weight:700;display:inline-block}
    .top-actions{display:flex;gap:8px;align-items:center}
    @media (max-width:900px){ .admin-wrap{flex-direction:column} .sidebar{width:100%;order:2} .main{order:1;padding:16px} }
  </style>

  <script>
    // small helper: confirm delete
    function confirmDelete(url) {
      if(confirm('Delete user? This action cannot be undone.')) {
        window.location = url;
      }
    }
  </script>
</head>
<body>
  <div class="admin-wrap">
    <aside class="sidebar" role="navigation">
      <div class="brand">EcoThrift Admin</div>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/dashboard') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/products') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/products">Products</a>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/orders') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/orders">Orders</a>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/donations') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/donations">Donations</a>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/users') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/users">Users</a>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/reports') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/reports">Reports</a>

      <div style="margin-top:18px">
        <div class="small">Logged in as</div>
        <div style="font-weight:700;margin-top:6px">${session.getAttribute("username")}</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/LogoutServlet" style="margin-top:10px;background:var(--danger);color:#fff">Logout</a>
      </div>
    </aside>

    <main class="main">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
        <div>
          <h1 style="margin:0 0 6px 0">Manage Users</h1>
          <div class="small">View and manage registered users</div>
        </div>
        <div class="top-actions">
          <a class="btn" href="${pageContext.request.contextPath}/admin/dashboard">Back to Dashboard</a>
        </div>
      </div>

      <div class="card">
        <form method="get" action="${pageContext.request.contextPath}/admin/users" class="search-row" style="align-items:center">
          <input type="text" name="q" placeholder="Search name or email" value="${fn:escapeXml(param.q)}" />
          <button class="btn" type="submit">Search</button>
        </form>

        <table>
          <thead><tr><th>ID</th><th>Name</th><th>Email</th><th>Role</th><th>Actions</th></tr></thead>
          <tbody>
            <c:forEach var="u" items="${users}">
              <tr>
                <td>${u.id}</td>
                <td>${fn:escapeXml(u.name)}</td>
                <td><a href="mailto:${fn:escapeXml(u.email)}" style="color:var(--accent)">${fn:escapeXml(u.email)}</a></td>
                <td><span class="role-badge">${u.role}</span></td>
                <td>
                  <a class="btn ghost" href="${pageContext.request.contextPath}/admin/viewUser?id=${u.id}">View</a>
                  <a class="btn" style="margin-left:8px" href="${pageContext.request.contextPath}/admin/changeRole?id=${u.id}">Change Role</a>
                  <a class="btn warn" style="margin-left:8px" href="javascript:void(0)" onclick="confirmDelete('${pageContext.request.contextPath}/admin/deleteUser?id=${u.id}')">Delete</a>
                </td>
              </tr>
            </c:forEach>

            <c:if test="${empty users}">
              <tr><td colspan="5" class="small">No users found</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</body>
</html>
