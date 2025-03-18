package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.CarDAO;
import com.cabservice.megacitycabservice.model.Car;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@WebServlet("/admin/cars")
public class CarServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private CarDAO carDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        carDAO = new CarDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Admin access required")));
            return;
        }
        List<Car> cars = carDAO.getAllCars();
        response.getWriter().write(gson.toJson(cars));
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Admin access required")));
            return;
        }

        String action = request.getParameter("action");
        System.out.println("Action received: " + action); // Debug log
        if (action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Action parameter is required")));
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
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid action")));
        }
    }

    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Admin access required")));
            return;
        }

        String carId = request.getParameter("id");
        if (carId == null || carId.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Car ID is required")));
            return;
        }

        try {
            UUID.fromString(carId);
            boolean success = carDAO.removeCar(carId);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write(gson.toJson(Map.of("status", success ? "success" : "error", "message", success ? "Car removed successfully" : "Car not found")));
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid car ID format")));
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Error removing car: " + e.getMessage())));
        }
    }

    private void addCar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            // Log all received parameters
            System.out.println("Received parameters:");
            request.getParameterMap().forEach((key, value) ->
                    System.out.println(key + ": " + String.join(",", value)));

            Car car = new Car();
            car.setId(UUID.fromString(request.getParameter("id")));
            car.setPlateNumber(request.getParameter("plate_number"));
            car.setModel(request.getParameter("model"));
            car.setBrand(request.getParameter("brand"));
            String yearStr = request.getParameter("year");
            String capacityStr = request.getParameter("capacity");
            car.setColor(request.getParameter("color"));

            System.out.println("After setting: plate_number=" + car.getPlateNumber() +
                    ", model=" + car.getModel() +
                    ", brand=" + car.getBrand() +
                    ", year=" + yearStr +
                    ", color=" + car.getColor() +
                    ", capacity=" + capacityStr);

            if (car.getPlateNumber() == null || car.getPlateNumber().trim().isEmpty() ||
                    car.getModel() == null || car.getModel().trim().isEmpty() ||
                    car.getBrand() == null || car.getBrand().trim().isEmpty() ||
                    yearStr == null || yearStr.trim().isEmpty() ||
                    car.getColor() == null || car.getColor().trim().isEmpty() ||
                    capacityStr == null || capacityStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "All car fields are required and must not be empty")));
                return;
            }

            car.setYear(Integer.parseInt(yearStr.trim()));
            car.setCapacity(Integer.parseInt(capacityStr.trim()));
            car.setId(UUID.randomUUID());
            car.setStatus("available");
            String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            car.setCreatedAt(currentTime);
            car.setUpdatedAt(currentTime);

            System.out.println("Attempting to add car: " + gson.toJson(car));
            boolean success = carDAO.addCar(car);
            System.out.println("Add car result: " + success);

            response.setStatus(success ? HttpServletResponse.SC_CREATED : HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> responseMap = new HashMap<>();
            responseMap.put("status", success ? "success" : "error");
            responseMap.put("message", success ? "Car added successfully" : "Failed to add car");
            if (success) responseMap.put("carId", car.getId().toString());
            response.getWriter().write(gson.toJson(responseMap));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid number format for year or capacity")));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Error adding car: " + e.getMessage())));
        }
    }

    private void updateCar(HttpServletRequest request, HttpServletResponse response) throws IOException {
        try {
            Car car = new Car();
            car.setId(UUID.fromString(request.getParameter("id")));
            car.setPlateNumber(request.getParameter("plate_number"));
            car.setModel(request.getParameter("model"));
            car.setBrand(request.getParameter("brand"));
            String yearStr = request.getParameter("year");
            String capacityStr = request.getParameter("capacity");
            car.setColor(request.getParameter("color"));
            car.setStatus(request.getParameter("status"));

            if (car.getId() == null || car.getPlateNumber() == null || car.getPlateNumber().trim().isEmpty() ||
                    car.getModel() == null || car.getModel().trim().isEmpty() ||
                    car.getBrand() == null || car.getBrand().trim().isEmpty() ||
                    yearStr == null || yearStr.trim().isEmpty() ||
                    car.getColor() == null || car.getColor().trim().isEmpty() ||
                    capacityStr == null || capacityStr.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "All car fields are required and must not be empty")));
                return;
            }

            car.setYear(Integer.parseInt(yearStr.trim()));
            car.setCapacity(Integer.parseInt(capacityStr.trim()));
            String currentTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            car.setUpdatedAt(currentTime);

            boolean success = carDAO.updateCar(car);
            response.setStatus(success ? HttpServletResponse.SC_OK : HttpServletResponse.SC_NOT_FOUND);
            response.getWriter().write(gson.toJson(Map.of("status", success ? "success" : "error", "message", success ? "Car updated successfully" : "Car not found")));
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Invalid number format for year or capacity")));
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write(gson.toJson(Map.of("status", "error", "message", "Error updating car: " + e.getMessage())));
        }
    }
}