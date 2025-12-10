package com.mycompany.ecothrift;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/orders")
public class AdminOrdersServlet extends HttpServlet {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
        String user = "root";         // <-- change to your DB user if different
        String pass = ""; // <-- change to your DB password
        return DriverManager.getConnection(url, user, pass);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String,Object>> orders = new ArrayList<>();

        String sql = "SELECT o.id, o.user_id, o.total, o.status, o.created_at, u.name AS user_name, u.email AS user_email " +
                     "FROM orders o LEFT JOIN users u ON u.id=o.user_id ORDER BY o.created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();
                m.put("id", rs.getInt("id"));
                m.put("user_name", rs.getString("user_name"));
                m.put("user_email", rs.getString("user_email"));
                m.put("total", rs.getBigDecimal("total"));
                m.put("status", rs.getString("status"));
                m.put("created_at", rs.getTimestamp("created_at"));
                orders.add(m);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Unable to load orders");
        }

        req.setAttribute("orders", orders);
        // FORWARD TO /admin/admin_orders.jsp (public under web root)
        req.getRequestDispatcher("/admin/admin_orders.jsp").forward(req, resp);
    }

    // update status
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String id = req.getParameter("id");
        String status = req.getParameter("status");

        if (id != null && status != null) {
            String sql = "UPDATE orders SET status=? WHERE id=?";
            try (Connection con = getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, status.toUpperCase());
                ps.setInt(2, Integer.parseInt(id));
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/orders");
    }
}
