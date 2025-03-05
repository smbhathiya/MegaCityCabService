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
    private final UserDAO userDAO;
    private static final Logger logger = LoggerFactory.getLogger(LoginServlet.class);

    public LoginServlet() {
        this(new UserDAO());
    }

    public LoginServlet(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    @Override
    public void init() throws ServletException {
        super.init();
        gson = new Gson();
    }

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        if (!"application/json".equals(request.getContentType())) {
            response.setStatus(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Content-Type must be application/json\"}");
            return;
        }

        Map<String, String> requestData;
        try {
            BufferedReader reader = request.getReader();
            requestData = gson.fromJson(reader, Map.class);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Invalid JSON format.\"}");
            return;
        }

        String email = requestData.get("email");
        String password = requestData.get("password");

        if (email == null || email.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.setContentType("application/json");
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Email and password are required.\"}");
            return;
        }

        User user;
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
            session.setAttribute("sessionId", UUID.randomUUID().toString());
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("role", user.getRole());
            session.setMaxInactiveInterval(30 * 60);

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