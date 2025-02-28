package com.cabservice.megacitycabservice.servlet.driver;

import com.cabservice.megacitycabservice.dao.DriverPaymentDAO;
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

@WebServlet("/driver/payments/*")
public class DriverPaymentServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(DriverPaymentServlet.class.getName());
    private static final int MAX_RETRIES = 3;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received GET request for path: " + request.getPathInfo());

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"driver".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID driverId = (UUID) session.getAttribute("userId");
        logger.info("Driver ID from session: " + driverId.toString());

        String pathInfo = request.getPathInfo();
        logger.info("Path Info: " + pathInfo);

        DriverPaymentDAO paymentDAO = new DriverPaymentDAO();
        int retries = 0;
        boolean success = false;
        List<DriverPaymentDAO.DriverPayment> result = null;
        String errorMessage = null;

        while (retries < MAX_RETRIES && !success) {
            try {
                if ("/pending".equals(pathInfo)) {
                    logger.info("Fetching pending payments for driver: " + driverId);
                    result = paymentDAO.getPendingPaymentsByDriverId(driverId.toString());
                    logger.info("Pending payments retrieved: " + result.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", result)));
                    success = true;
                } else if ("/history".equals(pathInfo)) {
                    logger.info("Fetching payment history for driver: " + driverId);
                    result = paymentDAO.getPaymentHistoryByDriverId(driverId.toString());
                    logger.info("Payment history retrieved: " + result.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", result)));
                    success = true;
                } else {
                    logger.warning("Invalid endpoint: " + pathInfo);
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Invalid payment endpoint");
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