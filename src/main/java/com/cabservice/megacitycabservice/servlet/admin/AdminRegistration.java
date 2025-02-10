package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.UserDao;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
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
import com.google.gson.Gson;

@WebServlet("/api/registerAdmin")
public class AdminRegistration extends HttpServlet {

    private final Gson gson = new Gson();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();
        StringBuilder jsonBuffer = new StringBuilder();
        String line;

        // Read the JSON payload from the request
        BufferedReader reader = request.getReader();
        while ((line = reader.readLine()) != null) {
            jsonBuffer.append(line);
        }

        // Parse the JSON payload into a User object
        String jsonString = jsonBuffer.toString();
        User adminUser = gson.fromJson(jsonString, User.class);

        // Hash the password
        String hashedPassword = PasswordUtil.hashPassword(adminUser.getPassword());
        adminUser.setPassword(hashedPassword);

        // Register the admin user
        UserDao userDAO = new UserDao();
        Map<String, String> resp = new HashMap<>();

        try {
            boolean isRegistered = userDAO.registerAdmin(adminUser);
            if (isRegistered) {
                response.setStatus(HttpServletResponse.SC_CREATED); // 201 Created
                resp.put("status", "success");
                resp.put("message", "Admin registration successful!");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
                resp.put("status", "error");
                resp.put("message", "Admin registration failed. Please try again.");
            }
        } catch (SQLException e) {
            if (e.getMessage().equals("AdminExists")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
                resp.put("status", "error");
                resp.put("message", "An admin account already exists!");
            } else if (e.getMessage().equals("EmailTaken")) {
                response.setStatus(HttpServletResponse.SC_CONFLICT); // 409 Conflict
                resp.put("status", "error");
                resp.put("message", "Error: Email already taken.");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
                resp.put("status", "error");
                resp.put("message", "Server error, please try again later.");
            }
        }

        // Send the JSON response
        out.write(gson.toJson(resp));
    }
}