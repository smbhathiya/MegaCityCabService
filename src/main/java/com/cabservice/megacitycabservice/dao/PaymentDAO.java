package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Payment;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class PaymentDAO {

    // Add a new payment
    public boolean addPayment(Payment payment) throws SQLException {
        String sql = "INSERT INTO payments (id, booking_id, customer_id, amount, payment_method, transaction_id, status, payment_date, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, payment.getId().toString());
            stmt.setString(2, payment.getBookingId().toString());
            stmt.setString(3, payment.getCustomerId().toString());
            stmt.setDouble(4, payment.getAmount());
            stmt.setString(5, payment.getPaymentMethod());
            stmt.setString(6, payment.getTransactionId());
            stmt.setString(7, payment.getStatus());
            stmt.setTimestamp(8, payment.getPaymentDate());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    // Update payment status
    public boolean updatePaymentStatus(UUID paymentId, String status) throws SQLException {
        String sql = "UPDATE payments SET status = ?, updated_at = NOW() WHERE id = ?";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setString(2, paymentId.toString());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }

    // Get pending bookings (bookings with payment_status = 'pending')
    public List<Payment> getPendingPaymentsByCustomerId(String customerId) throws SQLException {
        List<Payment> pendingPayments = new ArrayList<>();
        String sql = "SELECT b.id AS booking_id, b.booking_number, b.pickup_location, b.dropoff_location, " +
                "b.hire_date, b.total_fare " +
                "FROM bookings b " +
                "WHERE b.customer_id = ? AND b.payment_status = 'pending'";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Payment payment = new Payment();
                    payment.setBookingId(UUID.fromString(rs.getString("booking_id")));
                    payment.setBookingNumber(rs.getString("booking_number"));
                    payment.setPickupLocation(rs.getString("pickup_location"));
                    payment.setDropoffLocation(rs.getString("dropoff_location"));
                    payment.setHireDate(rs.getString("hire_date"));
                    payment.setAmount(rs.getDouble("total_fare"));
                    pendingPayments.add(payment);
                }
            }
        }
        return pendingPayments;
    }

    // Get payment history for a customer
    public List<Payment> getPaymentHistoryByCustomerId(String customerId) throws SQLException {
        List<Payment> paymentHistory = new ArrayList<>();
        String sql = "SELECT p.id, p.booking_id, b.booking_number, p.amount, p.payment_method, p.transaction_id, " +
                "p.status, p.payment_date " +
                "FROM payments p " +
                "JOIN bookings b ON p.booking_id = b.id " +
                "WHERE p.customer_id = ?";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Payment payment = new Payment();
                    payment.setId(UUID.fromString(rs.getString("id")));
                    payment.setBookingId(UUID.fromString(rs.getString("booking_id")));
                    payment.setBookingNumber(rs.getString("booking_number"));
                    payment.setAmount(rs.getDouble("amount"));
                    payment.setPaymentMethod(rs.getString("payment_method"));
                    payment.setTransactionId(rs.getString("transaction_id"));
                    payment.setStatus(rs.getString("status"));
                    payment.setPaymentDate(rs.getTimestamp("payment_date"));
                    paymentHistory.add(payment);
                }
            }
        }
        return paymentHistory;
    }
}