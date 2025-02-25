package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserDAO {

    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    // Utility method to map a ResultSet to a User object with null checks
    private User mapUserResultSet(ResultSet rs) throws SQLException {
        String idStr = rs.getString("id");
        if (idStr == null) {
            throw new SQLException("User ID cannot be null in database");
        }
        UUID id = UUID.fromString(idStr);
        String name = rs.getString("name");
        String email = rs.getString("email");
        if (email == null) {
            throw new SQLException("User email cannot be null in database");
        }
        String password = rs.getString("password");
        String role = rs.getString("role");
        boolean isEnabled = rs.getBoolean("is_enabled");
        String createdAt = rs.getString("created_at");
        String updatedAt = rs.getString("updated_at");

        return new User(id, name, email, password, role, isEnabled, createdAt, updatedAt);
    }

    // Get user by email
    public User getUserByEmail(String email) throws SQLException {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
        String query = "SELECT id, name, email, password, role, is_enabled, created_at, updated_at FROM users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUserResultSet(rs);
                }
            }
        }
        return null;
    }

    // Get all users
    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, name, email, password, role, is_enabled, created_at, updated_at FROM users";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                users.add(mapUserResultSet(rs));
            }
        }
        return users;
    }

    // Search users by name
    public List<User> searchUsersByName(String name) throws SQLException {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be null or empty");
        }
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, name, email, password, role, is_enabled, created_at, updated_at FROM users WHERE name LIKE ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + name + "%");
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUserResultSet(rs));
                }
            }
        }
        return users;
    }

    // Filter users by role
    public List<User> filterUsersByRole(String role) throws SQLException {
        if (role == null || role.trim().isEmpty()) {
            throw new IllegalArgumentException("Role cannot be null or empty");
        }
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, name, email, password, role, is_enabled, created_at, updated_at FROM users WHERE role = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapUserResultSet(rs));
                }
            }
        }
        return users;
    }

    // Get user by ID
    public User getUserById(UUID id) throws SQLException {
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        String sql = "SELECT id, name, email, password, role, is_enabled, created_at, updated_at FROM users WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, id.toString());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapUserResultSet(rs);
                }
            }
        }
        return null;
    }
}