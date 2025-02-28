<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        #calendar {
            color: #F5F5F5;
        }
        .fc-daygrid-event {
            white-space: normal !important;
            padding: 2px 4px;
        }
    </style>
</head>
<body class="bg-dark text-light">
<%
    UUID adminUUID = (UUID) session.getAttribute("userId");
    String adminId = adminUUID != null ? adminUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (adminId == null || !"admin".equals(role)) {
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
                        <p class="text-sm text-light/70">Admin Dashboard</p>
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
        <!-- Dashboard Overview -->
        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-6 mb-12 animate-slide-up">
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Total Cars</p>
                <p id="totalCars" class="text-3xl font-bold text-white">0</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Total Drivers</p>
                <p id="totalDrivers" class="text-3xl font-bold text-white">0</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Active Bookings</p>
                <p id="activeBookings" class="text-3xl font-bold text-white">0</p>
            </div>
            <div class="overview-card rounded-xl p-6">
                <p class="text-sm text-light/70 mb-2">Total Revenue</p>
                <p id="totalRevenue" class="text-3xl font-bold text-white">Rs. 0</p>
                <p id="systemProfit" class="text-sm text-light/70 mt-1">System Profit: Rs. 0</p>
            </div>
        </div>

        <!-- Cards Grid -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
            <a href="${pageContext.request.contextPath}/views/admin/manageCars.jsp" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="car" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Manage Cars</h2>
                </div>
            </a>
            <a href="${pageContext.request.contextPath}/views/admin/manageDrivers.jsp" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="users" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Manage Drivers</h2>
                </div>
            </a>
            <a href="#" class="card p-8 animate-slide-up">
                <div class="flex flex-col items-center text-center">
                    <i data-lucide="bar-chart" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">View Reports</h2>
                </div>
            </a>
        </div>

        <!-- Performance Graph and Calendar -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
            <!-- Performance Graph -->
            <div class="card p-6 animate-slide-up">
                <h2 class="text-2xl font-bold text-white mb-6">Last 30 Days Revenue</h2>
                <canvas id="performanceChart"></canvas>
            </div>
            <!-- Calendar -->
            <div class="card p-6 animate-slide-up">
                <h2 class="text-2xl font-bold text-white mb-6">Booking Schedule</h2>
                <div id="calendar"></div>
            </div>
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
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
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

    // Fetch and update Dashboard Overview
    function fetchDashboardStats() {
        // Fetch Total Cars
        fetch('<%= request.getContextPath() %>/admin/vehicles/count', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                return response.json();
            })
            .then(data => {
                console.log('Total cars response:', JSON.stringify(data, null, 2));
                if (data.status === 'success') {
                    document.getElementById('totalCars').textContent = data.data;
                } else {
                    console.error('Total cars API error:', data.data || data.message || 'No error message provided');
                    document.getElementById('totalCars').textContent = 'Error';
                    Toastify({
                        text: "Failed to load total cars: " + (data.data || data.message || 'Unknown error'),
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error fetching total cars:', error);
                document.getElementById('totalCars').textContent = 'Error';
                Toastify({
                    text: "Error fetching total cars: " + error.message,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            })
            .then(() => {
                // Fetch Total Drivers
                fetch('<%= request.getContextPath() %>/admin/drivers/count', {
                    method: 'GET',
                    headers: { 'Content-Type': 'application/json' },
                    credentials: 'include'
                })
                    .then(response => {
                        if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                        return response.json();
                    })
                    .then(data => {
                        console.log('Total drivers response:', JSON.stringify(data, null, 2));
                        if (data.status === 'success') {
                            document.getElementById('totalDrivers').textContent = data.data;
                        } else {
                            console.error('Total drivers API error:', data.data || data.message || 'No error message provided');
                            document.getElementById('totalDrivers').textContent = 'Error';
                            Toastify({
                                text: "Failed to load total drivers: " + (data.data || data.message || 'Unknown error'),
                                duration: 3000,
                                close: true,
                                gravity: "top",
                                position: "right",
                                style: { background: "red" }
                            }).showToast();
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching total drivers:', error);
                        document.getElementById('totalDrivers').textContent = 'Error';
                        Toastify({
                            text: "Error fetching total drivers: " + error.message,
                            duration: 3000,
                            close: true,
                            gravity: "top",
                            position: "right",
                            style: { background: "red" }
                        }).showToast();
                    })
                    .then(() => {
                        // Fetch Payments for Total Revenue
                        fetch('<%= request.getContextPath() %>/admin/payments/history', {
                            method: 'GET',
                            headers: { 'Content-Type': 'application/json' },
                            credentials: 'include'
                        })
                            .then(response => {
                                if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                                return response.json();
                            })
                            .then(data => {
                                console.log('Payment history response:', JSON.stringify(data, null, 2));
                                if (data.status === 'success' && Array.isArray(data.data)) {
                                    const payments = data.data;
                                    const totalRevenue = payments.reduce((sum, payment) => sum + (payment.amount || 0), 0) / 0.7; // Reverse 70% driver share
                                    const systemProfit = totalRevenue * 0.3; // 30% system profit
                                    console.log('Total Revenue:', totalRevenue, 'System Profit:', systemProfit);
                                    document.getElementById('totalRevenue').textContent = "Rs. "+totalRevenue.toFixed(2);
                                    document.getElementById('systemProfit').textContent = "Profit: Rs. "+systemProfit.toFixed(2);
                                } else {
                                    console.error('Payment history API error:', data.data || data.message || 'No error message provided');
                                    document.getElementById('totalRevenue').textContent = 'Error';
                                    document.getElementById('systemProfit').textContent = 'System Profit: Error';
                                    Toastify({
                                        text: "Failed to load revenue: " + (data.data || data.message || 'Unknown error'),
                                        duration: 3000,
                                        close: true,
                                        gravity: "top",
                                        position: "right",
                                        style: { background: "red" }
                                    }).showToast();
                                }
                            })
                            .catch(error => {
                                console.error('Error fetching payment history:', error);
                                document.getElementById('totalRevenue').textContent = 'Error';
                                document.getElementById('systemProfit').textContent = 'System Profit: Error';
                                Toastify({
                                    text: "Error fetching revenue: " + error.message,
                                    duration: 3000,
                                    close: true,
                                    gravity: "top",
                                    position: "right",
                                    style: { background: "red" }
                                }).showToast();
                            })
                            .then(() => {
                                // Fetch Bookings for Active Bookings
                                fetch('<%= request.getContextPath() %>/admin/bookings', {
                                    method: 'GET',
                                    headers: { 'Content-Type': 'application/json' },
                                    credentials: 'include'
                                })
                                    .then(response => {
                                        if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                                        return response.json();
                                    })
                                    .then(data => {
                                        console.log('Bookings response for overview:', JSON.stringify(data, null, 2));
                                        if (data.status === 'success' && Array.isArray(data.data)) {
                                            const bookings = data.data;
                                            const activeCount = bookings.filter(booking => booking.bookingStatus === 'confirmed').length;
                                            console.log('Active Bookings Count:', activeCount);
                                            document.getElementById('activeBookings').textContent = activeCount;
                                        } else {
                                            console.error('Bookings API error for overview:', data.data || data.message || 'No error message provided');
                                            document.getElementById('activeBookings').textContent = 'Error';
                                            Toastify({
                                                text: "Failed to load active bookings: " + (data.data || data.message || 'Unknown error'),
                                                duration: 3000,
                                                close: true,
                                                gravity: "top",
                                                position: "right",
                                                style: { background: "red" }
                                            }).showToast();
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error fetching bookings for overview:', error);
                                        document.getElementById('activeBookings').textContent = 'Error';
                                        Toastify({
                                            text: "Error fetching active bookings: " + error.message,
                                            duration: 3000,
                                            close: true,
                                            gravity: "top",
                                            position: "right",
                                            style: { background: "red" }
                                        }).showToast();
                                    });
                            });
                    });
            });
    }

    // Fetch and populate Performance Chart (Last 30 Days)
    function fetchEarningsData() {
        fetch('<%= request.getContextPath() %>/admin/payments/history', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                return response.json();
            })
            .then(data => {
                console.log('Payment history response for chart:', JSON.stringify(data, null, 2));
                if (data.status === 'success' && Array.isArray(data.data)) {
                    const payments = data.data;
                    const now = new Date();
                    const thirtyDaysAgo = new Date(now);
                    thirtyDaysAgo.setDate(now.getDate() - 30);

                    const dailyEarnings = {};
                    payments.forEach(payment => {
                        const paymentDate = new Date(payment.paymentDate);
                        if (paymentDate >= thirtyDaysAgo && paymentDate <= now) {
                            const dateKey = paymentDate.toISOString().split('T')[0];
                            dailyEarnings[dateKey] = (dailyEarnings[dateKey] || 0) + (payment.amount || 0) / 0.7;
                        }
                    });

                    const labels = [];
                    const earnings = [];
                    for (let i = 0; i <= 30; i++) {
                        const date = new Date(now);
                        date.setDate(now.getDate() - i);
                        const dateKey = date.toISOString().split('T')[0];
                        labels.push(date.toLocaleDateString('default', { day: 'numeric', month: 'short' }));
                        earnings.push(dailyEarnings[dateKey] || 0);
                    }

                    labels.reverse();
                    earnings.reverse();

                    console.log('Chart labels:', labels);
                    console.log('Chart earnings:', earnings);

                    const ctx = document.getElementById('performanceChart').getContext('2d');
                    new Chart(ctx, {
                        type: 'line',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: 'Revenue (Last 30 Days)',
                                data: earnings,
                                borderColor: '#FCC603',
                                backgroundColor: 'rgba(252, 198, 3, 0.2)',
                                fill: true,
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    grid: { color: 'rgba(255, 255, 255, 0.1)' },
                                    ticks: { color: '#F5F5F5' }
                                },
                                x: {
                                    grid: { display: false },
                                    ticks: { color: '#F5F5F5', maxRotation: 45, minRotation: 45 }
                                }
                            },
                            plugins: {
                                legend: { labels: { color: '#F5F5F5' } }
                            }
                        }
                    });
                } else {
                    console.error('Payment history API error for chart:', data.data || data.message || 'No error message');
                    Toastify({
                        text: "Failed to load revenue data: " + (data.data || data.message || 'Unknown error'),
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error fetching payment history for chart:', error);
                Toastify({
                    text: "Error fetching revenue data: " + error.message,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            });
    }

    // Fetch and populate Calendar
    function fetchBookingData() {
        fetch('<%= request.getContextPath() %>/admin/bookings', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => {
                if (!response.ok) throw new Error('Network response was not ok: ' + response.statusText);
                return response.json();
            })
            .then(data => {
                console.log('Bookings response for calendar:', JSON.stringify(data, null, 2));
                if (data.status === 'success' && Array.isArray(data.data)) {
                    const bookings = data.data;
                    const events = bookings.map(booking => ({
                        title: booking.bookingNumber,
                        start: booking.hireDate,
                        allDay: true,
                        backgroundColor: '#FCC603',
                        borderColor: '#CC9F02',
                        textColor: '#1A1A1A'
                    }));

                    console.log('Calendar events:', events);

                    const calendarEl = document.getElementById('calendar');
                    const calendar = new FullCalendar.Calendar(calendarEl, {
                        initialView: 'dayGridMonth',
                        height: 'auto',
                        events: events,
                        headerToolbar: {
                            left: 'prev,next',
                            center: 'title',
                            right: 'today'
                        },
                        themeSystem: 'standard',
                        dayMaxEvents: true,
                        eventClick: function(info) {
                            alert('Booking ID: ' + info.event.title);
                        },
                        eventContent: function(arg) {
                            return { html: '<div>' + arg.event.title + '</div>' };
                        }
                    });
                    calendar.render();
                } else {
                    console.error('Bookings API error for calendar:', data.data || data.message || 'No error message provided');
                    Toastify({
                        text: "Failed to load bookings: " + (data.data || data.message || 'Unknown error'),
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error fetching bookings for calendar:', error);
                Toastify({
                    text: "Error fetching bookings: " + error.message,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            });
    }

    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function () {
        fetchDashboardStats();
        fetchEarningsData();
        fetchBookingData();
    });
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