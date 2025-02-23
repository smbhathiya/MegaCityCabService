<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.BookingDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Booking" %>
<%@ page import="java.util.List" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Booking Management - Mega City Cabs</title>
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
        .modal-content {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
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
                        <p class="text-sm text-light/70">Driver Dashboard</p>
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
            BookingDAO bookingDAO = new BookingDAO();
            List<Booking> bookings = null;
            try {
                bookings = bookingDAO.getBookingsByDriverId(UUID.fromString(driverId));
            } catch (Exception e) {
            }
    %>
    <h2 class="text-3xl font-bold text-white mb-8">Booking Management</h2>

    <!-- Pending and Ongoing Bookings -->
    <div class="card p-6 animate-slide-up mb-8">
        <h3 class="text-2xl font-semibold text-white mb-4">Pending & Ongoing Bookings</h3>
        <table id="activeBookingsTable">
            <thead>
            <tr>
                <th>Booking Number</th>
                <th>Pickup Location</th>
                <th>Drop-off Location</th>
                <th>Hire Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody id="activeBookingsBody">
            <% if (bookings != null) {
                for (Booking booking : bookings) {
                    if ("pending".equalsIgnoreCase(booking.getBookingStatus()) || "confirmed".equalsIgnoreCase(booking.getBookingStatus())) {
            %>
            <tr>
                <td><%= booking.getBookingNumber() %></td>
                <td><%= booking.getPickupLocation() %></td>
                <td><%= booking.getDropoffLocation() %></td>
                <td><%= booking.getHireDate() %></td>
                <td><%= booking.getBookingStatus() %></td>
                <td>
                    <button class="bg-primary text-white px-2 py-1 rounded-md hover:bg-primary-700 btn-primary"
                            onclick='showBookingDetails("<%= booking.getId() %>")'>View</button>
                </td>
            </tr>
            <%      }
            }
            } else { %>
            <tr>
                <td colspan="6" class="text-center">No pending or ongoing bookings found.</td>
            </tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <!-- Booking History -->
    <div class="card p-6 animate-slide-up">
        <h3 class="text-2xl font-semibold text-white mb-4">Booking History</h3>
        <table id="historyBookingsTable">
            <thead>
            <tr>
                <th>Booking Number</th>
                <th>Pickup Location</th>
                <th>Drop-off Location</th>
                <th>Hire Date</th>
                <th>Status</th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody id="historyBookingsBody">
            <% if (bookings != null) {
                for (Booking booking : bookings) {
                    if ("completed".equalsIgnoreCase(booking.getBookingStatus()) || "cancelled".equalsIgnoreCase(booking.getBookingStatus())) {
            %>
            <tr>
                <td><%= booking.getBookingNumber() %></td>
                <td><%= booking.getPickupLocation() %></td>
                <td><%= booking.getDropoffLocation() %></td>
                <td><%= booking.getHireDate() %></td>
                <td><%= booking.getBookingStatus() %></td>
                <td>
                    <button class="bg-primary text-white px-2 py-1 rounded-md hover:bg-primary-700 btn-primary"
                            onclick='showBookingDetails("<%= booking.getId() %>")'>View</button>
                </td>
            </tr>
            <%      }
            }
            } else { %>
            <tr>
                <td colspan="6" class="text-center">No history bookings found.</td>
            </tr>
            <% } %>
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

<!-- Booking Details Modal -->
<div id="bookingDetailsModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="modal-content p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-xl font-bold text-white mb-4">Booking Details</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="modalBookingNumber"></span></p>
            <p><strong>Pickup Location:</strong> <span id="modalPickupLocation"></span></p>
            <p><strong>Drop-off Location:</strong> <span id="modalDropoffLocation"></span></p>
            <p><strong>Hire Date:</strong> <span id="modalHireDate"></span></p>
            <p><strong>Hire Time:</strong> <span id="modalHireTime"></span></p>
            <p><strong>Status:</strong> <span id="modalStatus"></span></p>
            <p><strong>Distance:</strong> <span id="modalDistance"></span></p>
            <p><strong>Total Fare:</strong> <span id="modalTotalFare"></span></p>
        </div>
        <div class="flex gap-4">
            <button id="updateStatusButton" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700 btn-primary" onclick="showUpdateStatusModal()">Update Status</button>
            <button onclick="closeBookingDetailsModal()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500">Close</button>
        </div>
    </div>
</div>

<!-- Update Status Modal -->
<div id="updateStatusModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="modal-content p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-xl font-bold text-white mb-4">Update Booking Status</h3>
        <form id="updateStatusForm">
            <div class="mb-4">
                <label for="statusSelect" class="block text-sm font-medium text-light">Select Status</label>
                <select id="statusSelect" name="status" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light border border-white/10">
                    <option value="completed">Completed</option>
                    <option value="cancelled">Cancelled</option>
                </select>
            </div>
            <div class="flex gap-4 justify-end">
                <button type="submit" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700 btn-primary">Update</button>
                <button type="button" onclick="closeUpdateStatusModal()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500">Cancel</button>
            </div>
        </form>
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

    function showBookingDetails(bookingId) {
        fetch('<%= request.getContextPath() %>/driver/bookings/details?id=' + bookingId, {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                console.log('Booking Details Response:', data);
                // Check if data is an object and not an error response
                if (data && !data.status) {
                    document.getElementById('modalBookingNumber').innerText = data.bookingNumber || 'N/A';
                    document.getElementById('modalPickupLocation').innerText = data.pickupLocation || 'N/A';
                    document.getElementById('modalDropoffLocation').innerText = data.dropoffLocation || 'N/A';
                    document.getElementById('modalHireDate').innerText = data.hireDate || 'N/A';
                    document.getElementById('modalHireTime').innerText = data.hireTime || 'N/A';
                    document.getElementById('modalStatus').innerText = data.bookingStatus || 'N/A';
                    document.getElementById('modalDistance').innerText = (data.distance ? data.distance.toFixed(2) + ' km' : 'N/A');
                    document.getElementById('modalTotalFare').innerText = (data.totalFare ? 'Rs. ' + data.totalFare.toFixed(2) : 'N/A');
                    document.getElementById('bookingDetailsModal').classList.remove('hidden');
                    document.getElementById('updateStatusForm').dataset.bookingId = bookingId;
                } else {
                    Toastify({
                        text: "Failed to fetch booking details: " + (data.message || 'Unknown error'),
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
                console.error('Error fetching booking details:', error);
                Toastify({
                    text: "Error fetching booking details: " + error.message,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    function closeBookingDetailsModal() {
        document.getElementById('bookingDetailsModal').classList.add('hidden');
    }

    function showUpdateStatusModal() {
        document.getElementById('updateStatusModal').classList.remove('hidden');
    }

    function closeUpdateStatusModal() {
        document.getElementById('updateStatusModal').classList.add('hidden');
    }

    document.getElementById('updateStatusForm').addEventListener('submit', function(e) {
        e.preventDefault();
        const bookingId = this.dataset.bookingId;
        const newStatus = document.getElementById('statusSelect').value;

        fetch('<%= request.getContextPath() %>/driver/bookings/status', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ id: bookingId, status: newStatus })
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    Toastify({
                        text: "Booking status updated successfully!",
                        duration: 1500,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "green" },
                        stopOnFocus: true
                    }).showToast();
                    closeUpdateStatusModal();
                    closeBookingDetailsModal();
                    window.location.reload();
                } else {
                    Toastify({
                        text: "Status update failed: " + data.message,
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
                console.error('Error updating status:', error);
                Toastify({
                    text: "Something went wrong. Please try again.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    });
</script>

</body>
</html>