<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>

<%
    List<Map<String,Object>> donations = (List<Map<String,Object>>) request.getAttribute("donations");
    if (donations == null) donations = new ArrayList<>();
    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>

<!DOCTYPE html>
<html>
<head>
    <title>My Donations | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        .donation-box {
            width: 80%;
            margin: 20px auto;
            background:#fff;
            padding:20px;
            border-radius:10px;
            box-shadow:0 0 10px rgba(0,0,0,0.1);
        }

        table { width:100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border-bottom: 1px solid #ddd; padding: 10px; }
        th { background:#f4f4f4; }

        /* ====== MODAL FIX + RESPONSIVE ====== */
        #reportModal {
            display:none;
            position:fixed;
            left:0; top:0;
            width:100%; height:100%;
            background:rgba(0,0,0,0.5);
            justify-content:center;
            align-items:center;
            padding: 20px;
            z-index: 9999;
        }

        .modal-content {
            background:#fff;
            width: 90%;
            max-width: 650px;
            max-height: 90vh;
            overflow-y: auto;
            padding: 20px;
            border-radius: 12px;
            box-shadow:0 0 15px rgba(0,0,0,0.3);
        }

        .modal-content canvas {
            width: 100% !important;
            height: auto !important;
            max-height: 320px;
        }

        #thanksLine {
            text-align:center;
            margin-top:15px;
            color:#2e7d32;
            font-weight:bold;
            display:none;
        }
    </style>
</head>

<body>

<!-- HEADER -->
<header>
    <div class="logo">EcoThrift</div>

    <nav>
  <a href="${pageContext.request.contextPath}/index.jsp">Home</a>
  <a href="${pageContext.request.contextPath}/products">Shop</a>
  <a href="${pageContext.request.contextPath}/donate.jsp">Donate</a>
  <a href="${pageContext.request.contextPath}/about.jsp">About</a>
  <a href="${pageContext.request.contextPath}/cart.jsp">Cart</a>

  <%
    HttpSession __s = request.getSession(false);
    String user = (__s == null) ? null : (String) __s.getAttribute("username");
  %>

  <% if (user == null) { %>
      <a href="${pageContext.request.contextPath}/login.jsp" class="btn">Login</a>
      <a href="${pageContext.request.contextPath}/register.jsp" class="btn">Register</a>
  <% } else { %>
      <a href="${pageContext.request.contextPath}/orders.jsp">My Orders</a>
      <a href="${pageContext.request.contextPath}/DonationListServlet">My Donations</a>
      <span style="margin-left:10px; font-weight:bold;">Hi, <%= user %></span>
      <a href="${pageContext.request.contextPath}/LogoutServlet" class="btn">Logout</a>
  <% } %>
</nav>

    </nav>
</header>

<!-- MAIN CONTENT -->
<main>
    <h2 style="text-align:center; margin-top:30px;">Your Donations</h2>

    <div style="text-align:center;">
        <button onclick="openReport()" class="btn">View Donation Report</button>
    </div>

    <div class="donation-box">
        <% if (donations.isEmpty()) { %>

            <p style="text-align:center;">You haven't made any donations yet.</p>

        <% } else { %>

            <table>
                <tr>
                    <th>Type</th>
                    <th>Items</th>
                    <th>NGO</th>
                    <th>Pickup</th>
                    <th>Status</th>
                    <th>Photo</th>
                </tr>

                <% for (Map<String,Object> d : donations) { %>
                    <tr>
                        <td><%= d.get("donation_type") %></td>
                        <td><%= d.get("donated_items") %></td>
                        <td><%= d.get("ngo_name") != null ? d.get("ngo_name") : d.get("other_ngo") %></td>
                        <td><%= df.format((java.sql.Timestamp)d.get("pickup_datetime")) %></td>
                        <td><%= d.get("status") %></td>
                        <td>
                              <% String img = (String) d.get("imageUrl"); %>
                              <% if (img != null) { %>
                                <img src="<%= img %>" width="80">
                              <% } else { %>
                                -
                              <% } %>
                        </td>

                    </tr>
                <% } %>
            </table>

        <% } %>
    </div>
</main>

<!-- ===== REPORT MODAL ===== -->
<div id="reportModal">
    <div class="modal-content">
        <h2 style="text-align:center;">Donation Report</h2>

        <h3>Items Donation Distribution</h3>
        <canvas id="itemsPie"></canvas>
        <p id="itemsSummary" style="text-align:center;"></p>

        <h3>Monetary Donations</h3>
        <canvas id="monetaryPie"></canvas>
        <p id="monetarySummary" style="text-align:center;"></p>

        <p id="thanksLine">
            Thank you for contributing to EcoThrift's mission. We are truly grateful! 💚
        </p>

        <div style="text-align:center; margin-top:20px;">
            <button onclick="closeReport()" class="btn">Close</button>
        </div>
    </div>
