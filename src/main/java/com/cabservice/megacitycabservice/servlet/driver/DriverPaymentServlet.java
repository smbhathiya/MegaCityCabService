package com.cabservice.megacitycabservice.servlet.driver;

import com.cabservice.megacitycabservice.dao.DriverPaymentDAO;
import com.cabservice.megacitycabservice.util.DBUtil;
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
        try {
            if ("/pending".equals(pathInfo)) {
                logger.info("Fetching pending payments for driver: " + driverId);
                synchronized (DBUtil.class) {
                    List<DriverPaymentDAO.DriverPayment> pendingPayments = paymentDAO.getPendingPaymentsByDriverId(driverId.toString());
                    logger.info("Pending payments retrieved: " + pendingPayments.size() + " records");
                    response.getWriter().write(gson.toJson(new ResponseWrapper("success", pendingPayments)));
                }
            } else if ("/history".equals(pathInfo)) {
                logger.info("Fetching payment history for driver: " + driverId);
                synchronized (DBUtil.class) {
                    List<DriverPaymentDAO.DriverPayment> paymentHistory = paymentDAO.getPaymentHistoryByDriverId(driverId.toString());
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