package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.DriverDAO;
import com.cabservice.megacitycabservice.model.Driver;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin/drivers")
public class DriverServlet extends HttpServlet {
    private DriverDAO driverDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        driverDAO = new DriverDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("getAll".equals(action)) {
            getAllDrivers(request, response);
        } else if ("getById".equals(action)) {
            getDriverById(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        switch (action) {
            case "add":
                addDriver(request, response);
                break;
            case "update":
                updateDriver(request, response);
                break;
            case "changeStatus":
                changeDriverStatus(request, response);
                break;
            case "assignCar":
                assignCarToDriver(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    // add driver
    private void addDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            // Read the request body
            BufferedReader reader = request.getReader();
            Map<String, String> requestData = gson.fromJson(reader, Map.class);

            // Extract fields from the request
            String name = requestData.get("name");
            String email = requestData.get("email");
            String password = requestData.get("password");
            String licenseNumber = requestData.get("licenseNumber");

            // Log received data for debugging
            System.out.println("Received data: " + gson.toJson(requestData));

            // Validate inputs
            if (name == null || name.isEmpty() || email == null || email.isEmpty() || password == null || password.isEmpty() || licenseNumber == null || licenseNumber.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("message", "Missing required fields.")));
                return;
            }

            // Check if email already exists
            DriverDAO driverdao = new DriverDAO();
            if (driverdao.isEmailExists(email)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("message", "Email already exists. Please use a different email.")));
                return;
            }

            // Hash the password
            String hashedPassword = PasswordUtil.hashPassword(password);

            // Generate UUIDs
            UUID userId = UUID.randomUUID();
            UUID driverId = UUID.randomUUID();
            String currentTime = new Timestamp(System.currentTimeMillis()).toString();

            // Create User object
            User user = new User(userId, name, email, hashedPassword, "driver", true, currentTime, currentTime);

            // Create Driver object
            Driver driver = new Driver(driverId, userId, null, licenseNumber, "available", 0.0, currentTime, currentTime);

            // Register driver
            boolean isRegistered = driverdao.addDriver(user, driver);

            // Send response
            if (isRegistered) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write(gson.toJson(Map.of("message", "Driver registered successfully!")));
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(gson.toJson(Map.of("message", "Registration failed. Please try again.")));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", "Error adding driver: " + e.getMessage())));
        }
    }

    //update driver
    private void updateDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            JsonObject jsonObject = JsonParser.parseReader(reader).getAsJsonObject();

            UUID driverId = UUID.fromString(jsonObject.get("id").getAsString());
            String name = jsonObject.get("name").getAsString(); // Name from request

            // Fetch existing driver details
            Driver existingDriver = driverDAO.getDriverById(driverId);
            if (existingDriver == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Driver not found");
                return;
            }

            // Update only the allowed fields
            existingDriver.setCarId(jsonObject.has("carId") ? UUID.fromString(jsonObject.get("carId").getAsString()) : existingDriver.getCarId());
            existingDriver.setLicenseNumber(jsonObject.has("licenseNumber") ? jsonObject.get("licenseNumber").getAsString() : existingDriver.getLicenseNumber());
            existingDriver.setAvailabilityStatus(jsonObject.has("availabilityStatus") ? jsonObject.get("availabilityStatus").getAsString() : existingDriver.getAvailabilityStatus());
            existingDriver.setRating(jsonObject.has("rating") ? jsonObject.get("rating").getAsDouble() : existingDriver.getRating());
            existingDriver.setUpdatedAt(new Timestamp(System.currentTimeMillis()).toString());

            // Perform update
            boolean success = driverDAO.updateDriver(existingDriver, name);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", success ? "Driver updated successfully" : "Failed to update driver")));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating driver: " + e.getMessage());
        }
    }

    private void changeDriverStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            Map<String, String> requestData = gson.fromJson(reader, Map.class);

            UUID driverId = UUID.fromString(requestData.get("id"));
            String status = requestData.get("status");

            boolean success = driverDAO.changeDriverStatus(driverId, status);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", success ? "Driver status updated successfully" : "Failed to update status")));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating driver status: " + e.getMessage());
        }
    }

    private void assignCarToDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            Map<String, String> requestData = gson.fromJson(reader, Map.class);

            UUID driverId = UUID.fromString(requestData.get("driverId"));
            UUID carId = UUID.fromString(requestData.get("carId"));

            boolean success = driverDAO.assignCarToDriver(driverId, carId);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", success ? "Car assigned successfully" : "Failed to assign car")));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error assigning car: " + e.getMessage());
        }
    }

    // Get all drivers
    private void getAllDrivers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            List<Driver> drivers = driverDAO.getAllDrivers();
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(drivers));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving drivers: " + e.getMessage());
        }
    }

    // Get driver by ID
    private void getDriverById(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String driverIdParam = request.getParameter("driverId");
            if (driverIdParam == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Driver ID is required");
                return;
            }

            UUID driverId = UUID.fromString(driverIdParam);
            Driver driver = driverDAO.getDriverById(driverId);

            if (driver != null) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write(gson.toJson(driver));
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Driver not found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving driver: " + e.getMessage());
        }
    }
}
