package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Car;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CarAssignmentDAO {

    // Retrieve unassigned cars
    public List<Car> getUnassignedCars() throws SQLException {
        List<Car> unassignedCars = new ArrayList<>();
        String sql = "SELECT c.* FROM cars c LEFT JOIN drivers d ON c.id = d.car_id WHERE d.car_id IS NULL";

        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Car car = new Car();
                car.setId(UUID.fromString(rs.getString("id")));
                car.setPlateNumber(rs.getString("plate_number"));
                car.setBrand(rs.getString("brand"));
                car.setModel(rs.getString("model"));
                car.setYear(rs.getInt("year"));
                car.setColor(rs.getString("color"));
                car.setCapacity(rs.getInt("capacity"));
                car.setStatus(rs.getString("status"));
                car.setCreatedAt(rs.getString("created_at"));
                car.setUpdatedAt(rs.getString("updated_at"));
                unassignedCars.add(car);
            }
        } catch (SQLException e) {
            System.out.println("Error in getUnassignedCars: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
        return unassignedCars;
    }

    // Check if a car is assigned to any driver
    public boolean isCarAssigned(UUID carId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM drivers WHERE car_id = ?";
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            stmt = conn.prepareStatement(sql);
            stmt.setObject(1, carId.toString());
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error in isCarAssigned: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
        return false;
    }


    // Assign a car to a driver
    public boolean assignCarToDriver(UUID driverId, UUID carId) throws SQLException {
        String updateQuery = "UPDATE drivers SET car_id = ?, updated_at = NOW() WHERE id = ?"; // Removed the car_id check

        Connection conn = null;
        PreparedStatement updateStmt = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // Assign car
            updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setObject(1, carId.toString());
            updateStmt.setObject(2, driverId.toString());
            int rowsAffected = updateStmt.executeUpdate();

            if (rowsAffected == 0) {
                conn.rollback();
                return false; // Driver not found
            }

            conn.commit();
            return true; // Successfully assigned the car
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            System.out.println("Error in assignCarToDriver: " + e.getMessage());
            e.printStackTrace();
            throw e;
        } finally {
            if (updateStmt != null) updateStmt.close();
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeEx) {
                    closeEx.printStackTrace();
                }
            }
        }
    }

    public UUID getDriverIdByCarId(UUID carId) throws SQLException {
        String sql = "SELECT user_id FROM drivers WHERE car_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, carId.toString());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return UUID.fromString(rs.getString("user_id"));
            }
        }
        return null;
    }
}