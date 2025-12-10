package com.mycompany.ecothrift;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/users")
public class AdminUsersServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    public void init() throws ServletException {
        try { Class.forName("com.mysql.cj.jdbc.Driver"); } 
        catch (Exception e) { throw new ServletException(e); }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String q = req.getParameter("q");
        if (q == null) q = "";

        List<Map<String,Object>> users = new ArrayList<>();

        String sql = "SELECT id, name, email, role FROM users " +
                     "WHERE name LIKE ? OR email LIKE ? ORDER BY id DESC";

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + q + "%");
            ps.setString(2, "%" + q + "%");

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> u = new HashMap<>();
                    u.put("id", rs.getInt("id"));
                    u.put("name", rs.getString("name"));
                    u.put("email", rs.getString("email"));
                    u.put("role", rs.getString("role"));
                    users.add(u);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }

        req.setAttribute("users", users);
        req.setAttribute("q", q);

        req.getRequestDispatcher("/admin/users.jsp").forward(req, resp);
    }
}
