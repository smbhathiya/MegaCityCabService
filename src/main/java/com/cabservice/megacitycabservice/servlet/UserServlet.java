package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.UserDAO;
import com.cabservice.megacitycabservice.model.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

@WebServlet("/users")
public class UserServlet extends HttpServlet {
    private final Gson gson = new Gson();
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json; charset=UTF-8");
        String action = request.getParameter("action");

        if (action == null || action.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required.");
            return;
        }

        try {
            switch (action) {
                case "getAll":
                    getAllUsers(request, response);
                    break;
                case "search":
                    searchUsersByName(request, response);
                    break;
                case "filterByRole":
                    filterUsersByRole(request, response);
                    break;
                case "getById":
                    getUserById(request, response);
                    break;
                default:
                    sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid action: " + action);
            }
        } catch (SQLException e) {
            sendError(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + e.getMessage());
        }
    }

    private void getAllUsers(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        List<User> users = userDAO.getAllUsers();
        response.getWriter().write(gson.toJson(users));
    }

    private void searchUsersByName(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Name parameter is required.");
            return;
        }
        List<User> users = userDAO.searchUsersByName(name);
        response.getWriter().write(gson.toJson(users));
    }

    private void filterUsersByRole(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        String role = request.getParameter("role");
        if (role == null || role.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Role parameter is required.");
            return;
        }
        List<User> users = userDAO.filterUsersByRole(role);
        response.getWriter().write(gson.toJson(users));
    }

    private void getUserById(HttpServletRequest request, HttpServletResponse response) throws IOException, SQLException {
        String userIdStr = request.getParameter("userId");
        if (userIdStr == null || userIdStr.trim().isEmpty()) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "userId parameter is required.");
            return;
        }

        UUID userId;
        try {
            userId = UUID.fromString(userIdStr);
        } catch (IllegalArgumentException e) {
            sendError(response, HttpServletResponse.SC_BAD_REQUEST, "Invalid userId format: " + userIdStr);
            return;
        }

        User user = userDAO.getUserById(userId);
        if (user != null) {
            response.getWriter().write(gson.toJson(user));
        } else {
            sendError(response, HttpServletResponse.SC_NOT_FOUND, "User not found with ID: " + userId);
        }
    }

    // Helper method to send JSON error responses
    private void sendError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        String jsonError = gson.toJson(new ErrorResponse(message));
        response.getWriter().write(jsonError);
    }

    // Simple error response class
    private static class ErrorResponse {
        private final String error;

        ErrorResponse(String error) {
            this.error = error;
        }

        public String getError() {
            return error;
        }
    }
}