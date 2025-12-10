package com.mycompany.ecothrift;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;
import java.util.logging.*;

@WebServlet("/admin/donations")
public class AdminDonationsServlet extends HttpServlet {
    private static final Logger LOG = Logger.getLogger(AdminDonationsServlet.class.getName());

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/ecothrift?useSSL=false&serverTimezone=UTC";
        String user = "root";    // <-- change if needed
        String pass = "";        // <-- change to your DB password
        return DriverManager.getConnection(url, user, pass);
    }

    // Normalize stored path / filename and return just the filename when possible
    private String normalizeToFilename(String raw) {
        if (raw == null) return null;
        String s = raw.trim();
        if (s.isEmpty()) return null;

        // If raw already contains '/uploads/donations/' or '/uploads/' keep filename part
        // Example raw values we might see:
        // - "donation_1765...jpg"
        // - "/Ecothrift/uploads/donations/donation_1765...jpg"
        // - "/uploads/donations/donation_1765...jpg"
        // - "C:\...EcothriftUploads\donation_1765...jpg"
        // - absolute URL "http://..."
        if (s.startsWith("http://") || s.startsWith("https://")) {
            return s; // return absolute URL as-is (handled by caller)
        }

        // normalize backslashes -> forward slashes
        s = s.replace("\\", "/");

        // if contains uploads/donations path, extract filename
        int idx = s.lastIndexOf("/uploads/donations/");
        if (idx >= 0) {
            String name = s.substring(idx + "/uploads/donations/".length());
            return name.isEmpty() ? null : name;
        }

        // if contains /uploads/ extract filename
        idx = s.lastIndexOf("/uploads/");
        if (idx >= 0) {
            String name = s.substring(idx + "/uploads/".length());
            return name.isEmpty() ? null : name;
        }

        // if contains EcothriftUploads absolute path, extract last segment
        idx = s.lastIndexOf("/EcothriftUploads/");
        if (idx >= 0) {
            String name = s.substring(idx + "/EcothriftUploads/".length());
            return name.isEmpty() ? null : name;
        }

        // fallback: if string contains slashes, take last segment
        if (s.contains("/")) {
            String name = s.substring(s.lastIndexOf('/') + 1);
            return name.isEmpty() ? null : name;
        }

        // otherwise assume s is already filename
        return s;
    }

    // Build imageUrl that matches user behaviour: /<context>/uploads/donations/<filename>
    private String buildImageUrl(String rawOrFilename, HttpServletRequest req) {
        if (rawOrFilename == null) return null;
        String s = rawOrFilename.trim();
        if (s.isEmpty()) return null;
        if (s.startsWith("http://") || s.startsWith("https://")) return s; // absolute URL stored
        // if rawOrFilename already is a path starting with /uploads/donations or context path, normalize
        if (s.startsWith(req.getContextPath() + "/uploads/donations/") || s.startsWith("/uploads/donations/")) {
            // ensure context path present
            if (s.startsWith(req.getContextPath())) return s;
            return req.getContextPath() + s;
        }
        // else s should be a filename -> build /<context>/uploads/donations/<filename>
        return req.getContextPath() + "/uploads/donations/" + s;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        List<Map<String,Object>> donations = new ArrayList<>();

        String sql = "SELECT id, user_id, name, email, phone, address, donation_type, ngo_name, other_ngo, " +
                     "donated_items, donation_photo_path, pickup_datetime, status, created_at " +
                     "FROM donationform ORDER BY created_at DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String,Object> m = new HashMap<>();

                m.put("id", rs.getObject("id"));
                m.put("user_id", rs.getObject("user_id"));
                m.put("name", rs.getObject("name"));
                m.put("email", rs.getObject("email"));
                m.put("phone", rs.getObject("phone"));
                m.put("address", rs.getObject("address"));
                m.put("donation_type", rs.getObject("donation_type"));
                m.put("ngo_name", rs.getObject("ngo_name"));
                m.put("other_ngo", rs.getObject("other_ngo"));

                m.put("donated_items", rs.getObject("donated_items"));
                String rawPhoto = rs.getString("donation_photo_path");
                m.put("donation_photo_path", rawPhoto);

                // Build imageUrl exactly like user page: /<context>/uploads/donations/<filename>
                String imageUrl = null;
                if (rawPhoto != null && (rawPhoto.startsWith("http://") || rawPhoto.startsWith("https://"))) {
                    // already absolute URL
                    imageUrl = rawPhoto;
                } else {
                    String filename = normalizeToFilename(rawPhoto);
                    if (filename != null) {
                        // if normalizeToFilename returned an absolute URL (it returns absolute if startsWith http)
                        if (filename.startsWith("http://") || filename.startsWith("https://")) {
                            imageUrl = filename;
                        } else {
                            imageUrl = buildImageUrl(filename, req);
                        }
                    } else {
                        imageUrl = null;
                    }
                }
                m.put("imageUrl", imageUrl);

                m.put("pickup_datetime", rs.getObject("pickup_datetime"));
                m.put("status", rs.getObject("status"));
                m.put("created_at", rs.getObject("created_at"));

                LOG.info("Donation id=" + m.get("id") + " rawPhoto='" + rawPhoto + "' -> imageUrl='" + imageUrl + "'");
                donations.add(m);
            }

        } catch (SQLException sqle) {
            LOG.log(Level.SEVERE, "SQL error loading donations", sqle);
            req.setAttribute("error", "Database error while loading donations: " + sqle.getMessage());
        } catch (Exception e) {
            LOG.log(Level.SEVERE, "Error loading donations", e);
            req.setAttribute("error", "Error while loading donations: " + e.getMessage());
        }

        req.setAttribute("donations", donations);
        req.getRequestDispatcher("/admin/admin_donations.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String id = req.getParameter("id");
        String action = req.getParameter("action");
        if (id != null && action != null) {
            String newStatus = null;
            if ("approve".equals(action)) newStatus = "ACCEPTED";
            else if ("reject".equals(action)) newStatus = "REJECTED";
            else if ("complete".equals(action)) newStatus = "COMPLETED";

            if (newStatus != null) {
                String updateSql = "UPDATE donationform SET status=? WHERE id=?";
                try (Connection con = getConnection();
                     PreparedStatement ps = con.prepareStatement(updateSql)) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, Integer.parseInt(id));
                    ps.executeUpdate();
                } catch (SQLException sqle) {
                    LOG.log(Level.SEVERE, "SQL error updating donation status", sqle);
                    req.setAttribute("error", "Unable to update donation status: " + sqle.getMessage());
                } catch (Exception e) {
                    LOG.log(Level.SEVERE, "Error updating donation status", e);
                    req.setAttribute("error", "Error updating donation status: " + e.getMessage());
                }
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/donations");
    }
}
