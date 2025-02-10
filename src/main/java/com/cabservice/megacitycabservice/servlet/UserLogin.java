package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.UserDao;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/UserLogin")
public class UserLogin extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDao userDAO = new UserDao();
        User user = null;

        try {
            user = userDAO.getUserByEmail(email);

            if (user != null && PasswordUtil.checkPassword(password, user.getPassword())) {
                HttpSession session = request.getSession(true);
                String sessionId = UUID.randomUUID().toString();

                // Store session data
                session.setAttribute("sessionId", sessionId);
                session.setAttribute("userId", user.getId());
                session.setAttribute("userName", user.getName());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60);

                Cookie sessionCookie = new Cookie("sessionId", sessionId);
                sessionCookie.setHttpOnly(true);
                sessionCookie.setSecure(false);
                sessionCookie.setPath("/");
                sessionCookie.setMaxAge(30 * 60);
                response.addCookie(sessionCookie);

                response.sendRedirect(getDashboardURL(user.getRole()));
            } else {
                request.setAttribute("errorMessage", "Invalid email or password.");
                request.getRequestDispatcher("auth/login.jsp").forward(request, response);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred. Please try again.");
            request.getRequestDispatcher("auth/login.jsp").forward(request, response);
        }
    }

    private String getDashboardURL(String role) {
        switch (role) {
            case "admin": return "admin/dashboard.jsp";
            case "manager": return "manager/dashboard.jsp";
            case "customer": return "customer/dashboard.jsp";
            default: return "auth/login.jsp";
        }
    }
}
