package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/addProduct")
public class AdminAddProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // set your DB password

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // admin check omitted (assume caller enforces)
        req.setCharacterEncoding("UTF-8");
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        String priceS = req.getParameter("price");
        String category = req.getParameter("category");
        String imageUrl = req.getParameter("image_url"); // simple URL field in form

        String[] sizes = req.getParameterValues("size[]");
        String[] qtys  = req.getParameterValues("qty[]");

        double price = 0;
        try { price = Double.parseDouble(priceS); } catch (Exception e) {}

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
                con.setAutoCommit(false);

                String insP = "INSERT INTO products (name, description, price, category) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(insP, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, name);
                    ps.setString(2, description);
                    ps.setDouble(3, price);
                    ps.setString(4, category);
                    ps.executeUpdate();
                    try (ResultSet g = ps.getGeneratedKeys()) {
                        if (!g.next()) throw new SQLException("No product id");
                        int productId = g.getInt(1);

                        if (imageUrl != null && !imageUrl.trim().isEmpty()) {
                            String insImg = "INSERT INTO product_images (product_id, image_url, is_primary) VALUES (?, ?, 1)";
                            try (PreparedStatement psi = con.prepareStatement(insImg)) {
                                psi.setInt(1, productId);
                                psi.setString(2, imageUrl);
                                psi.executeUpdate();
                            }
                        }

                        if (sizes != null && sizes.length > 0) {
                            String insSize = "INSERT INTO product_sizes (product_id, size, quantity) VALUES (?, ?, ?)";
                            try (PreparedStatement pss = con.prepareStatement(insSize)) {
                                for (int i = 0; i < sizes.length; i++) {
                                    String s = sizes[i];
                                    int q = 0;
                                    try { q = Integer.parseInt(qtys[i]); } catch (Exception ex) {}
                                    pss.setInt(1, productId);
                                    pss.setString(2, s);
                                    pss.setInt(3, q);
                                    pss.addBatch();
                                }
                                pss.executeBatch();
                            }
                        }
                    }
                }
                con.commit();
                resp.sendRedirect(req.getContextPath() + "/admin/products");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?error=addfail");
        }
    }
}
