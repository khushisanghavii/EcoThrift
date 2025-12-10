package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/editProduct")
public class AdminEditProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // set your DB password

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pidS = req.getParameter("productId");
        if (pidS == null) { resp.sendRedirect(req.getContextPath()+"/admin/products"); return; }
        int pid = Integer.parseInt(pidS);

        Map<String,Object> product = new HashMap<>();
        List<Map<String,Object>> sizes = new ArrayList<>();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                String sql = "SELECT id, name, description, price, category, active FROM products WHERE id=?";
                try (PreparedStatement ps = con.prepareStatement(sql)) {
                    ps.setInt(1, pid);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            product.put("id", rs.getInt("id"));
                            product.put("name", rs.getString("name"));
                            product.put("description", rs.getString("description"));
                            product.put("price", rs.getDouble("price"));
                            product.put("category", rs.getString("category"));
                            product.put("active", rs.getInt("active"));
                        } else { resp.sendRedirect(req.getContextPath()+"/admin/products"); return; }
                    }
                }
                String sqlSz = "SELECT id, size, quantity FROM product_sizes WHERE product_id=?";
                try (PreparedStatement ps2 = con.prepareStatement(sqlSz)) {
                    ps2.setInt(1, pid);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
                            Map<String,Object> s = new HashMap<>();
                            s.put("id", rs2.getInt("id"));
                            s.put("size", rs2.getString("size"));
                            s.put("quantity", rs2.getInt("quantity"));
                            sizes.add(s);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("product", product);
        req.setAttribute("sizes", sizes);
        RequestDispatcher rd = req.getRequestDispatcher("/admin/edit_product.jsp");
        rd.forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int pid = Integer.parseInt(req.getParameter("productId"));
        String name = req.getParameter("name");
        String desc = req.getParameter("description");
        double price = 0;
        try { price = Double.parseDouble(req.getParameter("price")); } catch(Exception e){}
        String category = req.getParameter("category");
        String activeS = req.getParameter("active");
        int active = "on".equals(activeS) ? 1 : 0;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                String upd = "UPDATE products SET name=?, description=?, price=?, category=?, active=? WHERE id=?";
                try (PreparedStatement ps = con.prepareStatement(upd)) {
                    ps.setString(1, name);
                    ps.setString(2, desc);
                    ps.setDouble(3, price);
                    ps.setString(4, category);
                    ps.setInt(5, active);
                    ps.setInt(6, pid);
                    ps.executeUpdate();
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?error=editfail");
        }
    }
}
