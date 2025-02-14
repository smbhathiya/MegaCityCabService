package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.UserDao;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/UserLogin")
public class UserLogin extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(UserLogin.class);

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        // Input validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Email and password are required.");
            request.getRequestDispatcher("auth/login.jsp").forward(request, response);
            return;
        }

        UserDao userDAO = new UserDao();
        User user = null;

        try {
            user = userDAO.getUserByEmail(email);

            if (user != null && PasswordUtil.checkPassword(password, user.getPassword())) {
                // Regenerate session to prevent session fixation
                HttpSession oldSession = request.getSession(false);
                if (oldSession != null) {
                    oldSession.invalidate();
                }
                HttpSession session = request.getSession(true);

                // Store session data
                session.setAttribute("sessionId", UUID.randomUUID().toString());
                session.setAttribute("userId", user.getId());
                session.setAttribute("userName", user.getName());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60);

                // Set session cookie
                Cookie sessionCookie = new Cookie("sessionId", session.getId());
                sessionCookie.setHttpOnly(true);
                sessionCookie.setSecure(true); // Enable for HTTPS
                sessionCookie.setPath("/");
                sessionCookie.setMaxAge(30 * 60);
                response.addCookie(sessionCookie);

                // Redirect based on role
                response.sendRedirect(getDashboardURL(user.getRole()));
            } else {
                request.setAttribute("errorMessage", "Invalid email or password.");
                request.getRequestDispatcher("auth/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            logger.error("Database error during login for email: {}", email, e);
            request.setAttribute("errorMessage", "An error occurred. Please try again.");
            request.getRequestDispatcher("auth/login.jsp").forward(request, response);
        }
    }

    private String getDashboardURL(String role) {
        switch (role.toLowerCase()) {
            case "admin": return "admin/dashboard.jsp";
            case "manager": return "manager/dashboard.jsp";
            case "customer": return "customer/dashboard.jsp";
            default: return "auth/login.jsp";
        }
    }
}