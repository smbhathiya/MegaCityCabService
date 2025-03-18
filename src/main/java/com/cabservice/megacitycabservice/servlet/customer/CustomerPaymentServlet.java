package com.cabservice.megacitycabservice.servlet.customer;

import com.cabservice.megacitycabservice.dao.BookingDAO;
import com.cabservice.megacitycabservice.dao.PaymentDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Payment;
import com.cabservice.megacitycabservice.util.DBUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/customer/payments/*")
public class CustomerPaymentServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(CustomerPaymentServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received GET request for path: " + request.getPathInfo());

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID customerId = (UUID) session.getAttribute("userId");
        logger.info("Customer ID from session: " + customerId.toString());

        String pathInfo = request.getPathInfo();
        logger.info("Path Info: " + pathInfo);

        PaymentDAO paymentDAO = new PaymentDAO();
        try {
            if ("/pending".equals(pathInfo)) {
                logger.info("Fetching pending payments for customer: " + customerId);
                synchronized (DBUtil.class) {
                    List<Payment> pendingPayments = paymentDAO.getPendingPaymentsByCustomerId(customerId.toString());
                    logger.info("Pending payments retrieved: " + pendingPayments.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", pendingPayments)));
                }
            } else if ("/history".equals(pathInfo)) {
                logger.info("Fetching payment history for customer: " + customerId);
                synchronized (DBUtil.class) {
                    List<Payment> paymentHistory = paymentDAO.getPaymentHistoryByCustomerId(customerId.toString());
                    logger.info("Payment history retrieved: " + paymentHistory.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", paymentHistory)));
                }
            } else {
                logger.warning("Invalid endpoint: " + pathInfo);
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid payment endpoint");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in GET request", e);
            response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Database error: " + e.getMessage())));
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error in GET request", e);
            response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Unexpected error: " + e.getMessage())));
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received POST request for path: " + request.getPathInfo());

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID customerId = (UUID) session.getAttribute("userId");
        logger.info("Customer ID from session: " + customerId.toString());

        String pathInfo = request.getPathInfo();
        logger.info("Path Info: " + pathInfo);

        if (!"/make".equals(pathInfo)) {
            logger.warning("Invalid POST endpoint: " + pathInfo);
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid payment endpoint");
            return;
        }

        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            sb.append(line);
        }
        String requestBody = sb.toString();
        logger.info("Request Body: " + requestBody);

        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);
        String bookingId = jsonObject.get("bookingId").getAsString();
        String paymentMethod = jsonObject.get("paymentMethod").getAsString();
        logger.info("Parsed bookingId: " + bookingId + ", paymentMethod: " + paymentMethod);

        BookingDAO bookingDAO = new BookingDAO();
        PaymentDAO paymentDAO = new PaymentDAO();
        try {
            synchronized (DBUtil.class) {
                Booking booking = bookingDAO.getBookingById(UUID.fromString(bookingId));
                if (booking == null || !booking.getCustomerId().equals(customerId)) {
                    logger.warning("Invalid booking or unauthorized access: bookingId=" + bookingId);
                    response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Invalid booking or unauthorized access")));
                    return;
                }
                logger.info("Booking retrieved: " + booking.getBookingNumber());

                UUID paymentId = UUID.randomUUID();
                String transactionId = "TXN-" + UUID.randomUUID().toString().substring(0, 8);
                Payment payment = new Payment(
                        paymentId,
                        UUID.fromString(bookingId),
                        customerId,
                        booking.getTotalFare(),
                        paymentMethod,
                        transactionId,
                        "successful",
                        new Timestamp(System.currentTimeMillis())
                );
                logger.info("Payment object created: " + paymentId);

                boolean paymentAdded = paymentDAO.addPayment(payment);
                logger.info("Payment added to DB: " + paymentAdded);

                if (paymentAdded) {
                    Connection conn = DBUtil.getConnection();
                    String sql = "UPDATE bookings SET payment_status = 'paid', updated_at = NOW() WHERE id = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                        stmt.setString(1, bookingId);
                        int rowsAffected = stmt.executeUpdate();
                        logger.info("Booking payment status updated: " + rowsAffected + " rows affected");
                    }
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", "Payment processed successfully")));
                } else {
                    logger.warning("Failed to add payment to DB for booking: " + bookingId);
                    response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Failed to process payment")));
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error in POST request", e);
            response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Database error: " + e.getMessage())));
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error in POST request", e);
            response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Unexpected error: " + e.getMessage())));
        }
    }

    // Simple response wrapper class
    private static class ResponseWrapper {
        String status;
        Object data;

        ResponseWrapper(String status, Object data) {
            this.status = status;
            this.data = data;
        }
    }
}