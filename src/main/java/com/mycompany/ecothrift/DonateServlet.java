package com.mycompany.ecothrift;

import java.io.*;
import java.nio.file.*;
import java.sql.*;
import java.time.*;
import java.time.format.DateTimeParseException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 10 * 1024 * 1024,  // 10MB
    maxRequestSize = 20 * 1024 * 1024
)
@WebServlet("/DonateServlet")
public class DonateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // DB config - update if needed
    private static final String DB_URL = "jdbc:mysql://localhost:3306/ecothrift?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    // EXTERNAL upload root - must match folder you created
    private static final String EXTERNAL_UPLOAD_ROOT = "/Users/khushisanghavi/EcothriftUploads";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        // ensure directories exist
        File root = new File(EXTERNAL_UPLOAD_ROOT);
        if (!root.exists()) root.mkdirs();
        File donationsDir = new File(root, "donations");
        if (!donationsDir.exists()) donationsDir.mkdirs();

        // --- read form fields (names must match your donate.jsp)
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        String donationType = request.getParameter("type");
        String donatedItems = request.getParameter("items");
        String ngoName = request.getParameter("ngo");
        String otherNgo = request.getParameter("other_ngo");

        String pickupDate = request.getParameter("pickup");      // yyyy-MM-dd
        String pickupTime = request.getParameter("pickup_time"); // HH:mm (optional)
        Timestamp pickupTimestamp = null;

        if (pickupDate != null && !pickupDate.trim().isEmpty()) {
            try {
                LocalDate d = LocalDate.parse(pickupDate);
                LocalTime t = (pickupTime != null && !pickupTime.trim().isEmpty()) ? LocalTime.parse(pickupTime) : LocalTime.of(9,0);
                LocalDateTime ldt = LocalDateTime.of(d, t);
                pickupTimestamp = Timestamp.valueOf(ldt);
            } catch (DateTimeParseException ex) {
                // ignore parse error and leave pickupTimestamp null
                System.out.println("[DonateServlet] pickup parse error: " + ex.getMessage());
            }
        }

        // get logged-in user id from session
        HttpSession session = request.getSession(false);
        Integer userId = (session != null && session.getAttribute("userId") != null)
                ? Integer.parseInt(session.getAttribute("userId").toString()) : null;
        if (userId == null) {
            // not logged in -> redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // --- handle file upload (name = "photo")
        Part photoPart = request.getPart("photo");
        String savedFilename = null;

        if (photoPart != null && photoPart.getSize() > 0) {
            String submitted = getSubmittedFileName(photoPart);
            String ext = "";
            int dot = (submitted != null) ? submitted.lastIndexOf('.') : -1;
            if (dot > 0) ext = submitted.substring(dot).toLowerCase();

            String unique = "donation_" + System.currentTimeMillis();
            savedFilename = unique + ext;

            File outFile = new File(donationsDir, savedFilename);
            try (InputStream in = photoPart.getInputStream()) {
                Files.copy(in, outFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            } catch (IOException ex) {
                ex.printStackTrace();
                request.setAttribute("error", "Failed to save uploaded file.");
            }
        }

        // --- INSERT into DB
        // NOTE: adjust column list to match your donationform table exactly.
        String sql = "INSERT INTO donationform "
                   + "(user_id, name, email, phone, address, donation_type, donated_items, ngo_name, other_ngo, donation_photo_path, pickup_datetime, status, created_at) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);                 // user_id
            ps.setString(2, name);                // name
            ps.setString(3, email);               // email
            ps.setString(4, phone);               // phone
            ps.setString(5, address);             // address
            ps.setString(6, donationType);        // donation_type
            ps.setString(7, donatedItems);        // donated_items
            ps.setString(8, ngoName);             // ngo_name
            ps.setString(9, otherNgo);            // other_ngo

            if (savedFilename != null) ps.setString(10, savedFilename);
            else ps.setNull(10, Types.VARCHAR);

            if (pickupTimestamp != null) ps.setTimestamp(11, pickupTimestamp);
            else ps.setNull(11, Types.TIMESTAMP);

            ps.setString(12, "Pending"); // status
            ps.executeUpdate();

            System.out.println("[DonateServlet] Insert successful for userId=" + userId + " file=" + savedFilename);

        } catch (SQLException e) {
            // Log and forward friendly error
            e.printStackTrace();
            request.setAttribute("error", "DB error: " + e.getMessage());
        }

        // redirect back to donations list
        response.sendRedirect(request.getContextPath() + "/DonationListServlet");
    }

    // helper to parse filename from Part header
    private static String getSubmittedFileName(Part part) {
        if (part == null) return null;
        String header = part.getHeader("content-disposition");
        if (header == null) return null;
        for (String cd : header.split(";")) {
            if (cd.trim().startsWith("filename")) {
                String filename = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                return filename;
            }
        }
        return null;
    }
}
