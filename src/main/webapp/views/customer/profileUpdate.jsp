<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile - Mega City Cabs</title>
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
                        <p class="text-sm text-light/70">Customer Dashboard</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-4">
                <!-- Profile Dropdown -->
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                        <span class="text-white">${userName}</span>
                    </button>
                    <!-- Dropdown Menu -->
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                        <div class="py-1">
                            <a href="${pageContext.request.contextPath}/views/customer/dashboard.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Dashboard</a>
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
        UUID customerUUID = (UUID) session.getAttribute("userId");
        String customerId = customerUUID != null ? customerUUID.toString() : null;
        if (customerId != null) {
    %>
    <div class="container mx-auto px-4 py-16 flex flex-col md:flex-row justify-center md:justify-start">
        <div class="max-w-lg w-full md:w-1/2">
            <h2 class="text-2xl font-bold text-light mb-4">Update Profile</h2>
            <form id="profileForm">
                <div class="mb-4">
                    <label for="name" class="block text-sm font-medium text-light">Name</label>
                    <input type="text" id="name" name="name" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled>
                </div>
                <div class="mb-4">
                    <label for="email" class="block text-sm font-medium text-light">Email</label>
                    <input type="email" id="email" name="email" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light" disabled readonly>
                </div>
                <div class="mb-4">
                    <label for="contactNo" class="block text-sm font-medium text-light">Contact Number</label>
                    <input type="text" id="contactNo" name="contactNo" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled>
                </div>
                <div class="mb-4">
                    <label for="address" class="block text-sm font-medium text-light">Address</label>
                    <textarea id="address" name="address" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled></textarea>
                </div>
                <button type="button" id="editButton" class="w-full bg-red-700 text-dark p-2 rounded-md hover:bg-red-500 transition">Edit</button>
                <button type="submit" id="updateButton" class="w-full bg-primary text-dark p-2 rounded-md hover:bg-primary-700 transition hidden">Update Profile</button>
            </form>
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
            <p class="text-gray-300">Are you sure you want to logout?</p>
            <div class="mt-4">
                <button onclick="confirmLogout()" class="bg-primary text-dark px-4 py-2 rounded-md hover:bg-primary-700">Yes</button>
                <button onclick="cancelLogout()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500 ml-2">No</button>
            </div>
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
                headers: {
                    'Content-Type': 'application/json'
                }
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

        // Fetch customer data
        function fetchCustomerData() {
            fetch('${pageContext.request.contextPath}/customer?id=' + '<%= customerId %>', {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
                .then(response => response.json())
                .then(data => {
                    if (data.status !== "error") {
                        document.getElementById('name').value = data.name;
                        document.getElementById('email').value = data.email;
                        document.getElementById('contactNo').value = data.contactNo;
                        document.getElementById('address').value = data.address;
                    }
                })
                .catch(error => {
                    console.error('Error fetching customer data:', error);
                });
        }

        // DOM Content Loaded Event Listener
        document.addEventListener("DOMContentLoaded", function () {
            // Fetch data on page load
            fetchCustomerData();

            // Edit button click handler
            document.getElementById('editButton').addEventListener('click', function () {
                let editables = document.querySelectorAll('.editable');
                editables.forEach(input => {
                    input.disabled = false;
                    input.classList.add('editing'); // Show borders
                });
                document.getElementById('editButton').classList.add('hidden');
                document.getElementById('updateButton').classList.remove('hidden');
            });

            // Form submission handler
            document.getElementById('profileForm').addEventListener('submit', function (e) {
                e.preventDefault();

                let jsonObject = {
                    id: '<%= customerId %>',
                    name: document.getElementById('name').value,
                    contact_no: document.getElementById('contactNo').value,
                    address: document.getElementById('address').value
                };

                fetch('${pageContext.request.contextPath}/customer', {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
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

                            // Reset form to view mode
                            let editables = document.querySelectorAll('.editable');
                            editables.forEach(input => {
                                input.disabled = true;
                                input.classList.remove('editing'); // Hide borders
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
        });
    </script>

</body>
</html>