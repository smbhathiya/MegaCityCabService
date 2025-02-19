package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Customer;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.*;
import java.util.UUID;

public class CustomerDAO {

    // Add new customer
    public boolean addCustomer(String name, String email, boolean isEnabled, String contactNo, String address,String passwordHash) throws SQLException {
        UUID userId = UUID.randomUUID();

        String sql = "INSERT INTO users (id, name, email, is_enabled, password) VALUES (?, ?, ?, ?,?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setObject(1, userId.toString());
            stmt.setString(2, name);
            stmt.setString(3, email);
            stmt.setBoolean(4, isEnabled);
            stmt.setString(5, passwordHash);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating user failed, no rows affected.");
            }

            String customerSql = "INSERT INTO customers (id, user_id, contact_no, address, created_at, updated_at) VALUES (?,?, ?, ?, NOW(), NOW())";
            try (PreparedStatement stmt2 = conn.prepareStatement(customerSql)) {
                stmt2.setObject(1, userId.toString());
                stmt2.setObject(2, userId.toString());
                stmt2.setString(3, contactNo);
                stmt2.setString(4, address);
                return stmt2.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            System.out.println("Error in addCustomer: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    // Get customer details by ID
    public Customer getCustomerById(UUID customerId) throws SQLException {
        String sql = "SELECT c.id, c.user_id, c.contact_no, c.address, c.created_at, c.updated_at, u.name, u.email, u.is_enabled " +
                "FROM customers c " +
                "JOIN users u ON c.user_id = u.id " +
                "WHERE c.id = ?;";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, customerId.toString());
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                return new Customer(
                        UUID.fromString(rs.getString("id")),
                        UUID.fromString(rs.getString("user_id")),
                        rs.getString("address"),
                        rs.getString("contact_no"),
                        rs.getString("created_at"),
                        rs.getString("updated_at"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getBoolean("is_enabled")
                );
            } else {
                System.out.println("No customer found for customerId: " + customerId);
            }
        }
        return null;
    }

    // Update customer details
    public boolean updateCustomer(UUID customerId, String name, String contactNo, String address) throws SQLException {
        String sql = "UPDATE users u JOIN customers c ON u.id = c.user_id " +
                "SET u.name = ?, c.contact_no = ?, c.address = ?, c.updated_at = NOW() " +
                "WHERE c.id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, name);
            stmt.setString(2, contactNo);
            stmt.setString(3, address);
            stmt.setObject(4, customerId.toString());

            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected == 0) {
                throw new SQLException("No customer found with the given ID.");
            }

            return rowsAffected > 0;
        } catch (SQLException e) {
            throw new SQLException("Error updating customer: " + e.getMessage());
        }
    }




}
