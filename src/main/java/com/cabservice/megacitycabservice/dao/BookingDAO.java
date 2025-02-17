package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
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


    // Get booking details by booking number
    public Booking getBookingByBookingNumber(String bookingNumber) throws SQLException {
        String sql = "SELECT * FROM bookings WHERE booking_number = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingNumber);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new Booking(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("booking_number"),
                        UUID.fromString(rs.getString("customer_id")),
                        UUID.fromString(rs.getString("driver_id")),
                        UUID.fromString(rs.getString("car_id")),
                        rs.getString("pickup_location"),
                        rs.getString("dropoff_location"),
                        rs.getDouble("distance"),
                        rs.getInt("duration"),
                        rs.getDouble("fare_estimate"),
                        rs.getDouble("total_fare"),
                        rs.getDate("hire_date"),
                        rs.getString("booking_status"),
                        rs.getString("payment_status"),
                        rs.getString("created_at")
                );
            }
        }
        return null;
    }
}
