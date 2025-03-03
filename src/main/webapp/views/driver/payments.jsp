<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.DriverPaymentDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    UUID driverUUID = (UUID) session.getAttribute("userId");
    String driverId = driverUUID != null ? driverUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (driverId == null || !"driver".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    DriverPaymentDAO paymentDAO = new DriverPaymentDAO();
    DecimalFormat df = new DecimalFormat("#.##");
    List<DriverPaymentDAO.DriverPayment> pendingPayments = null;
    List<DriverPaymentDAO.DriverPayment> paymentHistory = null;
    String errorMessage = null;

    try {
        pendingPayments = paymentDAO.getPendingPaymentsByDriverId(driverId);
        paymentHistory = paymentDAO.getPaymentHistoryByDriverId(driverId);
    } catch (Exception e) {
        errorMessage = "Error fetching payment data: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Payments - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
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
                        <a href="${pageContext.request.contextPath}/views/driver/dashboard.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10 flex items-center gap-2">
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
        <!-- Pending Payments Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up mb-8">
            <h2 class="text-3xl font-bold text-white mb-6">Pending Payments</h2>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Booking Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Pickup</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Drop-off</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Amount</th>
                    </tr>
                    </thead>
                    <tbody id="pendingPaymentsTableBody">
                    <% if (pendingPayments != null && !pendingPayments.isEmpty()) {
                        for (DriverPaymentDAO.DriverPayment payment : pendingPayments) {
                    %>
                    <tr class="border-b border-white/10">
                        <td class="px-6 py-4"><%= payment.bookingNumber != null ? payment.bookingNumber : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.pickupLocation != null ? payment.pickupLocation : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.dropoffLocation != null ? payment.dropoffLocation : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.hireDate != null ? payment.hireDate : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.amount > 0 ? "Rs. " + df.format(payment.amount) : "N/A" %></td>
                    </tr>
                    <%  }
                    } else { %>
                    <tr>
                        <td colspan="5" class="text-center text-white py-4">No pending payments</td>
                    </tr>
                    <% } %>
                    </tbody>
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
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Amount</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Payment Method</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Transaction ID</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Status</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Payment Date</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="paymentHistoryTableBody">
                    <% if (paymentHistory != null && !paymentHistory.isEmpty()) {
                        for (DriverPaymentDAO.DriverPayment payment : paymentHistory) {
                    %>
                    <tr class="border-b border-white/10">
                        <td class="px-6 py-4"><%= payment.bookingNumber != null ? payment.bookingNumber : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.amount > 0 ? "Rs. " + df.format(payment.amount) : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.paymentMethod != null ? payment.paymentMethod : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.transactionId != null ? payment.transactionId : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.status != null ? payment.status : "N/A" %></td>
                        <td class="px-6 py-4"><%= payment.paymentDate != null ? payment.paymentDate : "N/A" %></td>
                        <td class="px-6 py-4">
                            <button class="text-primary hover:text-primary-700 flex items-center gap-2" onclick='printBill(<%= new com.google.gson.Gson().toJson(payment) %>)'>
                                <i data-lucide="printer" class="w-5 h-5"></i> Print Bill
                            </button>
                        </td>
                    </tr>
                    <%  }
                    } else { %>
                    <tr>
                        <td colspan="7" class="text-center text-white py-4">No payment history</td>
                    </tr>
                    <% } %>
                    </tbody>
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

<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<script>
    lucide.createIcons();
    const { jsPDF } = window.jspdf;

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

    function printBill(payment) {
        const doc = new jsPDF();

        console.log('Payment data for PDF:', payment);

        doc.setFontSize(20);
        doc.text("Mega City Cabs - Payment Receipt", 20, 20);

        doc.setFontSize(12);
        doc.text("Booking Number: " + (payment.bookingNumber || 'N/A'), 20, 40);
        doc.text("Amount: Rs. " + (payment.amount ? payment.amount.toFixed(2) : 'N/A'), 20, 50);
        doc.text("Payment Method: " + (payment.paymentMethod || 'N/A'), 20, 60);
        doc.text("Transaction ID: " + (payment.transactionId || 'N/A'), 20, 70);
        doc.text("Status: " + (payment.status || 'N/A'), 20, 80);
        doc.text("Payment Date: " + (payment.paymentDate ? new Date(payment.paymentDate).toLocaleString() : 'N/A'), 20, 90);

        doc.setFontSize(10);
        doc.text("Thank you for choosing Mega City Cabs!", 20, 110);

        doc.save("Receipt_"+payment.bookingNumber || 'Unknown'+".pdf");
    }

    // Display error toast if applicable
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
</script>

</body>
</html>