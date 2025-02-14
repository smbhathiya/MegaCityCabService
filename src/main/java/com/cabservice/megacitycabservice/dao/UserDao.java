package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Customer;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UserDao {

    // Helper method for obtaining a connection
    private Connection getConnection() throws SQLException {
        return DBUtil.getConnection();
    }

    // customer user registration
    public boolean registerUserAndCustomer(User user, Customer customer) throws SQLException {
        boolean success = false;
        UUID userId = UUID.randomUUID();
        UUID customerId = UUID.randomUUID();

        String userSql = "INSERT INTO users (id, name, email, password, role, isEnabled) VALUES (?, ?, ?, ?, ?, ?)";
        String customerSql = "INSERT INTO customers (id, user_id, address, contact_no) VALUES (?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement userStmt = conn.prepareStatement(userSql);
             PreparedStatement customerStmt = conn.prepareStatement(customerSql)) {

            conn.setAutoCommit(false);

            // Insert user
            userStmt.setString(1, userId.toString());
            userStmt.setString(2, user.getName());
            userStmt.setString(3, user.getEmail());
            userStmt.setString(4, user.getPassword());
            userStmt.setString(5, user.getRole());
            userStmt.setBoolean(6, true);  // Assuming the user is enabled by default

            if (userStmt.executeUpdate() > 0) {
                // Insert customer
                customerStmt.setString(1, customerId.toString());
                customerStmt.setString(2, userId.toString());
                customerStmt.setString(3, customer.getAddress());
                customerStmt.setString(4, customer.getContactNo());

                if (customerStmt.executeUpdate() > 0) {
                    conn.commit();
                    success = true;
                } else {
                    conn.rollback();
                }
            } else {
                conn.rollback();
            }

        } catch (SQLException e) {
            throw new SQLException("Error registering user and customer: " + e.getMessage(), e);
        }
        return success;
    }

    // Register admin user
    public boolean registerAdmin(User user) throws SQLException {
        boolean success = false;
        String checkAdminSql = "SELECT 1 FROM users WHERE role = 'admin' LIMIT 1";
        String checkEmailSql = "SELECT 1 FROM users WHERE email = ? LIMIT 1";
        String insertUserSql = "INSERT INTO users (id, name, email, password, role, isEnabled) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement checkAdminStmt = conn.prepareStatement(checkAdminSql);
             PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql)) {

            // Check if admin already exists
            ResultSet rs = checkAdminStmt.executeQuery();
            if (rs.next()) {
                throw new SQLException("AdminExists");
            }

            // Check if email is already taken
            checkEmailStmt.setString(1, user.getEmail());
            rs = checkEmailStmt.executeQuery();
            if (rs.next()) {
                throw new SQLException("EmailTaken");
            }

            // Insert admin user
            try (PreparedStatement stmt = conn.prepareStatement(insertUserSql)) {
                UUID userId = UUID.randomUUID();
                stmt.setString(1, userId.toString());
                stmt.setString(2, user.getName());
                stmt.setString(3, user.getEmail());
                stmt.setString(4, user.getPassword());
                stmt.setString(5, "admin");
                stmt.setBoolean(6, true);

                success = stmt.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            throw new SQLException("Error registering admin: " + e.getMessage(), e);
        }
        return success;
    }

    // Get user by email (Optimized using try-with-resources)
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
                        rs.getBoolean("isEnabled")
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
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                UUID id = UUID.fromString(rs.getString("id"));
                String name = rs.getString("name");
                String email = rs.getString("email");
                String role = rs.getString("role");
                boolean isEnabled = rs.getBoolean("isEnabled");

                users.add(new User(id, name, email, rs.getString("password"), role, isEnabled));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return users;
    }
}
