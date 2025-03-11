<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.BookingDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.ArrayList" %>
<%
    UUID customerUUID = (UUID) session.getAttribute("userId");
    String customerId = customerUUID != null ? customerUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (customerId == null || !"customer".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> bookings = null;
    String errorMessage = null;

    try {
        bookings = bookingDAO.getBookingsByCustomerId(customerId);
    } catch (Exception e) {
        errorMessage = "Error fetching booking history: " + e.getMessage();
    }

    Gson gson = new Gson();
    String bookingsJson = gson.toJson(bookings != null ? bookings : new ArrayList<>());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking History - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        primary: { DEFAULT: '#FCC603', 700: '#CC9F02' },
                        dark: '#1A1A1A',
                        light: '#F5F5F5',
                        accent: '#2A2A2A'
                    },
                    animation: { 'slide-up': 'slideUp 0.5s ease-out' },
                    keyframes: {
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
        body { background-color: #1A1A1A; font-family: 'Inter', sans-serif; }
        .table-container { background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8)); backdrop-filter: blur(10px); }
        .btn-primary { transition: transform 0.2s ease, background-color 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); }
        table { background-color: #2A2A2A; }
        th { background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8)); }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/90 backdrop-blur-md z-50">
    <div class="container mx-auto px-4 py-4 flex items-center justify-between">
        <a href="../index.jsp" class="flex items-center gap-2">
            <i data-lucide="car" class="w-8 h-8 text-primary"></i>
            <span class="text-2xl font-bold text-light">Mega City Cabs</span>
        </a>
        <div class="flex items-center gap-4">
            <div class="relative">
                <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                    <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                    <span class="text-white"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Guest" %></span>
                </button>
                <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                    <div class="py-1">
                        <a href="${pageContext.request.contextPath}/views/customer/dashboard.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10 flex items-center gap-2">
                            <i data-lucide="home" class="w-5 h-5"></i> Dashboard
                        </a>
                        <button onclick="showLogoutModal()" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10 flex items-center gap-2">
                            <i data-lucide="log-out" class="w-5 h-5"></i> Logout
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="flex-1 pt-28 pb-12 px-6">
    <div class="container mx-auto">
        <!-- Confirmed Bookings Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up mb-8">
            <h2 class="text-3xl font-bold text-white mb-6">Confirmed Bookings</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Booking Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Pickup</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Drop-off</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="confirmedBookingsTableBody"></tbody>
                </table>
            </div>
        </div>

        <!-- Completed and Cancelled Bookings Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up">
            <h2 class="text-3xl font-bold text-white mb-6">Completed and Cancelled Bookings</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Booking Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Pickup</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Drop-off</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Status</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="completedCancelledBookingsTableBody"></tbody>
                </table>
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
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="twitter" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="linkedin" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="github" class="w-6 h-6"></i></a>
            </div>
        </div>
    </div>
</footer>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="cancelLogout(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-4">Confirm Logout</h3>
        <p class="text-gray-300 mb-6">Are you sure you want to logout?</p>
        <div class="flex justify-end gap-4">
            <button onclick="confirmLogout()" class="bg-primary text-white px-6 py-2 rounded-full hover:bg-primary-700 font-semibold btn-primary">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">No</button>
        </div>
    </div>
</div>

