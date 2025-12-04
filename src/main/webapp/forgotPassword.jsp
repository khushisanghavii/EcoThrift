<!DOCTYPE html>
<html>
<head>
    <title>Forgot Password | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="form-page">

<div class="form-container">
    <h2>Forgot Password</h2>

    <% 
        String msg = (String) request.getAttribute("message");
        if (msg != null) { 
    %>
        <p style="color:red; text-align:center;"><%= msg %></p>
    <% 
        } 
    %>

    <form action="ForgotPasswordServlet" method="post">
        <input type="email" name="email" placeholder="Enter your registered email" required>
        <button type="submit">Next</button>
    </form>

    <p><a href="login.jsp">Back to Login</a></p>
</div>

</body>
</html>
