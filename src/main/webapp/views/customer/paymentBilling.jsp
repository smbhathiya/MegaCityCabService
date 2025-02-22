<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%
    UUID customerUUID = (UUID) session.getAttribute("userId");
    String customerId = customerUUID != null ? customerUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (customerId == null || !"customer".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payment & Billing - Mega City Cabs</title>
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
                        <a href="${pageContext.request.contextPath}/views/customer/bookingHistory.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10 flex items-center gap-2">
                            <i data-lucide="history" class="w-5 h-5"></i> Booking History
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
        <!-- Unpaid/Pending Payments Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up mb-8">
            <h2 class="text-3xl font-bold text-white mb-6">Unpaid/Pending Payments</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Booking Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Total Fare</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Payment Status</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="unpaidPendingPaymentsTableBody"></tbody>
                </table>
            </div>
        </div>

        <!-- Payment History Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up">
            <h2 class="text-3xl font-bold text-white mb-6">Payment History</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Booking Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Total Fare</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Payment Status</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="paymentHistoryTableBody"></tbody>
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

<!-- Payment Details Modal -->
<div id="paymentDetailsModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closePaymentDetailsModal(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-6">Payment Details</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="detailBookingNumber"></span></p>
            <p><strong>Car:</strong> <span id="detailCarDetails"></span></p>
            <p><strong>Pickup:</strong> <span id="detailPickupLocation"></span></p>
            <p><strong>Drop-off:</strong> <span id="detailDropoffLocation"></span></p>
            <p><strong>Date:</strong> <span id="detailHireDate"></span></p>
            <p><strong>Time:</strong> <span id="detailHireTime"></span></p>
            <p><strong>Distance:</strong> <span id="detailDistance"></span></p>
            <p><strong>Total Fare:</strong> <span id="detailTotalFare"></span></p>
            <p><strong>Payment Status:</strong> <span id="detailPaymentStatus"></span></p>
            <p><strong>Booking Status:</strong> <span id="detailBookingStatus"></span></p>
        </div>
        <div class="flex justify-end">
            <button onclick="closePaymentDetailsModal()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Close</button>
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
        fetchPaymentHistory();
    });

    function fetchPaymentHistory() {
        const unpaidPendingTbody = document.getElementById('unpaidPendingPaymentsTableBody');
        const paymentHistoryTbody = document.getElementById('paymentHistoryTableBody');
        unpaidPendingTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Loading...</td></tr>';
        paymentHistoryTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Loading...</td></tr>';

        fetch('<%= request.getContextPath() %>/customer/payment-history', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
        })
            .then(response => {
                if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
                return response.json();
            })
            .then(payments => {
                console.log('Fetched payment history:', payments);
                unpaidPendingTbody.innerHTML = '';
                paymentHistoryTbody.innerHTML = '';

                // Filter payments
                const unpaidPendingPayments = payments.filter(payment => payment.paymentStatus === 'pending' || payment.paymentStatus === 'unpaid');
                const paidPayments = payments.filter(payment => payment.paymentStatus === 'paid');

                // Populate Unpaid/Pending Payments
                unpaidPendingPayments.forEach(payment => {
                    const row = createPaymentRow(payment);
                    unpaidPendingTbody.appendChild(row);
                });
                if (unpaidPendingPayments.length === 0) {
                    unpaidPendingTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">No unpaid or pending payments</td></tr>';
                }

                // Populate Payment History
                paidPayments.forEach(payment => {
                    const row = createPaymentRow(payment);
                    paymentHistoryTbody.appendChild(row);
                });
                if (paidPayments.length === 0) {
                    paymentHistoryTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">No payment history</td></tr>';
                }
            })
            .catch(error => {
                console.error('Error fetching payment history:', error);
                unpaidPendingTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Error loading data</td></tr>';
                paymentHistoryTbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Error loading data</td></tr>';
                Toastify({ text: "Error fetching payment history: " + error.message, duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
            });
    }

    function createPaymentRow(payment) {
        const row = document.createElement('tr');
        row.className = 'border-b border-white/10';

        row.appendChild(createCell(payment.bookingNumber));
        row.appendChild(createCell(payment.hireDate));
        row.appendChild(createCell(payment.totalFare ? `Rs. ${payment.totalFare.toFixed(2)}` : 'N/A'));
        row.appendChild(createCell(payment.paymentStatus));

        const actionCell = document.createElement('td');
        actionCell.className = "px-6 py-4";
        const viewBtn = document.createElement('button');
        viewBtn.className = "text-primary hover:text-primary-700";
        viewBtn.innerHTML = '<i data-lucide="eye" class="w-5 h-5"></i>';
        viewBtn.onclick = () => viewPaymentDetails(payment);
        actionCell.appendChild(viewBtn);
        row.appendChild(actionCell);

        return row;
    }

    function createCell(text) {
        const td = document.createElement('td');
        td.className = "px-6 py-4";
        td.textContent = text || 'N/A';
        return td;
    }

    function viewPaymentDetails(payment) {
        document.getElementById('detailBookingNumber').textContent = payment.bookingNumber;
        document.getElementById('detailCarDetails').textContent = payment.carDetails ? `${payment.carDetails.brand} ${payment.carDetails.model} (${payment.carDetails.plateNumber})` : 'N/A';
        document.getElementById('detailPickupLocation').textContent = payment.pickupLocation;
        document.getElementById('detailDropoffLocation').textContent = payment.dropoffLocation;
        document.getElementById('detailHireDate').textContent = payment.hireDate;
        document.getElementById('detailHireTime').textContent = payment.hireTime;
        document.getElementById('detailDistance').textContent = payment.distance ? `${payment.distance.toFixed(2)} km` : 'N/A';
        document.getElementById('detailTotalFare').textContent = payment.totalFare ? `Rs. ${payment.totalFare.toFixed(2)}` : 'N/A';
        document.getElementById('detailPaymentStatus').textContent = payment.paymentStatus;
        document.getElementById('detailBookingStatus').textContent = payment.bookingStatus;
        document.getElementById('paymentDetailsModal').classList.remove('hidden');
    }

    function closePaymentDetailsModal(event) {
        if (!event || event.target === document.getElementById('paymentDetailsModal')) {
            document.getElementById('paymentDetailsModal').classList.add('hidden');
        }
    }
</script>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50">
    <div class="bg-accent p-6 rounded-xl shadow-2xl">
        <h3 class="text-xl font-bold text-white mb-4">Confirm Logout</h3>
        <p class="text-gray-300 mb-6">Are you sure you want to logout?</p>
        <div class="flex gap-4 justify-end">
            <button onclick="confirmLogout()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">No</button>
        </div>
    </div>
</div>

</body>
</html>