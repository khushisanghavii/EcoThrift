package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ce) {
            throw new ServletException("JDBC driver not found", ce);
        }

        String sql = "SELECT id, name, role FROM users WHERE email=? AND password=?";

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int userId = rs.getInt("id");
                    String username = rs.getString("name");
                    String role = rs.getString("role");
                    if (role == null || role.trim().isEmpty()) role = "USER";

                    // create session (or use existing) and store attributes
                    HttpSession session = request.getSession(true);
                    session.setAttribute("username", username);
                    session.setAttribute("userId", userId);
                    session.setAttribute("role", role);
                    // optional: session timeout (seconds)
                    // session.setMaxInactiveInterval(30 * 60);

                    System.out.println("[LOGIN] Logged in as: " + username + " | ROLE = " + role);

                    // redirect using context path so relative URLs still work correctly
                    if ("ADMIN".equalsIgnoreCase(role)) {
                        response.sendRedirect(request.getContextPath() + "/admin/products");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                    }
                    return;
                } else {
                    request.setAttribute("error", "Invalid email or password!");
                    request.getRequestDispatcher("login.jsp").forward(request, response);
                    return;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new ServletException("Database error during login", e);
        }
    }
}
