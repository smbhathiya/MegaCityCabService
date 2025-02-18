package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class BookingDAO {

    // Get the next booking number
    private String getNextBookingNumber() throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(booking_number, 5) AS UNSIGNED)) FROM bookings";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            if (rs.next()) {
                int lastBookingNumber = rs.getInt(1);
                return "BOOK" + (lastBookingNumber + 1);
            } else {
                return "BOOK1001";
            }
        }
    }

    // Add a new booking
    public boolean addBooking(String customerId, String pickupLocation, String dropOffLocation, String hireDate, String carId, String driverId, String hireTime) throws SQLException {
        String bookingNumber = getNextBookingNumber(); // Fetch sequential booking number
        String sql = "INSERT INTO bookings (id, booking_number, customer_id, pickup_location, dropoff_location, " +
                "hire_date, booking_status, payment_status, created_at, updated_at, driver_id, car_id, hire_time,total_fare) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'pending', 'pending', NOW(), NOW(), ?, ?, ?,?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setObject(1, UUID.randomUUID().toString());
            stmt.setString(2, bookingNumber);
            stmt.setObject(3, customerId);
            stmt.setString(4, pickupLocation);
            stmt.setString(5, dropOffLocation);
            stmt.setDate(6, Date.valueOf(hireDate));
            stmt.setString(7, driverId);
            stmt.setString(8, carId);
            stmt.setString(9, hireTime);
            stmt.setString(10, "0.0");

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            throw new SQLException("Error inserting booking into database: " + e.getMessage(), e);
        }
    }

    // Method to cancel a booking
    public boolean cancelBooking(String bookingNumber) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = 'cancelled',payment_status = 'cancelled', updated_at = NOW() WHERE booking_number = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingNumber);

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            throw new SQLException("Error cancelling booking: " + e.getMessage(), e);
        }
    }


    // Get booking by booking ID
    public Booking getBookingById(String bookingId) throws SQLException {
        String sql = "SELECT * FROM bookings WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapToBooking(rs);
                }
            }
        }
        return null; // If no booking found
    }

    // Get all bookings for a customer
    public List<Booking> getBookingsByCustomerId(String customerId) throws SQLException {
        String sql = "SELECT * FROM bookings WHERE customer_id = ?";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapToBooking(rs));
                }
            }
        }
        return bookings;
    }

    // Get all bookings for a driver
    public List<Booking> getBookingsByDriverId(String driverId) throws SQLException {
        String sql = "SELECT * FROM bookings WHERE driver_id = ?";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, driverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapToBooking(rs));
                }
            }
        }
        return bookings;
    }

    // Get all bookings
    public List<Booking> getAllBookings() throws SQLException {
        String sql = "SELECT * FROM bookings";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                bookings.add(mapToBooking(rs));
            }
        }
        return bookings;
    }

    // Map result set to Booking object
    private Booking mapToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(UUID.fromString(rs.getString("id")));
        booking.setBookingNumber(rs.getString("booking_number"));
        booking.setCustomerId(UUID.fromString(rs.getString("customer_id")));
        booking.setPickupLocation(rs.getString("pickup_location"));
        booking.setDropOffLocation(rs.getString("dropoff_location"));
        booking.setHireDate(rs.getDate("hire_date").toString());
        booking.setBookingStatus(rs.getString("booking_status"));
        booking.setPaymentStatus(rs.getString("payment_status"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));
        booking.setUpdatedAt(rs.getTimestamp("updated_at"));
        booking.setDriverId(UUID.fromString(rs.getString("driver_id")));
        booking.setCarId(UUID.fromString(rs.getString("car_id")));
        booking.setHireTime(rs.getString("hire_time"));
        booking.setTotalFare(rs.getDouble("total_fare"));
        return booking;
    }
}
