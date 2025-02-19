<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mega City Cabs - Update Profile</title>
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
            background-color: #1A1A1A; /* dark background */
            color: white;
        }
        .editable {
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
    <div class="card bg-dark/70 rounded-xl border border-light/10 p-6 max-w-lg mx-auto mt-16">
        <form id="profileForm">
            <div class="mb-4">
                <label for="name" class="block text-sm font-medium text-light">Name</label>
                <input type="text" id="name" name="name" class="mt-1 p-2 w-full bg-dark/50 rounded-md border border-light/10 text-light editable" disabled>
            </div>
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium text-light">Email</label>
                <input type="email" id="email" name="email" class="mt-1 p-2 w-full bg-dark/50 rounded-md border border-light/10 text-light" disabled readonly>
                <small class="text-gray-500">You can't update your email</small>
            </div>
            <div class="mb-4">
                <label for="contactNo" class="block text-sm font-medium text-light">Contact Number</label>
                <input type="text" id="contactNo" name="contactNo" class="mt-1 p-2 w-full bg-dark/50 rounded-md border border-light/10 text-light editable" disabled>
            </div>
            <div class="mb-4">
                <label for="address" class="block text-sm font-medium text-light">Address</label>
                <textarea id="address" name="address" class="mt-1 p-2 w-full bg-dark/50 rounded-md border border-light/10 text-light editable" disabled></textarea>
            </div>
            <button type="button" id="editButton" class="w-full bg-primary text-dark p-2 rounded-md hover:bg-primary-700 transition">Edit</button>
            <button type="submit" id="updateButton" class="w-full bg-primary text-dark p-2 rounded-md hover:bg-primary-700 transition hidden">Update Profile</button>
        </form>
    </div>
    <%
    } else {
    %>

    <div class="text-light mt-16">
        <div>Please login to update your profile.</div>
        <div class="flex ">
            <a href="../auth/login.jsp" class="bg-white text-dark text-dark px-2 pr-2 p-1 rounded-md hover:bg-white/50 transition justify-center items-center mt-2">Login</a>
        </div>
    </div>
    <%
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

<script>
    // Initialize Lucide Icons
    lucide.createIcons();

    // Toggle Profile Dropdown
    function toggleProfileDropdown() {
        const dropdown = document.getElementById('profileDropdown');
        dropdown.classList.toggle('hidden');
    }

    // Function to show logout confirmation modal
    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    // Function to hide logout confirmation modal
    function cancelLogout() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

    // Function to confirm logout and perform the action
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

    document.addEventListener("DOMContentLoaded", function () {
        // Function to fetch customer data
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
                    console.error('Error:', error);
                });
        }

        // Fetch data on page load
        fetchCustomerData();

        document.getElementById('editButton').addEventListener('click', function () {
            let editables = document.querySelectorAll('.editable');
            editables.forEach(input => input.disabled = false);
            document.getElementById('editButton').classList.add('hidden');
            document.getElementById('updateButton').classList.remove('hidden');
        });

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

                        setTimeout(() => location.reload(), 3000);
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
                    console.error('Error:', error);
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
