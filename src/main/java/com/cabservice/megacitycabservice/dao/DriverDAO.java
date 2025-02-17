package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Driver;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;
import com.cabservice.megacitycabservice.util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class DriverDAO {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    // add driver
    public boolean addDriver(User user, Driver driver) throws SQLException {
        Connection connection = null;
        try {
            connection = getConnection();
            connection.setAutoCommit(false);  // Start transaction

            // Insert user
            String userSql = "INSERT INTO users (id, name, email, password, role, isEnabled, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement userStatement = connection.prepareStatement(userSql)) {
                userStatement.setString(1, user.getId().toString());
                userStatement.setString(2, user.getName());
                userStatement.setString(3, user.getEmail());
                userStatement.setString(4, user.getPassword());
                userStatement.setString(5, user.getRole());
                userStatement.setBoolean(6, true);
                userStatement.setString(7, new Timestamp(System.currentTimeMillis()).toString());
                userStatement.setString(8, new Timestamp(System.currentTimeMillis()).toString());
                userStatement.executeUpdate();
            }

            // Insert driver
            String driverSql = "INSERT INTO drivers (id, user_id, license_number, availability_status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement driverStatement = connection.prepareStatement(driverSql)) {
                driverStatement.setString(1, driver.getId().toString());
                driverStatement.setString(2, driver.getUserId().toString());
                driverStatement.setString(3, driver.getLicenseNumber());
                driverStatement.setString(4, driver.getAvailabilityStatus());
                driverStatement.setString(5, new Timestamp(System.currentTimeMillis()).toString());
                driverStatement.setString(6, new Timestamp(System.currentTimeMillis()).toString());
                driverStatement.executeUpdate();
            }

            connection.commit();
            return true;
        } catch (SQLException e) {
            if (connection != null) {
                connection.rollback();
            }
            e.printStackTrace();
            return false;
        } finally {
            if (connection != null) {
                connection.setAutoCommit(true);
            }
        }
    }


    // Update an existing driver
    public boolean updateDriver(Driver driver, String name) {
        Connection connection = null;
        PreparedStatement updateDriverStmt = null;
        PreparedStatement updateUserStmt = null;

        try {
            connection = getConnection();
            connection.setAutoCommit(false); // Start transaction

            // Update the drivers table
            String updateDriverSQL = "UPDATE drivers SET car_id = ?, license_number = ?, availability_status = ?, rating = ?, updated_at = ? WHERE id = ?";
            updateDriverStmt = connection.prepareStatement(updateDriverSQL);
            updateDriverStmt.setString(1, driver.getCarId() != null ? driver.getCarId().toString() : null);
            updateDriverStmt.setString(2, driver.getLicenseNumber());
            updateDriverStmt.setString(3, driver.getAvailabilityStatus());
            updateDriverStmt.setDouble(4, driver.getRating());
            updateDriverStmt.setString(5, driver.getUpdatedAt());
            updateDriverStmt.setString(6, driver.getId().toString());

            int driverUpdateCount = updateDriverStmt.executeUpdate();

            // Update the users table (only the name, not the email)
            String updateUserSQL = "UPDATE users SET name = ? WHERE id = ?";
            updateUserStmt = connection.prepareStatement(updateUserSQL);
            updateUserStmt.setString(1, name);
            updateUserStmt.setString(2, driver.getUserId().toString());

            int userUpdateCount = updateUserStmt.executeUpdate();

            // Commit transaction if both updates succeed
            if (driverUpdateCount > 0 && userUpdateCount > 0) {
                connection.commit();
                return true;
            } else {
                connection.rollback();
                return false;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            // Close resources
            try {
                if (updateDriverStmt != null) updateDriverStmt.close();
                if (updateUserStmt != null) updateUserStmt.close();
                if (connection != null) connection.setAutoCommit(true);
                if (connection != null) connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    // Change driver availability status instead of deleting
    public boolean changeDriverStatus(UUID id, String status) {
        String sql = "UPDATE drivers SET availability_status = ?, updated_at = ? WHERE id = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setString(2, new Timestamp(System.currentTimeMillis()).toString());
            statement.setString(3, id.toString());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Assign a car to a driver
    public boolean assignCarToDriver(UUID driverId, UUID carId) {
        String sql = "UPDATE drivers SET car_id = ?, updated_at = ? WHERE id = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, carId.toString());
            statement.setString(2, new Timestamp(System.currentTimeMillis()).toString());
            statement.setString(3, driverId.toString());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all drivers
    public List<Driver> getAllDrivers() {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT * FROM drivers";
        try (Connection connection = getConnection();
             Statement statement = connection.createStatement();
             ResultSet resultSet = statement.executeQuery(sql)) {
            while (resultSet.next()) {
                Driver driver = new Driver(
                        UUID.fromString(resultSet.getString("id")),
                        UUID.fromString(resultSet.getString("user_id")),
                        resultSet.getString("car_id") != null ? UUID.fromString(resultSet.getString("car_id")) : null,
                        resultSet.getString("license_number"),
                        resultSet.getString("availability_status"),
                        resultSet.getDouble("rating"),
                        resultSet.getString("created_at"),
                        resultSet.getString("updated_at")
                );
                drivers.add(driver);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return drivers;
    }

    public Driver getDriverById(UUID driverId) {
        String sql = "SELECT d.id, d.user_id, d.car_id, d.license_number, d.availability_status, d.rating, d.created_at, d.updated_at, " +
                "u.name, u.email FROM drivers d " +
                "JOIN users u ON d.user_id = u.id WHERE d.id = ?";

        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setString(1, driverId.toString());
            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {
                UUID id = UUID.fromString(resultSet.getString("id"));
                UUID userId = UUID.fromString(resultSet.getString("user_id"));
                UUID carId = resultSet.getString("car_id") != null ? UUID.fromString(resultSet.getString("car_id")) : null;
                String licenseNumber = resultSet.getString("license_number");
                String availabilityStatus = resultSet.getString("availability_status");
                double rating = resultSet.getDouble("rating");
                String createdAt = resultSet.getString("created_at");
                String updatedAt = resultSet.getString("updated_at");
                String name = resultSet.getString("name"); // User name
                String email = resultSet.getString("email"); // User email

                // Create and return driver object
                 new Driver(id, userId, carId, licenseNumber, availabilityStatus, rating, createdAt, updatedAt);
                 //new User(userId, name, email, null, null, true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null; // Return null if driver not found
    }



    public boolean isEmailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        try (Connection connection = getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0;
                }
            }
        }
        return false;
    }

}
