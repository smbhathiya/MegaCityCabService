<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Dashboard</title>
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
                <i data-lucide="car" class="w-8 h-8 text-primary"></i>
                <div>
                    <span class="text-2xl font-bold text-light">Mega City Cabs</span>
                    <p class="text-sm text-light/70">Driver Dashboard</p>
                </div>
            </div>
            <div class="flex items-center gap-4">
                <!-- Profile Dropdown -->
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                        <span class="text-white"><%= session.getAttribute("userName") %></span>
                    </button>
                    <!-- Dropdown Menu -->
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                        <div class="py-1">
                            <a href="#" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Profile</a>
                            <form action="<%= request.getContextPath() %>/Logout" method="get">
                                <button type="submit" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                            </form>
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

        <!-- Dashboard Overview -->
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Total Earnings</p>
                <p class="text-2xl font-bold">Rs. 12,500</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Active Bookings</p>
                <p class="text-2xl font-bold">3</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Vehicle Status</p>
                <p class="text-2xl font-bold text-green-500">Good</p>
            </div>
            <div class="bg-dark/70 rounded-xl border border-light/10 p-4">
                <p class="text-sm text-light/70">Rating</p>
                <p class="text-2xl font-bold">4.8/5.0</p>
            </div>
        </div>

        <!-- Search Bar -->
        <div class="mb-8">
            <input type="text" placeholder="Search bookings..." class="w-full bg-dark/50 rounded-md p-2 border border-light/10">
        </div>

        <!-- Cards Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6 mb-8">
            <a href="/profile" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="user" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Profile Management</h2>
                </div>
            </a>
            <a href="/bookings" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="calendar" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Booking Management</h2>
                </div>
            </a>
            <a href="/ride-tracking" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="map-pin" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Ride Tracking</h2>
                </div>
            </a>
            <a href="/payments" class="card bg-dark/70 rounded-xl border border-light/10 p-6">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="dollar-sign" class="w-10 h-10 text-primary mb-4"></i>
                    <h2 class="text-xl font-bold mb-4">Payments</h2>
                </div>
            </a>
        </div>

        <!-- Performance Graph and Calendar in the same row on large screens -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <!-- Performance Graph -->
            <div class="bg-dark/70 rounded-xl border border-light/10 p-6">
                <h2 class="text-xl font-bold mb-4">Performance</h2>
                <canvas id="performanceChart"></canvas>
            </div>

            <!-- Calendar -->
            <div class="bg-dark/70 rounded-xl border border-light/10 p-6">
                <h2 class="text-xl font-bold mb-4">Schedule</h2>
                <div id="calendar"></div>
            </div>
        </div>
    </div>
</main>

<!-- Support Button -->
<div class="fixed bottom-4 right-4 z-50">
    <button onclick="openSupportModal()" class="bg-primary text-dark p-3 rounded-full shadow-lg hover:bg-primary-700 transition">
        <i data-lucide="message-circle" class="w-6 h-6"></i>
    </button>
</div>

<!-- Support Modal -->
<div id="support-modal" class="hidden fixed inset-0 bg-dark/90 backdrop-blur-md flex items-center justify-center">
    <div class="bg-dark/70 rounded-xl border border-light/10 p-6 w-96">
        <h2 class="text-xl font-bold mb-4">Support</h2>
        <textarea class="w-full bg-dark/50 rounded-md p-2 mb-4" placeholder="Describe your issue..."></textarea>
        <button class="bg-primary text-dark py-2 px-4 rounded-md hover:bg-primary-700 transition">Submit</button>
    </div>
</div>

<script>
    // Initialize Lucide Icons
    lucide.createIcons();

    // Toggle Profile Dropdown
    function toggleProfileDropdown() {
        const dropdown = document.getElementById('profileDropdown');
        dropdown.classList.toggle('hidden');
    }

    // Initialize Performance Chart
    const ctx = document.getElementById('performanceChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
            datasets: [{
                label: 'Earnings',
                data: [5000, 8000, 12000, 9000, 15000],
                borderColor: '#FCC603',
                fill: false
            }]
        }
    });

    // Initialize Calendar
    document.addEventListener('DOMContentLoaded', function() {
        const calendarEl = document.getElementById('calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            events: [
                { title: 'Ride with John', date: '2023-10-15' },
                { title: 'Vehicle Maintenance', date: '2023-10-20' }
            ]
        });
        calendar.render();
    });

    // Support Modal
    function openSupportModal() {
        document.getElementById('support-modal').classList.remove('hidden');
    }
</script>

</body>
</html>