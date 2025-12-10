package com.mycompany.ecothrift;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,        // 1 MB
    maxFileSize = 5L * 1024 * 1024,         // 5 MB per file
    maxRequestSize = 6L * 1024 * 1024       // 6 MB total
)
@WebServlet("/DonationFormServlet")
public class DonationForm extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // match your LoginServlet DB URL & creds
    private static final String DB_URL  = "jdbc:mysql://localhost:3306/ecothrift?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    private static final long MAX_FILE_BYTES = 5L * 1024 * 1024; // 5 MB

    private static final String INSERT_SQL =
        "INSERT INTO donationform (user_id, name, email, phone, address, donation_type, ngo_name, other_ngo, donated_items, donation_photo_path, pickup_datetime, status, created_at) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // --- read userId from session (exactly what LoginServlet sets) ---
        HttpSession session = req.getSession(false);
        Integer userId = null;
        if (session != null) {
            Object uid = session.getAttribute("userId"); // matches LoginServlet
            if (uid instanceof Number) userId = ((Number) uid).intValue();
            else if (uid instanceof String) {
                try { userId = Integer.valueOf(((String) uid).trim()); } catch (NumberFormatException ignored) {}
            }
        }

        // require login to donate (recommended) - change if you want anonymous donations
        if (userId == null) {
            resp.sendRedirect("login.jsp?redirect=donate");
            return;
        }

        // --- read form params ---
        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String address = req.getParameter("address");
        String donationType = req.getParameter("donation_type");
        String ngoName = req.getParameter("ngo_name");
        String otherNgo = req.getParameter("other_ngo");
        String donatedItems = req.getParameter("donated_items");
        String pickupDate = req.getParameter("pickup_date"); // yyyy-MM-dd
        String pickupTime = req.getParameter("pickup_time"); // HH:mm

        // simple validation
        if (isEmpty(name) || isEmpty(email) || isEmpty(phone) || isEmpty(address)
                || isEmpty(donationType) || isEmpty(donatedItems)
                || isEmpty(pickupDate) || isEmpty(pickupTime)) {

            req.setAttribute("error", "Please fill all required fields.");
            req.getRequestDispatcher("donate.jsp").forward(req, resp);
            return;
        }

        // combine date+time into Timestamp
        Timestamp pickupTimestamp;
        try {
            LocalDateTime ldt = LocalDateTime.parse(pickupDate + "T" + pickupTime);
            pickupTimestamp = Timestamp.valueOf(ldt);
        } catch (DateTimeParseException e) {
            pickupTimestamp = Timestamp.valueOf(LocalDateTime.now().plusDays(1));
        }

        // --- handle optional image upload ---
        String savedFileRelativePath = null;
        try {
            Part filePart = req.getPart("donation_photo");
            if (filePart != null && filePart.getSize() > 0) {
                if (filePart.getSize() > MAX_FILE_BYTES) {
                    req.setAttribute("error", "File size must be under 5 MB.");
                    req.getRequestDispatcher("donate.jsp").forward(req, resp);
                    return;
                }

                String contentType = filePart.getContentType();
                if (contentType == null || !contentType.startsWith("image/")) {
                    req.setAttribute("error", "Uploaded file must be an image.");
                    req.getRequestDispatcher("donate.jsp").forward(req, resp);
                    return;
                }

                // Determine upload dir
                String uploadsPath = getServletContext().getRealPath("/uploads/donations");
                if (uploadsPath == null) {
                    uploadsPath = System.getProperty("java.io.tmpdir") + File.separator + "ecothrift_uploads";
                }

                File uploadsDir = new File(uploadsPath);
                if (!uploadsDir.exists()) {
                    if (!uploadsDir.mkdirs()) {
                        req.setAttribute("error", "Server upload folder unavailable.");
                        req.getRequestDispatcher("donate.jsp").forward(req, resp);
                        return;
                    }
                }

                String submittedName = filePart.getSubmittedFileName();
                String ext = ".jpg";
                if (submittedName != null && submittedName.contains(".")) {
                    ext = submittedName.substring(submittedName.lastIndexOf(".")).toLowerCase();
                    if (!ext.matches("\\.(jpg|jpeg|png|gif|webp|bmp)")) ext = ".jpg";
                }

                String filename = "donation_" + System.currentTimeMillis() + ext;
                File outFile = new File(uploadsDir, filename);

                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, outFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
                } catch (IOException ioe) {
                    ioe.printStackTrace();
                    req.setAttribute("error", "Unable to save uploaded file.");
                    req.getRequestDispatcher("donate.jsp").forward(req, resp);
                    return;
                }

                savedFileRelativePath = "/uploads/donations/" + filename;
            }
        } catch (ServletException se) {
            se.printStackTrace();
            req.setAttribute("error", "Error processing uploaded file.");
            req.getRequestDispatcher("donate.jsp").forward(req, resp);
            return;
        }

        // --- insert into DB ---
        try (Connection con = getConnection();
             PreparedStatement pst = con.prepareStatement(INSERT_SQL)) {

            // set user id (from login)
            pst.setInt(1, userId);

            pst.setString(2, name);
            pst.setString(3, email);
            pst.setString(4, phone);
            pst.setString(5, address);
            pst.setString(6, donationType);
            pst.setString(7, ngoName);

            if (isEmpty(otherNgo)) pst.setNull(8, Types.VARCHAR);
            else pst.setString(8, otherNgo);

            pst.setString(9, donatedItems);

            if (savedFileRelativePath == null) pst.setNull(10, Types.VARCHAR);
            else pst.setString(10, savedFileRelativePath);

            pst.setTimestamp(11, pickupTimestamp);
            pst.setString(12, "Pending");

            int rows = pst.executeUpdate();
            if (rows > 0) {
                resp.sendRedirect("donationSuccess.jsp");
            } else {
                req.setAttribute("error", "Unable to save donation. Please try again.");
                req.getRequestDispatcher("donate.jsp").forward(req, resp);
            }

        } catch (SQLException ex) {
            ex.printStackTrace();
            req.setAttribute("error", "Database error: " + ex.getMessage());
            req.getRequestDispatcher("donate.jsp").forward(req, resp);
        }
    }

    // --- helpers ---
    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // ensure driver present
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
}
