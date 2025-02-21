package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Driver;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class DriverDAO {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    // Add driver (creates both user and driver records)
    public boolean addDriver(User user, Driver driver) throws SQLException {
        Connection connection = null;
        try {
            connection = getConnection();
            connection.setAutoCommit(false);

            String userSql = "INSERT INTO users (id, name, email, password, role, is_enabled, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement userStmt = connection.prepareStatement(userSql)) {
                userStmt.setString(1, user.getId().toString());
                userStmt.setString(2, user.getName());
                userStmt.setString(3, user.getEmail());
                userStmt.setString(4, user.getPassword());
                userStmt.setString(5, user.getRole());
                userStmt.setBoolean(6, true);
                userStmt.setTimestamp(7, Timestamp.valueOf(user.getCreatedAt()));
                userStmt.setTimestamp(8, Timestamp.valueOf(user.getUpdatedAt()));
                userStmt.executeUpdate();
            }

            String driverSql = "INSERT INTO drivers (id, user_id, license_number, availability_status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement driverStmt = connection.prepareStatement(driverSql)) {
                driverStmt.setString(1, driver.getId().toString());
                driverStmt.setString(2, driver.getUserId().toString());
                driverStmt.setString(3, driver.getLicenseNumber());
                driverStmt.setString(4, driver.getAvailabilityStatus());
                driverStmt.setTimestamp(5, Timestamp.valueOf(driver.getCreatedAt()));
                driverStmt.setTimestamp(6, Timestamp.valueOf(driver.getUpdatedAt()));
                driverStmt.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            if (connection != null) connection.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (connection != null) connection.setAutoCommit(true);
            if (connection != null) connection.close();
        }
    }

    // Update driver
    public boolean updateDriver(Driver driver, String name) throws SQLException {
        Connection connection = null;
        try {
            connection = getConnection();
            connection.setAutoCommit(false);

            String driverSql = "UPDATE drivers SET license_number = ?, availability_status = ?, updated_at = ? WHERE id = ?";
            try (PreparedStatement driverStmt = connection.prepareStatement(driverSql)) {
                driverStmt.setString(1, driver.getLicenseNumber());
                driverStmt.setString(2, driver.getAvailabilityStatus());
                driverStmt.setTimestamp(3, Timestamp.valueOf(driver.getUpdatedAt()));
                driverStmt.setString(4, driver.getId().toString());
                driverStmt.executeUpdate();
            }

            String userSql = "UPDATE users SET name = ?, updated_at = ? WHERE id = ?";
            try (PreparedStatement userStmt = connection.prepareStatement(userSql)) {
                userStmt.setString(1, name);
                userStmt.setTimestamp(2, Timestamp.valueOf(driver.getUpdatedAt()));
                userStmt.setString(3, driver.getUserId().toString());
                userStmt.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            if (connection != null) connection.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (connection != null) connection.setAutoCommit(true);
            if (connection != null) connection.close();
        }
    }

    // Remove driver (disables instead of deleting)
    public boolean removeDriver(UUID driverId) throws SQLException {
        Connection connection = null;
        try {
            connection = getConnection();
            connection.setAutoCommit(false);

            String driverSql = "UPDATE drivers SET availability_status = 'inactive', updated_at = ? WHERE id = ?";
            try (PreparedStatement driverStmt = connection.prepareStatement(driverSql)) {
                driverStmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
                driverStmt.setString(2, driverId.toString());
                driverStmt.executeUpdate();
            }

//            String userSql = "UPDATE users SET is_enabled = FALSE, updated_at = ? WHERE id = (SELECT user_id FROM drivers WHERE id = ?)";
//            try (PreparedStatement userStmt = connection.prepareStatement(userSql)) {
//                userStmt.setTimestamp(1, new Timestamp(System.currentTimeMillis()));
//                userStmt.setString(2, driverId.toString());
//                userStmt.executeUpdate();
//            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            if (connection != null) connection.rollback();
            e.printStackTrace();
            return false;
        } finally {
            if (connection != null) connection.setAutoCommit(true);
            if (connection != null) connection.close();
        }
    }

    // Get all drivers
    public List<Driver> getAllDrivers() throws SQLException {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT d.*, u.name, u.email, c.plate_number FROM drivers d " +
                "JOIN users u ON d.user_id = u.id " +
                "LEFT JOIN cars c ON d.car_id = c.id";
        try (Connection connection = getConnection();
             Statement stmt = connection.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Driver driver = new Driver(
                        UUID.fromString(rs.getString("id")),
                        UUID.fromString(rs.getString("user_id")),
                        rs.getString("car_id") != null ? UUID.fromString(rs.getString("car_id")) : null,
                        rs.getString("license_number"),
                        rs.getString("availability_status"),
                        rs.getDouble("rating"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );

                driver.setName(rs.getString("name"));
                driver.setEmail(rs.getString("email"));

                if (rs.getString("car_id") != null) {
                    driver.setAssignmentStatus("Assigned");
                    driver.setCarPlateNumber(rs.getString("plate_number"));
                } else {
                    driver.setAssignmentStatus("Not Assigned");
                    driver.setCarPlateNumber(null);
                }

                drivers.add(driver);
            }
        }
        return drivers;
    }



    // Get driver by ID
    public Driver getDriverById(UUID driverId) throws SQLException {
        String sql = "SELECT d.*, u.name, u.email FROM drivers d JOIN users u ON d.user_id = u.id WHERE d.id = ?";
        try (Connection connection = getConnection();
             PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setString(1, driverId.toString());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Driver driver = new Driver(
                            UUID.fromString(rs.getString("id")),
                            UUID.fromString(rs.getString("user_id")),
                            rs.getString("car_id") != null ? UUID.fromString(rs.getString("car_id")) : null,
                            rs.getString("license_number"),
                            rs.getString("availability_status"),
                            rs.getDouble("rating"),
                            rs.getString("created_at"),
                            rs.getString("updated_at")
                    );
                    driver.setName(rs.getString("name"));
                    driver.setEmail(rs.getString("email"));
                    return driver;
                }
            }
        }
        return null;
    }
}