package com.mycompany.ecothrift;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.*;

@WebServlet("/admin/changeStatus")
public class ChangeStatusServlet extends HttpServlet {

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

        String type = req.getParameter("type"); // order | donationform | donation
        String id = req.getParameter("id");

        req.setAttribute("type", type);
        req.setAttribute("id", id);

        req.getRequestDispatcher("/admin/changeStatus.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String type = req.getParameter("type");
        int id = Integer.parseInt(req.getParameter("id"));
        String newStatus = req.getParameter("status");

        try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            String sql = null;

            if ("order".equals(type)) {
                sql = "UPDATE orders SET status=? WHERE id=?";
            } else if ("donationform".equals(type)) {
                sql = "UPDATE donationform SET status=? WHERE id=?";
            } else if ("donation".equals(type)) {
                // donations table has no status in your DB but included for future
                sql = "UPDATE donations SET amount=amount WHERE id=?";
            }

            if (sql != null) {
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    if ("donation".equals(type)) {
                        ps.setInt(1, id); // dummy update
                    } else {
                        ps.setString(1, newStatus);
                        ps.setInt(2, id);
                    }
                    ps.executeUpdate();
                }
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
    }
}
