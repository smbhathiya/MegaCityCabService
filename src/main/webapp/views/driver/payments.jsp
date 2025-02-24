<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Payments - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://unpkg.com/toastify-js/src/toastify.css">
    <script src="https://unpkg.com/toastify-js"></script>
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
        .card {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            background-color: #2A2A2A;
            border-radius: 1rem;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        }
        .overview-card {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            border: none;
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
            color: #F5F5F5;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            color: #F5F5F5;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        th {
            background-color: #2A2A2A;
            font-weight: bold;
        }
        tr:hover {
            background-color: rgba(255, 255, 255, 0.05);
        }
        .main-content {
            padding-top: 100px;
        }
    </style>
</head>
<body class="bg-dark text-light">

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/90 backdrop-blur-md z-50">
    <div class="container mx-auto px-4 sm:px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-3">
                <a href="../index.jsp" class="flex items-center gap-2">
                    <i data-lucide="car" class="w-8 h-8 text-primary"></i>
                    <div>
                        <span class="text-2xl font-bold text-light">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Payments</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-4">
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                        <span class="text-white"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Guest" %></span>
                    </button>
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                        <div class="py-1">
                            <a href="${pageContext.request.contextPath}/views/driver/dashboard.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Dashboard</a>
                            <button onclick="showLogoutModal()" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<div class="container mx-auto px-4 main-content min-h-screen">
    <%
        UUID driverUUID = (UUID) session.getAttribute("userId");
        String driverId = driverUUID != null ? driverUUID.toString() : null;
        if (driverId != null) {
    %>
    <h2 class="text-3xl font-bold text-white mb-8">Payment Management</h2>

    <!-- Payment Overview Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-12 animate-slide-up">
        <div class="overview-card rounded-xl p-6">
            <p class="text-sm text-light/70 mb-2">Total Payments Received</p>
            <p class="text-3xl font-bold text-white">Rs. 0.00</p> <!-- Placeholder, to be computed -->
        </div>
        <div class="overview-card rounded-xl p-6">
            <p class="text-sm text-light/70 mb-2">Payments to Receive (Confirmed Rides)</p>
            <p class="text-3xl font-bold text-white">Rs. 0.00</p> <!-- Placeholder, to be computed -->
        </div>
    </div>

    <!-- Confirmed Bookings Table -->
    <div class="card p-6 animate-slide-up mb-8">
        <h3 class="text-2xl font-semibold text-white mb-4">Confirmed Bookings</h3>
        <table id="confirmedBookingsTable">
            <thead>
            <tr>
                <th>Booking Number</th>
                <th>Pickup Location</th>
                <th>Drop-off Location</th>
                <th>Hire Date</th>
                <th>Total Fare</th>
                <th>Payment Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody id="confirmedBookingsBody">
            <!-- To be populated dynamically -->
            </tbody>
        </table>
    </div>

    <!-- Payments History Table -->
    <div class="card p-6 animate-slide-up">
        <h3 class="text-2xl font-semibold text-white mb-4">Payments History</h3>
        <table id="paymentsHistoryTable">
            <thead>
            <tr>
                <th>Booking Number</th>
                <th>Payment Date</th>
                <th>Amount</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody id="paymentsHistoryBody">
            <!-- To be populated dynamically -->
            </tbody>
        </table>
    </div>
    <%
        } else {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }
    %>
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

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="bg-dark p-4 rounded-lg">
        <h3 class="text-lg font-bold text-white">Confirm Logout</h3>
        <p class="text-gray-400">Are you sure you want to logout?</p>
        <div class="mt-4">
            <button onclick="confirmLogout()" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700 btn-primary">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500 ml-2">No</button>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();

    function toggleProfileDropdown() {
        document.getElementById('profileDropdown').classList.toggle('hidden');
    }

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
                    text: 'An unexpected error occurred during logout.',
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

</body>
</html>