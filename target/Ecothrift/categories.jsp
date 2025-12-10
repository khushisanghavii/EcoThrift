<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Shop • Categories • EcoThrift</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .cats { max-width:1100px; margin:40px auto; display:grid; grid-template-columns: repeat(auto-fit,minmax(220px,1fr)); gap:20px; padding:0 16px;}
    .cat { background:#fff; padding:24px; border-radius:12px; text-align:center; box-shadow:0 6px 18px rgba(0,0,0,0.06); }
    .cat h3 { margin:0 0 8px; }
    .cat p { color:#666; font-size:14px; }
    .cat a { display:inline-block; margin-top:12px; padding:8px 12px; background:#2f8f3f; color:#fff; border-radius:8px; text-decoration:none; }
  </style>
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
  </nav>
</header>

<main>
  <section style="max-width:1100px;margin:28px auto;padding:0 16px;">
    <h1>Shop by category</h1>
    <div class="cats">
      <div class="cat">
        <h3>Women's Collection</h3>
        <p>Discover curated second-hand pieces for women.</p>
        <a href="${pageContext.request.contextPath}/products?category=women">Browse Women</a>
      </div>

      <div class="cat">
        <h3>Men's Collection</h3>
        <p>Stylish and sustainable picks for men.</p>
        <a href="${pageContext.request.contextPath}/products?category=men">Browse Men</a>
      </div>

      <div class="cat">
        <h3>Kids' Collection</h3>
        <p>Comfortable and affordable finds for kids.</p>
        <a href="${pageContext.request.contextPath}/products?category=kids">Browse Kids</a>
      </div>

      <div class="cat">
        <h3>All Products</h3>
        <p>See everything available right now.</p>
        <a href="${pageContext.request.contextPath}/products?show=all">Browse All</a>
      </div>
    </div>
  </section>
</main>

<footer style="text-align:center;margin:40px 0;color:#666;">
  © 2025 EcoThrift
</footer>
</body>
</html>
