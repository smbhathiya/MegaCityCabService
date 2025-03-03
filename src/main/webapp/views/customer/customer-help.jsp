<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Help - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
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
                        fadeIn: { '0%': { opacity: '0' }, '100%': { opacity: '1' } },
                        slideUp: { '0%': { transform: 'translateY(20px)', opacity: '0' }, '100%': { transform: 'translateY(0)', opacity: '1' } }
                    }
                }
            }
        };
    </script>
    <style>
        body { background-color: #1A1A1A; font-family: 'Inter', sans-serif; }
        .card { background-color: #2A2A2A; border-radius: 1rem; padding: 1.5rem; }
        .btn-primary { transition: transform 0.2s ease, background-color 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); }
    </style>
</head>
<body class="bg-dark text-light">
<%
    UUID userUUID = (UUID) session.getAttribute("userId");
    String userId = userUUID != null ? userUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (userId == null || !"customer".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }
%>
<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary animate-pulse-slow"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Customer Help</p>
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
                            <a href="#" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Profile</a>
                            <button onclick="showLogoutModal()" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="pt-28 pb-12 px-6">
    <div class="container mx-auto">
        <h1 class="text-4xl font-bold text-white mb-8 text-center">Customer Help Center</h1>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Booking a Ride</h2>
            <p class="text-light/80">To book a cab:</p>
            <ul class="list-disc list-inside text-light/80">
                <li>Log in to your customer dashboard.</li>
                <li>Enter your pickup and drop-off locations, date, and time.</li>
                <li>Select a vehicle and confirm the booking.</li>
                <li>Track your driver in real-time.</li>
            </ul>
        </div>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Making Payments</h2>
            <p class="text-light/80">Payment options:</p>
            <ul class="list-disc list-inside text-light/80">
                <li>Choose from credit card, cash, or online wallet at booking.</li>
                <li>Payments are processed after the trip ends.</li>
                <li>View your payment history in the dashboard.</li>
            </ul>
        </div>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Cancelling a Booking</h2>
            <p class="text-light/80">To cancel:</p>
            <ul class="list-disc list-inside text-light/80">
                <li>Go to your active bookings in the dashboard.</li>
                <li>Select the booking and click "Cancel".</li>
                <li>Note: Cancellation fees may apply based on timing.</li>
            </ul>
        </div>

        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">Need More Help?</h2>
            <p class="text-light/80">Contact Mega City Cabs support:</p>
            <ul class="list-disc list-inside text-light/80">
                <li>Email: <a href="mailto:support@megacitycabs.com" class="text-primary hover:text-primary-700">support@megacitycabs.com</a></li>
                <li>Phone: <span class="text-primary">+1-800-CAB-HELP</span></li>
            </ul>
        </div>
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
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="twitter" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="linkedin" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="github" class="w-6 h-6"></i></a>
            </div>
        </div>
    </div>
</footer>

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
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    window.location.href = "../index.jsp";
                } else {
                    Toastify({ text: "Logout failed: " + data.message, duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Toastify({ text: "An unexpected error occurred during logout.", duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
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