package com.cabservice.megacitycabservice.servlet.customer;

import com.cabservice.megacitycabservice.dao.UserDao;
import com.cabservice.megacitycabservice.model.Customer;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/customer/UserRegistration")
public class UserRegistration extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String contactNo = request.getParameter("phone_number");
        String address = request.getParameter("address");

        // Hash the password
        String hashedPassword = PasswordUtil.hashPassword(password);

        // Create User and Customer objects
        User user = new User(null, name, email, hashedPassword, "customer", true);
        Customer customer = new Customer(null, address, contactNo);

        UserDao userDAO = new UserDao();
        try {
            boolean isRegistered = userDAO.registerUserAndCustomer(user, customer);
            if (isRegistered) {
                request.getSession().setAttribute("toastMessage", "Registration successful!");
                request.getSession().setAttribute("toastType", "success");
                response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
            } else {
                request.getSession().setAttribute("toastMessage", "Registration failed. Please try again.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect(request.getContextPath() + "/customer/customerRegister.jsp");
            }
        } catch (SQLException e) {
            String errorMsg = e.getMessage();
            if (errorMsg.contains("users.email")) {
                request.getSession().setAttribute("toastMessage", "Error: Email already taken.");
            } else if (errorMsg.contains("customers.contact_no")) {
                request.getSession().setAttribute("toastMessage", "Error: Contact number already taken.");
            } else {
                request.getSession().setAttribute("toastMessage", "Server error, please try again later.");
            }
            request.getSession().setAttribute("toastType", "error");
            // Redirect back to the registration page
            response.sendRedirect(request.getContextPath() + "/customer/customerRegister.jsp");
        }
    }
}