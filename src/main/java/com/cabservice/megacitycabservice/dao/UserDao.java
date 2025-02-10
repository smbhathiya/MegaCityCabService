package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.Customer;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

public class UserDao {
    public boolean registerUserAndCustomer(User user, Customer customer) throws SQLException {
        boolean success = false;
        Connection conn = null;
        PreparedStatement userStmt = null;
        PreparedStatement customerStmt = null;


        UUID userId = UUID.randomUUID();
        UUID customerId = UUID.randomUUID();

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            String userSql = "INSERT INTO users (id, name, email, password, role) VALUES (?, ?, ?, ?, ?)";
            userStmt = conn.prepareStatement(userSql);
            userStmt.setString(1, userId.toString());
            userStmt.setString(2, user.getName());
            userStmt.setString(3, user.getEmail());
            userStmt.setString(4, user.getPassword());
            userStmt.setString(5, user.getRole());

            int affectedRows = userStmt.executeUpdate();
            if (affectedRows > 0) {
                String customerSql = "INSERT INTO customers (id, user_id, address, contact_no) VALUES (?, ?, ?, ?)";
                customerStmt = conn.prepareStatement(customerSql);
                customerStmt.setString(1, customerId.toString());
                customerStmt.setString(2, userId.toString());
                customerStmt.setString(3, customer.getAddress());
                customerStmt.setString(4, customer.getContactNo());

                int customerRows = customerStmt.executeUpdate();
                if (customerRows > 0) {
                    conn.commit();
                    success = true;
                } else {
                    conn.rollback();
                }
            } else {
                conn.rollback();
            }
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (userStmt != null) {
                try { userStmt.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            if (customerStmt != null) {
                try { customerStmt.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }

        return success;
    }


    public boolean registerAdmin(User user) throws SQLException {
        boolean success = false;
        Connection conn = null;
        PreparedStatement stmt = null;
        UUID userId = UUID.randomUUID();

        try {
            conn = DBUtil.getConnection();

            String checkAdminSql = "SELECT COUNT(*) FROM users WHERE role = 'admin'";
            PreparedStatement checkStmt = conn.prepareStatement(checkAdminSql);
            ResultSet r = checkStmt.executeQuery();

            if (r.next() && r.getInt(1) > 0) {
                throw new SQLException("AdminExists");
            }

            String checkEmailSql = "SELECT COUNT(*) FROM users WHERE email = ?";
            PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql);
            checkEmailStmt.setString(1, user.getEmail());
            ResultSet rs = checkEmailStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                throw new SQLException("EmailTaken");
            }

            String sql = "INSERT INTO users (id, name, email, password, role) VALUES (?, ?, ?, ?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, userId.toString());
            stmt.setString(2, user.getName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPassword());
            stmt.setString(5, "admin");

            int affectedRows = stmt.executeUpdate();
            success = (affectedRows > 0);
        } catch (SQLException e) {
            throw e;
        } finally {
            if (stmt != null) { try { stmt.close(); } catch (SQLException ex) { ex.printStackTrace(); } }
            if (conn != null) { try { conn.close(); } catch (SQLException ex) { ex.printStackTrace(); } }
        }
        return success;
    }

    public User getUserByEmail(String email) throws SQLException {
        User user = null;
        String query = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                user = new User();
                user.setId(UUID.fromString(rs.getString("id")));
                user.setName(rs.getString("name"));
                user.setEmail(rs.getString("email"));
                user.setPassword(rs.getString("password"));
                user.setRole(rs.getString("role"));
            }
        }
        return user;
    }
}

