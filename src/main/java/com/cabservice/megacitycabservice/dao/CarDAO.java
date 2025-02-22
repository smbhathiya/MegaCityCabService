package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Car;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CarDAO {

    // Add a new car
    public boolean addCar(Car car) {
        String sql = "INSERT INTO cars (id, plate_number, model, brand, year, color, capacity, status, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, car.getId().toString());
            stmt.setString(2, car.getPlateNumber());
            stmt.setString(3, car.getModel());
            stmt.setString(4, car.getBrand());
            stmt.setInt(5, car.getYear());
            stmt.setString(6, car.getColor());
            stmt.setInt(7, car.getCapacity());
            stmt.setString(8, car.getStatus());
            stmt.setString(9, car.getCreatedAt());
            stmt.setString(10, car.getUpdatedAt());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Update an existing car
    public boolean updateCar(Car car) {
        String sql = "UPDATE cars SET plate_number = ?, model = ?, brand = ?, year = ?, color = ?, capacity = ?, status = ?, updated_at = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, car.getPlateNumber());
            stmt.setString(2, car.getModel());
            stmt.setString(3, car.getBrand());
            stmt.setInt(4, car.getYear());
            stmt.setString(5, car.getColor());
            stmt.setInt(6, car.getCapacity());
            stmt.setString(7, car.getStatus());
            stmt.setString(8, car.getUpdatedAt());
            stmt.setString(9, car.getId().toString());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Remove a car
    public boolean removeCar(String carId) {
        String sql = "DELETE FROM cars WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, carId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Get all cars
    public List<Car> getAllCars() {
        List<Car> cars = new ArrayList<>();
        String sql = "SELECT * FROM cars";
        try (Connection conn = DBUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Car car = new Car(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("plate_number"),
                        rs.getString("model"),
                        rs.getString("brand"),
                        rs.getInt("year"),
                        rs.getString("color"),
                        rs.getInt("capacity"),
                        rs.getString("status"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
                cars.add(car);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return cars;
    }

    // Get available cars by date and capacity
    public List<Car> getAvailableCarsByDateAndCapacity(String hireDate, int passengerCount) throws SQLException {
        String sql = "SELECT c.id, c.brand, c.model, c.plate_number, c.capacity " +
                "FROM cars c " +
                "LEFT JOIN bookings b ON c.id = b.car_id AND b.hire_date = ? " +
                "WHERE c.status = 'available' AND c.capacity >= ? AND (b.id IS NULL OR b.booking_status = 'cancelled')";

        List<Car> availableCars = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hireDate);
            stmt.setInt(2, passengerCount);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Car car = new Car(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("brand"),
                        rs.getString("model"),
                        rs.getString("plate_number"),
                        rs.getInt("capacity")
                );
                availableCars.add(car);
            }
        }
        return availableCars;
    }
}