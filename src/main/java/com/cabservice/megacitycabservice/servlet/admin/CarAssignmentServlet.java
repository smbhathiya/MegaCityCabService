package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.CarAssignmentDAO;
import com.cabservice.megacitycabservice.dao.DriverDAO;
import com.cabservice.megacitycabservice.model.Driver;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin/assign-car")
public class CarAssignmentServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private CarAssignmentDAO carAssignmentDAO;
    private DriverDAO driverDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        carAssignmentDAO = new CarAssignmentDAO();
        driverDAO = new DriverDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);

        // Check admin authentication
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Admin access required")));
            return;
        }

        String availableOnly = request.getParameter("availableOnly");
        if ("true".equalsIgnoreCase(availableOnly)) {
            try {
                List<com.cabservice.megacitycabservice.model.Car> cars = carAssignmentDAO.getUnassignedCars();
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write(gson.toJson(cars));
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Error fetching unassigned cars: " + e.getMessage())));
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Use availableOnly=true to get unassigned cars")));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);

        // Check admin authentication
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Admin access required")));
            return;
        }

        try {
            BufferedReader reader = request.getReader();
            JsonObject json = gson.fromJson(reader, JsonObject.class);

            String driverIdStr = json.get("driverId").getAsString();
            String carIdStr = json.get("carId").getAsString();

            if (driverIdStr == null || carIdStr == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Driver ID and Car ID are required")));
                return;
            }

            UUID driverId = UUID.fromString(driverIdStr);
            UUID carId = UUID.fromString(carIdStr);

            Driver driver = driverDAO.getDriverById(driverId);
            if (driver == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Driver not found")));
                return;
            }


            // Check if car is already assigned
            if (carAssignmentDAO.isCarAssigned(carId)) {
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Car is already assigned to another driver")));
                return;
            }

            boolean success = carAssignmentDAO.assignCarToDriver(driverId, carId);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of(
                    "status", success ? "success" : "error",
                    "message", success ? "Car assigned successfully" : "Failed to assign car"
            )));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Error assigning car: " + e.getMessage())));
        }
    }
}