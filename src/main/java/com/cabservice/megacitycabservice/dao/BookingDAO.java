package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Booking;
import com.cabservice.megacitycabservice.model.Car;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class BookingDAO {

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
            stmt.setObject(4, booking.getDriverId() != null ? booking.getDriverId().toString() : null);
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

    // Cancel a booking
    public boolean cancelBooking(String bookingNumber) throws SQLException {
        String sql = "UPDATE bookings SET booking_status = 'cancelled', payment_status = 'cancelled', updated_at = NOW() WHERE booking_number = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingNumber);
            int rowsAffected = stmt.executeUpdate();
            return rowsAffected > 0;
        }
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
    public List<Booking> getBookingsByDriverId(UUID driverId) throws SQLException {
        String sql = "SELECT b.id, b.booking_number, b.pickup_location, b.dropoff_location, b.hire_date, b.booking_status, " +
                "b.hire_time, b.distance, b.total_fare, b.customer_id, u.name AS customer_name, c.contact_no " +
                "FROM bookings b " +
                "LEFT JOIN customers c ON b.customer_id = c.id " +
                "LEFT JOIN users u ON c.user_id = u.id " +
                "WHERE b.driver_id = ?";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, driverId.toString());
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Booking booking = new Booking(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("booking_number"),
                        rs.getString("customer_id") != null ? UUID.fromString(rs.getString("customer_id")) : null,
                        driverId,
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
                booking.setCustomerName(rs.getString("customer_name"));
                booking.setCustomerContact(rs.getString("contact_no"));
                bookings.add(booking);
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
                Booking booking = new Booking();
                booking.setId(UUID.fromString(rs.getString("id")));
                booking.setBookingNumber(rs.getString("booking_number"));
                booking.setCustomerId(rs.getString("customer_id") != null ? UUID.fromString(rs.getString("customer_id")) : null);
                booking.setDriverId(rs.getString("driver_id") != null ? UUID.fromString(rs.getString("driver_id")) : null);
                booking.setCarId(rs.getString("car_id") != null ? UUID.fromString(rs.getString("car_id")) : null);
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
                bookings.add(booking);
            }
        }
        return bookings;
    }

    // Fetch booking details by ID
    public Booking getBookingById(UUID bookingId) throws SQLException {
        String sql = "SELECT b.id, b.booking_number, b.pickup_location, b.dropoff_location, b.hire_date, b.hire_time, " +
                "b.distance, b.booking_status, b.total_fare, b.customer_id, u.name AS customer_name, c.contact_no " +
                "FROM bookings b " +
                "LEFT JOIN users u ON b.customer_id = u.id " +
                "LEFT JOIN customers c ON b.customer_id = c.id " +
                "WHERE b.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bookingId.toString());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                Booking booking = new Booking(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("booking_number"),
                        rs.getString("customer_id") != null ? UUID.fromString(rs.getString("customer_id")) : null,
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
                booking.setCustomerName(rs.getString("customer_name"));
                booking.setCustomerContact(rs.getString("contact_no"));
                return booking;
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