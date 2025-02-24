package com.cabservice.megacitycabservice.servlet.driver;

import com.cabservice.megacitycabservice.dao.DriverDAO;
import com.cabservice.megacitycabservice.model.Driver;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet(urlPatterns = {"/driver", "/driver/password"})
public class DriverProfileServlet extends HttpServlet {

    private final Gson gson = new Gson();
    private DriverDAO driverDAO;

    @Override
    public void init() throws ServletException {
        driverDAO = new DriverDAO();
    }

    // Fetch driver details (GET /driver?id=<userId>)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("id");
        if (userId == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"User ID is required.\"}");
            return;
        }

        try {
            UUID id = UUID.fromString(userId);
            Driver driver = driverDAO.getDriverById(id);
            if (driver != null) {
                JsonObject responseJson = new JsonObject();
                responseJson.addProperty("name", driver.getName());
                responseJson.addProperty("email", driver.getEmail());
                responseJson.addProperty("licenseNumber", driver.getLicenseNumber());
                response.getWriter().write(gson.toJson(responseJson));
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Driver not found.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error retrieving driver: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid user ID format.\"}");
        }
    }

    // Update driver profile (PUT /driver)
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }

        String requestBody = stringBuilder.toString();
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

        String userId = jsonObject.get("id").getAsString();
        String name = jsonObject.get("name").getAsString();
        String email = jsonObject.get("email").getAsString();
        String licenseNumber = jsonObject.get("licenseNumber").getAsString();

        if (userId == null || name == null || email == null || licenseNumber == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"User ID, name, email, and license number are required.\"}");
            return;
        }

        try {
            UUID id = UUID.fromString(userId);
            boolean isUpdated = driverDAO.updateDriver(id, name, email, licenseNumber);
            if (isUpdated) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Driver profile updated successfully.\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to update driver profile.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error updating driver: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid user ID format.\"}");
        }
    }

    // Update driver password (POST /driver/password)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (!request.getServletPath().equals("/driver/password")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }

        String requestBody = stringBuilder.toString();
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

        String userId = jsonObject.get("id").getAsString();
        String oldPassword = jsonObject.get("oldPassword").getAsString();
        String newPassword = jsonObject.get("newPassword").getAsString();

        if (userId == null || oldPassword == null || newPassword == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"User ID, old password, and new password are required.\"}");
            return;
        }

        try {
            UUID id = UUID.fromString(userId);
            String currentPasswordHash = driverDAO.getPasswordHashById(id);
            if (currentPasswordHash == null || !PasswordUtil.verifyPassword(oldPassword, currentPasswordHash)) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Old password is incorrect.\"}");
                return;
            }

            String newPasswordHash = PasswordUtil.hashPassword(newPassword);
            boolean isUpdated = driverDAO.updateDriverPassword(id, newPasswordHash);
            if (isUpdated) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Password updated successfully.\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to update password.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error updating password: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid user ID format.\"}");
        }
    }
}