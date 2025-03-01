<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.AdminReportsDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.cabservice.megacitycabservice.model.Car" %>
<%!
    private AdminReportsDAO.Reports getReports(String startDate, String endDate) {
        try {
            AdminReportsDAO dao = new AdminReportsDAO();
            return dao.getReports(startDate, endDate);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Reports - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.8.3/jspdf.plugin.autotable.min.js"></script>
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
        .card { transition: transform 0.3s ease, box-shadow 0.3s ease; background-color: #2A2A2A; border-radius: 1rem; }
        .card:hover { transform: translateY(-5px); box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3); }
        .btn-primary { transition: transform 0.2s ease, background-color 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #444; }
        th { background-color: #333; color: #F5F5F5; }
        @media print {
            .no-print { display: none; }
            body { background-color: #fff; color: #000; }
            .card { background-color: #fff; box-shadow: none; border: 1px solid #000; }
            table { border: 1px solid #000; }
            th, td { border: 1px solid #000; }
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

    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    if (startDate == null || endDate == null || startDate.trim().isEmpty() || endDate.trim().isEmpty()) {
        java.util.Date today = new java.util.Date();
        java.util.Calendar cal = java.util.Calendar.getInstance();
        cal.setTime(today);
        endDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
        cal.add(java.util.Calendar.DATE, -30);
        startDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
    }

    AdminReportsDAO.Reports reports = getReports(startDate, endDate);
    DecimalFormat df = new DecimalFormat("#.##");
%>
<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md no-print">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary animate-pulse-slow"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Admin Reports</p>
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
        <div class="flex justify-between items-center mb-6 no-print">
            <h1 class="text-3xl font-bold text-white">Reports</h1>
            <form method="get" action="<%= request.getContextPath() %>/views/admin/reports.jsp" class="flex gap-4">
                <input type="date" id="startDate" name="startDate" value="<%= startDate %>" class="bg-dark text-light p-2 rounded-md border border-white/10">
                <input type="date" id="endDate" name="endDate" value="<%= endDate %>" class="bg-dark text-light p-2 rounded-md border border-white/10">
                <button type="submit" id="generateBtn" class="bg-primary text-dark px-4 py-2 rounded-full btn-primary font-semibold">Generate</button>
                <button type="button" onclick="window.print()" class="bg-green-500 text-white px-4 py-2 rounded-full btn-primary font-semibold">Print</button>
                <button type="button" onclick="downloadPDF()" class="bg-blue-500 text-white px-4 py-2 rounded-full btn-primary font-semibold">Download PDF</button>
            </form>
        </div>

        <!-- Revenue Report -->
        <div class="card p-6 mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Revenue Report</h2>
            <table id="revenueTable">
                <thead>
                <tr>
                    <th>Date</th>
                    <th>Revenue (Rs.)</th>
                </tr>
                </thead>
                <tbody>
                <%
                    double totalRevenue = 0;
                    if (reports != null && reports.revenue != null) {
                        for (AdminReportsDAO.RevenueItem item : reports.revenue) {
                            totalRevenue += item.amount;
                %>
                <tr>
                    <td><%= item.date %></td>
                    <td>Rs. <%= df.format(item.amount) %></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="2">No revenue data available</td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <p class="text-lg font-semibold text-white mt-4">Total Revenue: Rs. <%= df.format(totalRevenue) %></p>
        </div>

        <!-- Booking Summary -->
        <div class="card p-6 mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Booking Summary</h2>
            <table id="bookingTable">
                <thead>
                <tr>
                    <th>Status</th>
                    <th>Count</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (reports != null && reports.bookings != null && !reports.bookings.isEmpty()) {
                        for (Map.Entry<String, Integer> entry : reports.bookings.entrySet()) {
                %>
                <tr>
                    <td><%= entry.getKey() %></td>
                    <td><%= entry.getValue() %></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="2">No booking data available</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- Driver Performance -->
        <div class="card p-6 mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Driver Performance</h2>
            <table id="driverTable">
                <thead>
                <tr>
                    <th>Driver Name</th>
                    <th>Earnings (Rs.)</th>
                    <th>Bookings</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (reports != null && reports.drivers != null) {
                        for (AdminReportsDAO.DriverItem driver : reports.drivers) {
                %>
                <tr>
                    <td><%= driver.name != null ? driver.name : "N/A" %></td>
                    <td>Rs. <%= df.format(driver.earnings) %></td>
                    <td><%= driver.bookings %></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="3">No driver data available</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>

        <!-- Vehicle Utilization -->
        <div class="card p-6 mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Vehicle Utilization</h2>
            <table id="vehicleTable">
                <thead>
                <tr>
                    <th>Plate Number</th>
                    <th>Bookings</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (reports != null && reports.vehicles != null) {
                        for (Car vehicle : reports.vehicles) {
                %>
                <tr>
                    <td><%= vehicle.getPlateNumber() != null ? vehicle.getPlateNumber() : "N/A" %></td>
                    <td><%= vehicle.getBookings() %></td>
                </tr>
                <%
                    }
                } else {
                %>
                <tr>
                    <td colspan="2">No vehicle data available</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- Footer -->
<footer class="bg-dark/50 py-12 border-t border-white/10 flex-shrink-0 no-print">
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

    function downloadPDF() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        let yOffset = 10;

        doc.setFontSize(16);
        doc.text("Mega City Cabs - Admin Reports", 10, yOffset);
        yOffset += 10;

        // Revenue Report
        doc.setFontSize(12);
        doc.text("Revenue Report", 10, yOffset);
        yOffset += 10;
        doc.autoTable({
            startY: yOffset,
            html: '#revenueTable',
            theme: 'grid',
            headStyles: { fillColor: [51, 51, 51] },
            bodyStyles: { textColor: [0, 0, 0] }
        });
        yOffset = doc.lastAutoTable.finalY + 10;
        doc.text("Total Revenue: Rs. <%= df.format(totalRevenue) %>", 10, yOffset);
        yOffset += 20;

        // Booking Summary
        doc.text("Booking Summary", 10, yOffset);
        yOffset += 10;
        doc.autoTable({
            startY: yOffset,
            html: '#bookingTable',
            theme: 'grid',
            headStyles: { fillColor: [51, 51, 51] },
            bodyStyles: { textColor: [0, 0, 0] }
        });
        yOffset = doc.lastAutoTable.finalY + 20;

        // Driver Performance
        doc.text("Driver Performance", 10, yOffset);
        yOffset += 10;
        doc.autoTable({
            startY: yOffset,
            html: '#driverTable',
            theme: 'grid',
            headStyles: { fillColor: [51, 51, 51] },
            bodyStyles: { textColor: [0, 0, 0] }
        });
        yOffset = doc.lastAutoTable.finalY + 20;

        // Vehicle Utilization
        doc.text("Vehicle Utilization", 10, yOffset);
        yOffset += 10;
        doc.autoTable({
            startY: yOffset,
            html: '#vehicleTable',
            theme: 'grid',
            headStyles: { fillColor: [51, 51, 51] },
            bodyStyles: { textColor: [0, 0, 0] }
        });

        doc.save("MegaCityCabs_Reports.pdf");
    }

    document.addEventListener('DOMContentLoaded', function() {
        const startDateInput = document.getElementById('startDate');
        const endDateInput = document.getElementById('endDate');
        const generateBtn = document.getElementById('generateBtn');

        const checkDates = () => {
            const start = startDateInput.value;
            const end = endDateInput.value;
            generateBtn.disabled = !start || !end;
        };
        startDateInput.addEventListener('input', checkDates);
        endDateInput.addEventListener('input', checkDates);
        checkDates();
    });
</script>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50 no-print">
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