package com.cabservice.megacitycabservice.servlet.customer;

import com.cabservice.megacitycabservice.dao.BookingDAO;
import com.cabservice.megacitycabservice.dao.PaymentDAO;
import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Payment;
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

@WebServlet("/customer/dashboard-data")
public class CustomerDashboardServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private static final Logger logger = Logger.getLogger(CustomerDashboardServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        logger.info("Received GET request for customer dashboard data");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
            logger.warning("Unauthorized access attempt: No session or invalid role");
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized access");
            return;
        }

        UUID customerId = (UUID) session.getAttribute("userId");
        logger.info("Customer ID from session: " + customerId.toString());

        try {
            synchronized (DBUtil.class) {
                PaymentDAO paymentDAO = new PaymentDAO();
                BookingDAO bookingDAO = new BookingDAO();

                double totalSpend = calculateTotalSpend(paymentDAO, customerId.toString());
                logger.info("Total Spend calculated: Rs. " + totalSpend);

                int activeBookings = calculateActiveBookings(bookingDAO, customerId.toString());
                logger.info("Active Bookings calculated: " + activeBookings);

                String bookingStatus = activeBookings > 0 ? "In Progress" : "None";
                logger.info("Booking Status: " + bookingStatus);

                double points = totalSpend / 100.0;
                logger.info("Points calculated: " + points);

                DashboardData dashboardData = new DashboardData(totalSpend, activeBookings, bookingStatus, points);
                response.getWriter().write(gson.toJson(dashboardData));
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Database error fetching dashboard data", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Unexpected error fetching dashboard data", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unexpected error: " + e.getMessage());
        }
    }

    // Calculate total spend from payments table
    private double calculateTotalSpend(PaymentDAO paymentDAO, String customerId) throws SQLException {
        List<Payment> payments = paymentDAO.getPaymentHistoryByCustomerId(customerId);
        double totalSpend = 0.0;
        for (Payment payment : payments) {
            totalSpend += payment.getAmount();
        }
        return totalSpend;
    }

    // Calculate active bookings (pending payments)
    private int calculateActiveBookings(BookingDAO bookingDAO, String customerId) throws SQLException {
        List<Booking> bookings = bookingDAO.getBookingsByCustomerId(customerId);
        int activeCount = 0;
        for (Booking booking : bookings) {
            if ("pending".equals(booking.getPaymentStatus())) {
                activeCount++;
            }
        }
        return activeCount;
    }

    // Data class for dashboard response
    private static class DashboardData {
        private final double totalSpend;
        private final int activeBookings;
        private final String bookingStatus;
        private final double points;

        public DashboardData(double totalSpend, int activeBookings, String bookingStatus, double points) {
            this.totalSpend = totalSpend;
            this.activeBookings = activeBookings;
            this.bookingStatus = bookingStatus;
            this.points = points;
        }
    }
}