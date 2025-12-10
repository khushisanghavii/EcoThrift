<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="form-page">
    <div class="form-container">
        <h2>Welcome Back</h2>

        <!-- ? ERROR MESSAGE UI -->
        <%
            String error = (String) request.getAttribute("error");
            if (error != null) {
        %>
            <p style="color:red; text-align:center; margin-bottom:10px;">
                <%= error %>
            </p>
        <%
            }
        %>

        <form action="LoginServlet" method="post">
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>

            <!-- ? FORGOT PASSWORD LINK -->
            <div style="text-align:right; margin-bottom:10px;">
                <a href="forgotPassword.jsp" style="color:#4CAF50; font-size:14px;">
                    Forgot Password?
                </a>
            </div>

            <button type="submit">Login</button>
        </form>

        <p>Don?t have an account? <a href="register.jsp">Register</a></p>
    </div>
</body>
</html>
