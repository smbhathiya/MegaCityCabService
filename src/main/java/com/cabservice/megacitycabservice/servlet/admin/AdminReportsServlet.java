package com.cabservice.megacitycabservice.servlet.admin;

import com.cabservice.megacitycabservice.dao.AdminReportsDAO;
import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;
import java.util.logging.Logger;
import java.util.logging.Level;

@WebServlet("/admin/reports")
public class AdminReportsServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(AdminReportsServlet.class.getName());
    private static final int MAX_RETRIES = 3;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received GET request for /admin/reports");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"admin".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID adminId = (UUID) session.getAttribute("userId");
        logger.info("Admin ID from session: " + adminId.toString());

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");

        logger.info("Request parameters - startDate: " + startDate + ", endDate: " + endDate);

        if (startDate == null || endDate == null || startDate.trim().isEmpty() || endDate.trim().isEmpty()) {
            logger.warning("Invalid date parameters: startDate=" + startDate + ", endDate=" + endDate);
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Start date and end date must be non-empty");
            return;
        }

        AdminReportsDAO reportsDAO = new AdminReportsDAO();
        int retries = 0;
        boolean success = false;
        String errorMessage = null;

        while (retries < MAX_RETRIES && !success) {
            try {
                logger.info("Attempt " + (retries + 1) + " - Fetching reports for period: " + startDate + " to " + endDate);
                AdminReportsDAO.Reports reports = reportsDAO.getReports(startDate, endDate);
                logger.info("Reports retrieved successfully: Revenue items=" + reports.revenue.size() +
                        ", Booking statuses=" + reports.bookings.size() +
                        ", Drivers (by name)=" + reports.drivers.size() +
                        ", Vehicles (by plate number)=" + reports.vehicles.size());
                String jsonResponse = gson.toJson(new ResponseWrapper("success", reports));
                logger.fine("JSON response: " + jsonResponse);
                response.getWriter().write(jsonResponse);
                success = true;
            } catch (SQLException e) {
                retries++;
                errorMessage = "Database error: " + e.getMessage();
                logger.log(Level.SEVERE, "Database error on attempt " + retries + ": " + errorMessage, e);
                if (retries >= MAX_RETRIES) {
                    String errorJson = gson.toJson(new ResponseWrapper("error", errorMessage));
                    logger.info("Max retries reached, sending error response: " + errorJson);
                    response.getWriter().write(errorJson);
                } else {
                    try {
                        logger.info("Retrying after delay: " + (100 * retries) + "ms");
                        Thread.sleep(100 * retries);
                    } catch (InterruptedException ie) {
                        logger.log(Level.WARNING, "Retry delay interrupted", ie);
                    }
                }
            } catch (Exception e) {
                logger.log(Level.SEVERE, "Unexpected error in GET request", e);
                String errorJson = gson.toJson(new ResponseWrapper("error", "Unexpected error: " + e.getMessage()));
                logger.info("Sending unexpected error response: " + errorJson);
                response.getWriter().write(errorJson);
                return;
            }
        }
    }

    private static class ResponseWrapper {
        String status;
        Object data;

        ResponseWrapper(String status, Object data) {
            this.status = status;
            this.data = data;
        }
    }
}