<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.PaymentDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Payment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
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

    PaymentDAO paymentDAO = new PaymentDAO();
    DecimalFormat df = new DecimalFormat("#.##");
    Gson gson = new Gson();

    List<Payment> pendingPayments = null;
    List<Payment> paymentHistory = null;
    String errorMessage = null;

    try {
        pendingPayments = paymentDAO.getPendingPaymentsByCustomerId(customerId);
        paymentHistory = paymentDAO.getPaymentHistoryByCustomerId(customerId);
    } catch (Exception e) {
        errorMessage = "Error fetching payment data: " + e.getMessage();
    }

    String pendingPaymentsJson = gson.toJson(pendingPayments != null ? pendingPayments : new ArrayList<>());
    String paymentHistoryJson = gson.toJson(paymentHistory != null ? paymentHistory : new ArrayList<>());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Payments - Mega City Cabs</title>
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
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="pendingPaymentsTableBody"></tbody>
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
            <p><strong>Amount:</strong> <span id="detailAmount"></span></p>
            <p><strong>Payment Method:</strong> <span id="detailPaymentMethod"></span></p>
            <p><strong>Transaction ID:</strong> <span id="detailTransactionId"></span></p>
            <p><strong>Status:</strong> <span id="detailStatus"></span></p>
            <p><strong>Payment Date:</strong> <span id="detailPaymentDate"></span></p>
        </div>
        <div class="flex justify-end">
            <button onclick="closePaymentDetailsModal()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Close</button>
        </div>
    </div>
</div>

<!-- Select Payment Method Modal -->
<div id="selectPaymentMethodModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeSelectPaymentMethodModal(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-6">Select Payment Method</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="selectBookingNumber"></span></p>
            <p><strong>Amount:</strong> <span id="selectAmount"></span></p>
        </div>
        <div class="flex justify-between gap-4">
            <button onclick="selectCashPayment()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Cash</button>
            <button onclick="selectCardPayment()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Card</button>
        </div>
    </div>
</div>

<!-- Confirm Cash Payment Modal -->
<div id="confirmCashPaymentModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeConfirmCashPaymentModal(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-6">Confirm Cash Payment</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="cashBookingNumber"></span></p>
            <p><strong>Amount:</strong> <span id="cashAmount"></span></p>
            <p class="mt-2">Please confirm to process this payment as cash.</p>
        </div>
        <div class="flex justify-end gap-4">
            <button onclick="confirmCashPayment()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Confirm Payment</button>
            <button onclick="closeConfirmCashPaymentModal()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Cancel</button>
        </div>
    </div>
</div>

<!-- Card Payment Modal -->
<div id="cardPaymentModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeCardPaymentModal(event)">
    <div class="bg-accent p-6 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
        <h3 class="text-2xl font-bold text-white mb-6">Card Payment</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="cardBookingNumber"></span></p>
            <p><strong>Amount:</strong> <span id="cardAmount"></span></p>
            <div class="mt-4">
                <label for="cardNumber" class="block text-sm font-semibold text-white">Card Number</label>
                <input type="text" id="cardNumber" class="w-full mt-2 p-2 rounded bg-dark text-white border border-white/10 focus:outline-none" placeholder="XXXX-XXXX-XXXX-XXXX">

                <div class="flex gap-4 mt-4">
                    <div class="w-1/2">
                        <label for="expiryDate" class="block text-sm font-semibold text-white">Expiry Date</label>
                        <input type="text" id="expiryDate" class="w-full mt-2 p-2 rounded bg-dark text-white border border-white/10 focus:outline-none" placeholder="MM/YY">
                    </div>
                    <div class="w-1/2">
                        <label for="cvv" class="block text-sm font-semibold text-white">CVV</label>
                        <input type="text" id="cvv" class="w-full mt-2 p-2 rounded bg-dark text-white border border-white/10 focus:outline-none" placeholder="XXX">
                    </div>
                </div>
                <label for="cardHolderName" class="block text-sm font-semibold text-white mt-4">Cardholder Name</label>
                <input type="text" id="cardHolderName" class="w-full mt-2 p-2 rounded bg-dark text-white border border-white/10 focus:outline-none" placeholder="John Doe">
                <p class="mt-2 text-sm text-gray-400">This is a test app; card details are optional.</p>
            </div>
        </div>
        <div class="flex justify-end gap-4">
            <button id="processCardPaymentBtn" onclick="processCardPayment()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Process Payment</button>
            <button onclick="closeCardPaymentModal()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Cancel</button>
        </div>
    </div>
