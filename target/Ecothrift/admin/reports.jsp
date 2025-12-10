<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Admin Reports - EcoThrift</title>

  <style>
    body{background:#071428;color:#eaf3ff;font-family:Inter,system-ui,Segoe UI,Roboto,Arial;margin:0}
    .wrap{max-width:1200px;margin:28px auto;padding:18px}
    header{display:flex;align-items:center;justify-content:space-between}
    h1{margin:0}
    .grid{display:grid;grid-template-columns:1fr 420px;gap:14px;margin-top:14px}
    .card{background:linear-gradient(180deg,rgba(255,255,255,0.02), rgba(255,255,255,0.01));padding:14px;border-radius:10px}
    table{width:100%;border-collapse:collapse;margin-top:8px}
    thead th{color:#9cb4c9;padding:8px 6px;text-align:left}
    tbody td{padding:8px 6px;border-top:1px solid rgba(255,255,255,0.02)}
    .small{font-size:13px;color:#9bb0c8}
    .btn{padding:8px 12px;border-radius:8px;background:#10b981;color:#fff;text-decoration:none}
  </style>

  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
  <div class="wrap">
    <header>
      <h1>Reports</h1>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/admin/dashboard">Back to Dashboard</a>
      </div>
    </header>

    <div style="height:12px"></div>

    <div class="card" style="margin-bottom:12px">
      <h3 style="margin:0 0 6px 0">Summary</h3>
      <div class="small">Orders: <strong>${totalOrders}</strong> &nbsp; | &nbsp; Donation records: <strong>${totalDonations}</strong> &nbsp; | &nbsp; Orders with donation: <strong>${ordersWithDonationAmount}</strong></div>
    </div>

    <div class="grid">
      <div class="card">
        <h4 style="margin:0 0 8px 0">Monetary donations — last 6 months</h4>
        <canvas id="donationsLine" width="800" height="320"></canvas>

        <h4 style="margin:18px 0 8px 0">Donation forms (NGO distribution)</h4>
        <table>
          <thead><tr><th>NGO</th><th>Count</th></tr></thead>
          <tbody>
            <c:forEach var="n" items="${ngoCounts}">
              <tr><td>${fn:escapeXml(n.ngo)}</td><td>${n.count}</td></tr>
            </c:forEach>
            <c:if test="${empty ngoCounts}">
              <tr><td colspan="2" class="small">No donation form data</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>

      <div class="card">
        <h4 style="margin:0 0 8px 0">NGO distribution (pie)</h4>
        <canvas id="ngoPie" width="400" height="260"></canvas>

        <div style="height:18px"></div>

        <h4 style="margin:0 0 8px 0">Orders vs Donation records</h4>
        <table>
          <tbody>
            <tr><td class="small">Orders</td><td><strong>${totalOrders}</strong></td></tr>
            <tr><td class="small">Donation records</td><td><strong>${totalDonations}</strong></td></tr>
            <tr><td class="small">Distinct donors</td><td><strong>${distinctDonorsCount}</strong></td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- optional donation forms list (if you set donationForms attribute in servlet) -->
    <div style="height:14px"></div>
    <div class="card">
      <h4 style="margin:0 0 8px 0">Recent donation forms (if any)</h4>
      <table>
        <thead><tr><th>#</th><th>Name</th><th>NGO</th><th>Type</th><th>Pickup</th><th>Status</th><th>Action</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${donationForms}">
            <tr>
              <td>${f.id}</td>
              <td>${fn:escapeXml(f.name)}</td>
              <td>${fn:escapeXml(f.ngo_name)}</td>
              <td>${fn:escapeXml(f.donation_type)}</td>
              <td class="small">${f.pickup_datetime}</td>
              <td>
                <c:choose>
                  <c:when test="${fn:toLowerCase(f.status) == 'pending'}">
                    <span style="color:#ffb547;font-weight:700">PENDING</span>
                  </c:when>
                  <c:otherwise>
                    <span class="small">${f.status}</span>
                  </c:otherwise>
                </c:choose>
              </td>
              <td>
                <a class="btn" href="${pageContext.request.contextPath}/admin/changeStatus?type=donationform&id=${f.id}">Change</a>
              </td>
            </tr>
          </c:forEach>
          <c:if test="${empty donationForms}">
            <tr><td colspan="7" class="small">No donation form entries available</td></tr>
          </c:if>
        </tbody>
      </table>
    </div>
  </div>

  <!-- charts JS: use ngoCounts and donationsSeries supplied by servlet -->
  <script>
    (function(){
      // NGO pie data
      var ngoCounts = [];
      <c:if test="${not empty ngoCounts}">
        <c:forEach var="n" items="${ngoCounts}">
          ngoCounts.push({ name: "${fn:escapeXml(n.ngo)}", count: ${n.count} });
        </c:forEach>
      </c:if>

      var ngoLabels = ngoCounts.map(function(x){return x.name});
      var ngoData = ngoCounts.map(function(x){return x.count});

      var ctxPie = document.getElementById('ngoPie').getContext('2d');
      new Chart(ctxPie, {
        type: 'pie',
        data: {
          labels: ngoLabels.length ? ngoLabels : ['No data'],
          datasets: [{
            data: ngoData.length ? ngoData : [1]
          }]
        },
        options: { plugins:{legend:{position:'bottom'}} }
      });

      // donations series
      var donationsSeries = [];
      <c:if test="${not empty donationsSeries}">
        <c:forEach var="d" items="${donationsSeries}">
          donationsSeries.push({ month: "${d.month}", total: ${d.total_amount != null ? d.total_amount : 0}, count: ${d.donations_count != null ? d.donations_count : 0} });
        </c:forEach>
      </c:if>

      var months = donationsSeries.map(function(x){ return x.month });
      var totals = donationsSeries.map(function(x){ return x.total });

      var ctxLine = document.getElementById('donationsLine').getContext('2d');
      new Chart(ctxLine, {
        type: 'line',
        data: {
          labels: months.length ? months : ['--'],
          datasets: [{
            label: 'Total donated',
            data: totals.length ? totals : [0],
            fill: true,
            tension: 0.3
          }]
        },
        options: {
          scales: {
            y: { beginAtZero:true }
          },
          plugins: { legend: { display: false } }
        }
      });
    })();
  </script>
</body>
</html>
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
  <title>Admin Reports - EcoThrift</title>
  <style>
    :root{--accent:#2f8f3f;--text:#0f1724;--bg:#fff;--muted:#4b5563;--glass:rgba(47,143,63,0.06);--danger:#ef4444;font-family:Inter,system-ui,Segoe UI,Roboto,Arial}
    html,body{margin:0;padding:0;background:var(--bg);color:var(--text);height:100%}
    .admin-wrap{display:flex;min-height:100vh}
    .sidebar{width:240px;padding:18px;border-right:1px solid #eef6ee;background:var(--bg)}
    .brand{font-size:20px;font-weight:800;color:var(--accent);margin-bottom:12px}
    .nav-item{display:block;padding:10px 12px;color:var(--accent);text-decoration:none;border-radius:8px;margin-bottom:6px;font-weight:700}
    .nav-item:hover{background:var(--glass)}
    .nav-item.active{background:var(--accent);color:#fff!important}
    .main{flex:1;padding:28px}
    .card{background:#fff;padding:14px;border-radius:10px;box-shadow:0 6px 18px rgba(47,143,63,0.06)}
    table{width:100%;border-collapse:collapse;margin-top:8px}
    thead th{color:var(--muted);padding:8px 6px;text-align:left}
    tbody td{padding:8px 6px;border-top:1px solid #f3f6f4}
    .small{font-size:13px;color:var(--muted)}
    .btn{padding:8px 12px;border-radius:8px;background:var(--accent);color:#fff;text-decoration:none;font-weight:700}
    @media (max-width:900px){.admin-wrap{flex-direction:column}.sidebar{width:100%}.main{padding:16px}}
  </style>
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
          <h1 style="margin:0 0 6px 0">Reports</h1>
          <div class="small">Orders, donations and NGO distribution</div>
        </div>
        <div>
          <a class="btn" href="${pageContext.request.contextPath}/admin/dashboard">Back to Dashboard</a>
        </div>
      </div>

      <div class="card" style="margin-bottom:12px">
        <h3 style="margin:0 0 6px 0">Summary</h3>
        <div class="small">Orders: <strong>${totalOrders}</strong> &nbsp; | &nbsp; Donation records: <strong>${totalDonations}</strong> &nbsp; | &nbsp; Orders with donation: <strong>${ordersWithDonationAmount}</strong></div>
      </div>

      <div style="display:grid;grid-template-columns:1fr 360px;gap:14px">
        <div class="card">
          <h4 style="margin:0 0 8px 0">Monetary donations — last 6 months</h4>
          <table>
            <thead><tr><th>Month</th><th>Total</th><th>Count</th></tr></thead>
            <tbody>
              <c:forEach var="d" items="${donationsSeries}">
                <tr><td>${fn:escapeXml(d.month)}</td><td>${d.total_amount}</td><td>${d.donations_count}</td></tr>
              </c:forEach>
              <c:if test="${empty donationsSeries}">
                <tr><td colspan="3" class="small">No donation series data</td></tr>
              </c:if>
            </tbody>
          </table>

          <h4 style="margin:18px 0 8px 0">Donation forms (NGO distribution)</h4>
          <table>
            <thead><tr><th>NGO</th><th>Count</th></tr></thead>
            <tbody>
              <c:forEach var="n" items="${ngoCounts}">
                <tr><td>${fn:escapeXml(n.ngo)}</td><td>${n.count}</td></tr>
              </c:forEach>
              <c:if test="${empty ngoCounts}">
                <tr><td colspan="2" class="small">No donation form data</td></tr>
              </c:if>
            </tbody>
          </table>
        </div>

        <div class="card">
          <h4 style="margin:0 0 8px 0">NGO distribution</h4>
          <table>
            <thead><tr><th>NGO</th><th class="small">Count</th></tr></thead>
            <tbody>
              <c:forEach var="n" items="${ngoCounts}">
                <tr><td>${fn:escapeXml(n.ngo)}</td><td class="small">${n.count}</td></tr>
              </c:forEach>
              <c:if test="${empty ngoCounts}">
                <tr><td colspan="2" class="small">No data</td></tr>
              </c:if>
            </tbody>
          </table>

          <div style="height:18px"></div>

          <h4 style="margin:0 0 8px 0">Orders vs Donation records</h4>
          <table>
            <tbody>
              <tr><td class="small">Orders</td><td><strong>${totalOrders}</strong></td></tr>
              <tr><td class="small">Donation records</td><td><strong>${totalDonations}</strong></td></tr>
              <tr><td class="small">Distinct donors</td><td><strong>${distinctDonorsCount}</strong></td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div style="height:14px"></div>
      <div class="card">
        <h4 style="margin:0 0 8px 0">Recent donation forms (if any)</h4>
        <table>
          <thead><tr><th>#</th><th>Name</th><th>NGO</th><th>Type</th><th>Pickup</th><th>Status</th><th>Action</th></tr></thead>
          <tbody>
            <c:forEach var="f" items="${donationForms}">
              <tr>
                <td>${f.id}</td>
                <td>${fn:escapeXml(f.name)}</td>
                <td>${fn:escapeXml(f.ngo_name)}</td>
                <td>${fn:escapeXml(f.donation_type)}</td>
                <td class="small">${f.pickup_datetime}</td>
                <td>
                  <c:choose>
                    <c:when test="${fn:toLowerCase(f.status) == 'pending'}">
                      <span style="color:#b45309;font-weight:700">PENDING</span>
                    </c:when>
                    <c:otherwise>
                      <span class="small">${f.status}</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td><a class="btn" href="${pageContext.request.contextPath}/admin/changeStatus?type=donationform&id=${f.id}">Change</a></td>
              </tr>
            </c:forEach>
            <c:if test="${empty donationForms}">
              <tr><td colspan="7" class="small">No donation form entries available</td></tr>
            </c:if>
          </tbody>
        </table>
      </div>
    </main>
  </div>
</body>
</html>
