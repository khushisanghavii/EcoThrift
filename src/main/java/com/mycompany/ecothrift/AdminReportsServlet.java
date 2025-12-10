package com.mycompany.ecothrift;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {

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

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // totals
            req.setAttribute("totalOrders", getCount(conn, "SELECT COUNT(*) FROM orders"));
            req.setAttribute("totalDonations", getCount(conn, "SELECT COUNT(*) FROM donations"));
            req.setAttribute("ordersWithDonationAmount",
                    getCount(conn, "SELECT COUNT(*) FROM orders WHERE donation_amount > 0"));
            req.setAttribute("distinctDonorsCount",
                    getCount(conn, "SELECT COUNT(DISTINCT user_id) FROM donations"));

            /* -------- NGO COUNTS (donationform) -------- */
            List<Map<String,Object>> ngoCounts = new ArrayList<>();
            String sql = "SELECT COALESCE(NULLIF(ngo_name,''),'Other') AS ngo, COUNT(*) AS cnt " +
                         "FROM donationform GROUP BY ngo ORDER BY cnt DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("ngo", rs.getString("ngo"));
                    m.put("count", rs.getInt("cnt"));
                    ngoCounts.add(m);
                }
            }
            req.setAttribute("ngoCounts", ngoCounts);

            /* -------- DONATIONS SERIES -------- */
            List<Map<String,Object>> donationsSeries = new ArrayList<>();
            sql = "SELECT DATE_FORMAT(donation_date, '%Y-%m') AS month, SUM(amount), COUNT(*) " +
                  "FROM donations WHERE donation_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                  "GROUP BY month ORDER BY month ASC";
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> m = new HashMap<>();
                    m.put("month", rs.getString(1));
                    m.put("total_amount", rs.getInt(2));
                    m.put("donations_count", rs.getInt(3));
                    donationsSeries.add(m);
                }
            }
            req.setAttribute("donationsSeries", donationsSeries);

            req.getRequestDispatcher("/admin/reports.jsp").forward(req, resp);

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
