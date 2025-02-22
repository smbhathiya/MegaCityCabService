<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Booking - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="https://unpkg.com/toastify-js/src/toastify.css">
    <script src="https://unpkg.com/toastify-js"></script>
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
    <style>
        body { background-color: #1A1A1A; font-family: 'Inter', sans-serif; }
        .form-container { background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8)); backdrop-filter: blur(10px); }
        .btn-primary { transition: transform 0.2s ease, background-color 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); }
        input:focus { transition: all 0.3s ease; outline: none; ring: 2px solid #FCC603; }
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
<main class="flex-1 flex items-center justify-center px-6 py-28">
    <%
        Object userIdObj = session.getAttribute("userId");
        String customerId = null;
        if (userIdObj != null && userIdObj instanceof UUID) {
            customerId = ((UUID) userIdObj).toString();
        }
        if (customerId == null) {
            response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
            return;
        }
    %>
    <div class="form-container p-8 rounded-xl shadow-2xl w-full max-w-2xl mx-auto animate-slide-up">
        <h2 class="text-3xl font-bold text-white mb-8 text-center">Book a Ride</h2>
        <form id="bookingForm" onsubmit="submitBooking(event)">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <div class="mb-6">
                        <label for="pickup_location" class="block text-sm font-medium text-gray-300 mb-2">Pickup Location</label>
                        <input type="text" id="pickup_location" name="pickup_location" required class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:ring-2 focus:ring-primary">
                    </div>
                    <div class="mb-6">
                        <label for="hire_date" class="block text-sm font-medium text-gray-300 mb-2">Hire Date</label>
                        <input type="date" id="hire_date" name="hire_date" required class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white focus:ring-2 focus:ring-primary">
                    </div>
                    <div class="mb-6">
                        <label for="passenger_count" class="block text-sm font-medium text-gray-300 mb-2">Passenger Count</label>
                        <input type="number" id="passenger_count" name="passenger_count" min="1" required class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:ring-2 focus:ring-primary">
                    </div>
                </div>
                <div>
                    <div class="mb-6">
                        <label for="dropoff_location" class="block text-sm font-medium text-gray-300 mb-2">Drop-off Location</label>
                        <input type="text" id="dropoff_location" name="dropoff_location" required class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white placeholder-gray-500 focus:ring-2 focus:ring-primary">
                    </div>
                    <div class="mb-6">
                        <label for="hire_time" class="block text-sm font-medium text-gray-300 mb-2">Hire Time</label>
                        <input type="time" id="hire_time" name="hire_time" required class="w-full px-4 py-3 bg-accent border border-white/10 rounded-full text-white focus:ring-2 focus:ring-primary">
                    </div>
                </div>
            </div>
            <button type="submit" class="w-full bg-primary text-dark py-3 rounded-full btn-primary font-semibold text-lg mt-4 flex items-center justify-center gap-2">
                <i data-lucide="check" class="w-5 h-5"></i> Book Now
            </button>
        </form>
        <p class="mt-6 text-center text-gray-400 text-sm">
            Back to <a href="${pageContext.request.contextPath}/views/customer/dashboard.jsp" class="text-primary hover:underline font-medium">Dashboard</a>
        </p>
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

<!-- Booking Confirmation Modal -->
<div id="bookingModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50">
    <div class="bg-accent p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-xl font-bold text-white mb-4">Booking Details</h3>
        <div class="text-gray-300 mb-6">
            <p><strong>Booking Number:</strong> <span id="bookingNumber"></span></p>
            <p><strong>Car:</strong> <span id="carDetails"></span></p>
            <p><strong>Pickup:</strong> <span id="pickupLocation"></span></p>
            <p><strong>Drop-off:</strong> <span id="dropoffLocation"></span></p>
            <p><strong>Date:</strong> <span id="hireDate"></span></p>
            <p><strong>Time:</strong> <span id="hireTime"></span></p>
            <p><strong>Distance:</strong> <span id="distance"></span></p>
            <p><strong>Total Fare:</strong> <span id="totalFare"></span></p>
        </div>
        <div class="flex gap-4 justify-end">
            <button onclick="confirmBooking('confirmed')" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Confirm</button>
            <button onclick="confirmBooking('cancelled')" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">Cancel</button>
        </div>
    </div>
</div>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50">
    <div class="bg-accent p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-xl font-bold text-white mb-4">Confirm Logout</h3>
        <p class="text-gray-300 mb-6">Are you sure you want to logout?</p>
        <div class="flex gap-4 justify-end">
            <button onclick="confirmLogout()" class="bg-primary text-dark px-6 py-2 rounded-full btn-primary font-semibold">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-700 text-white px-6 py-2 rounded-full hover:bg-gray-600 font-semibold">No</button>
        </div>
    </div>
</div>

<script>
    lucide.createIcons();

    function toggleProfileDropdown() {
        const dropdown = document.getElementById('profileDropdown');
        dropdown.classList.toggle('hidden');
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
                if (data.status === 'success') {
                    window.location.href = '../index.jsp';
                } else {
                    Toastify({
                        text: "Logout failed: " + data.message,
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Toastify({
                    text: "An error occurred during logout.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            });
    }

    function submitBooking(event) {
        event.preventDefault();
        const customerId = '<%= customerId %>';
        const formData = {
            customer_id: customerId,
            pickup_location: document.getElementById('pickup_location').value,
            dropoff_location: document.getElementById('dropoff_location').value,
            hire_date: document.getElementById('hire_date').value,
            hire_time: document.getElementById('hire_time').value,
            passenger_count: parseInt(document.getElementById('passenger_count').value, 10)
        };

        fetch('<%= request.getContextPath() %>/booking', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                console.log('Booking Response:', data);
                if (data.status === 'success') {
                    document.getElementById('bookingNumber').innerText = data.bookingNumber;
                    document.getElementById('carDetails').innerText = data.carDetails.plateNumber;
                    document.getElementById('pickupLocation').innerText = data.pickupLocation;
                    document.getElementById('dropoffLocation').innerText = data.dropoffLocation;
                    document.getElementById('hireDate').innerText = data.hireDate;
                    document.getElementById('hireTime').innerText = data.hireTime;
                    document.getElementById('distance').innerText = data.distance.toFixed(2) + ' km';
                    document.getElementById('totalFare').innerText = 'Rs. '+ data.total_fare.toFixed(2);

                    document.getElementById('bookingModal').dataset.bookingId = data.bookingId;
                    document.getElementById('bookingModal').classList.remove('hidden');
                } else {
                    Toastify({
                        text: "Booking failed: " + data.message,
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Toastify({
                    text: "An error occurred while booking: " + error.message,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            });
    }

    function confirmBooking(status) {
        const bookingId = document.getElementById('bookingModal').dataset.bookingId;
        fetch('<%= request.getContextPath() %>/booking/confirm', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ bookingId: bookingId, status: status })
        })
            .then(response => {
                console.log('Response Status:', response.status);
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                console.log('Parsed Confirm Response:', data);
                if (data.status === 'success') {
                    Toastify({
                        text: `Booking ${status == 'confirmed' ? 'confirmed' : 'cancelled'} successfully!`,
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "#FCC603", color: "#1A1A1A" }
                    }).showToast();
                    setTimeout(() => {
                        window.location.href = "<%= request.getContextPath() %>/views/customer/dashboard.jsp";
                    }, 2000);
                } else {
                    Toastify({
                        text: `${status == 'confirmed' ? 'Confirmation' : 'Cancellation'} failed: ${data.message}`,
                        duration: 3000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        style: { background: "red" }
                    }).showToast();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Toastify({
                    text: `An error occurred while ${status == 'confirmed' ? 'confirming' : 'cancelling'}: ${error.message}`,
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" }
                }).showToast();
            });
    }

    function closeBookingModal() {
        document.getElementById('bookingModal').classList.add('hidden');
    }
</script>
</body>
</html>