<!-- Booking Details Modal -->
<div id="bookingDetailsModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeBookingDetailsModal(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-6">Booking Details</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="detailBookingNumber"></span></p>
            <p><strong>Car:</strong> <span id="detailCarDetails"></span></p>
            <p><strong>Pickup:</strong> <span id="detailPickupLocation"></span></p>
            <p><strong>Drop-off:</strong> <span id="detailDropoffLocation"></span></p>
            <p><strong>Date:</strong> <span id="detailHireDate"></span></p>
            <p><strong>Time:</strong> <span id="detailHireTime"></span></p>
            <p><strong>Distance:</strong> <span id="detailDistance"></span></p>
            <p><strong>Total Fare:</strong> <span id="detailTotalFare"></span></p>
            <p><strong>Status:</strong> <span id="detailBookingStatus"></span></p>
        </div>
        <div class="flex justify-end">
            <button onclick="closeBookingDetailsModal()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Close</button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<script>
    lucide.createIcons();

    function toggleProfileDropdown() {
        document.getElementById('profileDropdown').classList.toggle('hidden');
    }

    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    function cancelLogout(event) {
        if (!event || event.target === document.getElementById('logoutModal')) {
            document.getElementById('logoutModal').classList.add('hidden');
        }
    }

    function confirmLogout() {
        fetch('<%= request.getContextPath() %>/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    window.location.href = '../index.jsp';
                } else {
                    Toastify({ text: "Logout failed: " + data.message, duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Toastify({ text: "An error occurred during logout.", duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
            });
    }

    document.addEventListener("DOMContentLoaded", function () {
        const bookings = <%= bookingsJson %>;

        const confirmedTbody = document.getElementById('confirmedBookingsTableBody');
        const completedCancelledTbody = document.getElementById('completedCancelledBookingsTableBody');

        // Filter bookings
        const confirmedBookings = bookings.filter(booking => booking.bookingStatus === 'confirmed');
        const otherBookings = bookings.filter(booking => booking.bookingStatus === 'completed' || booking.bookingStatus === 'cancelled');

        // Populate Confirmed Bookings
        confirmedTbody.innerHTML = '';
        if (confirmedBookings.length > 0) {
            confirmedBookings.forEach(booking => {
                const row = createBookingRow(booking, false);
                confirmedTbody.appendChild(row);
            });
        } else {
            confirmedTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">No confirmed bookings</td></tr>';
        }

        // Populate Completed/Cancelled Bookings
        completedCancelledTbody.innerHTML = '';
        if (otherBookings.length > 0) {
            otherBookings.forEach(booking => {
                const row = createBookingRow(booking, true);
                completedCancelledTbody.appendChild(row);
            });
        } else {
            completedCancelledTbody.innerHTML = '<tr><td colspan="6" class="text-center text-white py-4">No completed or cancelled bookings</td></tr>';
        }

        <% if (errorMessage != null) { %>
        Toastify({
            text: "<%= errorMessage %>",
            duration: 3000,
            close: true,
            gravity: "top",
            position: "right",
            style: { background: "red" },
            stopOnFocus: true
        }).showToast();
        <% } %>
    });

    function createBookingRow(booking, includeStatus) {
        const row = document.createElement('tr');
        row.className = 'border-b border-white/10';

        row.appendChild(createCell(booking.bookingNumber));
        row.appendChild(createCell(booking.pickupLocation));
        row.appendChild(createCell(booking.dropoffLocation));
        row.appendChild(createCell(booking.hireDate));

        if (includeStatus) {
            row.appendChild(createCell(booking.bookingStatus));
        }

        // Add View button
        const actionTd = document.createElement('td');
        actionTd.className = "px-6 py-4";
        const viewButton = document.createElement('button');
        viewButton.className = "bg-primary text-white px-4 py-1 rounded-full hover:bg-primary-700 font-semibold btn-primary";
        viewButton.textContent = 'View';
        viewButton.onclick = () => viewBookingDetails(booking);
        actionTd.appendChild(viewButton);
        row.appendChild(actionTd);

        return row;
    }

    function createCell(text) {
        const td = document.createElement('td');
        td.className = "px-6 py-4";
        td.textContent = text || 'N/A';
        return td;
    }

    function viewBookingDetails(booking) {
        document.getElementById('detailBookingNumber').textContent = booking.bookingNumber || 'N/A';
        document.getElementById('detailCarDetails').textContent = booking.carDetails ? `${booking.carDetails.brand} ${booking.carDetails.model} (${booking.carDetails.plateNumber})` : 'N/A';
        document.getElementById('detailPickupLocation').textContent = booking.pickupLocation || 'N/A';
        document.getElementById('detailDropoffLocation').textContent = booking.dropoffLocation || 'N/A';
        document.getElementById('detailHireDate').textContent = booking.hireDate || 'N/A';
        document.getElementById('detailHireTime').textContent = booking.hireTime || 'N/A';
        document.getElementById('detailDistance').textContent = booking.distance ? `${booking.distance.toFixed(2)} km` : 'N/A';
        document.getElementById('detailTotalFare').textContent = booking.totalFare ? `Rs. ${booking.totalFare.toFixed(2)}` : 'N/A';
        document.getElementById('detailBookingStatus').textContent = booking.bookingStatus || 'N/A';
        document.getElementById('bookingDetailsModal').classList.remove('hidden');
    }

    function closeBookingDetailsModal(event) {
        if (!event || event.target === document.getElementById('bookingDetailsModal')) {
            document.getElementById('bookingDetailsModal').classList.add('hidden');
        }
    }
</script>

</body>
</html>