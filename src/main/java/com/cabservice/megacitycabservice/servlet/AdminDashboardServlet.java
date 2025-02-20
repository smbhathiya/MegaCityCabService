package com.cabservice.megacitycabservice.servlet;

import com.cabservice.megacitycabservice.dao.AdminDAO;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/admin/dashboard-stats")
public class AdminDashboardServlet extends HttpServlet {
    private AdminDAO adminDAO;
    private Gson gson;

    @Override
    public void init() throws ServletException {
        super.init();
        adminDAO = new AdminDAO();
        gson = new Gson();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            Map<String, Integer> stats = new HashMap<>();
            stats.put("totalCars", adminDAO.getTotalCars());
            stats.put("totalDrivers", adminDAO.getTotalDrivers());
            stats.put("activeBookings", adminDAO.getActiveBookings());
            stats.put("pendingRequests", adminDAO.getPendingRequests());

            response.setContentType("application/json");
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(stats));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching dashboard stats: " + e.getMessage());
        }
    }
}