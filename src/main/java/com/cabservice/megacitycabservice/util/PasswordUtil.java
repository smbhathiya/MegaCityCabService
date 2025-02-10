package com.cabservice.megacitycabservice.util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {
    // Hashes the plain text password
    public static String hashPassword(String plainTextPassword) {
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt());
    }

    // Checks if the plain text password matches the hashed password
    public static boolean checkPassword(String plainTextPassword, String hashedPassword) {
        return BCrypt.checkpw(plainTextPassword, hashedPassword);
    }
}
