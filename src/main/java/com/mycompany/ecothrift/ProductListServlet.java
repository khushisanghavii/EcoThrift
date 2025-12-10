package com.mycompany.ecothrift;

import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/products")
public class ProductListServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Update these if needed
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = ""; // <-- set your DB password

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // --- DEBUG: show session + role info to console (remove after debugging)
        HttpSession debugSession = request.getSession(false);
        String debugSessionId = (debugSession == null ? "null" : debugSession.getId());
        Object debugRole = (debugSession == null ? null : debugSession.getAttribute("role"));

        // original request params
        String categoryParam = request.getParameter("category"); // men / women / kids or null
        String show = request.getParameter("show"); // optional show=all
        boolean showAll = "all".equalsIgnoreCase(show);

        System.out.println("DEBUG /products request -> URI=" + request.getRequestURI()
                + " query=" + request.getQueryString()
                + " sessionId=" + debugSessionId
                + " role=" + debugRole
                + " categoryParam=" + categoryParam
                + " showAll=" + showAll);

        // Determine category filter for SQL (do NOT overwrite categoryParam because we need it for JSP choice)
        String categoryFilter = null;
        if (!showAll && categoryParam != null && !categoryParam.trim().isEmpty()) {
            categoryFilter = categoryParam.trim();
        }

        List<Map<String,Object>> products = new ArrayList<>();

        String sql = "SELECT p.id, p.name, p.description, p.price, p.category, " +
                     "pi.image_url AS image_url " +
                     "FROM products p " +
                     "LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = 1 " +
                     "WHERE p.active = 1 " +
                     (categoryFilter != null ? " AND p.category = ? " : "") +
                     "ORDER BY p.id";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new ServletException("MySQL driver not found", e);
        }

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (categoryFilter != null) {
                ps.setString(1, categoryFilter);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> p = new HashMap<>();
                    int id = rs.getInt("id");
                    p.put("id", id);
                    p.put("name", rs.getString("name"));
                    p.put("description", rs.getString("description"));
                    p.put("price", rs.getDouble("price"));
                    p.put("category", rs.getString("category"));
                    p.put("image_url", rs.getString("image_url"));

                    // load sizes for product
                    List<Map<String,Object>> sizes = new ArrayList<>();
                    String sqlSizes = "SELECT id, size, quantity FROM product_sizes WHERE product_id = ? ORDER BY id";
                    try (PreparedStatement ps2 = con.prepareStatement(sqlSizes)) {
                        ps2.setInt(1, id);
                        try (ResultSet rs2 = ps2.executeQuery()) {
                            while (rs2.next()) {
                                Map<String,Object> s = new HashMap<>();
                                s.put("id", rs2.getInt("id"));
                                s.put("size", rs2.getString("size"));
                                s.put("quantity", rs2.getInt("quantity"));
                                sizes.add(s);
                            }
                        }
                    } catch (SQLException seSizes) {
                        // log and continue (so one product's sizes failing won't break the entire list)
                        seSizes.printStackTrace();
                    }
                    p.put("sizes", sizes);
                    products.add(p);
                }
            }

        } catch (SQLException e) {
            // Log full stacktrace for debugging
            e.printStackTrace();
            // Set a friendly error attribute (safe to show in dev)
            request.setAttribute("error", "DB error while loading products: " + e.getMessage());
        }

        // put attributes for JSP
        request.setAttribute("products", products);
        request.setAttribute("showAll", showAll);      // useful if JSP wants to show a banner
        request.setAttribute("category", categoryParam);// original param (may be null)

        // Decide which JSP to forward to.
        // IMPORTANT: your file is "All.jsp" (capital A) — forward to that exact path.
        String jsp;
        if (showAll) {
            jsp = "/All.jsp";    // <- matches your actual file name (case-sensitive on server)
        } else if (categoryParam == null || categoryParam.trim().isEmpty()) {
            jsp = "/categories.jsp";
        } else if ("women".equalsIgnoreCase(categoryParam)) {
            jsp = "/women.jsp";
        } else if ("men".equalsIgnoreCase(categoryParam)) {
            jsp = "/men.jsp";
        } else if ("kids".equalsIgnoreCase(categoryParam)) {
            jsp = "/kids.jsp";
        } else {
            // unknown category -> fallback to All.jsp
            jsp = "/All.jsp";
        }

        System.out.println("DEBUG /products -> forwarding to JSP: " + jsp + " productsCount=" + products.size());

        RequestDispatcher rd = request.getRequestDispatcher(jsp);
        rd.forward(request, response);
    }
}
