package com.cabservice.megacitycabservice.servlet.auth;

import com.cabservice.megacitycabservice.dao.UserDAO;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;
import java.util.UUID;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        gson = new Gson();
    }

    private static final Logger logger = LoggerFactory.getLogger(LoginServlet.class);

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        BufferedReader reader = request.getReader();
        Map<String, String> requestData = gson.fromJson(reader, Map.class);

        String email = requestData.get("email");
        String password = requestData.get("password");

        // Input validation
        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Email and password are required.\"}");
            return;
        }

        UserDAO userDAO = new UserDAO();
        User user = null;

        try {
            user = userDAO.getUserByEmail(email);
        } catch (SQLException e) {
            logger.error("Database error while fetching user", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"An internal server error occurred.\"}");
            return;
        }

        if (user != null && PasswordUtil.checkPassword(password, user.getPassword())) {
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
            sessionCookie.setSecure(true);
            sessionCookie.setPath("/");
            sessionCookie.setMaxAge(30 * 60);
            response.addCookie(sessionCookie);

            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"success\",\"role\":\"" + user.getRole() + "\",\"message\":\"Login successful.\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Invalid email or password.\"}");
        }
    }
}
