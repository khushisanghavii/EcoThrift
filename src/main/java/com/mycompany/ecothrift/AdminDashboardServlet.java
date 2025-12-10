package com.mycompany.ecothrift;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    public void init() throws ServletException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (Exception e) {
            throw new ServletException("Driver not found", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // total users
            request.setAttribute("totalUsers", getCount(conn, "SELECT COUNT(*) FROM users"));
            // total orders
            request.setAttribute("totalOrders", getCount(conn, "SELECT COUNT(*) FROM orders"));
            // total donations
            request.setAttribute("totalDonations", getCount(conn, "SELECT COUNT(*) FROM donations"));

            // orders with donation_amount
            request.setAttribute("ordersWithDonationAmount",
                    getCount(conn, "SELECT COUNT(*) FROM orders WHERE donation_amount > 0"));

            // distinct donors
            request.setAttribute("distinctDonorsCount",
                    getCount(conn, "SELECT COUNT(DISTINCT user_id) FROM donations"));

            /* -------- RECENT ORDERS -------- */
            List<Map<String,Object>> recentOrders = new ArrayList<>();
            String sql = "SELECT o.id, o.user_id, u.name AS user_name, o.total, o.donation_amount, o.status, o.created_at " +
                         "FROM orders o LEFT JOIN users u ON o.user_id = u.id ORDER BY o.created_at DESC LIMIT 5";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("user_name", rs.getString("user_name"));
                    m.put("total", rs.getBigDecimal("total"));
                    m.put("donation_amount", rs.getBigDecimal("donation_amount"));
                    m.put("status", rs.getString("status"));
                    m.put("created_at", rs.getTimestamp("created_at"));
                    recentOrders.add(m);
                }
            }
            request.setAttribute("recentOrders", recentOrders);

            /* -------- RECENT DONATIONS -------- */
            List<Map<String,Object>> recentDonations = new ArrayList<>();
            sql = "SELECT d.id, d.user_id, u.name AS user_name, d.amount, d.donation_date " +
                  "FROM donations d LEFT JOIN users u ON d.user_id = u.id ORDER BY d.donation_date DESC LIMIT 5";
            try (PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("id", rs.getInt("id"));
                    m.put("user_name", rs.getString("user_name"));
                    m.put("amount", rs.getInt("amount"));
                    m.put("donation_date", rs.getTimestamp("donation_date"));
                    recentDonations.add(m);
                }
            }
            request.setAttribute("recentDonations", recentDonations);

            RequestDispatcher rd = request.getRequestDispatcher("/admin/dashboard.jsp");
            rd.forward(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    private int getCount(Connection conn, String sql) throws Exception {
        try (PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}
