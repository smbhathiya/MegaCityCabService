<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
    <style>
        .card {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
        }
        a.card {
            display: block;
            text-decoration: none;
            color: inherit;
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
                        <p class="text-sm text-light/70">Customer Dashboard</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-4">
                <!-- Profile Dropdown -->
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                        <span class="text-white">${userName}</span>
                    </button>
                    <!-- Dropdown Menu -->
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                        <div class="py-1">
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
<main class="pt-24 pb-8 px-4 sm:px-6">
    <div class="container mx-auto">
        <%
            UUID customerUUID = (UUID) session.getAttribute("userId");
            String customerId = customerUUID != null ? customerUUID.toString() : null;
            if (customerId != null) {
        %>
        <!-- Dashboard Overview -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Total Spend</p>
                <p class="text-2xl font-bold">Rs. 8,500</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Active Bookings</p>
                <p class="text-2xl font-bold">2</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Booking Status</p>
                <p class="text-2xl font-bold text-yellow-500">In Progress</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Rating</p>
                <p class="text-2xl font-bold">4.9/5.0</p>
            </div>
        </div>

        <!-- Search Bar -->
        <div class="mb-8">
            <input type="text" placeholder="Search bookings..." class="w-full bg-dark/50 rounded-md p-2 border border-light/10">
        </div>

        <!-- Cards Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
            <a href="${pageContext.request.contextPath}/views/customer/profileUpdate.jsp" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="user" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Profile Management</h2>
                </div>
            </a>
            <a href="/book-ride" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="car" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Book a Ride</h2>
                </div>
            </a>
            <a href="/booking-history" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="calendar" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Booking History</h2>
                </div>
            </a>
            <a href="/payment" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="dollar-sign" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Payment & Billing</h2>
                </div>
            </a>
        </div>

        <!-- Customer Support & Help -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-8">
            <a href="/support" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="help-circle" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Customer Support</h2>
                </div>
            </a>
            <a href="/feedback" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="star" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Rate Your Driver</h2>
                </div>
            </a>
        </div>
        <%
        } else {
        %>
        <div class="text-light mt-16 mb-24">
            <div>Please log in to access the dashboard</div>
            <div class="flex ">
                <a href="../auth/login.jsp" class="bg-white text-dark text-dark px-2 pr-2 p-1 rounded-md hover:bg-white/50 transition justify-center items-center mt-2">Login</a>
            </div>
        </div>
        <%
            }
        %>
    </div>
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
</main>

<!-- Support Button -->
<div class="fixed bottom-4 right-4 z-50">
    <button onclick="openSupportModal()" class="bg-primary text-dark p-3 rounded-full shadow-lg hover:bg-primary-700 transition">
        <i data-lucide="message-circle" class="w-6 h-6"></i>
    </button>
</div>

<!-- Support Modal -->
<div id="support-modal" class="hidden fixed inset-0 bg-dark/80 flex items-center justify-center z-50">
    <div class="bg-dark/90 p-6 rounded-lg">
        <h2 class="text-xl font-bold mb-4">Customer Support</h2>
        <p class="mb-4">If you need assistance, please contact us at:</p>
        <p class="text-light">support@megacitycabs.com</p>
        <button onclick="closeSupportModal()" class="mt-4 bg-primary text-dark px-4 py-2 rounded">Close</button>
    </div>
</div>

<script>
    // Initialize Lucide Icons
    lucide.createIcons();
    function toggleProfileDropdown() {
        const dropdown = document.getElementById('profileDropdown');
        dropdown.classList.toggle('hidden');
    }

    function showLogoutModal() {
        // Implement logout modal logic
    }

    function openSupportModal() {
        document.getElementById('support-modal').classList.remove('hidden');
    }

    function closeSupportModal() {
        document.getElementById('support-modal').classList.add('hidden');
    }
</script>

</body>
</html>
