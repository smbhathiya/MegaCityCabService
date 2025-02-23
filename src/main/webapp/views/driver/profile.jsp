<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
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
                        light: '#F5F5F5'
                    }
                }
            }
        };
    </script>
    <style>
        body {
            background-color: #1A1A1A;
            color: white;
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
        .form-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
            color: #F5F5F5; /* White text for primary buttons */
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        #editButton {
            color: #F5F5F5; /* White text for Edit button */
        }
        #changePasswordButton {
            background-color: #FCC603; /* Yellow background for Change Password button */
            color: #F5F5F5; /* White text */
        }
        #changePasswordButton:hover {
            background-color: #CC9F02; /* Darker yellow on hover */
        }
        #passwordModal input {
            border: 1px solid #FCC603; /* Primary color border for password textboxes */
            background-color: rgba(255, 255, 255, 0.1);
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
<div class="container mx-auto px-4 py-16">
    <%
        UUID driverUUID = (UUID) session.getAttribute("userId");
        String driverId = driverUUID != null ? driverUUID.toString() : null;
        if (driverId != null) {
    %>
    <div class="container mx-auto px-4 py-16 min-h-screen flex items-center justify-center">
        <div class="max-w-lg w-full form-container p-8 rounded-xl shadow-2xl">
            <h2 class="text-2xl font-bold text-light text-center mb-4">Update Driver Profile</h2>
            <form id="profileForm">
                <div class="mb-4">
                    <label for="name" class="block text-sm font-medium text-light">Name</label>
                    <input type="text" id="name" name="name" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled>
                </div>
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-light">Email</label>
                    <input type="email" id="email" name="email" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled>
                </div>
                <div class="mb-4">
                    <label for="licenseNumber" class="block text-sm font-medium text-light">License Number</label>
                    <input type="text" id="licenseNumber" name="licenseNumber" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled>
                </div>
                <div class="flex gap-4">
                    <button type="button" id="editButton" class="w-full bg-red-700 text-dark p-2 rounded-md hover:bg-red-500 transition">Edit</button>
                    <button type="submit" id="updateButton" class="w-full bg-primary text-dark p-2 rounded-md hover:bg-primary-700 transition hidden">Update Profile</button>
                </div>
                <button type="button" id="changePasswordButton" class="w-full bg-blue-700 text-dark p-2 rounded-md hover:bg-blue-500 transition mt-4">Change Password</button>
            </form>
        </div>
    </div>
    <%
        } else {
            Object userIdObj = session.getAttribute("userId");
            if (userIdObj == null || !(userIdObj instanceof UUID)) {
                response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
                return;
            }
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
            <button onclick="confirmLogout()" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500 ml-2">No</button>
        </div>
    </div>
</div>

<!-- Password Change Modal -->
<div id="passwordModal" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center hidden">
    <div class="bg-dark p-6 rounded-lg max-w-md w-full">
        <h3 class="text-lg font-bold text-white mb-4">Change Password</h3>
        <form id="passwordForm">
            <div class="mb-4">
                <label for="oldPassword" class="block text-sm font-medium text-light">Previous Password</label>
                <input type="password" id="oldPassword" name="oldPassword" required
                       class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light">
            </div>
            <div class="mb-4">
                <label for="newPassword" class="block text-sm font-medium text-light">New Password</label>
                <input type="password" id="newPassword" name="newPassword" required
                       class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light">
            </div>
            <div class="flex gap-4 justify-end">
                <button type="submit" class="bg-primary text-white px-4 py-2 rounded-md hover:bg-primary-700">Update Password</button>
                <button type="button" onclick="closePasswordModal()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500">Cancel</button>
            </div>
        </form>
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

    // Show logout confirmation modal
    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    // Hide logout confirmation modal
    function cancelLogout() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

    // Confirm logout and perform the action
    function confirmLogout() {
        fetch('${pageContext.request.contextPath}/logout', {
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

    // Fetch driver data
    function fetchDriverData() {
        fetch('${pageContext.request.contextPath}/driver?id=' + '<%= driverId %>', {
            method: 'GET',
            headers: { 'Content-Type': 'application/json' }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status !== "error") {
                    document.getElementById('name').value = data.name || '';
                    document.getElementById('email').value = data.email || '';
                    document.getElementById('licenseNumber').value = data.licenseNumber || '';
                } else {
                    Toastify({
                        text: "Failed to fetch driver data: " + data.message,
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
                console.error('Error fetching driver data:', error);
                Toastify({
                    text: "Error fetching driver data.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    // Show password change modal
    function showPasswordModal() {
        document.getElementById('passwordModal').classList.remove('hidden');
    }

    // Hide password change modal
    function closePasswordModal() {
        document.getElementById('passwordModal').classList.add('hidden');
        document.getElementById('passwordForm').reset();
    }

    // DOM Content Loaded Event Listener
    document.addEventListener("DOMContentLoaded", function () {
        // Fetch data on page load
        fetchDriverData();

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

        // Form submission handler for profile update
        document.getElementById('profileForm').addEventListener('submit', function (e) {
            e.preventDefault();

            let jsonObject = {
                id: '<%= driverId %>',
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                licenseNumber: document.getElementById('licenseNumber').value
            };

            fetch('${pageContext.request.contextPath}/driver', {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(jsonObject)
            })
                .then(response => response.json())
                .then(data => {
                    if (data.status === "success") {
                        Toastify({
                            text: "Profile updated successfully!",
                            duration: 1500,
                            close: true,
                            gravity: "top",
                            position: "right",
                            style: { background: "green" },
                            stopOnFocus: true
                        }).showToast();

                        let editables = document.querySelectorAll('.editable');
                        editables.forEach(input => {
                            input.disabled = true;
                            input.classList.remove('editing');
                        });
                        document.getElementById('editButton').classList.remove('hidden');
                        document.getElementById('updateButton').classList.add('hidden');
                    } else {
                        Toastify({
                            text: "Update failed: " + data.message,
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
                    console.error('Error updating profile:', error);
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

        // Change password button handler
        document.getElementById('changePasswordButton').addEventListener('click', showPasswordModal);

        // Password form submission handler
        document.getElementById('passwordForm').addEventListener('submit', function (e) {
            e.preventDefault();

            let passwordData = {
                id: '<%= driverId %>',
                oldPassword: document.getElementById('oldPassword').value,
                newPassword: document.getElementById('newPassword').value
            };

            fetch('${pageContext.request.contextPath}/driver/password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(passwordData)
            })
                .then(response => response.json())
                .then(data => {
                    if (data.status === "success") {
                        Toastify({
                            text: "Password updated successfully!",
                            duration: 1500,
                            close: true,
                            gravity: "top",
                            position: "right",
                            style: { background: "green" },
                            stopOnFocus: true
                        }).showToast();
                        closePasswordModal();
                    } else {
                        Toastify({
                            text: "Password update failed: " + data.message,
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
                    console.error('Error updating password:', error);
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
    });
</script>

</body>
</html>