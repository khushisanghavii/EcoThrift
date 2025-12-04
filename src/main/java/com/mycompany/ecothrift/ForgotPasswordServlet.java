package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/ecothrift", "root", ""
            );

            PreparedStatement pst = con.prepareStatement("SELECT * FROM users WHERE email=?");
            pst.setString(1, email);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) {
                // email exists -> send to reset page
                response.sendRedirect("resetPassword.jsp?email=" + email);
            } else {
                // email not found
                request.setAttribute("message", "Email not found!");
                request.getRequestDispatcher("forgotPassword.jsp").forward(request, response);
            }

            con.close();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
