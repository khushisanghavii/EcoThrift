package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Connection con = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/ecothrift",
                "root",
                ""
            );

            String sql = "SELECT * FROM users WHERE email=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {

                int userId = rs.getInt("id");
                String username = rs.getString("name");

                HttpSession session = request.getSession();
                session.setAttribute("username", username);
                session.setAttribute("userId", userId);

                // ⭐ STEP 2: MERGE SESSION CART INTO DATABASE
                List<Map<String, String>> guestCart =
                    (List<Map<String, String>>) session.getAttribute("cart");

                if (guestCart != null && !guestCart.isEmpty()) {

                    for (Map<String, String> item : guestCart) {
                        PreparedStatement pst = con.prepareStatement(
                            "INSERT INTO cart (user_id, name, price, size) VALUES (?, ?, ?, ?)"
                        );

                        pst.setInt(1, userId);
                        pst.setString(2, item.get("name"));
                        pst.setDouble(3, Double.parseDouble(item.get("price")));
                        pst.setString(4, item.get("size"));
                        pst.executeUpdate();
                    }

                    // Clear guest cart after merging
                    session.removeAttribute("cart");
                }

                response.sendRedirect("index.jsp");

            } 
            else {
                request.setAttribute("error", "Invalid email or password!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            }


        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Login Failed: " + e.getMessage());
        }
    }
}
