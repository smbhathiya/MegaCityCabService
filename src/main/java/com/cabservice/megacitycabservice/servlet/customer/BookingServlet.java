package com.cabservice.megacitycabservice.servlet.customer;

import com.cabservice.megacitycabservice.dao.BookingDAO;
import com.cabservice.megacitycabservice.dao.CarAssignmentDAO;
import com.cabservice.megacitycabservice.dao.CarDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Car;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.SQLException;
import java.util.List;
import java.util.Random;
import java.util.UUID;

@WebServlet("/booking")
public class BookingServlet extends HttpServlet {
    private final Gson gson = new Gson();

    // Create a new booking
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");

            StringBuilder stringBuilder = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                stringBuilder.append(line);
            }

            String requestBody = stringBuilder.toString();
            JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

            UUID customerId = UUID.fromString(jsonObject.get("customer_id").getAsString());
            String pickupLocation = jsonObject.get("pickup_location").getAsString();
            String dropoffLocation = jsonObject.get("dropoff_location").getAsString();
            String hireDate = jsonObject.get("hire_date").getAsString();
            String hireTime = jsonObject.get("hire_time").getAsString();
            int passengerCount = jsonObject.get("passenger_count").getAsInt();

            try {
                CarDAO carDAO = new CarDAO();
                BookingDAO bookingDAO = new BookingDAO();
                CarAssignmentDAO carAssignmentDAO = new CarAssignmentDAO();

                // Check for available cars
                List<Car> availableCars = carDAO.getAvailableCarsByDateAndCapacity(hireDate, passengerCount);
                if (availableCars.isEmpty()) {
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"No cars available for the selected date and passenger count.\"}");
                    return;
                }

                Car selectedCar = availableCars.get(0);

                // Fetch the driver assigned to the selected car
                UUID driverId = carAssignmentDAO.getDriverIdByCarId(selectedCar.getId());
                if (driverId == null) {
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"No driver assigned to the selected car.\"}");
                    return;
                }

                // Simulate distance (10-60 km)
                Random random = new Random();
                double distance = 10 + (random.nextDouble() * 50);

                // Calculate price (e.g., Rs. 50 per km + Rs. 10 per passenger)
                double totalFare = (distance * 50) + (passengerCount * 10);

                String bookingNumber = "BOOK-" + String.format("%06d", random.nextInt(1000000));

                // Create booking with driver_id
                UUID bookingId = UUID.randomUUID();
                Booking booking = new Booking(
                        bookingId,
                        bookingNumber,
                        customerId,
                        driverId, // Set driver_id here
                        selectedCar.getId(),
                        pickupLocation,
                        dropoffLocation,
                        distance,
                        "pending",
                        totalFare,
                        "pending",
                        hireDate,
                        hireTime
                );

                boolean isAdded = bookingDAO.addBooking(booking);
                if (isAdded) {
                    JsonObject carDetails = new JsonObject();
                    carDetails.addProperty("brand", selectedCar.getBrand());
                    carDetails.addProperty("model", selectedCar.getModel());
                    carDetails.addProperty("plateNumber", selectedCar.getPlateNumber());

                    JsonObject responseJson = new JsonObject();
                    responseJson.addProperty("status", "success");
                    responseJson.addProperty("bookingId", bookingId.toString());
                    responseJson.addProperty("bookingNumber", bookingNumber);
                    responseJson.add("carDetails", carDetails);
                    responseJson.addProperty("pickupLocation", pickupLocation);
                    responseJson.addProperty("dropoffLocation", dropoffLocation);
                    responseJson.addProperty("hireDate", hireDate);
                    responseJson.addProperty("hireTime", hireTime);
                    responseJson.addProperty("distance", distance);
                    responseJson.addProperty("total_fare", totalFare);

                    response.getWriter().write(gson.toJson(responseJson));
                } else {
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to create booking.\"}");
                }
            } catch (SQLException e) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Database error: " + e.getMessage() + "\"}");
                e.printStackTrace();
            }
        }

    // Cancel a booking
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }

        String requestBody = stringBuilder.toString();
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

        String bookingNumber = jsonObject.get("booking_number") != null ? jsonObject.get("booking_number").getAsString() : null;

        if (bookingNumber == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Booking number is required.\"}");
            return;
        }

        try {
            BookingDAO bookingDAO = new BookingDAO();
            boolean isBookingCancelled = bookingDAO.cancelBooking(bookingNumber);

            if (isBookingCancelled) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Booking cancelled successfully!\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to cancel booking.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error cancelling booking: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        }
    }

    // Get a booking by booking ID
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String bookingId = request.getParameter("booking_id");
        String customerId = request.getParameter("customer_id");
        String driverId = request.getParameter("driver_id");

        try {
            BookingDAO bookingDAO = new BookingDAO();
            List<Booking> bookings = null;

            if (bookingId != null) {
                bookings = List.of(bookingDAO.getBookingById(bookingId));
            } else if (customerId != null) {
                bookings = bookingDAO.getBookingsByCustomerId(customerId);
            } else if (driverId != null) {
                bookings = bookingDAO.getBookingsByDriverId(driverId);
            } else {
                bookings = bookingDAO.getAllBookings();
            }

            if (bookings != null && !bookings.isEmpty()) {
                response.getWriter().write(gson.toJson(bookings));
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"No bookings found.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error retrieving booking: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        }
    }
}

