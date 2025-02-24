package com.cabservice.megacitycabservice.servlet.customer;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.logging.Logger;

@WebServlet("/booking/confirm")
public class BookingConfirmServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(BookingConfirmServlet.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Read request body
        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }
        String requestBody = stringBuilder.toString();
        logger.info("Request Body: " + requestBody);

        // Parse JSON
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);
        String bookingId = jsonObject.get("bookingId") != null ? jsonObject.get("bookingId").getAsString() : null;
        String status = jsonObject.get("status") != null ? jsonObject.get("status").getAsString() : null;

        JsonObject responseJson = new JsonObject();

        // Basic validation
        if (bookingId == null || status == null) {
            responseJson.addProperty("status", "error");
            responseJson.addProperty("message", "Booking ID and status are required.");
        } else {
            try (Connection conn = com.cabservice.megacitycabservice.util.DBUtil.getConnection();
                 PreparedStatement stmt = conn.prepareStatement("UPDATE bookings SET booking_status = ?, updated_at = NOW() WHERE id = ?")) {
                stmt.setString(1, status);
                stmt.setString(2, bookingId);
                logger.info("Executing update: bookingId=" + bookingId + ", status=" + status);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    responseJson.addProperty("status", "success");
                    responseJson.addProperty("message", "Update successful");
                } else {
                    responseJson.addProperty("status", "error");
                    responseJson.addProperty("message", "Booking not found or update failed.");
                }
            } catch (SQLException e) {
                logger.severe("SQLException: " + e.getMessage());
                responseJson.addProperty("status", "error");
                responseJson.addProperty("message", "Database error: " + e.getMessage());
            }
        }

        String jsonResponse = gson.toJson(responseJson);
        logger.info("Sending response: " + jsonResponse);
        response.getWriter().write(jsonResponse);
    }
}