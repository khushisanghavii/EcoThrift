package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/updateSizes")
public class AdminUpdateSizesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        int productId = Integer.parseInt(req.getParameter("productId"));

        // Existing sizes
        String[] sizeIds = req.getParameterValues("sizeId[]");
        String[] sizes = req.getParameterValues("sizeExisting[]");
        String[] qtys = req.getParameterValues("qtyExisting[]");

        // New sizes
        String[] newSizes = req.getParameterValues("sizeNew[]");
        String[] newQtys = req.getParameterValues("qtyNew[]");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

                con.setAutoCommit(false);

                // Update existing rows
                if (sizeIds != null) {
                    String upd = "UPDATE product_sizes SET size=?, quantity=? WHERE id=?";
                    PreparedStatement ps = con.prepareStatement(upd);

                    for (int i = 0; i < sizeIds.length; i++) {
                        ps.setString(1, sizes[i]);
                        ps.setInt(2, Integer.parseInt(qtys[i]));
                        ps.setInt(3, Integer.parseInt(sizeIds[i]));
                        ps.addBatch();
                    }
                    ps.executeBatch();
                }

                // Insert new sizes
                if (newSizes != null) {
                    String ins = "INSERT INTO product_sizes (product_id, size, quantity) VALUES (?, ?, ?)";
                    PreparedStatement ps2 = con.prepareStatement(ins);

                    for (int j = 0; j < newSizes.length; j++) {
                        ps2.setInt(1, productId);
                        ps2.setString(2, newSizes[j]);
                        ps2.setInt(3, Integer.parseInt(newQtys[j]));
                        ps2.addBatch();
                    }
                    ps2.executeBatch();
                }

                con.commit();
            }

            // 👇 redirect back to SAME PAGE
            resp.sendRedirect(req.getContextPath() + "/admin/sizes?productId=" + productId);

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/sizes?productId=" + productId + "&error=1");
        }
    }
}
