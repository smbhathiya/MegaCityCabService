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
                        light: '#F5F5F5',
                        accent: '#2A2A2A' // New accent color for cards
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
        a.card {
            display: block;
            text-decoration: none;
            color: inherit;
        }
        .overview-card {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            border: none;
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="bg-dark text-light">

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Customer Dashboard</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-3 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-8 h-8 text-primary"></i>
                        <span class="text-lg text-white font-medium">${userName}</span>
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
<main class="pt-28 pb-12 px-6">
    <div class="container mx-auto">
        <%
            UUID customerUUID = (UUID) session.getAttribute("userId");
            String customerId = customerUUID != null ? customerUUID.toString() : null;
            if (customerId != null) {
        %>
        <!-- Dashboard Overview -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mb-12 animate-slide-up">
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Total Spend</p>
                <p class="text-3xl font-bold text-white">Rs. 8,500</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Active Bookings</p>
                <p class="text-3xl font-bold text-white">2</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Booking Status</p>
                <p class="text-3xl font-bold text-primary">In Progress</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Rating</p>
                <p class="text-3xl font-bold text-white">4.9/5.0</p>
            </div>
        </div>

        <!-- Search Bar -->
        <div class="mb-12 animate-fade-in">
            <div class="relative max-w-2xl mx-auto">
                <input type="text" placeholder="Search bookings..." class="w-full bg-accent rounded-full py-3 px-6 border border-white/10 text-light placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/50">
                <i data-lucide="search" class="absolute right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400"></i>
            </div>
        </div>

        <!-- Cards Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8 mb-12">
            <a href="${pageContext.request.contextPath}/views/customer/profileUpdate.jsp" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="user" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Profile Management</h2>
                </div>
            </a>
            <a href="/book-ride" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="car" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Book a Ride</h2>
                </div>
            </a>
            <a href="/booking-history" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="calendar" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Booking History</h2>
                </div>
            </a>
            <a href="/payment" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="dollar-sign" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Payment & Billing</h2>
                </div>
            </a>
        </div>

        <!-- Customer Support & Help -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-8 mb-12">
            <a href="/support" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="help-circle" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Customer Support</h2>
                </div>
            </a>
            <a href="/feedback" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="star" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Rate Your Driver</h2>
                </div>
            </a>
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
    <!-- Footer (Unchanged) -->
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
<div class="fixed bottom-6 right-6 z-50">
    <button onclick="openSupportModal()" class="bg-primary text-dark p-4 rounded-full shadow-xl btn-primary">
        <i data-lucide="message-circle" class="w-7 h-7"></i>
    </button>
</div>

<!-- Support Modal -->
<div id="support-modal" class="hidden fixed inset-0 bg-dark/90 flex items-center justify-center z-50">
    <div class="bg-accent p-8 rounded-xl shadow-2xl max-w-md w-full">
        <h2 class="text-2xl font-bold text-white mb-4">Customer Support</h2>
        <p class="text-gray-300 mb-6">Need help? Reach out to us at:</p>
        <p class="text-lg text-primary font-semibold mb-6">support@megacitycabs.com</p>
        <button onclick="closeSupportModal()" class="w-full bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Close</button>
    </div>
</div>

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
        fetch('${pageContext.request.contextPath}/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    window.location.href = "../index.jsp";
                } else {
                    alert("Logout failed: " + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert("An unexpected error occurred during logout.");
            });
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