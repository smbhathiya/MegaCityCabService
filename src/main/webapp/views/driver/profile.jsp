<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.DriverDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Driver" %>
<%@ page import="com.cabservice.megacitycabservice.util.PasswordUtil" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    UUID driverUUID = (UUID) session.getAttribute("userId");
    String driverId = driverUUID != null ? driverUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (driverId == null || !"driver".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    DriverDAO driverDAO = new DriverDAO();
    Driver driver = null;
    String errorMessage = null;
    String successMessage = null;
    String toastType = null;

    // Fetch driver data on page load
    try {
        driver = driverDAO.getDriverById(driverUUID);
        if (driver == null) {
            errorMessage = "Driver not found.";
        }
    } catch (Exception e) {
        errorMessage = "Error fetching driver data: " + e.getMessage();
    }

    // Handle profile update
    String action = request.getParameter("action");
    if ("updateProfile".equals(action)) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String licenseNumber = request.getParameter("licenseNumber");
        try {
            boolean updated = driverDAO.updateDriver(driverUUID, name, email, licenseNumber);
            if (updated) {
                successMessage = "Profile updated successfully!";
                toastType = "success";
                driver = driverDAO.getDriverById(driverUUID); // Refresh driver data
            } else {
                errorMessage = "Failed to update profile.";
                toastType = "error";
            }
        } catch (Exception e) {
            errorMessage = "Error updating profile: " + e.getMessage();
            toastType = "error";
        }
    }

    // Handle password update
    if ("updatePassword".equals(action)) {
        String oldPassword = request.getParameter("oldPassword");
        String newPassword = request.getParameter("newPassword");
        try {
            String currentPasswordHash = driverDAO.getPasswordHashById(driverUUID);
            if (currentPasswordHash != null && PasswordUtil.verifyPassword(oldPassword, currentPasswordHash)) {
                String newPasswordHash = PasswordUtil.hashPassword(newPassword);
                boolean updated = driverDAO.updateDriverPassword(driverUUID, newPasswordHash);
                if (updated) {
                    successMessage = "Password updated successfully!";
                    toastType = "success";
                } else {
                    errorMessage = "Failed to update password.";
                    toastType = "error";
                }
            } else {
                errorMessage = "Old password is incorrect.";
                toastType = "error";
            }
        } catch (Exception e) {
            errorMessage = "Error updating password: " + e.getMessage();
            toastType = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Profile - Mega City Cabs</title>
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
            cursor: pointer;
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        }
        .card div {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            color: inherit;
            height: 100%;
        }
        .editable {
            background-color: rgba(255, 255, 255, 0.1);
            border: none;
        }
        .editable.editing {
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        input[type="email"][disabled] {
            border: none;
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
        #passwordModal input {
            border: 1px solid #FCC603;
            background-color: rgba(255, 255, 255, 0.1);
        }
        .cards-container {
            display: flex;
            justify-content: flex-start;
            max-width: 1200px;
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
                        <p class="text-sm text-light/70">Driver Privacy Settings</p>
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
<div class="container mx-auto px-4 py-16 min-h-screen flex items-center">
    <div class="cards-container w-full">
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-8">
            <!-- Update Profile Card -->
            <div class="card p-8 animate-slide-up" onclick="showProfileModal()">
                <div>
                    <i data-lucide="user" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Update Profile</h2>
                </div>
            </div>

            <!-- Update Password Card -->
            <div class="card p-8 animate-slide-up" onclick="showPasswordModal()">
                <div>
                    <i data-lucide="lock" class="w-12 h-12 text-primary mb-4"></i>
                    <h2 class="text-xl font-semibold text-white">Update Password</h2>
                </div>
            </div>
        </div>
    </div>
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

<!-- Profile Update Modal -->
<div id="profileModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="modal-content p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-xl font-bold text-white mb-4">Update Profile</h3>
        <form method="post" action="<%= request.getContextPath() %>/views/driver/profile.jsp">
            <input type="hidden" name="action" value="updateProfile">
            <div class="mb-4">
                <label for="name" class="block text-sm font-medium text-light">Name</label>
                <input type="text" id="name" name="name" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" value="<%= driver != null && driver.getName() != null ? driver.getName() : "" %>" disabled required>
            </div>
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium text-light">Email</label>
                <input type="email" id="email" name="email" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" value="<%= driver != null && driver.getEmail() != null ? driver.getEmail() : "" %>" disabled required>
            </div>
            <div class="mb-4">
                <label for="licenseNumber" class="block text-sm font-medium text-light">License Number</label>
                <input type="text" id="licenseNumber" name="licenseNumber" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" value="<%= driver != null && driver.getLicenseNumber() != null ? driver.getLicenseNumber() : "" %>" disabled required>
            </div>
            <div class="flex gap-4">
                <button type="button" id="editButton" class="w-full bg-red-700 text-white p-2 rounded-md hover:bg-red-500 transition btn-primary">Edit</button>
                <button type="submit" id="updateButton" class="w-full bg-primary text-white p-2 rounded-md hover:bg-primary-700 transition btn-primary hidden">Update Profile</button>
            </div>
            <button type="button" onclick="closeProfileModal()" class="w-full bg-gray-600 text-white p-2 rounded-md hover:bg-gray-500 mt-4">Close</button>
        </form>
    </div>
</div>

<!-- Password Change Modal -->
<div id="passwordModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="modal-content p-6 rounded-xl shadow-2xl max-w-md w-full">
        <h3 class="text-lg font-bold text-white mb-4">Change Password</h3>
        <form method="post" action="<%= request.getContextPath() %>/views/driver/profile.jsp">
            <input type="hidden" name="action" value="updatePassword">
            <div class="mb-4">
                <label for="oldPassword" class="block text-sm font-medium text-light">Previous Password</label>
                <input type="password" id="oldPassword" name="oldPassword" required class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light">
            </div>
            <div class="mb-4">
                <label for="newPassword" class="block text-sm font-medium text-light">New Password</label>
                <input type="password" id="newPassword" name="newPassword" required class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light">
            </div>
            <div class="flex gap-4 justify-end">
                <button type="submit" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700 btn-primary">Update Password</button>
                <button type="button" onclick="closePasswordModal()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500">Cancel</button>
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

    function showProfileModal() {
        document.getElementById('profileModal').classList.remove('hidden');
    }

    function closeProfileModal() {
        document.getElementById('profileModal').classList.add('hidden');
        let editables = document.querySelectorAll('.editable');
        editables.forEach(input => {
            input.disabled = true;
            input.classList.remove('editing');
        });
        document.getElementById('editButton').classList.remove('hidden');
        document.getElementById('updateButton').classList.add('hidden');
    }

    function showPasswordModal() {
        document.getElementById('passwordModal').classList.remove('hidden');
    }

    function closePasswordModal() {
        document.getElementById('passwordModal').classList.add('hidden');
        document.getElementById('passwordForm').reset();
    }

    document.addEventListener("DOMContentLoaded", function () {
        // Edit button click handler
        document.getElementById('editButton').addEventListener('click', function () {
            let editables = document.querySelectorAll('.editable');
            editables.forEach(input => {
                input.disabled = false;
                input.classList.add('editing');
            });
            document.getElementById('editButton').classList.add('hidden');
            document.getElementById('updateButton').classList.remove('hidden');
        });

        // Display toast messages if set
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
        <% } else if (successMessage != null) { %>
        Toastify({
            text: "<%= successMessage %>",
            duration: 1500,
            close: true,
            gravity: "top",
            position: "right",
            style: { background: "green" },
            stopOnFocus: true,
            onClick: function() { closeProfileModal(); }
        }).showToast();
        <% } %>
    });
</script>

</body>
</html>