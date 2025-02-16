package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.CarDAO;
import com.cabservice.megacitycabservice.model.Car;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.google.gson.Gson;

import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin/cars")
public class CarServlet extends HttpServlet {
    private CarDAO carDAO;
    private final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        super.init();
        carDAO = new CarDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        Map<String, String> resp = new HashMap<>();

        try {
            String action = request.getParameter("action");

            if (action == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required.");
                return;
            }

            switch (action) {
                case "add":
                    addCar(request, response);
                    break;
                case "update":
                    updateCar(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Server error: " + e.getMessage());
        }
    }

    private void addCar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            Car car = gson.fromJson(reader, Car.class);

            car.setId(UUID.randomUUID());
            car.setStatus("available");

            String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            car.setCreatedAt(currentTime);
            car.setUpdatedAt(currentTime);

            boolean success = carDAO.addCar(car);

            response.setStatus(success ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", success ? "Car added successfully" : "Failed to add car")));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error adding car: " + e.getMessage());
        }
    }

    private void updateCar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            BufferedReader reader = request.getReader();
            Car car = gson.fromJson(reader, Car.class);

            if (car.getId() == null || car.getStatus() == null) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Car ID and status are required");
                return;
            }

            String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            car.setUpdatedAt(currentTime);

            boolean success = carDAO.updateCar(car);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("message", success ? "Car updated successfully" : "Failed to update car")));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error updating car: " + e.getMessage());
        }
    }


//    private void changeCarStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
//        try {
//            UUID id = UUID.fromString(request.getParameter("id"));
//            String status = request.getParameter("status");
//
//            if (!status.equalsIgnoreCase("available") && !status.equalsIgnoreCase("unavailable")) {
//                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid status value");
//                return;
//            }
//
//            boolean success = carDAO.changeCarStatus(id, status);
//            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
//            response.getWriter().write(gson.toJson(Map.of("message", success ? "Car status updated" : "Failed to update status")));
//
//        } catch (Exception e) {
//            e.printStackTrace();
//            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error changing car status: " + e.getMessage());
//        }
//    }
}
