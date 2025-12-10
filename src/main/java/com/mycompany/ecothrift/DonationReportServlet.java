package com.mycompany.ecothrift;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/DonationReportServlet")
public class DonationReportServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/ecothrift?serverTimezone=UTC";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        resp.setContentType("application/json;charset=UTF-8");

        HttpSession session = req.getSession(false);
        Integer userId = null;
        if (session != null && session.getAttribute("userId") != null)
            userId = Integer.parseInt(session.getAttribute("userId").toString());

        Map<String, Object> result = new LinkedHashMap<>();

        try (Connection con = getConnection()) {

            /* =====================================================
               1️⃣  ITEM DONATIONS (donationform)
               ===================================================== */
            Map<String,Integer> itemsDist = new LinkedHashMap<>();

            PreparedStatement ps1 = con.prepareStatement(
                "SELECT donation_type, COUNT(*) AS cnt FROM donationform GROUP BY donation_type"
            );
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                itemsDist.put(rs1.getString("donation_type"), rs1.getInt("cnt"));
            }
            result.put("items_distribution", itemsDist);

            // total items across platform
            int platformItems = 0;
            PreparedStatement ps2 = con.prepareStatement("SELECT COUNT(*) AS total FROM donationform");
            ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) platformItems = rs2.getInt("total");

            // total items donated by logged-in user
            int userItems = 0;
            PreparedStatement ps3 = con.prepareStatement(
                "SELECT COUNT(*) AS total FROM donationform WHERE user_id=?"
            );
            ps3.setInt(1, userId);
            ResultSet rs3 = ps3.executeQuery();
            if (rs3.next()) userItems = rs3.getInt("total");

            result.put("items_total", platformItems);
            result.put("items_user_total", userItems);
            result.put("items_user_percentage",
                platformItems == 0 ? 0 : (userItems * 100.0 / platformItems)
            );


            /* =====================================================
               2️⃣  MONETARY DONATIONS (orders.donation_amount)
               ===================================================== */
            double platformMoney = 0;
            PreparedStatement ps4 = con.prepareStatement(
                "SELECT IFNULL(SUM(donation_amount),0) AS total FROM orders"
            );
            ResultSet rs4 = ps4.executeQuery();
            if (rs4.next()) platformMoney = rs4.getDouble("total");

            double userMoney = 0;
            PreparedStatement ps5 = con.prepareStatement(
                "SELECT IFNULL(SUM(donation_amount),0) AS total FROM orders WHERE user_id=?"
            );
            ps5.setInt(1, userId);
            ResultSet rs5 = ps5.executeQuery();
            if (rs5.next()) userMoney = rs5.getDouble("total");

            Map<String,Object> money = new LinkedHashMap<>();
            money.put("platform_total", platformMoney);
            money.put("user_total", userMoney);
            money.put("user_percentage",
                platformMoney == 0 ? 0 : (userMoney * 100.0 / platformMoney)
            );

            result.put("monetary", money);


            result.put("ok", true);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("ok", false);
            result.put("error", e.getMessage());
        }

        PrintWriter out = resp.getWriter();
        out.print(toJson(result));
        out.close();
    }


    /* ----------------- Helper Methods ------------------ */

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }

    private String toJson(Object v) {
        if (v == null) return "null";

        if (v instanceof Map) {
            StringBuilder sb = new StringBuilder("{");
            boolean first = true;
            for (Object k : ((Map<?,?>) v).keySet()) {
                if (!first) sb.append(",");
                first = false;
                sb.append("\"").append(k).append("\":").append(toJson(((Map<?,?>) v).get(k)));
            }
            return sb.append("}").toString();
        }

        if (v instanceof Number || v instanceof Boolean)
            return v.toString();

        return "\"" + v.toString().replace("\"","\\\"") + "\"";
    }
}
