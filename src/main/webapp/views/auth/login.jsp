<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.UserDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.User" %>
<%@ page import="com.cabservice.megacitycabservice.util.PasswordUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Mega City Cabs</title>
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
    <style>
        body {
            background-color: #1A1A1A;
            font-family: 'Inter', sans-serif;
        }
        .login-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        input:focus {
            transition: all 0.3s ease;
        }
        .spinner {
            display: inline-block;
            width: 1.5rem;
            height: 1.5rem;
            border: 3px solid rgba(255, 255, 255, 0.3);
            border-radius: 50%;
            border-top-color: #fff;
            animation: spin 1s ease-in-out infinite;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">
<%
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String errorMessage = null;

    if (email != null && password != null) {
        UserDAO userDAO = new UserDAO();
        try {
            User user = userDAO.getUserByEmail(email);
            if (user != null && PasswordUtil.checkPassword(password, user.getPassword())) {
                // Invalidate old session if exists
                if (session != null) {
                    session.invalidate();
                }
                session = request.getSession(true);
                session.setAttribute("sessionId", UUID.randomUUID().toString());
                session.setAttribute("userId", user.getId());
                session.setAttribute("userName", user.getName());
                session.setAttribute("userEmail", user.getEmail());
                session.setAttribute("role", user.getRole());
                session.setMaxInactiveInterval(30 * 60);

                // Set session cookie
                Cookie sessionCookie = new Cookie("sessionId", session.getId());
                sessionCookie.setHttpOnly(true);
                sessionCookie.setSecure(true);
                sessionCookie.setPath("/");
                sessionCookie.setMaxAge(30 * 60);
                response.addCookie(sessionCookie);

                String redirectURL;
                if ("admin".equals(user.getRole())) {
                    redirectURL = request.getContextPath() + "/views/admin/dashboard.jsp";
                } else if ("driver".equals(user.getRole())) {
                    redirectURL = request.getContextPath() + "/views/driver/dashboard.jsp";
                } else if ("customer".equals(user.getRole())) {
                    redirectURL = request.getContextPath() + "/views/customer/dashboard.jsp";
                } else {
                    redirectURL = request.getContextPath() + "/index.jsp";
                }
                response.sendRedirect(redirectURL);
                return;
            } else {
                errorMessage = "Invalid email or password.";
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "An internal server error occurred.";
        }
    }
%>

<!-- Navbar (Unchanged) -->
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
                <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                   class="px-6 py-2 border border-primary text-primary rounded-full hover:bg-primary/10 transition flex items-center gap-2 text-lg">
                    <i data-lucide="user-plus" class="w-5 h-5"></i>
                    Register
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="flex-1 flex items-center justify-center px-6 py-28">
    <div class="login-container p-8 rounded-xl shadow-2xl w-full max-w-md animate-slide-up">
        <h2 class="text-3xl font-bold text-white mb-8 text-center">Login</h2>
        <form method="post" action="<%= request.getContextPath() %>/views/auth/login.jsp">
            <div class="mb-6">
                <label for="email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
                <input type="email" id="email" name="email"
                       class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary"
                       value="<%= email != null ? email : "" %>" required>
            </div>
            <div class="mb-8">
                <label for="password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
                <input type="password" id="password" name="password"
                       class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary"
                       required>
            </div>
            <button type="submit" id="loginButton"
                    class="w-full bg-primary text-black py-3 rounded-full btn-primary font-semibold text-lg flex items-center justify-center">
                <span id="buttonText">Login</span>
                <span id="loadingSpinner" class="spinner hidden"></span>
            </button>
        </form>
        <p class="mt-6 text-center text-gray-400 text-sm">
            Don't have an account? <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                                      class="text-primary hover:underline">Register here</a>
        </p>
    </div>
</div>

<!-- Footer (Unchanged) -->
<footer class="bg-dark/50 py-6 border-t border-white/10 flex-shrink-0">
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
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

<script>
    lucide.createIcons();

    window.onload = function () {
        lucide.createIcons();

        var toastMessage = '<%= errorMessage != null ? errorMessage : "" %>';
        var toastType = '<%= errorMessage != null ? "error" : "" %>';

        if (toastMessage.trim() !== "") {
            Toastify({
                text: toastMessage,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: toastType.trim().toLowerCase() === "success" ? "green" : "red" },
                stopOnFocus: true
            }).showToast();
        }
    };
</script>

</body>
</html>