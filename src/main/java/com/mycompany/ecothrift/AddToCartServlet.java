package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AddToCartServlet")
public class AddToCartServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // update if needed

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name = request.getParameter("name");
        String price = request.getParameter("price");
        String size = request.getParameter("size");
        String image = request.getParameter("image");
        String productId = request.getParameter("productId"); // optional; not used for DB insert

        HttpSession session = request.getSession(false);
        Integer userId = null;

        // --- robustly obtain userId from session (handles Integer or String)
        if (session != null) {
            Object uidObj = session.getAttribute("userId");
            if (uidObj instanceof Integer) {
                userId = (Integer) uidObj;
            } else if (uidObj instanceof String) {
                try {
                    userId = Integer.parseInt((String) uidObj);
                } catch (NumberFormatException ignored) {}
            } else if (uidObj != null) {
                // try toString parse
                try { userId = Integer.parseInt(uidObj.toString()); } catch (Exception ignored) {}
            }
        }

        // Log session info for debugging
        System.out.println("[AddToCart] session userId raw = " + (session != null ? session.getAttribute("userId") : "no-session"));
        System.out.println("[AddToCart] resolved userId = " + userId);
        System.out.println("[AddToCart] product: name=" + name + " price=" + price + " size=" + size + " image=" + image + " productId=" + productId);

        // sentinel for redirect
        String redirect = "cart.jsp";

        if (userId != null) {
            // Logged in -> save to DB (ecothrift.cart)
            Connection con = null;
            PreparedStatement pst = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

                // <-- UPDATED: remove product_id (matches your table)
                pst = con.prepareStatement(
                    "INSERT INTO cart (user_id, name, price, size, image_url) VALUES (?, ?, ?, ?, ?)"
                );

                pst.setInt(1, userId);

                // name
                pst.setString(2, name == null ? "" : name);

                // safe parse for price
                double priceVal = 0.0;
                try { if (price != null && !price.trim().isEmpty()) priceVal = Double.parseDouble(price); }
                catch (NumberFormatException nfe) { priceVal = 0.0; }
                pst.setDouble(3, priceVal);

                // size
                pst.setString(4, size == null ? "" : size);

                // image_url
                pst.setString(5, image == null ? "" : image);

                int rows = pst.executeUpdate();
                System.out.println("[AddToCart] DB insert rows = " + rows);

            } catch (SQLException sqe) {
                // log SQL errors and redirect with error
                sqe.printStackTrace();
                redirect = "cart.jsp?addError=db";
            } catch (ClassNotFoundException cnf) {
                cnf.printStackTrace();
                redirect = "cart.jsp?addError=driver";
            } catch (Exception e) {
                e.printStackTrace();
                redirect = "cart.jsp?addError=other";
            } finally {
                try { if (pst != null) pst.close(); } catch (Exception ignored) {}
                try { if (con != null) con.close(); } catch (Exception ignored) {}
            }

        } else {
            // Guest -> session cart
            if (session == null) session = request.getSession(true);
            List<Map<String, String>> cart = (List<Map<String, String>>) session.getAttribute("cart");
            if (cart == null) cart = new ArrayList<>();
            Map<String, String> item = new HashMap<>();
            item.put("productId", productId == null ? "" : productId);
            item.put("name", name == null ? "" : name);
            item.put("price", price == null ? "0" : price);
            item.put("size", size == null ? "" : size);
            item.put("image", image == null ? "" : image);
            cart.add(item);
            session.setAttribute("cart", cart);
            System.out.println("[AddToCart] Added to session cart, size now = " + cart.size());
        }

        response.sendRedirect(redirect);
    }
}
