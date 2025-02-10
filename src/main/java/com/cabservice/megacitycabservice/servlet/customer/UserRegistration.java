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
import java.io.Serial;
import java.sql.SQLException;

//@WebServlet("/register")
public class UserRegistration extends HttpServlet {

    @Serial
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String contactNo = request.getParameter("phone_number");
        String address = request.getParameter("address");

        String hashedPassword = PasswordUtil.hashPassword(password);

        User user = new User(null, name, email, hashedPassword, "customer");
        Customer customer = new Customer(null, address, contactNo);

        UserDao userDAO = new UserDao();
        try {
            boolean isRegistered = userDAO.registerUserAndCustomer(user, customer);
            if (isRegistered) {
                request.getSession().setAttribute("toastMessage", "Registration successful!");
                request.getSession().setAttribute("toastType", "success");
                response.sendRedirect("auth/login.jsp");
            } else {
                request.getSession().setAttribute("toastMessage", "Registration failed. Please try again.");
                request.getSession().setAttribute("toastType", "error");
                response.sendRedirect("auth/register.jsp");
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
            response.sendRedirect("auth/register.jsp");
        }
    }
}
