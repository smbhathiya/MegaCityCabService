package com.cabservice.megacitycabservice.dao;

import com.cabservice.megacitycabservice.model.User;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

import static com.cabservice.megacitycabservice.util.DBUtil.getConnection;

public class AdminDAO {

    public boolean registerAdmin(User user) throws SQLException {
        String checkAdminSql = "SELECT COUNT(*) FROM users WHERE role = 'admin'";
        String checkEmailSql = "SELECT COUNT(*) FROM users WHERE email = ?";
        String insertUserSql = "INSERT INTO users (id, name, email, password, role, isEnabled) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false); // Start transaction

            // Check if an admin already exists
            try (PreparedStatement checkAdminStmt = conn.prepareStatement(checkAdminSql);
                 ResultSet rs = checkAdminStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("AdminExists");
                }
            }

            // Check if email is already taken
            try (PreparedStatement checkEmailStmt = conn.prepareStatement(checkEmailSql)) {
                checkEmailStmt.setString(1, user.getEmail());
                try (ResultSet rs = checkEmailStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        throw new SQLException("EmailTaken");
                    }
                }
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

                if (stmt.executeUpdate() > 0) {
                    conn.commit(); // Commit transaction if successful
                    return true;
                }
            }

            conn.rollback(); // Rollback if insertion fails
            return false;

        } catch (SQLException e) {
            throw new SQLException("Error registering admin: " + e.getMessage(), e);
        }
    }
}
