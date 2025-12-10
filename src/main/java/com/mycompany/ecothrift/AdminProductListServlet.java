package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.RequestDispatcher;

@WebServlet("/admin/products")
public class AdminProductListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // your DB password

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Map<String, Object>> products = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                String sql = "SELECT p.id, p.name, p.price, p.category, p.active, " +
                             "(SELECT image_url FROM product_images WHERE product_id = p.id LIMIT 1) AS image " +
                             "FROM products p ORDER BY p.id DESC";

                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("id", rs.getInt("id"));
                    row.put("name", rs.getString("name"));
                    row.put("price", rs.getDouble("price"));
                    row.put("category", rs.getString("category"));
                    row.put("active", rs.getInt("active"));
                    row.put("image", rs.getString("image"));
                    products.add(row);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("products", products);
        RequestDispatcher rd = req.getRequestDispatcher("/admin/admin_products.jsp");
        rd.forward(req, resp);
    }
}
