package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

public class AdminDAO {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    public boolean registerAdmin(User user) throws SQLException {
        String checkAdminSql = "SELECT COUNT(*) FROM users WHERE role = 'admin'";
        String checkEmailSql = "SELECT COUNT(*) FROM users WHERE email = ?";
        String insertUserSql = "INSERT INTO users (id, name, email, password, role, is_enabled) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            try (PreparedStatement checkAdminStmt = conn.prepareStatement(checkAdminSql);
                 ResultSet rs = checkAdminStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("AdminExists");
                }
            }

            try (PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql)) {
                checkEmailStmt.setString(1, user.getEmail());
                try (ResultSet rs = checkEmailStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new SQLException("EmailTaken");
                    }
                }
            }

            try (PreparedStatement stmt = conn.prepareStatement(insertUserSql)) {
                UUID userId = UUID.randomUUID();
                stmt.setString(1, userId.toString());
                stmt.setString(2, user.getName());
                stmt.setString(3, user.getEmail());
                stmt.setString(4, user.getPassword());
                stmt.setString(5, "admin");
                stmt.setBoolean(6, true);

                if (stmt.executeUpdate() > 0) {
                    conn.commit();
                    return true;
                }
            }

            conn.rollback();
            return false;
        } catch (SQLException e) {
            throw new SQLException("Error registering admin: " + e.getMessage(), e);
        }
    }

    public int getTotalCars() throws SQLException {
        String sql = "SELECT COUNT(*) FROM cars";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int getTotalDrivers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM drivers WHERE availability_status != 'inactive'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int getActiveBookings() throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE booking_status IN ('confirmed', 'in-progress')";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }

    public int getPendingRequests() throws SQLException {
        String sql = "SELECT COUNT(*) FROM bookings WHERE booking_status = 'pending'";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        }
    }
}