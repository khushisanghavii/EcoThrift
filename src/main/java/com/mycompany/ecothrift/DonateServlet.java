package com.mycompany.ecothrift;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/DonateServlet")
public class DonateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Collect form data
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String ngoName = request.getParameter("ngo_name");
        String otherNgo = request.getParameter("other_ngo");
        String donatedItems = request.getParameter("donated_items");
        String celebrateBirthday = request.getParameter("celebrate_birthday");
        String[] birthdayOptions = request.getParameterValues("birthday_option");
        String message = request.getParameter("message");

        // Log donation info safely
        System.out.println("=== New Donation Received ===");
        System.out.println("Name: " + name);
        System.out.println("Email: " + email);
        System.out.println("Phone: " + phone);
        System.out.println("Address: " + address);

        if (ngoName != null) {
            System.out.println("Selected NGO: " + ngoName);
            if ("Other".equalsIgnoreCase(ngoName) && otherNgo != null && !otherNgo.isEmpty()) {
                System.out.println("Specified NGO: " + otherNgo);
            }
        } else {
            System.out.println("No NGO selected");
        }

        System.out.println("Items Donated: " + donatedItems);
        System.out.println("Celebrate Birthday: " + celebrateBirthday);

        if (birthdayOptions != null) {
            System.out.println("Birthday Activities Selected:");
            for (String option : birthdayOptions) {
                System.out.println(" - " + option);
            }
        }

        if (message != null && !message.trim().isEmpty()) {
            System.out.println("Message: " + message);
        }

        System.out.println("==============================");

        // Redirect to success page
        response.sendRedirect("donationSuccess.jsp");
    }
}