</div>

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

    document.addEventListener("DOMContentLoaded", function () {
        const pendingPayments = <%= pendingPaymentsJson %>;
        const paymentHistory = <%= paymentHistoryJson %>;

        const pendingTbody = document.getElementById('pendingPaymentsTableBody');
        const historyTbody = document.getElementById('paymentHistoryTableBody');

        // Populate Pending Payments
        pendingTbody.innerHTML = '';
        if (pendingPayments.length > 0) {
            pendingPayments.forEach(payment => {
                const row = createPendingPaymentRow(payment);
                pendingTbody.appendChild(row);
            });
        } else {
            pendingTbody.innerHTML = '<tr><td colspan="6" class="text-center text-white py-4">No pending payments</td></tr>';
        }

        // Populate Payment History
        historyTbody.innerHTML = '';
        if (paymentHistory.length > 0) {
            paymentHistory.forEach(payment => {
                const row = createPaymentHistoryRow(payment);
                historyTbody.appendChild(row);
            });
        } else {
            historyTbody.innerHTML = '<tr><td colspan="7" class="text-center text-white py-4">No payment history</td></tr>';
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

    function createPendingPaymentRow(payment) {
        const row = document.createElement('tr');
        row.className = 'border-b border-white/10';

        row.appendChild(createCell(payment.bookingNumber));
        row.appendChild(createCell(payment.pickupLocation));
        row.appendChild(createCell(payment.dropoffLocation));
        row.appendChild(createCell(payment.hireDate));
        row.appendChild(createCell('Rs.' + Number(payment.amount).toFixed(2)));

        const actionCell = document.createElement('td');
        actionCell.className = "px-6 py-4";
        const payBtn = document.createElement('button');
        payBtn.className = "text-primary hover:text-primary-700 flex items-center gap-2";
        payBtn.innerHTML = '<i data-lucide="credit-card" class="w-5 h-5"></i> Make Payment';
        payBtn.onclick = () => showSelectPaymentMethodModal(payment);
        actionCell.appendChild(payBtn);
        row.appendChild(actionCell);

        return row;
    }

    function createPaymentHistoryRow(payment) {
        const row = document.createElement('tr');
        row.className = 'border-b border-white/10';

        row.appendChild(createCell(payment.bookingNumber));
        row.appendChild(createCell('Rs.' + Number(payment.amount).toFixed(2)));
        row.appendChild(createCell(payment.paymentMethod));
        row.appendChild(createCell(payment.transactionId));
        row.appendChild(createCell(payment.status));
        row.appendChild(createCell(new Date(payment.paymentDate).toLocaleString()));

        const actionCell = document.createElement('td');
        actionCell.className = "px-6 py-4";
        const printBtn = document.createElement('button');
        printBtn.className = "text-primary hover:text-primary-700 flex items-center gap-2";
        printBtn.innerHTML = '<i data-lucide="printer" class="w-5 h-5"></i> Print Bill';
        printBtn.onclick = () => printBill(payment);
        actionCell.appendChild(printBtn);
        row.appendChild(actionCell);

        return row;
    }

    function createCell(text) {
        const td = document.createElement('td');
        td.className = "px-6 py-4";
        td.textContent = text || 'N/A';
        return td;
    }

    function printBill(payment) {
        const doc = new jsPDF();

        doc.setFontSize(20);
        doc.text("Mega City Cabs - Payment Receipt", 20, 20);

        doc.setFontSize(12);
        doc.text("Booking Number: " + (payment.bookingNumber || 'N/A'), 20, 40);
        doc.text("Amount: Rs. " + (payment.amount ? Number(payment.amount).toFixed(2) : 'N/A'), 20, 50);
        doc.text("Payment Method: " + (payment.paymentMethod || 'N/A'), 20, 60);
        doc.text("Transaction ID: " + (payment.transactionId || 'N/A'), 20, 70);
        doc.text("Status: " + (payment.status || 'N/A'), 20, 80);
        doc.text("Payment Date: " + (payment.paymentDate ? new Date(payment.paymentDate).toLocaleString() : 'N/A'), 20, 90);

        doc.setFontSize(10);
        doc.text("Thank you for choosing Mega City Cabs!", 20, 110);

        doc.save("Receipt_" + (payment.bookingNumber || 'Unknown') + ".pdf");
    }

    let currentPayment = null;

    function showSelectPaymentMethodModal(payment) {
        currentPayment = payment;
        document.getElementById('selectBookingNumber').textContent = payment.bookingNumber || 'N/A';
        document.getElementById('selectAmount').textContent = 'Rs.' + (payment.amount ? Number(payment.amount).toFixed(2) : 'N/A');
        document.getElementById('selectPaymentMethodModal').classList.remove('hidden');
    }

    function closeSelectPaymentMethodModal(event) {
        if (!event || event.target === document.getElementById('selectPaymentMethodModal')) {
            document.getElementById('selectPaymentMethodModal').classList.add('hidden');
        }
    }

    function selectCashPayment() {
        closeSelectPaymentMethodModal();
        document.getElementById('cashBookingNumber').textContent = currentPayment.bookingNumber || 'N/A';
        document.getElementById('cashAmount').textContent = 'Rs.' + (currentPayment.amount ? Number(currentPayment.amount).toFixed(2) : 'N/A');
        document.getElementById('confirmCashPaymentModal').classList.remove('hidden');
    }

    function closeConfirmCashPaymentModal(event) {
        if (!event || event.target === document.getElementById('confirmCashPaymentModal')) {
            document.getElementById('confirmCashPaymentModal').classList.add('hidden');
        }
    }

    function confirmCashPayment() {
        const paymentData = {
            bookingId: currentPayment.bookingId,
            paymentMethod: 'cash'
        };

        fetch('<%= request.getContextPath() %>/customer/payments/make', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(paymentData),
            credentials: 'include'
        })
            .then(response => response.json())
            .then(data => {
                if (data.status === 'success') {
                    Toastify({ text: "Cash payment processed successfully!", duration: 3000, close: true, gravity: "top", position: "right", style: { background: "green" } }).showToast();
                    closeConfirmCashPaymentModal();
                    location.reload(); // Refresh to update tables
                } else {
                    throw new Error(data.data || "Unknown error");
                }
            })
            .catch(error => {
                console.error('Error processing cash payment:', error);
                Toastify({ text: "Error processing cash payment: " + error.message, duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
            });
    }

    function selectCardPayment() {
        closeSelectPaymentMethodModal();
        document.getElementById('cardBookingNumber').textContent = currentPayment.bookingNumber || 'N/A';
        document.getElementById('cardAmount').textContent = 'Rs.' + (currentPayment.amount ? Number(currentPayment.amount).toFixed(2) : 'N/A');
        document.getElementById('cardPaymentModal').classList.remove('hidden');
    }

    function closeCardPaymentModal(event) {
        if (!event || event.target === document.getElementById('cardPaymentModal')) {
            document.getElementById('cardPaymentModal').classList.add('hidden');
        }
    }

    function processCardPayment() {
        const processBtn = document.getElementById('processCardPaymentBtn');
        processBtn.textContent = 'Processing...';
        processBtn.disabled = true;

        const paymentData = {
            bookingId: currentPayment.bookingId,
            paymentMethod: 'credit_card'
        };

        setTimeout(() => { // Simulate processing delay
            fetch('<%= request.getContextPath() %>/customer/payments/make', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(paymentData),
                credentials: 'include'
            })
                .then(response => response.json())
                .then(data => {
                    processBtn.textContent = 'Process Payment';
                    processBtn.disabled = false;
                    if (data.status === 'success') {
                        Toastify({ text: "Card payment processed successfully!", duration: 3000, close: true, gravity: "top", position: "right", style: { background: "green" } }).showToast();
                        closeCardPaymentModal();
                        location.reload(); // Refresh to update tables
                    } else {
                        throw new Error(data.data || "Unknown error");
                    }
                })
                .catch(error => {
                    processBtn.textContent = 'Process Payment';
                    processBtn.disabled = false;
                    console.error('Error processing card payment:', error);
                    Toastify({ text: "Error processing card payment: " + error.message, duration: 3000, close: true, gravity: "top", position: "right", style: { background: "red" } }).showToast();
                });
        }, 1500);
    }
</script>

</body>
</html>