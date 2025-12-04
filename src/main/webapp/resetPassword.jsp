<%
    String email = request.getParameter("email");
%>

<!DOCTYPE html>
<html>
<head>
    <title>Reset Password | EcoThrift</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="form-page">

<div class="form-container">
    <h2>Reset Password</h2>

    <form action="ResetPasswordServlet" method="post">
        <input type="hidden" name="email" value="<%= email %>">

        <input type="password" name="password" placeholder="New Password" required>
        <input type="password" name="confirmPassword" placeholder="Confirm Password" required>

        <button type="submit">Update Password</button>
    </form>
</div>

</body>
</html>
