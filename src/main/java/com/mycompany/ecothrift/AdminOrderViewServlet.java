package com.mycompany.ecothrift;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/orders/view")
public class AdminOrderViewServlet extends HttpServlet {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
        String user = "root";
        String pass = "";
        return DriverManager.getConnection(url, user, pass);
    }

    // Normalize image URL like user page
    private String normalizeImage(String raw, HttpServletRequest req) {
        if (raw == null || raw.trim().isEmpty()) {
            return req.getContextPath() + "/images/placeholder.png";
        }

        String p = raw.trim();

        // If already absolute URL → return as-is
        if (p.startsWith("http://") || p.startsWith("https://"))
            return p;

        // If DB stored absolute file path → convert to filename only
        if (p.contains("EcothriftUploads")) {
            int idx = p.lastIndexOf("/");
            p = (idx >= 0) ? p.substring(idx + 1) : p;
            return req.getContextPath() + "/uploads/" + p;
        }

        // If DB stored relative path like 'uploads/products/x.jpg'
        if (!p.startsWith("/"))
            return req.getContextPath() + "/" + p;

        // If DB stored '/uploads/...'
        return req.getContextPath() + p;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession s = req.getSession(false);
        if (s == null || !"ADMIN".equals(s.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String idStr = req.getParameter("id");
        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/orders");
            return;
        }
        int orderId = Integer.parseInt(idStr);

        Map<String,Object> order = new HashMap<>();
        List<Map<String,Object>> items = new ArrayList<>();

        // Order Meta
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                    "SELECT id, user_id, total, status, shipping_address, payment_method, created_at FROM orders WHERE id=?")) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    order.put("id", rs.getInt("id"));
                    order.put("total", rs.getBigDecimal("total"));
                    order.put("status", rs.getString("status"));
                    order.put("shipping_address", rs.getString("shipping_address"));
                    order.put("payment_method", rs.getString("payment_method"));
                    order.put("created_at", rs.getTimestamp("created_at"));
                }
            }

        } catch (Exception e) { e.printStackTrace(); }

        // Order Items
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(
                    "SELECT product_id, name, price, size, quantity, image_url FROM order_items WHERE order_id=?")) {

            ps.setInt(1, orderId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {

                    Map<String,Object> it = new HashMap<>();
                    it.put("product_id", rs.getInt("product_id"));
                    it.put("name", rs.getString("name"));
                    it.put("price", rs.getBigDecimal("price"));
                    it.put("size", rs.getString("size"));
                    it.put("quantity", rs.getInt("quantity"));

                    // HERE is the FIX ✔✔✔
                    String fixedImg = normalizeImage(rs.getString("image_url"), req);
                    it.put("image_url", fixedImg);

                    items.add(it);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        req.setAttribute("order", order);
        req.setAttribute("items", items);

        req.getRequestDispatcher("/admin/admin_order_view.jsp").forward(req, resp);
    }

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
            try (Connection con = getConnection();
                 PreparedStatement ps = con.prepareStatement(
                        "UPDATE orders SET status=? WHERE id=?")) {

                ps.setString(1, status.toUpperCase());
                ps.setInt(2, Integer.parseInt(id));
                ps.executeUpdate();

            } catch (Exception e) { e.printStackTrace(); }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/orders/view?id=" + id);
    }
}
