package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.DriverDAO;
import com.cabservice.megacitycabservice.model.Driver;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
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
        try {
            List<Driver> drivers = driverDAO.getAllDrivers();
            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(drivers));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving drivers: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                addDriver(request, response);
                break;
            case "update":
                updateDriver(request, response);
                break;
            default:
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String driverId = request.getParameter("id");
            if (driverId == null || driverId.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Driver ID is required");
                return;
            }

            UUID id = UUID.fromString(driverId);
            boolean success = driverDAO.removeDriver(id);
            response.setContentType("application/json");
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of(
                    "status", success ? "success" : "error",
                    "message", success ? "Driver removed successfully" : "Failed to remove driver"
            )));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error removing driver: " + e.getMessage());
        }
    }

    private void addDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String licenseNumber = request.getParameter("licenseNumber");

            if (name == null || email == null || password == null || licenseNumber == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required fields");
                return;
            }

            UUID userId = UUID.randomUUID();
            UUID driverId = UUID.randomUUID();
            String currentTime = new Timestamp(System.currentTimeMillis()).toString();
            User user = new User(userId, name, email, PasswordUtil.hashPassword(password), "driver", true, currentTime, currentTime);
            Driver driver = new Driver(driverId, userId, null, licenseNumber, "available", 0.0, currentTime, currentTime);

            boolean success = driverDAO.addDriver(user, driver);
            response.setContentType("application/json");
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of(
                    "status", success ? "success" : "error",
                    "message", success ? "Driver added successfully" : "Failed to add driver"
            )));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error adding driver: " + e.getMessage());
        }
    }

    private void updateDriver(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            JsonObject json = gson.fromJson(reader, JsonObject.class);

            UUID driverId = UUID.fromString(json.get("id").getAsString());
            String name = json.get("name").getAsString();
            String licenseNumber = json.get("licenseNumber").getAsString();
            String availabilityStatus = json.get("availabilityStatus").getAsString();
            String currentTime = new Timestamp(System.currentTimeMillis()).toString();

            Driver driver = new Driver(driverId, null, null, licenseNumber, availabilityStatus, 0.0, null, currentTime);
            driver.setUserId(driverDAO.getDriverById(driverId).getUserId());

            boolean success = driverDAO.updateDriver(driver, name);
            response.setContentType("application/json");
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of(
                    "status", success ? "success" : "error",
                    "message", success ? "Driver updated successfully" : "Failed to update driver"
            )));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating driver: " + e.getMessage());
        }
    }
}