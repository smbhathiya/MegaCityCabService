package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.AdminDAO;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/api/admin")
public class AdminServlet extends HttpServlet {

    private final Gson gson = new Gson();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        Map<String, String> resp = new HashMap<>();

        try {
            // Read JSON request body
            StringBuilder jsonBuffer = new StringBuilder();
            String line;
            BufferedReader reader = request.getReader();
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }

            // Convert JSON to User object
            User adminUser = gson.fromJson(jsonBuffer.toString(), User.class);

            // Hash the password before storing
            adminUser.setPassword(PasswordUtil.hashPassword(adminUser.getPassword()));

            // Register the admin
            AdminDAO adminDao = new AdminDAO();
            boolean isRegistered = adminDao.registerAdmin(adminUser);

            if (isRegistered) {
                response.setStatus(HttpServletResponse.SC_CREATED);
                resp.put("status", "success");
                resp.put("message", "Admin registration successful!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.put("status", "error");
                resp.put("message", "Admin registration failed. Please try again.");
            }

        } catch (SQLException e) {
            e.printStackTrace(); // Log the full error

            if ("AdminExists".equals(e.getMessage())) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                resp.put("status", "error");
                resp.put("message", "An admin account already exists!");
            } else if ("EmailTaken".equals(e.getMessage())) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                resp.put("status", "error");
                resp.put("message", "Error: Email already taken.");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.put("status", "error");
                resp.put("message", "Unexpected server error: " + e.getMessage());
            }
        }

        // Send JSON response
        out.write(gson.toJson(resp));
    }
}
