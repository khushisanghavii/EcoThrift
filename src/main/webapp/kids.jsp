<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String,Object>> products = (List<Map<String,Object>>) request.getAttribute("products");
    if (products == null) products = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Kids | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
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

</header>

<section class="products">
    <h2>Kids' Collection</h2>

    <div class="grid">
        <%
            for (Map<String,Object> p : products) {
                if (!"kids".equalsIgnoreCase((String)p.get("category"))) continue;
                int pid = (Integer) p.get("id");
                String name = (String) p.get("name");
                double price = (p.get("price") instanceof Double) ? (Double)p.get("price") : ((Number)p.get("price")).doubleValue();
                String img = (String) p.get("image_url");
                List<Map<String,Object>> sizes = (List<Map<String,Object>>) p.get("sizes");
        %>

        <div class="product">
            <img src="<%= (img != null ? img : "images/placeholder.png") %>" alt="<%=name%>">
            <h4><%=name%></h4>
            <p>₹<%= String.format("%.0f", price) %></p>

            <form action="AddToCartServlet" method="post">
                <input type="hidden" name="productId" value="<%=pid%>">
                <label>Size:</label>
                <select name="size" required>
                    <%
                        if (sizes != null && !sizes.isEmpty()) {
                            for (Map<String,Object> s : sizes) {
                                String sz = (String)s.get("size");
                                int q = (Integer)s.get("quantity");
                                if (q <= 0) {
                    %>
                                    <option value="<%=sz%>" disabled><%=sz%> (Out)</option>
                    <%
                                } else {
                    %>
                                    <option value="<%=sz%>"><%=sz%> (<%=q%>)</option>
                    <%
                                }
                            }
                        } else {
                    %>
                            <option>XS</option><option>S</option><option>M</option>
                    <%
                        }
                    %>
                </select>

                <button type="submit">Add to Cart</button>
            </form>
        </div>

        <% } %>
    </div>

</section>

<footer>
    <p>© 2025 EcoThrift | Sustainable fashion for all ages</p>
</footer>

</body>
</html>
