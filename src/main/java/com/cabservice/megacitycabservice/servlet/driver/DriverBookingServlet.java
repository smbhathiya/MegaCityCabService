package com.cabservice.megacitycabservice.servlet.driver;

import com.cabservice.megacitycabservice.dao.BookingDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = {"/driver/bookings", "/driver/bookings/details", "/driver/bookings/status"})
public class DriverBookingServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String path = request.getServletPath();
        if ("/driver/bookings".equals(path)) {
            String driverId = request.getParameter("id");
            if (driverId == null) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Driver ID is required.\"}");
                return;
            }
            try {
                UUID id = UUID.fromString(driverId);
                List<Booking> bookings = bookingDAO.getBookingsByDriverId(id);
                JsonObject responseJson = new JsonObject();
                responseJson.addProperty("status", "success");
                responseJson.add("bookings", gson.toJsonTree(bookings));
                response.getWriter().write(gson.toJson(responseJson));
            } catch (SQLException e) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Error retrieving bookings: " + e.getMessage() + "\"}");
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid driver ID format.\"}");
            }
        } else if ("/driver/bookings/details".equals(path)) {
            String bookingId = request.getParameter("id");
            if (bookingId == null) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Booking ID is required.\"}");
                return;
            }
            try {
                UUID id = UUID.fromString(bookingId);
                Booking booking = bookingDAO.getBookingById(id);
                if (booking != null) {
                    response.getWriter().write(gson.toJson(booking));
                } else {
                    response.getWriter().write("{\"status\": \"error\", \"message\": \"Booking not found.\"}");
                }
            } catch (SQLException e) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Error retrieving booking details: " + e.getMessage() + "\"}");
                e.printStackTrace();
            } catch (IllegalArgumentException e) {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid booking ID format.\"}");
            }
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        if (!"/driver/bookings/status".equals(request.getServletPath())) {
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

        String bookingId = jsonObject.get("id").getAsString();
        String newStatus = jsonObject.get("status").getAsString();

        if (bookingId == null || newStatus == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Booking ID and status are required.\"}");
            return;
        }

        try {
            UUID id = UUID.fromString(bookingId);
            boolean isUpdated = bookingDAO.updateBookingStatus(id, newStatus);
            if (isUpdated) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Booking status updated successfully.\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to update booking status.\"}");
            }
        } catch (SQLException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error updating booking status: " + e.getMessage() + "\"}");
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid booking ID format.\"}");
        }
    }
}