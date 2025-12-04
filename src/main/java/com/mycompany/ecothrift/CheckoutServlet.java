package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CheckoutServlet")
public class CheckoutServlet extends HttpServlet {
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // update if needed

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Resolve userId robustly
        Integer userId = null;
        Object uidObj = session.getAttribute("userId");
        if (uidObj instanceof Integer) userId = (Integer) uidObj;
        else if (uidObj instanceof String) {
            try { userId = Integer.parseInt((String) uidObj); } catch (NumberFormatException ignored) {}
        }

        System.out.println("[Checkout] session userId raw=" + uidObj + " resolved=" + userId);

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Donation: checkbox name "donation" expected; value e.g. "10"
        int donationAmount = 0;
        try {
            String donationParam = request.getParameter("donation");
            if (donationParam != null && !donationParam.trim().isEmpty()) {
                donationAmount = Integer.parseInt(donationParam);
            }
        } catch (Exception e) {
            System.out.println("[Checkout] donation parse error: " + e.getMessage());
            donationAmount = 0;
        }
        System.out.println("[Checkout] donationAmount=" + donationAmount);

        Connection con = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
            con.setAutoCommit(false);

            // --- Compute cart total from DB (server-side) ---
            PreparedStatement cartTotalStmt = con.prepareStatement(
                "SELECT SUM(price * IFNULL(quantity,1)) AS sum_total FROM cart WHERE user_id=?"
            );
            cartTotalStmt.setInt(1, userId);
            ResultSet sumRs = cartTotalStmt.executeQuery();

            double cartTotal = 0.0;
            if (sumRs.next()) cartTotal = sumRs.getDouble("sum_total");
            if (sumRs.wasNull()) cartTotal = 0.0;
            sumRs.close();
            cartTotalStmt.close();

            System.out.println("[Checkout] computed cartTotal=" + cartTotal);

            if (cartTotal <= 0.0) {
                // Empty cart; redirect with error code (or handle as you prefer)
                System.out.println("[Checkout] Cart empty for user " + userId);
                con.rollback();
                response.sendRedirect("cart.jsp?checkoutError=emptyCart");
                return;
            }

            double finalTotal = cartTotal + donationAmount;

            // 1) insert order using your schema (column name `total`)
            PreparedStatement orderStmt = con.prepareStatement(
                "INSERT INTO orders (user_id, total, donation_amount, status) VALUES (?, ?, ?, ?)",
                Statement.RETURN_GENERATED_KEYS
            );
            orderStmt.setInt(1, userId);
            orderStmt.setDouble(2, finalTotal);
            orderStmt.setDouble(3, donationAmount);
            orderStmt.setString(4, "PENDING");
            orderStmt.executeUpdate();

            ResultSet keys = orderStmt.getGeneratedKeys();
            int orderId = -1;
            if (keys.next()) orderId = keys.getInt(1);
            orderStmt.close();

            if (orderId == -1) throw new SQLException("No order id returned");

            // 2) Insert donation row if needed
            if (donationAmount > 0) {
                PreparedStatement donationStmt = con.prepareStatement(
                    "INSERT INTO donations (user_id, order_id, amount) VALUES (?, ?, ?)"
                );
                donationStmt.setInt(1, userId);
                donationStmt.setInt(2, orderId);
                donationStmt.setDouble(3, donationAmount);
                donationStmt.executeUpdate();
                donationStmt.close();
            }

            // 3) Move cart items -> order_items
            PreparedStatement cartItemsStmt = con.prepareStatement(
                "SELECT id, product_id, name, price, size, quantity, image_url FROM cart WHERE user_id=?"
            );
            cartItemsStmt.setInt(1, userId);
            ResultSet cartRs = cartItemsStmt.executeQuery();

            PreparedStatement itemInsert = con.prepareStatement(
                "INSERT INTO order_items (order_id, product_id, name, price, size, quantity, image_url) VALUES (?, ?, ?, ?, ?, ?, ?)"
            );

            boolean hadItems = false;
            while (cartRs.next()) {
                hadItems = true;
                itemInsert.setInt(1, orderId);

                int pid = cartRs.getInt("product_id");
                if (cartRs.wasNull()) itemInsert.setNull(2, Types.INTEGER);
                else itemInsert.setInt(2, pid);

                itemInsert.setString(3, cartRs.getString("name"));
                itemInsert.setDouble(4, cartRs.getDouble("price"));
                itemInsert.setString(5, cartRs.getString("size"));
                int qty = 1;
                try { qty = cartRs.getInt("quantity"); } catch (Exception ignored) {}
                itemInsert.setInt(6, qty);
                itemInsert.setString(7, cartRs.getString("image_url"));

                itemInsert.executeUpdate();
            }
            cartRs.close();
            cartItemsStmt.close();
            itemInsert.close();

            if (!hadItems) {
                throw new SQLException("Cart had no items to move");
            }

            // 4) Clear cart
            PreparedStatement clear = con.prepareStatement("DELETE FROM cart WHERE user_id=?");
            clear.setInt(1, userId);
            clear.executeUpdate();
            clear.close();

            con.commit();

            session.setAttribute("finalTotal", finalTotal);
            session.setAttribute("donationAmount", donationAmount);
            session.setAttribute("recentOrderId", orderId);

            // redirect to success
            response.sendRedirect("order_success.jsp?orderId=" + orderId);

        } catch (Exception e) {
            e.printStackTrace(); // IMPORTANT: check Tomcat logs for this stacktrace
            if (con != null) {
                try { con.rollback(); } catch (SQLException ignored) {}
            }
            response.sendRedirect("cart.jsp?checkoutError=1");
        } finally {
            if (con != null) {
                try { con.setAutoCommit(true); con.close(); } catch (Exception ignored) {}
            }
        }
    }
}
