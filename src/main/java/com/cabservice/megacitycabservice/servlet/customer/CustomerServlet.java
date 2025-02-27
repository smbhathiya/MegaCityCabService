package com.cabservice.megacitycabservice.servlet.customer;

import com.cabservice.megacitycabservice.dao.CustomerDAO;
import com.cabservice.megacitycabservice.model.Customer;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/customer")
public class CustomerServlet extends HttpServlet {

    private final Gson gson = new Gson();

    // View customer details
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        UUID customerId = UUID.fromString(request.getParameter("id"));

        if (customerId == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Customer ID is required.\"}");
            return;
        }

        try {
            CustomerDAO customerDAO = new CustomerDAO();
            Customer customer = customerDAO.getCustomerById(customerId);

            if (customer != null) {
                response.getWriter().write(gson.toJson(customer));
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Customer not found.\"}");
            }
        } catch (SQLException | IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Error retrieving customer.\"}");
        }
    }

    // Create new customer
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }

        String requestBody = stringBuilder.toString();
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

        String name = jsonObject.get("name").getAsString();
        String email = jsonObject.get("email").getAsString();
        boolean isEnabled = jsonObject.get("is_enabled").getAsBoolean();
        String contactNo = jsonObject.get("contact_no").getAsString();
        String address = jsonObject.get("address").getAsString();
        String password = jsonObject.get("password").getAsString();

        String passwordHash = PasswordUtil.hashPassword(password);

        if (name == null || email == null || contactNo == null || address == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Name, email, contact number, and address are required.\"}");
            return;
        }

        try {
            CustomerDAO customerDAO = new CustomerDAO();
            boolean isAdded = customerDAO.addCustomer(name, email, isEnabled, contactNo, address, passwordHash);

            if (isAdded) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Customer added successfully!\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to add customer.\"}");
            }
        } catch (SQLException e) {
            String errorMessage = e.getMessage();

            if (errorMessage.contains("Duplicate entry")) {
                if (errorMessage.contains("customers.contact_no")) {
                    errorMessage = "This phone number is already registered.";
                } else if (errorMessage.contains("users.email")) {
                    errorMessage = "This email is already registered.";
                } else {
                    errorMessage = "Duplicate entry found.";
                }
            } else {
                errorMessage = "An unexpected error occurred. Please try again.";
            }

            response.getWriter().write("{\"status\": \"error\", \"message\": \"" + errorMessage + "\"}");
            e.printStackTrace();
        }

    }


    // Update customer details
    protected void doPut(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        StringBuilder stringBuilder = new StringBuilder();
        String line;
        while ((line = request.getReader().readLine()) != null) {
            stringBuilder.append(line);
        }

        String requestBody = stringBuilder.toString();
        JsonObject jsonObject = gson.fromJson(requestBody, JsonObject.class);

        String customerId = jsonObject.get("id").getAsString();
        String name = jsonObject.get("name").getAsString();
        String contactNo = jsonObject.get("contact_no").getAsString();
        String address = jsonObject.get("address").getAsString();
        String email = jsonObject.get("email").getAsString(); // Added email extraction

        if (customerId == null || name == null || contactNo == null || address == null || email == null) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Customer ID, name, contact number, address, and email are required.\"}");
            return;
        }

        try {
            UUID id = UUID.fromString(customerId);

            CustomerDAO customerDAO = new CustomerDAO();
            boolean isUpdated = customerDAO.updateCustomer(id, name, contactNo, address, email);

            if (isUpdated) {
                response.getWriter().write("{\"status\": \"success\", \"message\": \"Customer details updated successfully!\"}");
            } else {
                response.getWriter().write("{\"status\": \"error\", \"message\": \"Failed to update customer details.\"}");
            }
        } catch (SQLException e) {
            // Provide a more specific error message
            String errorMessage = "Error updating customer: " + e.getMessage();
            response.getWriter().write("{\"status\": \"error\", \"message\": \"" + errorMessage + "\"}");
        } catch (IllegalArgumentException e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Invalid customer ID format.\"}");
        } catch (Exception e) {
            response.getWriter().write("{\"status\": \"error\", \"message\": \"Unexpected error: " + e.getMessage() + "\"}");
        }
    }
}




