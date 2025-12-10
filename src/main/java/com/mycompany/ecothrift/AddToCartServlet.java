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

    // DB config - update password if needed
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // <-- set your DB password

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // Expect productId, size and optional qty from client
        String productIdStr = request.getParameter("productId");
        String size = request.getParameter("size");
        String qtyStr = request.getParameter("qty"); // optional
        int qty = 1;
        if (qtyStr != null && !qtyStr.isEmpty()) {
            try { qty = Integer.parseInt(qtyStr); } catch (NumberFormatException ignored) { qty = 1; }
            if (qty <= 0) qty = 1;
        }

        HttpSession session = request.getSession(false);
        Integer userId = null;

        // robustly obtain userId from session (handles Integer or String)
        if (session != null) {
            Object uidObj = session.getAttribute("userId");
            if (uidObj instanceof Integer) {
                userId = (Integer) uidObj;
            } else if (uidObj instanceof String) {
                try { userId = Integer.parseInt((String) uidObj); } catch (NumberFormatException ignored) {}
            } else if (uidObj != null) {
                try { userId = Integer.parseInt(uidObj.toString()); } catch (Exception ignored) {}
            }
        }

        // Debug
        System.out.println("[AddToCart] session userId raw = " + (session != null ? session.getAttribute("userId") : "no-session"));
        System.out.println("[AddToCart] resolved userId = " + userId);
        System.out.println("[AddToCart] productId=" + productIdStr + " size=" + size + " qty=" + qty);

        String redirect = "cart.jsp";

        // Validate productId
        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            response.sendRedirect("products?error=missingProduct");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect("products?error=invalidProduct");
            return;
        }

        // Fetch product info and check stock
        String productName = null;
        double productPrice = 0.0;
        String imageUrl = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
            response.sendRedirect("cart.jsp?addError=driver");
            return;
        }

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            // 1) product name & price
            String sqlProd = "SELECT name, price FROM products WHERE id = ? AND active = 1";
            try (PreparedStatement ps = con.prepareStatement(sqlProd)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.sendRedirect("products?error=productNotFound");
                        return;
                    }
                    productName = rs.getString("name");
                    productPrice = rs.getDouble("price");
                }
            }

            // 2) primary image if present
            String sqlImg = "SELECT image_url FROM product_images WHERE product_id = ? AND is_primary = 1 LIMIT 1";
            try (PreparedStatement ps = con.prepareStatement(sqlImg)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) imageUrl = rs.getString("image_url");
                }
            }

            // 3) check stock for selected size
            String sqlSize = "SELECT quantity FROM product_sizes WHERE product_id = ? AND size = ? LIMIT 1";
            int available = 0;
            try (PreparedStatement ps = con.prepareStatement(sqlSize)) {
                ps.setInt(1, productId);
                ps.setString(2, size);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        available = rs.getInt("quantity");
                    } else {
                        // size not found
                        response.sendRedirect("products?error=sizeNotFound");
                        return;
                    }
                }
            }

            if (available < qty) {
                // not enough stock
                response.sendRedirect("products?error=outOfStock");
                return;
            }

            // 4) Insert into DB cart if logged in; else add to session cart
            if (userId != null) {
                // Insert into cart table:
                // columns: user_id, name, price, size, image_url, product_id, quantity
                String sqlInsert = "INSERT INTO cart (user_id, name, price, size, image_url, product_id, quantity) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement ps = con.prepareStatement(sqlInsert)) {
                    ps.setInt(1, userId);
                    ps.setString(2, productName != null ? productName : "");
                    ps.setDouble(3, productPrice);
                    ps.setString(4, size != null ? size : "");
                    ps.setString(5, imageUrl != null ? imageUrl : "");
                    ps.setInt(6, productId);
                    ps.setInt(7, qty);
                    ps.executeUpdate();
                }

            } else {
                // Guest -> session cart (store qty too)
                if (session == null) session = request.getSession(true);
                @SuppressWarnings("unchecked")
                List<Map<String, String>> cart = (List<Map<String, String>>) session.getAttribute("cart");
                if (cart == null) cart = new ArrayList<>();
                Map<String, String> item = new HashMap<>();
                item.put("productId", Integer.toString(productId));
                item.put("name", productName != null ? productName : "");
                item.put("price", Double.toString(productPrice));
                item.put("size", size != null ? size : "");
                item.put("image", imageUrl != null ? imageUrl : "");
                item.put("qty", Integer.toString(qty));
                cart.add(item);
                session.setAttribute("cart", cart);
                System.out.println("[AddToCart] Added to session cart, size now = " + cart.size());
            }

        } catch (SQLException sqe) {
            sqe.printStackTrace();
            redirect = "cart.jsp?addError=db";
        } catch (Exception ex) {
            ex.printStackTrace();
            redirect = "cart.jsp?addError=other";
        }

        response.sendRedirect(redirect);
    }
}
