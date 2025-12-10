<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>EcoThrift | Home</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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

<main>
    <section class="hero">
        <div class="hero-text" style="padding:40px; text-align:center;">
            <h1>Thrift. Donate. Sustain.</h1>
            <p>Buy second-hand treasures or donate what you don’t use anymore — for a greener tomorrow.</p>
            <!-- corrected: context-path aware link to servlet /products -->
            <a href="${pageContext.request.contextPath}/products" class="cta">Start Shopping</a>
        </div>
    </section>
</main>

<footer>
    <p>© 2025 EcoThrift | Made with love for sustainability</p>
</footer>

</body>
</html>