</div>

<!-- ===== JAVASCRIPT FOR REPORT ===== -->
<script>
function openReport() {
    fetch("DonationReportServlet")
        .then(r => r.json())
        .then(data => {
            if (!data.ok) {
                alert("Unable to load report");
                return;
            }

            /* ==== ITEMS PIE ==== */
            const items = data.items_distribution || {};
            const rawLabels = Object.keys(items);
            const values = Object.values(items).map(v => Number(v) || 0);

            // CLEAN / PRETTY DISPLAY LABELS and fix typos like "foe" -> "for"
            const displayLabels = rawLabels.map(l => {
                let s = String(l || "");
                // common typo fixes
                s = s.replace(/foe/gi, "for");
                s = s.replace(/\bmens\b/gi, "men");
                s = s.replace(/\bwomans\b/gi, "women");
                s = s.replace(/\bmen's\b/gi, "men");
                s = s.replace(/\bwomen's\b/gi, "women");
                s = s.replace(/\bkid(s)?\b/gi, "kids");
                // trim and normalize spacing
                s = s.replace(/\s+/g, " ").trim();
                // Title case for display
                s = s.split(" ").map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");
                return s;
            });

            // choose colors based on whole-word matching (safer)
            const colors = rawLabels.map(l => {
                const typeLower = String(l || "").toLowerCase();
                // check 'women' first so "women" doesn't accidentally match 'men'
                if (/\bwomen\b/.test(typeLower)) return "#FF4FA3";   // pink
                if (/\bwomen's\b/.test(typeLower)) return "#FF4FA3";
                if (/\bwom\b/.test(typeLower)) return "#FF4FA3"; // fallback
                if (/\bmen\b/.test(typeLower)) return "#3A7BFF";     // blue
                if (/\bmen's\b/.test(typeLower)) return "#3A7BFF";
                if (/\bkid/.test(typeLower)) return "#A066FF";     // purple
                // fallback color
                return "#8ad8c7";
            });

            if (window.itemsChart) window.itemsChart.destroy();

            window.itemsChart = new Chart(document.getElementById("itemsPie"), {
                type: "pie",
                data: {
                    labels: displayLabels,
                    datasets: [{ data: values, backgroundColor: colors }]
                },
                options: {
                    plugins: {
                        legend: {
                            position: 'top'
                        }
                    }
                }
            });

            // safe numeric formatting for summary
            const itemsTotal = Number(data.items_total) || values.reduce((a,b) => a+b, 0);
            const itemsUserTotal = Number(data.items_user_total) || 0;
            const itemsUserPct = Number(data.items_user_percentage);
            const itemsUserPctDisplay = isNaN(itemsUserPct) ? (itemsTotal ? (itemsUserTotal/itemsTotal*100).toFixed(2) : "0.00") : itemsUserPct.toFixed(2);

            document.getElementById("itemsSummary").innerHTML =
                "Platform Total: <strong>" + itemsTotal + "</strong> • " +
                "Your Items: <strong>" + itemsUserTotal + "</strong> " +
                "(" + itemsUserPctDisplay + "%)";


            /* ==== MONETARY PIE ==== */
            const m = data.monetary || {};
            const mPlatform = Number(m.platform_total) || 0;
            const mUser = Number(m.user_total) || 0;
            const mUserPct = (mPlatform > 0) ? ((mUser / mPlatform) * 100).toFixed(2) : (Number(m.user_percentage) ? Number(m.user_percentage).toFixed(2) : "0.00");

            if (window.monetaryChart) window.monetaryChart.destroy();

            window.monetaryChart = new Chart(document.getElementById("monetaryPie"), {
                type: "pie",
                data: {
                    labels: ["You", "Others"],
                    datasets: [{
                        data: [mUser, Math.max(0, mPlatform - mUser)],
                        backgroundColor: ["#2ecc71", "#cccccc"]
                    }]
                },
                options: {
                    plugins: {
                        legend: {
                            position: 'top'
                        }
                    }
                }
            });

            document.getElementById("monetarySummary").innerHTML =
                "Platform Total: <strong>₹" + mPlatform + "</strong> • " +
                "You Donated: <strong>₹" + mUser + "</strong> " +
                "(" + mUserPct + "%)";

            document.getElementById("thanksLine").style.display = "block";
            document.getElementById("reportModal").style.display = "flex";
        })
        .catch(err => {
            console.error("Report fetch error:", err);
            alert("Unable to load report");
        });
}

function closeReport() {
    document.getElementById("reportModal").style.display = "none";
}
</script>

</body>
</html>
