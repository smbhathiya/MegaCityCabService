<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Booking - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
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
        .form-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        input:focus, textarea:focus {
            transition: all 0.3s ease;
        }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Add Booking</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-3 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-8 h-8 text-primary"></i>
                        <span class="text-lg text-white font-medium"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Guest" %></span>
                    </button>
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-56 bg-dark/95 border border-white/10 rounded-xl shadow-lg hidden">
                        <div class="py-2">
                            <a href="${pageContext.request.contextPath}/views/customer/profileUpdate.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Profile</a>
                            <button onclick="showLogoutModal()" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="flex-1 flex items-center justify-center px-6 py-28">
    <div class="container mx-auto">
        <%
            UUID customerUUID = (UUID) session.getAttribute("userId");
            String customerId = customerUUID != null ? customerUUID.toString() : null;
            if (customerId != null) {
        %>
        <div class="form-container p-8 rounded-xl shadow-2xl w-full max-w-lg mx-auto animate-slide-up">
            <h2 class="text-3xl font-bold text-white mb-8 text-center">Book a Ride</h2>
            <form id="bookingForm" onsubmit="submitBooking(event)">
                <div class="mb-6">
                    <label for="pickup_location" class="block text-sm font-medium text-gray-300 mb-2">Pickup Location</label>
                    <input type="text" id="pickup_location" name="pickup_location" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div class="mb-6">
                    <label for="dropoff_location" class="block text-sm font-medium text-gray-300 mb-2">Drop-off Location</label>
                    <input type="text" id="dropoff_location" name="dropoff_location" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div class="mb-6">
                    <label for="hire_date" class="block text-sm font-medium text-gray-300 mb-2">Hire Date</label>
                    <input type="date" id="hire_date" name="hire_date" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <div class="mb-8">
                    <label for="hire_time" class="block text-sm font-medium text-gray-300 mb-2">Hire Time</label>
                    <input type="time" id="hire_time" name="hire_time" required
                           class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
                </div>
                <button type="submit" class="w-full bg-primary text-dark py-3 rounded-full btn-primary font-semibold text-lg">
                    Book Now
                </button>
            </form>
            <p class="mt-6 text-center text-gray-400 text-sm">
                Back to <a href="${pageContext.request.contextPath}/views/customer/dashboard.jsp" class="text-primary hover:underline font-medium">Dashboard</a>
            </p>
        </div>
        <%
            } else {
                Object userIdObj = session.getAttribute("userId");
                if (userIdObj == null || !(userIdObj instanceof UUID)) {
                    response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                    return;
                }
            }
        %>
    </div>
</main>

<!-- Footer -->
<footer class="bg-dark/50 py-12 border-t border-white/10 flex-shrink-0">
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

    // Toggle Profile Dropdown
    function toggleProfileDropdown() {
        document.getElementById('profileDropdown').classList.toggle('hidden');
    }

    // Logout Modal Functions
    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    function cancelLogout() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

    function confirmLogout() {
        fetch('<%= request.getContextPath() %>/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    window.location.href = "../index.jsp";
                } else {
                    Toastify({
                        text: "Logout failed: " + data.message,
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
                console.error('Error:', error);
                Toastify({
                    text: "An unexpected error occurred during logout.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    // Fetch Customer Data and Submit Booking
    document.addEventListener("DOMContentLoaded", function () {
        const customerId = '<%= customerId %>';
        if (customerId) {
            fetchCustomerData(customerId);
        }
    });

    function fetchCustomerData(customerId) {
        fetch(`${'<%= request.getContextPath() %>/customer'}?id=${customerId}`, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status !== "error") {
                    // Customer data fetched successfully, no action needed here unless displaying it
                    console.log("Customer Data:", data);
                } else {
                    Toastify({
                        text: "Failed to fetch customer data: " + data.message,
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
                console.error('Error fetching customer data:', error);
                Toastify({
                    text: "Error fetching customer data.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    function submitBooking(event) {
        event.preventDefault();

        const customerId = '<%= customerId %>';
        const formData = {
            customer_id: customerId,
            pickup_location: document.getElementById('pickup_location').value,
            dropoff_location: document.getElementById('dropoff_location').value,
            hire_date: document.getElementById('hire_date').value,
            hire_time: document.getElementById('hire_time').value
        };

        fetch('<%= request.getContextPath() %>/booking', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    Toastify({
                        text: "Booking created successfully!",
                        duration: 1500,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "green" },
                        stopOnFocus: true
                    }).showToast();
                    setTimeout(() => window.location.href = "<%= request.getContextPath() %>/views/customer/dashboard.jsp", 1500);
                } else {
                    Toastify({
                        text: "Booking failed: " + data.message,
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
                console.error('Error:', error);
                Toastify({
                    text: "An error occurred while booking. Please try again.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }
</script>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50">
    <div class="bg-accent p-6 rounded-xl shadow-2xl">
        <h3 class="text-xl font-bold text-white mb-4">Confirm Logout</h3>
        <p class="text-gray-300 mb-6">Are you sure you want to logout?</p>
        <div class="flex gap-4 justify-end">
            <button onclick="confirmLogout()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 transition font-semibold">No</button>
        </div>
    </div>
</div>

</body>
</html>