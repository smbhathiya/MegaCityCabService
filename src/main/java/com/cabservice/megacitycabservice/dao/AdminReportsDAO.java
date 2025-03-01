package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Car;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;

public class AdminReportsDAO {
    private static final Logger logger = Logger.getLogger(AdminReportsDAO.class.getName());

    public static class Reports {
        public List<RevenueItem> revenue;
        public Map<String, Integer> bookings;
        public List<DriverItem> drivers;
        public List<Car> vehicles;

        public Reports(List<RevenueItem> revenue, Map<String, Integer> bookings, List<DriverItem> drivers, List<Car> vehicles) {
            this.revenue = revenue;
            this.bookings = bookings;
            this.drivers = drivers;
            this.vehicles = vehicles;
        }
    }

    public static class RevenueItem {
        public String date;
        public double amount;

        public RevenueItem(String date, double amount) {
            this.date = date;
            this.amount = amount;
        }
    }

    public static class DriverItem {
        public String name;  // Changed from driverId to name
        public double earnings;
        public int bookings;

        public DriverItem(String name, double earnings, int bookings) {
            this.name = name;
            this.earnings = earnings;
            this.bookings = bookings;
        }
    }

    public Reports getReports(String startDate, String endDate) throws SQLException {
        Connection conn = DBUtil.getConnection();
        List<RevenueItem> revenue = new ArrayList<>();
        Map<String, Integer> bookings = new HashMap<>();
        List<DriverItem> drivers = new ArrayList<>();
        List<Car> vehicles = new ArrayList<>();

        // Revenue Report
        String revenueSql = "SELECT DATE(payment_date) as date, SUM(amount) as total FROM payments WHERE payment_date BETWEEN ? AND ? AND status = 'successful' GROUP BY DATE(payment_date)";
        logger.info("Executing revenue query: " + revenueSql + " with startDate=" + startDate + ", endDate=" + endDate);
        try (PreparedStatement stmt = conn.prepareStatement(revenueSql)) {
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    RevenueItem item = new RevenueItem(rs.getString("date"), rs.getDouble("total"));
                    revenue.add(item);
                    logger.fine("Revenue item retrieved: date=" + item.date + ", amount=" + item.amount);
                }
                logger.info("Revenue report retrieved: " + revenue.size() + " items");
            }
        }

        // Booking Summary
        String bookingSql = "SELECT booking_status, COUNT(*) as count FROM bookings WHERE hire_date BETWEEN ? AND ? GROUP BY booking_status";
        logger.info("Executing booking summary query: " + bookingSql + " with startDate=" + startDate + ", endDate=" + endDate);
        try (PreparedStatement stmt = conn.prepareStatement(bookingSql)) {
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("booking_status");
                    int count = rs.getInt("count");
                    bookings.put(status, count);
                    logger.fine("Booking status retrieved: " + status + "=" + count);
                }
                logger.info("Booking summary retrieved: " + bookings.size() + " statuses");
            }
        }

        // Driver Performance - Join with users table to get name
        String driverSql = "SELECT u.name, COUNT(b.id) as bookings, SUM(p.amount) as earnings " +
                "FROM bookings b LEFT JOIN payments p ON b.id = p.booking_id " +
                "LEFT JOIN users u ON b.driver_id = u.id " +
                "WHERE b.hire_date BETWEEN ? AND ? AND p.status = 'successful' GROUP BY u.name";
        logger.info("Executing driver performance query: " + driverSql + " with startDate=" + startDate + ", endDate=" + endDate);
        try (PreparedStatement stmt = conn.prepareStatement(driverSql)) {
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DriverItem item = new DriverItem(rs.getString("name"), rs.getDouble("earnings"), rs.getInt("bookings"));
                    drivers.add(item);
                    logger.fine("Driver item retrieved: name=" + item.name + ", earnings=" + item.earnings + ", bookings=" + item.bookings);
                }
                logger.info("Driver performance retrieved: " + drivers.size() + " drivers");
            }
        }

        // Vehicle Utilization
        String vehicleSql = "SELECT c.plate_number, COUNT(b.id) as bookings " +
                "FROM bookings b LEFT JOIN cars c ON b.car_id = c.id " +
                "WHERE b.hire_date BETWEEN ? AND ? GROUP BY c.plate_number";
        logger.info("Executing vehicle utilization query: " + vehicleSql + " with startDate=" + startDate + ", endDate=" + endDate);
        try (PreparedStatement stmt = conn.prepareStatement(vehicleSql)) {
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Car item = new Car(rs.getString("plate_number"), rs.getInt("bookings"));
                    vehicles.add(item);
                    logger.fine("Vehicle item retrieved: plateNumber=" + item.getPlateNumber() + ", bookings=" + item.getBookings());
                }
                logger.info("Vehicle utilization retrieved: " + vehicles.size() + " vehicles");
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error executing vehicle utilization query: " + vehicleSql, e);
            throw e;
        }

        Reports reports = new Reports(revenue, bookings, drivers, vehicles);
        logger.info("Reports object constructed: " + reports.revenue.size() + " revenue items, " + reports.bookings.size() + " booking statuses, " +
                reports.drivers.size() + " drivers, " + reports.vehicles.size() + " vehicles");
        return reports;
    }
}