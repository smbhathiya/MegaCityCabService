package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.UserDao;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class UserLogin extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        UserDao userDAO = new UserDao();
        User user = null;

        try {
            user = userDAO.getUserByEmail(email);

            if (user != null && PasswordUtil.checkPassword(password, user.getPassword())) {
                HttpSession session = request.getSession();
                session.setAttribute("userId", user.getId());
                session.setAttribute("userName", user.getName());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60); // Session expires after 30 minutes

                // Redirect to the appropriate dashboard based on user role
                String dashboardURL = getDashboardURL(user.getRole());
                response.sendRedirect(dashboardURL);
            } else {
                // Handle invalid credentials
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
            case "admin":
                return "/admin/dashboard.jsp";
            case "manager":
                return "/manager/dashboard.jsp";
            case "customer":
                return "/customer/dashboard.jsp";
            default:
                return "/auth/login.jsp";
        }
    }
}
