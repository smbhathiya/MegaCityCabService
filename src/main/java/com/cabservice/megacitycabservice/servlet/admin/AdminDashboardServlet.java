package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.AdminDashboardDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Payment;
import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/admin/*")
public class AdminDashboardServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(AdminDashboardServlet.class.getName());
    private static final int MAX_RETRIES = 3;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received GET request for path: " + request.getPathInfo());

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID adminId = (UUID) session.getAttribute("userId");
        logger.info("Admin ID from session: " + adminId.toString());

        String pathInfo = request.getPathInfo();
        logger.info("Path Info: " + pathInfo);

        AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
        int retries = 0;
        boolean success = false;
        String errorMessage = null;

        while (retries < MAX_RETRIES && !success) {
            try {
                if ("/payments/history".equals(pathInfo)) {
                    logger.info("Fetching payment history");
                    List<Payment> paymentHistory = dashboardDAO.getPaymentHistory();
                    logger.info("Payment history retrieved: " + paymentHistory.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", paymentHistory)));
                    success = true;
                } else if ("/bookings".equals(pathInfo)) {
                    logger.info("Fetching all bookings");
                    List<Booking> bookings = dashboardDAO.getAllBookings();
                    logger.info("Bookings retrieved: " + bookings.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", bookings)));
                    success = true;
                } else if ("/vehicles/count".equals(pathInfo)) {
                    logger.info("Fetching total vehicles count");
                    int totalCars = dashboardDAO.getTotalCars();
                    logger.info("Total vehicles: " + totalCars);
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", totalCars)));
                    success = true;
                } else if ("/drivers/count".equals(pathInfo)) {
                    logger.info("Fetching total drivers count");
                    int totalDrivers = dashboardDAO.getTotalDrivers();
                    logger.info("Total drivers: " + totalDrivers);
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", totalDrivers)));
                    success = true;
                } else {
                    logger.warning("Invalid endpoint: " + pathInfo);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid endpoint");
                    return;
                }
            } catch (SQLException e) {
                retries++;
                errorMessage = "Database error: " + e.getMessage();
                logger.log(Level.SEVERE, "Database error on attempt " + retries + ": " + errorMessage, e);
                if (retries >= MAX_RETRIES) {
                    response.getWriter().write(gson.toJson(new ResponseWrapper("error", errorMessage)));
                } else {
                    try {
                        Thread.sleep(100 * retries);
                    } catch (InterruptedException ie) {
                        logger.log(Level.WARNING, "Retry delay interrupted", ie);
                    }
                }
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Unexpected error in GET request", e);
                response.getWriter().write(gson.toJson(new ResponseWrapper("error", "Unexpected error: " + e.getMessage())));
                return;
            }
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