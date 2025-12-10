package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/admin/deleteProduct")
public class AdminDeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // set your DB password

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pidS = req.getParameter("productId");
        if (pidS == null) { resp.sendRedirect(req.getContextPath()+"/admin/products"); return; }

        int pid = Integer.parseInt(pidS);
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = con.prepareStatement("UPDATE products SET active=0 WHERE id=?")) {
                ps.setInt(1, pid);
                ps.executeUpdate();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/products");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/products?error=deletefail");
        }
    }
}
