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
        HttpSession session = request.getSession();
        UUID customerId = (UUID) session.getAttribute("userId");
        if (customerId == null) {
            session.setAttribute("errorMessage", "User not logged in.");
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("confirmBooking".equals(action)) {
            handleConfirmation(request, response);
        } else {
            handleBookingCreation(request, response);
        }
    }

    private void handleBookingCreation(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        UUID customerId = (UUID) session.getAttribute("userId");

        String pickupLocation = request.getParameter("pickup_location");
        String dropoffLocation = request.getParameter("dropoff_location");
        String hireDate = request.getParameter("hire_date");
        String hireTime = request.getParameter("hire_time");
        int passengerCount;
        try {
            passengerCount = Integer.parseInt(request.getParameter("passenger_count"));
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid passenger count.");
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            return;
        }

        if (pickupLocation == null || dropoffLocation == null || hireDate == null || hireTime == null) {
            session.setAttribute("errorMessage", "Missing required fields.");
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            return;
        }

        try {
            CarDAO carDAO = new CarDAO();
            BookingDAO bookingDAO = new BookingDAO();
            CarAssignmentDAO carAssignmentDAO = new CarAssignmentDAO();

            List<Car> availableCars = carDAO.getAvailableCarsByDateAndCapacity(hireDate, passengerCount);
            if (availableCars.isEmpty()) {
                session.setAttribute("errorMessage", "No cars available for the selected date and passenger count.");
                response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
                return;
            }

            Car selectedCar = availableCars.get(0);
            UUID driverId = carAssignmentDAO.getDriverIdByCarId(selectedCar.getId());
            if (driverId == null) {
                session.setAttribute("errorMessage", "No driver assigned to the selected car.");
                response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
                return;
            }

            Random random = new Random();
            double distance = 10 + (random.nextDouble() * 50);
            double totalFare = (distance * 50) + (passengerCount * 10);
            String bookingNumber = "BOOK-" + String.format("%06d", random.nextInt(1000000));
            UUID bookingId = UUID.randomUUID();

            Booking booking = new Booking(
                    bookingId, bookingNumber, customerId, driverId, selectedCar.getId(),
                    pickupLocation, dropoffLocation, distance, "pending", totalFare, "pending", hireDate, hireTime
            );
            booking.setCarDetails(selectedCar); // Set car details for display

            boolean isAdded = bookingDAO.addBooking(booking);
            if (isAdded) {
                session.setAttribute("newBooking", booking);
                response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            } else {
                session.setAttribute("errorMessage", "Failed to create booking in database.");
                response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            }
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            e.printStackTrace();
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Unexpected error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            e.printStackTrace();
        }
    }

    private void handleConfirmation(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        String bookingId = request.getParameter("bookingId");
        String status = request.getParameter("status");

        try {
            BookingDAO bookingDAO = new BookingDAO();
            boolean updated = bookingDAO.updateBookingStatus(UUID.fromString(bookingId), status);
            if (updated) {
                session.removeAttribute("newBooking");
                response.sendRedirect(request.getContextPath() + "/views/customer/dashboard.jsp");
            } else {
                session.setAttribute("errorMessage", "Failed to update booking status.");
                response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
            }
        } catch (SQLException e) {
            session.setAttribute("errorMessage", "Error updating booking status: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/customer/addBooking.jsp");
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
                bookings = List.of(bookingDAO.getBookingById(UUID.fromString(bookingId)));
            } else if (customerId != null) {
                bookings = bookingDAO.getBookingsByCustomerId(customerId);
            } else if (driverId != null) {
                bookings = bookingDAO.getBookingsByDriverId(UUID.fromString(driverId));
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

