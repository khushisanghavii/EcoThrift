package com.mycompany.ecothrift;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DonationListServlet")
public class DonationListServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    // Placeholder served from webapp
    private static final String PLACEHOLDER = "/images/placeholder.png";

    // External uploads root (Option B)
    private static final String EXTERNAL_UPLOADS_ROOT = "/Users/khushisanghavi/EcothriftUploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Integer userId = (session != null && session.getAttribute("userId") != null)
                ? Integer.parseInt(session.getAttribute("userId").toString()) : null;

        if (userId == null) {
            resp.sendRedirect("login.jsp");
            return;
        }

        List<Map<String,Object>> donations = new ArrayList<>();
        String ctx = req.getContextPath();

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {
            PreparedStatement pst = con.prepareStatement(
                "SELECT * FROM donationform WHERE user_id=? ORDER BY created_at DESC"
            );
            pst.setInt(1, userId);
            try (ResultSet rs = pst.executeQuery()) {
                while (rs.next()) {
                    Map<String,Object> d = new HashMap<>();
                    d.put("donation_type", rs.getString("donation_type"));
                    d.put("donated_items", rs.getString("donated_items"));
                    d.put("ngo_name", rs.getString("ngo_name"));
                    d.put("other_ngo", rs.getString("other_ngo"));

                    String rawPhotoPath = rs.getString("donation_photo_path"); // value from DB
                    d.put("donation_photo_path", rawPhotoPath);

                    // Build image URL robustly
                    String imageUrl = buildImageUrl(ctx, rawPhotoPath);
                    d.put("imageUrl", imageUrl);

                    d.put("pickup_datetime", rs.getTimestamp("pickup_datetime"));
                    d.put("created_at", rs.getTimestamp("created_at"));
                    d.put("status", rs.getString("status"));
                    donations.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        req.setAttribute("donations", donations);
        req.getRequestDispatcher("donationList.jsp").forward(req, resp);
    }

    /**
     * Normalize stored photoPath and produce a public URL served by FileServlet:
     *   public URL:  <contextPath>/uploads/donations/<filename>
     *   filesystem: EXTERNAL_UPLOADS_ROOT + "/donations/<filename>"
     *
     * Accepts DB values in forms:
     *   - filename.jpg
     *   - donations/filename.jpg
     *   - uploads/donations/filename.jpg
     *   - /uploads/donations/filename.jpg
     *
     * Returns placeholder if photoPath is null/empty or the file missing.
     */
    private String buildImageUrl(String contextPath, String rawPhotoPath) {
        String placeholderUrl = contextPath + PLACEHOLDER;

        if (rawPhotoPath == null || rawPhotoPath.trim().isEmpty()) {
            return placeholderUrl;
        }

        // normalize: remove any leading slashes
        String p = rawPhotoPath.trim();
        while (p.startsWith("/")) p = p.substring(1);

        // remove leading "uploads/" if present
        if (p.toLowerCase().startsWith("uploads/")) {
            p = p.substring("uploads/".length());
        }

        // now p might be "donations/filename.jpg" or "filename.jpg"
        String remainder;
        if (p.toLowerCase().startsWith("donations/")) {
            remainder = p.substring("donations/".length()); // filename.jpg
        } else {
            // assume it's a bare filename
            remainder = p;
        }

        // Build public URL: /<context>/uploads/donations/<filename>
        String imageUrl = contextPath + "/uploads/donations/" + remainder;

        // Build expected filesystem path: EXTERNAL_UPLOADS_ROOT/donations/<filename>
        File expected = new File(EXTERNAL_UPLOADS_ROOT + File.separator + "donations", remainder);
        if (!expected.exists() || !expected.isFile()) {
            // File missing: log clear message and return placeholder (FileServlet would 404 otherwise)
            System.out.println("DonationListServlet: image file not found in external folder: " + expected.getAbsolutePath()
                    + " -> serving placeholder. (Original DB value: '" + rawPhotoPath + "', computed URL: " + imageUrl + ")");
            return placeholderUrl;
        }

        // File exists on disk — return the public URL that FileServlet will serve
        return imageUrl;
    }
}
