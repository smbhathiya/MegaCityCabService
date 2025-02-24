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
        response.setContentType("application/json");
        String action = request.getParameter("action");

        if (action == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action parameter is required.");
            return;
        }

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
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    // get all users
    private void getAllUsers(HttpServletRequest request, HttpServletResponse response) throws IOException {
        List<User> users = userDAO.getAllUsers();
        response.getWriter().write(gson.toJson(users));
    }


    private void searchUsersByName(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String name = request.getParameter("name");
        List<User> users = userDAO.searchUsersByName(name);
        response.getWriter().write(gson.toJson(users));
    }

    private void filterUsersByRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String role = request.getParameter("role");
        List<User> users = userDAO.filterUsersByRole(role);
        response.getWriter().write(gson.toJson(users));
    }

    private void getUserById(HttpServletRequest request, HttpServletResponse response) throws IOException {
        UUID userId = UUID.fromString(request.getParameter("userId"));
        User user = userDAO.getUserById(userId);

        if (user != null) {
            response.getWriter().write(gson.toJson(user));
        } else {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "User not found");
        }
    }
}
