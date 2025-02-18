package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.BookingDAO;
import com.cabservice.megacitycabservice.dao.CarDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Date;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet("/booking")
public class BookingServlet extends HttpServlet {
    private final Gson gson = new Gson();

    @Override
    public void init() throws ServletException {
        super.init();
    }


    // Add a new booking
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String customerId = jsonObject.get("customer_id") != null ? jsonObject.get("customer_id").getAsString() : null;
        String pickupLocation = jsonObject.get("pickup_location") != null ? jsonObject.get("pickup_location").getAsString() : null;
        String dropOffLocation = jsonObject.get("dropoff_location") != null ? jsonObject.get("dropoff_location").getAsString() : null;
        String hireDate = jsonObject.get("hire_date") != null ? jsonObject.get("hire_date").getAsString() : null;
        String carId = jsonObject.get("car_id") != null ? jsonObject.get("car_id").getAsString() : null;
        String driverId = jsonObject.get("driver_id") != null ? jsonObject.get("driver_id").getAsString() : null;
        String hireTime = jsonObject.get("hire_time") != null ? jsonObject.get("hire_time").getAsString() : null;

        if (customerId == null || pickupLocation == null || dropOffLocation == null || hireDate == null || carId == null || driverId == null || hireTime == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Required fields are missing.\"}");
            return;
        }

        try {
            BookingDAO bookingDAO = new BookingDAO();
            boolean isBookingAdded = bookingDAO.addBooking(customerId, pickupLocation, dropOffLocation, hireDate, carId, driverId, hireTime);

            if (isBookingAdded) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Booking added successfully!\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to add booking.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error creating booking: " + e.getMessage() + "\"}");
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid input: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
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

