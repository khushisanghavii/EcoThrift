package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RemoveFromCartServlet")
public class RemoveFromCartServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        // If user is logged in -> remove from DB
        String cartId = request.getParameter("cartId");

        if (userId != null && cartId != null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/ecothrift", "root", ""
                );

                PreparedStatement pst = con.prepareStatement(
                    "DELETE FROM cart WHERE id=? AND user_id=?"
                );
                pst.setInt(1, Integer.parseInt(cartId));
                pst.setInt(2, userId);
                pst.executeUpdate();

                con.close();

            } catch (Exception e) {
                e.printStackTrace();
            }

            response.sendRedirect("cart.jsp");
            return;
        }

        // If NOT logged in -> remove from SESSION cart
        String indexParam = request.getParameter("index");

        if (indexParam != null) {
            int index = Integer.parseInt(indexParam);

            java.util.List<java.util.Map<String, String>> cart =
                (java.util.List<java.util.Map<String, String>>)
                        session.getAttribute("cart");

            if (cart != null && index >= 0 && index < cart.size()) {
                cart.remove(index);
                session.setAttribute("cart", cart);
            }
        }

        response.sendRedirect("cart.jsp");
    }
}
