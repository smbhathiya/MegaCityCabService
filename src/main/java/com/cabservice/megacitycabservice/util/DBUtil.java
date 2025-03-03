package com.cabservice.megacitycabservice.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {
    private static final String URL = "jdbc:mysql://localhost:3306/megacitycabs";
    private static final String USER = "root";
    private static final String PASSWORD = "1234";
    private static volatile Connection connection = null;

    private DBUtil() {
        throw new UnsupportedOperationException("Utility class cannot be instantiated");
    }

    public static synchronized Connection getConnection() {
        if (connection == null || isConnectionClosed()) {
            synchronized (DBUtil.class) {
                if (connection == null || isConnectionClosed()) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connection = DriverManager.getConnection(URL, USER, PASSWORD);
                    } catch (ClassNotFoundException | SQLException e) {
                        e.printStackTrace();
                        throw new RuntimeException("Failed to establish database connection", e);
                    }
                }
            }
        }
        return connection;
    }

    private static boolean isConnectionClosed() {
        try {
            return connection == null || connection.isClosed();
        } catch (SQLException e) {
            return true;
        }
    }

}