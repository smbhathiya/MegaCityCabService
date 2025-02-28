package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Payment;

public class AdminDashboardDAO {



    // Get all payment history
    public List<Payment> getPaymentHistory() throws SQLException {
        List<Payment> paymentHistory = new ArrayList<>();
        String sql = "SELECT amount, payment_date FROM payments WHERE status = 'successful'";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Payment payment = new Payment(
                        rs.getDouble("amount"),
                        rs.getTimestamp("payment_date")
                );
                paymentHistory.add(payment);
            }
        }
        return paymentHistory;
    }

    // Get all bookings
    public List<Booking> getAllBookings() throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT booking_number, hire_date, booking_status FROM bookings";

        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Booking booking = new Booking(
                        rs.getString("booking_number"),
                        rs.getString("hire_date"),
                        rs.getString("booking_status")
                );
                bookings.add(booking);
            }
        }
        return bookings;
    }

    // Get total number of cars
    public int getTotalCars() throws SQLException {
        String sql = "SELECT COUNT(*) FROM cars";
        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // Get total number of drivers
    public int getTotalDrivers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'driver'";
        Connection conn = DBUtil.getConnection();
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}