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
  <title>Admin Dashboard - EcoThrift</title>
  <style>
    :root{
      --accent:#2f8f3f; --text:#0f1724; --bg:#ffffff; --muted:#4b5563; --glass: rgba(47,143,63,0.06);
      --danger:#ef4444; font-family:Inter,system-ui,Segoe UI,Roboto,Arial,Helvetica,sans-serif;
    }
    html,body{margin:0;padding:0;background:var(--bg);color:var(--text);height:100%}
    .admin-wrap{display:flex;min-height:100vh}
    .sidebar{width:240px;padding:18px;border-right:1px solid #eef6ee;background:var(--bg)}
    .brand{font-size:20px;font-weight:800;color:var(--accent);margin-bottom:12px}
    .nav-item{display:block;padding:10px 12px;color:var(--accent);text-decoration:none;border-radius:8px;margin-bottom:6px;font-weight:700}
    .nav-item:hover{background:var(--glass)}
    .nav-item.active{background:var(--accent);color:#fff!important}
    .main{flex:1;padding:28px}
    .card{background:#fff;padding:14px;border-radius:10px;box-shadow:0 6px 18px rgba(47,143,63,0.06)}
    .top-stats{display:flex;gap:12px;flex-wrap:wrap;margin-bottom:18px}
    .stat{background:#fff;padding:12px;border-radius:10px;min-width:160px;box-shadow:0 6px 18px rgba(0,0,0,0.03)}
    .stat small{display:block;color:var(--muted);font-size:12px}
    .stat strong{display:block;font-size:20px;margin-top:6px;color:var(--text)}
    table{width:100%;border-collapse:collapse;margin-top:8px}
    thead th{font-weight:700;text-align:left;padding:10px 8px;color:var(--muted);font-size:13px}
    tbody td{padding:10px 8px;border-top:1px solid #f3f6f4}
    .btn{display:inline-block;padding:6px 10px;border-radius:8px;border:none;background:var(--accent);color:#fff;font-weight:700;text-decoration:none}
    .btn.ghost{background:transparent;border:1px solid #e6efe6;color:var(--accent)}
    .small-muted{font-size:12px;color:var(--muted)}
    @media (max-width:900px){ .admin-wrap{flex-direction:column} .sidebar{width:100%} .main{padding:16px} }
  </style>

  <script>
    // nothing heavy - small helper for cancel links if needed
    function go(url){ location.href = url; }
  </script>
</head>
<body>
  <div class="admin-wrap">
    <aside class="sidebar">
      <div class="brand">EcoThrift Admin</div>
      <a class="nav-item ${pageContext.request.requestURI.contains('/admin/dashboard') ? 'active' : ''}" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a>
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
      <header style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px">
        <div>
          <h1 style="margin:0">EcoThrift — Admin Dashboard</h1>
          <div class="small-muted">Overview</div>
        </div>
        <div>
          <a class="btn ghost" href="${pageContext.request.contextPath}/admin/users">Manage Users</a>
          <a class="btn ghost" href="${pageContext.request.contextPath}/admin/reports">Reports</a>
        </div>
      </header>

      <div class="top-stats">
        <div class="stat">
          <small>Total users</small>
          <strong>${totalUsers}</strong>
        </div>
        <div class="stat">
          <small>Total orders</small>
          <strong>${totalOrders}</strong>
          <div class="small-muted">Orders with donation: ${ordersWithDonationAmount}</div>
        </div>
        <div class="stat">
          <small>Total donations</small>
          <strong>${totalDonations}</strong>
          <div class="small-muted">Unique donors: ${distinctDonorsCount}</div>
        </div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 360px;gap:14px">
        <div>
          <div class="card" style="margin-bottom:12px">
            <h3 style="margin:0 0 8px 0">Recent Orders</h3>
            <div class="small-muted" style="margin-bottom:8px">Latest 5 orders — click pending orders to change status</div>
            <table>
              <thead><tr><th>#</th><th>User</th><th>Total</th><th>Donation</th><th>Status</th><th>Placed</th></tr></thead>
              <tbody>
                <c:forEach var="o" items="${recentOrders}">
                  <tr>
                    <td>${o.id}</td>
                    <td><c:out value="${o.user_name != null ? o.user_name : o.user_id}"/></td>
                    <td>${o.total}</td>
                    <td><c:out value="${o.donation_amount != null ? o.donation_amount : '-'}"/></td>
                    <td>
                      <c:choose>
                        <c:when test="${fn:toLowerCase(o.status) == 'pending'}">
                          <span style="padding:6px 10px;border-radius:999px;background:var(--glass);font-weight:700">PENDING</span>
                          &nbsp;
                          <a class="btn" href="${pageContext.request.contextPath}/admin/changeStatus?type=order&id=${o.id}">Change</a>
                        </c:when>
                        <c:when test="${fn:toLowerCase(o.status) == 'completed' || fn:toLowerCase(o.status) == 'delivered'}">
                          <span style="padding:6px 10px;border-radius:999px;background:rgba(47,143,63,0.12);font-weight:700">${o.status}</span>
                        </c:when>
                        <c:otherwise>
                          <span style="padding:6px 10px;border-radius:999px;background:#f3f6f4;color:var(--muted);font-weight:700">${o.status}</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td class="small-muted">${o.created_at}</td>
                  </tr>
                </c:forEach>
                <c:if test="${empty recentOrders}">
                  <tr><td colspan="6" class="small-muted">No orders yet</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>

          <div class="card">
            <h3 style="margin:0 0 8px 0">Recent Donations</h3>
            <div class="small-muted" style="margin-bottom:8px">Latest 5 donations (from donations table).</div>
            <table>
              <thead><tr><th>#</th><th>User</th><th>Amount</th><th>When</th><th>Action</th></tr></thead>
              <tbody>
                <c:forEach var="d" items="${recentDonations}">
                  <tr>
                    <td>${d.id}</td>
                    <td><c:out value="${d.user_name != null ? d.user_name : d.user_id}"/></td>
                    <td>${d.amount}</td>
                    <td class="small-muted">${d.donation_date}</td>
                    <td><a class="btn ghost" href="${pageContext.request.contextPath}/admin/changeStatus?type=donation&id=${d.id}">Change</a></td>
                  </tr>
                </c:forEach>
                <c:if test="${empty recentDonations}">
                  <tr><td colspan="5" class="small-muted">No donations yet</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>

        <div>
          <div class="card" style="margin-bottom:12px">
            <h4 style="margin:0 0 8px 0">Quick Summary</h4>
            <div class="small-muted" style="display:flex;flex-direction:column;gap:8px">
              <div>Orders: <strong>${totalOrders}</strong></div>
              <div>Donation records: <strong>${totalDonations}</strong></div>
              <div>Orders with donation: <strong>${ordersWithDonationAmount}</strong></div>
              <div>Distinct donors: <strong>${distinctDonorsCount}</strong></div>
            </div>
            <div style="margin-top:12px">
              <a class="btn" href="${pageContext.request.contextPath}/admin/reports">Open Reports</a>
              <a class="btn ghost" style="margin-left:8px" href="${pageContext.request.contextPath}/admin/users">Users</a>
            </div>
          </div>

          <div class="card">
            <h4 style="margin:0 0 8px 0">NGO distribution (preview)</h4>
            <table>
              <thead><tr><th>NGO</th><th class="small-muted">Count</th></tr></thead>
              <tbody>
                <c:forEach var="n" items="${ngoCounts}">
                  <tr><td>${fn:escapeXml(n.ngo)}</td><td class="small-muted">${n.count}</td></tr>
                </c:forEach>
                <c:if test="${empty ngoCounts}">
                  <tr><td colspan="2" class="small-muted">No data</td></tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </main>
  </div>
</body>
</html>
