package com.mycompany.ecothrift;

import java.io.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.nio.file.*;

@WebServlet("/uploads/*")
public class FileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // must match external folder where uploads are stored
    private static final String EXTERNAL_UPLOADS_ROOT = "/Users/khushisanghavi/EcothriftUploads";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String pathInfo = req.getPathInfo(); // e.g. /donation_1765...jpg
        if (pathInfo == null || pathInfo.equals("/")) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        // Normalize to prevent traversal
        Path requested = Paths.get(pathInfo).normalize();
        String requestedNormalized = requested.toString().replace("\\", "/");
        if (requestedNormalized.startsWith("..")) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        File externalFile = new File(EXTERNAL_UPLOADS_ROOT, requestedNormalized);
        String webappUploadsReal = getServletContext().getRealPath("/uploads");
        File webappFile = (webappUploadsReal == null) ? null : new File(webappUploadsReal, requestedNormalized);

        System.out.println("FileServlet request pathInfo=" + pathInfo + " normalized=" + requestedNormalized
                + " -> external=" + externalFile.getAbsolutePath()
                + (webappFile != null ? (" webapp=" + webappFile.getAbsolutePath()) : " webapp=null"));

        File toServe = null;
        if (externalFile.exists() && externalFile.isFile()) toServe = externalFile;
        else if (webappFile != null && webappFile.exists() && webappFile.isFile()) toServe = webappFile;

        if (toServe == null) {
            System.out.println("FileServlet: NOT FOUND for: " + requestedNormalized);
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = getServletContext().getMimeType(toServe.getName());
        if (mime == null) mime = "application/octet-stream";
        resp.setContentType(mime);
        resp.setContentLengthLong(toServe.length());
        resp.setHeader("Cache-Control", "public, max-age=86400");

        try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(toServe));
             BufferedOutputStream out = new BufferedOutputStream(resp.getOutputStream())) {
            byte[] buffer = new byte[8192];
            int len;
            while ((len = in.read(buffer)) != -1) out.write(buffer, 0, len);
        } catch (IOException ioe) {
            System.out.println("FileServlet: IO error serving " + toServe.getAbsolutePath() + " -> " + ioe.getMessage());
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
