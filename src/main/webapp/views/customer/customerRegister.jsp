<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Mega City Cabs</title>
    <!-- Tailwind CSS -->
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
                        light: '#F5F5F5'
                    }
                }
            }
        };
    </script>
    <!-- Toastify CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        .background {
            background-size: cover;
            background-position: center;
            position: absolute;
            inset: 0;
            width: 100%;
        }

        .password-match .check-icon {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            display: none;
            color: green;
        }

        .password-match.match .check-icon {
            display: inline-block;
        }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">
<!-- Navbar -->
<nav class=" top-0 left-0 right-0  bg-dark">
    <div class="container mx-auto px-6 py-3">
        <div class="flex h-16 items-center justify-between">
            <div class="flex items-center gap-2">
                <a href="../index.jsp" class="flex items-center gap-2">
                    <i data-lucide="car" class="w-6 h-6 sm:w-8 sm:h-8 text-primary"></i>
                    <span class="text-xl sm:text-2xl font-bold text-white">Mega City Cabs</span>
                </a>
            </div>
            <div class="flex items-center gap-4">
                <a href="${pageContext.request.contextPath}/views/auth/login.jsp"
                   class="px-4 py-2 bg-primary text-black rounded-lg flex items-center gap-2 transition font-semibold">
                    <i data-lucide="log-in" class="w-5 h-5"></i>
                    Login
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- Registration Form -->
<div class="flex-1 flex items-center justify-center px-4">
    <div class="bg-dark/50 p-8 rounded-lg shadow-lg border border-white/10 w-full max-w-2xl relative z-10 mb-8">
        <h2 class="text-3xl font-bold text-center mb-6">Registration</h2>
        <form id="registrationForm" onsubmit="handleRegistration(event)">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <!-- Form Fields -->
                <div>
                    <label for="name" class="block text-sm font-medium mb-2">Full Name</label>
                    <input type="text" id="name" name="name" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                </div>
                <div>
                    <label for="email" class="block text-sm font-medium mb-2">Email</label>
                    <input type="email" id="email" name="email" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                </div>
                <div>
                    <label for="password" class="block text-sm font-medium mb-2">Password</label>
                    <input type="password" id="password" name="password" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                </div>
                <div class="password-match">
                    <label for="confirm_password" class="block text-sm font-medium mb-2">Confirm Password</label>
                    <input type="password" id="confirm_password" name="confirm_password" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                    <i id="check-icon" class="check-icon lucide lucide-check-circle"></i>
                </div>
                <div>
                    <label for="phone_number" class="block text-sm font-medium mb-2">Phone Number</label>
                    <input type="text" id="phone_number" name="phone_number" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                </div>
                <div class="md:col-span-2">
                    <label for="address" class="block text-sm font-medium mb-2">Address</label>
                    <input type="text" id="address" name="address" required
                           class="w-full px-3 py-2 bg-dark/30 border border-white/20 rounded-md text-white placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none">
                </div>
            </div>
            <button type="submit"
                    class="w-full mt-6 bg-primary text-dark py-3 rounded-md font-semibold hover:bg-primary-700 transition">
                Register
            </button>
        </form>
        <p class="mt-4 text-center text-gray-400">
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
    window.onload = function () {
        lucide.createIcons();

        var toastMessage = '<%= session.getAttribute("toastMessage") != null ? session.getAttribute("toastMessage") : "" %>';
        var toastType = '<%= session.getAttribute("toastType") != null ? session.getAttribute("toastType") : "" %>';

        if (toastMessage !== "") {
            Toastify({
                text: toastMessage,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: toastType === "success" ? "green" : "red",
                stopOnFocus: true
            }).showToast();

            if (toastType === "success") {
                setTimeout(function () {
                    window.location.href = "../auth/login.jsp";
                }, 3500);
            }

            <% session.removeAttribute("toastMessage"); %>
            <% session.removeAttribute("toastType"); %>
        }
    };

    function handleRegistration(event) {
        event.preventDefault();

        const formData = {
            name: document.getElementById('name').value,
            email: document.getElementById('email').value,
            is_enabled: true,
            contact_no: document.getElementById('phone_number').value,
            address: document.getElementById('address').value,
            password: document.getElementById('password').value,
        };

        fetch('${pageContext.request.contextPath}/customer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(formData)
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    Toastify({
                        text: "Registration successful",
                        duration: 1500,
                        close: true,
                        gravity: "top",
                        position: "right",
                        backgroundColor: "green",
                        stopOnFocus: true
                    }).showToast();

                    setTimeout(() => {
                        window.location.href = "../auth/login.jsp";
                    }, 3500);
                } else {
                    Toastify({
                        text: data.message || "Registration failed!",
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        backgroundColor: "red",
                        stopOnFocus: true
                    }).showToast();
                }
            })
                .catch(error => {
                console.error('Error:', error);
                Toastify({
                    text: "An error occurred. Please try again.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    backgroundColor: "red",
                    stopOnFocus: true
                }).showToast();
            });
    }

    // Password Confirmation Check Script
    document.getElementById('confirm_password').addEventListener('input', function () {
        var password = document.getElementById('password').value;
        var confirmPassword = document.getElementById('confirm_password').value;
        var confirmPasswordField = document.getElementById('confirm_password');
        var checkIcon = document.getElementById('check-icon');

        if (password === confirmPassword) {
            confirmPasswordField.classList.remove('border-red-500');
            confirmPasswordField.classList.add('border-green-500');
            checkIcon.style.display = 'inline-block';
        } else {
            confirmPasswordField.classList.remove('border-green-500');
            confirmPasswordField.classList.add('border-red-500');
            checkIcon.style.display = 'none';
        }
    });
</script>
</body>
</html>
