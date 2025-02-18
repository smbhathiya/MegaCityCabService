package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static com.cabservice.megacitycabservice.util.DBUtil.getConnection;

public class UserDAO {

    // Get user by email
    public User getUserByEmail(String email) throws SQLException {
        String query = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role"),
                        rs.getBoolean("is_enabled"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
            }
        }
        return null;
    }

    // Get all users
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users";

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                User user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("role"),
                        rs.getBoolean("isEnabled"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // Search users by name
    public List<User> searchUsersByName(String name) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE name LIKE ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + name + "%");
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                User user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role"),
                        rs.getBoolean("is_enabled"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // Filter users by role
    public List<User> filterUsersByRole(String role) {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                User user = new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role"),
                        rs.getBoolean("is_enabled"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
                users.add(user);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }

    // Get user by ID
    public User getUserById(UUID id) {
        String sql = "SELECT * FROM users WHERE id = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setObject(1, id);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new User(
                        UUID.fromString(rs.getString("id")),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("password"),
                        rs.getString("role"),
                        rs.getBoolean("is_enabled"),
                        rs.getString("created_at"),
                        rs.getString("updated_at")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
