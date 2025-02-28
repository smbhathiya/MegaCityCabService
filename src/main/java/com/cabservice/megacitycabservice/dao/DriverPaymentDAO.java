package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DriverPaymentDAO {

    // Inner class to represent payment data
    public static class DriverPayment {
        public String bookingNumber;
        public String pickupLocation;
        public String dropoffLocation;
        public String hireDate;
        public double amount; // 70% of total_fare
        public String paymentMethod;
        public String transactionId;
        public String status;
        public String paymentDate;

        public DriverPayment(String bookingNumber, String pickupLocation, String dropoffLocation, String hireDate,
                             double amount, String paymentMethod, String transactionId, String status, String paymentDate) {
            this.bookingNumber = bookingNumber;
            this.pickupLocation = pickupLocation;
            this.dropoffLocation = dropoffLocation;
            this.hireDate = hireDate;
            this.amount = amount;
            this.paymentMethod = paymentMethod;
            this.transactionId = transactionId;
            this.status = status;
            this.paymentDate = paymentDate;
        }
    }

    // Get pending payments by driver ID (from bookings table)
    public List<DriverPayment> getPendingPaymentsByDriverId(String driverId) throws SQLException {
        List<DriverPayment> pendingPayments = new ArrayList<>();
        String sql = "SELECT b.booking_number, b.pickup_location, b.dropoff_location, b.hire_date, b.total_fare " +
                "FROM bookings b " +
                "WHERE b.driver_id = ? AND b.payment_status = 'pending'";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    double totalFare = rs.getDouble("total_fare");
                    double driverAmount = totalFare * 0.7;
                    DriverPayment payment = new DriverPayment(
                            rs.getString("booking_number"),
                            rs.getString("pickup_location"),
                            rs.getString("dropoff_location"),
                            rs.getString("hire_date"),
                            driverAmount,
                            null,
                            null,
                            "pending",
                            null
                    );
                    pendingPayments.add(payment);
                }
            }
        }
        return pendingPayments;
    }

    // Get payment history by driver ID (from payments and bookings tables)
    public List<DriverPayment> getPaymentHistoryByDriverId(String driverId) throws SQLException {
        List<DriverPayment> paymentHistory = new ArrayList<>();
        String sql = "SELECT b.booking_number, p.amount, p.payment_method, p.transaction_id, p.status, p.payment_date " +
                "FROM payments p " +
                "JOIN bookings b ON p.booking_id = b.id " +
                "WHERE b.driver_id = ? AND p.status = 'successful'";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    double paymentAmount = rs.getDouble("amount");
                    double driverAmount = paymentAmount * 0.7;
                    DriverPayment payment = new DriverPayment(
                            rs.getString("booking_number"),
                            null,
                            null,
                            null,
                            driverAmount,
                            rs.getString("payment_method"),
                            rs.getString("transaction_id"),
                            rs.getString("status"),
                            rs.getString("payment_date")
                    );
                    paymentHistory.add(payment);
                }
            }
        }
        return paymentHistory;
    }
}