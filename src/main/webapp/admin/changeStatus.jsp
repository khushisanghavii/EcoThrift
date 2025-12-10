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
  <title>Change Status - Admin</title>
  <style>
    :root{--accent:#2f8f3f;--text:#0f1724;--bg:#fff;--muted:#4b5563;--glass:rgba(47,143,63,0.06);--danger:#ef4444;font-family:Inter,system-ui,Segoe UI,Roboto,Arial}
    html,body{margin:0;padding:0;background:var(--bg);color:var(--text);height:100%}
    .admin-wrap{display:flex;min-height:100vh}
    .sidebar{width:240px;padding:18px;border-right:1px solid #eef6ee;background:var(--bg)}
    .brand{font-size:20px;font-weight:800;color:var(--accent);margin-bottom:12px}
    .nav-item{display:block;padding:10px 12px;color:var(--accent);text-decoration:none;border-radius:8px;margin-bottom:6px;font-weight:700}
    .nav-item:hover{background:var(--glass)}
    .main{flex:1;padding:28px}
    .card{background:#fff;padding:18px;border-radius:10px;box-shadow:0 6px 18px rgba(47,143,63,0.06)}
    label{display:block;margin-bottom:8px;font-weight:700;color:var(--text)}
    select,input[type=text]{padding:10px;border-radius:8px;border:1px solid #eef3ec;width:320px}
    .btn{padding:9px 14px;border-radius:8px;background:var(--accent);color:#fff;border:none;font-weight:700}
    .btn.ghost{background:transparent;border:1px solid #e6efe6;color:var(--accent)}
    .small-muted{font-size:13px;color:var(--muted)}
    @media (max-width:900px){ .admin-wrap{flex-direction:column} .sidebar{width:100%} .main{padding:16px} }
  </style>
</head>
<body>
  <div class="admin-wrap">
    <aside class="sidebar">
      <div class="brand">EcoThrift Admin</div>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/products">Products</a>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/orders">Orders</a>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/donations">Donations</a>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/users">Users</a>
      <a class="nav-item" href="${pageContext.request.contextPath}/admin/reports">Reports</a>

      <div style="margin-top:18px">
        <div class="small-muted">Logged in as</div>
        <div style="font-weight:700;margin-top:6px">${session.getAttribute("username")}</div>
        <a class="nav-item" href="${pageContext.request.contextPath}/LogoutServlet" style="margin-top:10px;background:var(--danger);color:#fff">Logout</a>
      </div>
    </aside>

    <main class="main">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:18px">
        <div>
          <h1 style="margin:0 0 6px 0">Change status</h1>
          <div class="small-muted">Update record status</div>
        </div>
        <div>
          <a class="btn ghost" href="${pageContext.request.contextPath}/admin/dashboard">← Back to Dashboard</a>
        </div>
      </div>

      <div class="card">
        <div class="small-muted" style="margin-bottom:12px">
          Use this form to update the selected record. Type:
          <strong><c:out value="${param.type}"/></strong> &nbsp; | &nbsp; ID: <strong><c:out value="${param.id}"/></strong>
        </div>

        <c:choose>
          <c:when test="${param.type == 'order'}">
            <form method="post" action="${pageContext.request.contextPath}/admin/changeStatus">
              <input type="hidden" name="type" value="order"/>
              <input type="hidden" name="id" value="${fn:escapeXml(param.id)}"/>
              <label for="status">New order status</label>
              <select id="status" name="status" required>
                <option value="">-- select status --</option>
                <option value="PENDING">PENDING</option>
                <option value="PROCESSING">PROCESSING</option>
                <option value="SHIPPED">SHIPPED</option>
                <option value="DELIVERED">DELIVERED</option>
                <option value="CANCELLED">CANCELLED</option>
                <option value="REFUNDED">REFUNDED</option>
              </select>
              <div class="small-muted" style="margin-top:8px">Tip: choose <strong>DELIVERED</strong> when the order reaches customer, or <strong>CANCELLED</strong> to void it.</div>
              <div style="margin-top:12px">
                <button class="btn" type="submit">Save status</button>
                <a class="btn ghost" href="${pageContext.request.contextPath}/admin/dashboard" style="margin-left:8px">Cancel</a>
              </div>
            </form>
          </c:when>

          <c:when test="${param.type == 'donationform'}">
            <form method="post" action="${pageContext.request.contextPath}/admin/changeStatus">
              <input type="hidden" name="type" value="donationform"/>
              <input type="hidden" name="id" value="${fn:escapeXml(param.id)}"/>
              <label for="status">New donation form status</label>
              <select id="status" name="status" required>
                <option value="">-- select status --</option>
                <option value="PENDING">PENDING</option>
                <option value="SCHEDULED">SCHEDULED</option>
                <option value="PICKEDUP">PICKEDUP</option>
                <option value="COMPLETED">COMPLETED</option>
                <option value="REJECTED">REJECTED</option>
              </select>
              <div class="small-muted" style="margin-top:8px">Use <strong>PICKEDUP</strong> when the pickup is done, <strong>COMPLETED</strong> when donation is received by NGO.</div>
              <div style="margin-top:12px">
                <button class="btn" type="submit">Save status</button>
                <a class="btn ghost" href="${pageContext.request.contextPath}/admin/reports" style="margin-left:8px">Cancel</a>
              </div>
            </form>
          </c:when>

          <c:when test="${param.type == 'donation'}">
            <div class="small-muted">The `donations` table (monetary donations) doesn't include a `status` column. Add a status column (VARCHAR) to enable changing it here.</div>
            <div style="margin-top:12px"><a class="btn" href="${pageContext.request.contextPath}/admin/dashboard">Back to dashboard</a></div>
          </c:when>

          <c:otherwise>
            <div class="small-muted">Unknown type: <strong><c:out value="${param.type}"/></strong>. Use the dashboard links.</div>
            <div style="margin-top:12px"><a class="btn ghost" href="${pageContext.request.contextPath}/admin/dashboard">Back</a></div>
          </c:otherwise>
        </c:choose>
      </div>
    </main>
  </div>
</body>
</html>
