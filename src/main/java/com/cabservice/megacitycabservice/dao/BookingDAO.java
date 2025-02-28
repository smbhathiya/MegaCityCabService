package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Car;
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
    public boolean addBooking(Booking booking) throws SQLException {
        String sql = "INSERT INTO bookings (id, booking_number, customer_id, driver_id, car_id, pickup_location, " +
                "dropoff_location, distance, booking_status, total_fare, payment_status, hire_date, hire_time, created_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setObject(1, booking.getId().toString());
            stmt.setString(2, booking.getBookingNumber());
            stmt.setObject(3, booking.getCustomerId().toString());
            stmt.setObject(4, booking.getDriverId() != null ? booking.getDriverId().toString() : null); // Add driver_id
            stmt.setObject(5, booking.getCarId() != null ? booking.getCarId().toString() : null);
            stmt.setString(6, booking.getPickupLocation());
            stmt.setString(7, booking.getDropoffLocation());
            stmt.setDouble(8, booking.getDistance());
            stmt.setString(9, booking.getBookingStatus());
            stmt.setDouble(10, booking.getTotalFare());
            stmt.setString(11, booking.getPaymentStatus());
            stmt.setString(12, booking.getHireDate());
            stmt.setString(13, booking.getHireTime());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
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
        String sql = "SELECT id, booking_number, customer_id, driver_id, car_id, pickup_location, dropoff_location, " +
                "distance, booking_status, total_fare, payment_status, hire_date, hire_time, created_at, updated_at " +
                "FROM bookings WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapToBooking(rs);
                }
            }
        }
        return null;
    }

    // Get all bookings for a customer
    public List<Booking> getBookingsByCustomerId(String customerId) throws SQLException {
        List<Booking> bookings = new ArrayList<>();
        String sql = "SELECT b.id, b.booking_number, b.customer_id, b.car_id, b.pickup_location, b.dropoff_location, " +
                "b.distance, b.booking_status, b.total_fare, b.payment_status, b.hire_date, b.hire_time, " +
                "c.brand, c.model, c.plate_number " +
                "FROM bookings b " +
                "LEFT JOIN cars c ON b.car_id = c.id " +
                "WHERE b.customer_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customerId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Booking booking = new Booking();
                    booking.setId(UUID.fromString(rs.getString("id")));
                    booking.setBookingNumber(rs.getString("booking_number"));
                    booking.setCustomerId(UUID.fromString(rs.getString("customer_id")));
                    booking.setCarId(rs.getString("car_id") != null ? UUID.fromString(rs.getString("car_id")) : null);
                    booking.setPickupLocation(rs.getString("pickup_location"));
                    booking.setDropOffLocation(rs.getString("dropoff_location"));
                    booking.setDistance(rs.getDouble("distance"));
                    booking.setBookingStatus(rs.getString("booking_status"));
                    booking.setTotalFare(rs.getDouble("total_fare"));
                    booking.setPaymentStatus(rs.getString("payment_status"));
                    booking.setHireDate(rs.getString("hire_date"));
                    booking.setHireTime(rs.getString("hire_time"));

                    // Car Details
                    if (rs.getString("car_id") != null) {
                        Car car = new Car();
                        car.setBrand(rs.getString("brand"));
                        car.setModel(rs.getString("model"));
                        car.setPlateNumber(rs.getString("plate_number"));
                        booking.setCarDetails(car);
                    }

                    bookings.add(booking);
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
        String id = rs.getString("id");
        if (id != null) booking.setId(UUID.fromString(id));
        booking.setBookingNumber(rs.getString("booking_number"));
        String customerId = rs.getString("customer_id");
        if (customerId != null) booking.setCustomerId(UUID.fromString(customerId));
        String driverId = rs.getString("driver_id");
        if (driverId != null) booking.setDriverId(UUID.fromString(driverId));
        String carId = rs.getString("car_id");
        if (carId != null) booking.setCarId(UUID.fromString(carId));
        booking.setPickupLocation(rs.getString("pickup_location"));
        booking.setDropOffLocation(rs.getString("dropoff_location"));
        booking.setDistance(rs.getDouble("distance"));
        booking.setBookingStatus(rs.getString("booking_status"));
        booking.setTotalFare(rs.getDouble("total_fare"));
        booking.setPaymentStatus(rs.getString("payment_status"));
        booking.setHireDate(rs.getString("hire_date"));
        booking.setHireTime(rs.getString("hire_time"));
        booking.setCreatedAt(rs.getTimestamp("created_at"));
        booking.setUpdatedAt(rs.getTimestamp("updated_at"));
        return booking;
    }

    // Fetch all bookings for a driver
    public List<Booking> getBookingsByDriverId(UUID driverId) throws SQLException {
        String sql = "SELECT id, booking_number, pickup_location, dropoff_location, hire_date, booking_status " +
                "FROM bookings " +
                "WHERE driver_id = ?";
        List<Booking> bookings = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, driverId.toString());
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Booking booking = new Booking(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("booking_number"),
                        null,
                        driverId,
                        null,
                        rs.getString("pickup_location"),
                        rs.getString("dropoff_location"),
                        0.0,
                        rs.getString("booking_status"),
                        0.0,
                        null,
                        rs.getString("hire_date"),
                        null
                );
                bookings.add(booking);
            }
        }
        return bookings;
    }

    // Fetch booking details by ID
    public Booking getBookingById(UUID bookingId) throws SQLException {
        String sql = "SELECT id, booking_number, pickup_location, dropoff_location, hire_date, hire_time, " +
                "distance, booking_status, total_fare " +
                "FROM bookings " +
                "WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId.toString());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new Booking(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("booking_number"),
                        null,
                        null,
                        null,
                        rs.getString("pickup_location"),
                        rs.getString("dropoff_location"),
                        rs.getDouble("distance"),
                        rs.getString("booking_status"),
                        rs.getDouble("total_fare"),
                        null,
                        rs.getString("hire_date"),
                        rs.getString("hire_time")
                );
            }
        }
        return null;
    }

    // Update booking status
    public boolean updateBookingStatus(UUID bookingId, String newStatus) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newStatus);
            stmt.setString(2, bookingId.toString());

            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
    }
}
