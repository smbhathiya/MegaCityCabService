<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.cabservice.megacitycabservice.dao.CustomerDAO" %>
<%@ page import="com.cabservice.megacitycabservice.util.PasswordUtil" %>
<%@ page import="java.sql.SQLException" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: {
                            DEFAULT: '#FCC603',
                            50: 'rgba(252, 198, 3, 0.1)',
                            100: 'rgba(252, 198, 3, 0.2)',
                            700: '#CC9F02'
                        },
                        dark: '#1A1A1A',
                        light: '#F5F5F5',
                        accent: '#2A2A2A'
                    },
                    animation: {
                        'fade-in': 'fadeIn 0.5s ease-in-out',
                        'slide-up': 'slideUp 0.5s ease-out'
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0' },
                            '100%': { opacity: '1' }
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(20px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' }
                        }
                    }
                }
            }
        };
    </script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        body {
            background-color: #1A1A1A;
            font-family: 'Inter', sans-serif;
        }
        .register-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        .password-match {
            position: relative;
        }
        .check-icon {
            position: absolute;
            right: 12px;
            top: 65%;
            transform: translateY(-50%);
            display: none;
            color: #22c55e;
        }
        .password-match.match .check-icon {
            display: inline-block;
        }
        input:focus {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">
<%
    String errorMessage = null;
    String successMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String phoneNumber = request.getParameter("phone_number");
        String address = request.getParameter("address");

        if (password != null && !password.equals(confirmPassword)) {
            errorMessage = "Passwords do not match!";
        } else if (name != null && email != null && phoneNumber != null && address != null && password != null) {
            try {
                CustomerDAO customerDAO = new CustomerDAO();
                String passwordHash = PasswordUtil.hashPassword(password);
                boolean isAdded = customerDAO.addCustomer(name, email, true, phoneNumber, address, passwordHash);

                if (isAdded) {
                    successMessage = "Registration successful!";
                    session.setAttribute("toastMessage", successMessage);
                    session.setAttribute("toastType", "success");
                } else {
                    errorMessage = "Failed to register customer.";
                }
            } catch (SQLException e) {
                String sqlMessage = e.getMessage();
                if (sqlMessage.contains("Duplicate entry")) {
                    if (sqlMessage.contains("customers.contact_no")) {
                        errorMessage = "This phone number is already registered.";
                    } else if (sqlMessage.contains("users.email")) {
                        errorMessage = "This email is already registered.";
                    } else {
                        errorMessage = "Duplicate entry found.";
                    }
                } else {
                    errorMessage = "An unexpected error occurred. Please try again.";
                }
                e.printStackTrace();
            }
        } else {
            errorMessage = "All fields are required!";
        }
    }
%>

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <a href="${pageContext.request.contextPath}/views/auth/login.jsp"
                   class="px-6 py-2 bg-primary text-black rounded-full btn-primary flex items-center gap-2 text-lg font-semibold">
                    <i data-lucide="log-in" class="w-5 h-5"></i>
                    Login
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- Registration Form -->
<div class="flex-1 flex items-center justify-center px-6 py-28">
    <div class="register-container p-8 rounded-xl shadow-2xl w-full max-w-2xl animate-slide-up">
        <h2 class="text-3xl font-bold text-white text-center mb-8">Registration</h2>
        <form id="registrationForm" method="post" action="<%= request.getContextPath() %>/views/customer/customerRegister.jsp">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label for="name" class="block text-sm font-medium text-gray-300 mb-2">Full Name</label>
                    <input type="text" id="name" name="name" required
                           value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>"
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div>
                    <label for="email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
                    <input type="email" id="email" name="email" required
                           value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>"
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
                    <input type="password" id="password" name="password" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div class="password-match">
                    <label for="confirm_password" class="block text-sm font-medium text-gray-300 mb-2">Confirm Password</label>
                    <input type="password" id="confirm_password" name="confirm_password" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                    <i id="check-icon" class="check-icon lucide lucide-check-circle w-5 h-5"></i>
                </div>
                <div>
                    <label for="phone_number" class="block text-sm font-medium text-gray-300 mb-2">Phone Number</label>
                    <input type="text" id="phone_number" name="phone_number" required
                           value="<%= request.getParameter("phone_number") != null ? request.getParameter("phone_number") : "" %>"
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div class="md:col-span-2">
                    <label for="address" class="block text-sm font-medium text-gray-300 mb-2">Address</label>
                    <input type="text" id="address" name="address" required
                           value="<%= request.getParameter("address") != null ? request.getParameter("address") : "" %>"
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
            </div>
            <button type="submit"
                    class="w-full mt-8 bg-primary text-dark py-3 rounded-full btn-primary font-semibold text-lg">
                Register
            </button>
        </form>
        <p class="mt-6 text-center text-gray-400 text-sm">
            Already have an account? <a href="${pageContext.request.contextPath}/views/auth/login.jsp"
                                        class="text-primary hover:underline font-medium">Login here</a>
        </p>
    </div>
</div>

<!-- Footer -->
<footer class="bg-dark/50 py-12 border-t border-white/10">
    <div class="container mx-auto px-4">
        <div class="flex flex-col md:flex-row justify-between items-center">
            <div>
                <h3 class="text-2xl font-bold text-white mb-2">Mega City Cabs</h3>
                <p class="text-gray-400">© <%= java.time.Year.now().getValue() %> All rights reserved</p>
            </div>
            <div class="flex gap-4 mt-4 md:mt-0">
                <a href="#" class="text-primary hover:text-primary-700">
                    <i data-lucide="twitter" class="w-6 h-6"></i>
                </a>
                <a href="#" class="text-primary hover:text-primary-700">
                    <i data-lucide="linkedin" class="w-6 h-6"></i>
                </a>
                <a href="#" class="text-primary hover:text-primary-700">
                    <i data-lucide="github" class="w-6 h-6"></i>
                </a>
            </div>
        </div>
    </div>
</footer>

<script src="https://unpkg.com/lucide@latest"></script>
<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

<script>
    lucide.createIcons();

    document.getElementById('confirm_password').addEventListener('input', function () {
        const password = document.getElementById('password').value;
        const confirmPassword = this.value;
        const confirmPasswordField = document.querySelector('.password-match');
        const checkIcon = document.getElementById('check-icon');

        if (password === confirmPassword && password !== '') {
            confirmPasswordField.classList.add('match');
            confirmPasswordField.classList.remove('border-red-500');
            confirmPasswordField.classList.add('border-green-500');
        } else {
            confirmPasswordField.classList.remove('match');
            confirmPasswordField.classList.add('border-red-500');
            confirmPasswordField.classList.remove('border-green-500');
        }
    });

    window.onload = function () {
        lucide.createIcons();

        var errorMessage = '<%= errorMessage != null ? errorMessage : "" %>';
        var successMessage = '<%= successMessage != null ? successMessage : "" %>';

        if (errorMessage.trim() !== "") {
            Toastify({
                text: errorMessage,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "red" },
                stopOnFocus: true
            }).showToast();
        } else if (successMessage.trim() !== "") {
            Toastify({
                text: successMessage,
                duration: 1500,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "green" },
                stopOnFocus: true,
                callback: function() {
                    window.location.href = "../auth/login.jsp";
                }
            }).showToast();
        }

        <% session.removeAttribute("toastMessage"); %>
        <% session.removeAttribute("toastType"); %>
    };
</script>

</body>
</html>