<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">

<!-- Navbar (Aligned with Customer/Admin Dashboard) -->
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
        <form onsubmit="loginUser(event)">
            <div class="mb-6">
                <label for="email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
                <input type="email" id="email" name="email"
                       class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary"
                       required>
            </div>
            <div class="mb-8">
                <label for="password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
                <input type="password" id="password" name="password"
                       class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary"
                       required>
            </div>
            <button type="submit"
                    class="w-full bg-primary text-black py-3 rounded-full btn-primary font-semibold text-lg">
                Login
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

    function loginUser(event) {
        event.preventDefault();

        let email = document.getElementById("email").value;
        let password = document.getElementById("password").value;

        fetch("${pageContext.request.contextPath}/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    Toastify({
                        text: data.message,
                        duration: 1000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "green" },
                        stopOnFocus: true
                    }).showToast();

                    let redirectURL = "";
                    if (data.role === "admin") {
                        redirectURL = "../admin/dashboard.jsp";
                    } else if (data.role === "driver") {
                        redirectURL = "../driver/dashboard.jsp";
                    } else if (data.role === "customer") {
                        redirectURL = "../customer/dashboard.jsp";
                    } else {
                        redirectURL = "../index.jsp";
                    }

                    setTimeout(() => window.location.href = redirectURL, 1000);
                } else {
                    Toastify({
                        text: "Login Failed: " + data.message,
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" },
                        stopOnFocus: true
                    }).showToast();
                }
            })
            .catch(error => {
                console.error("Fetch Error:", error);
                Toastify({
                    text: "Something went wrong.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    window.onload = function () {
        lucide.createIcons();

        var toastMessage = '<%= session.getAttribute("toastMessage") != null ? session.getAttribute("toastMessage") : "" %>';
        var toastType = '<%= session.getAttribute("toastType") != null ? session.getAttribute("toastType") : "" %>';
        var redirectURL = '<%= session.getAttribute("redirectURL") != null ? session.getAttribute("redirectURL") : "" %>';

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

            if (toastType.trim().toLowerCase() === "success" && redirectURL.trim() !== "") {
                setTimeout(() => window.location.href = redirectURL, 3500);
            }
        }

        <% session.removeAttribute("toastMessage"); %>
        <% session.removeAttribute("toastType"); %>
        <% session.removeAttribute("redirectURL"); %>
    };
</script>

</body>
</html>