package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/sizes")
public class AdminSizesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // <-- your password

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String pidS = req.getParameter("productId");
        if (pidS == null || pidS.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/products");
            return;
        }

        int productId;
        try { productId = Integer.parseInt(pidS); } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/admin/products"); return;
        }

        Map<String,Object> product = new HashMap<>();
        List<Map<String,Object>> sizes = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                // load product
                try (PreparedStatement ps = con.prepareStatement("SELECT id, name FROM products WHERE id=?")) {
                    ps.setInt(1, productId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            product.put("id", rs.getInt("id"));
                            product.put("name", rs.getString("name"));
                        } else {
                            resp.sendRedirect(req.getContextPath() + "/admin/products");
                            return;
                        }
                    }
                }
                // load sizes
                try (PreparedStatement ps2 = con.prepareStatement("SELECT id, size, quantity FROM product_sizes WHERE product_id=?")) {
                    ps2.setInt(1, productId);
                    try (ResultSet rs2 = ps2.executeQuery()) {
                        while (rs2.next()) {
                            Map<String,Object> row = new HashMap<>();
                            row.put("id", rs2.getInt("id"));
                            row.put("size", rs2.getString("size"));
                            row.put("quantity", rs2.getInt("quantity"));
                            sizes.add(row);
                        }
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("product", product);
        req.setAttribute("sizes", sizes);
        RequestDispatcher rd = req.getRequestDispatcher("/admin/sizes.jsp");
        rd.forward(req, resp);
    }
}
