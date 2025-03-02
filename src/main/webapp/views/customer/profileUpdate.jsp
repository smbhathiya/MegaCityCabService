<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.CustomerDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Customer" %>
<%
    UUID customerUUID = (UUID) session.getAttribute("userId");
    String customerId = customerUUID != null ? customerUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (customerId == null || !"customer".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    CustomerDAO customerDAO = new CustomerDAO();
    Customer customer = null;
    String errorMessage = null;
    String successMessage = null;

    // Fetch customer data on page load
    try {
        customer = customerDAO.getCustomerById(customerUUID);
        if (customer == null) {
            errorMessage = "Customer not found.";
        }
    } catch (Exception e) {
        errorMessage = "Error fetching customer data: " + e.getMessage();
    }

    // Handle profile update
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String contactNo = request.getParameter("contactNo");
        String address = request.getParameter("address");

        try {
            boolean updated = customerDAO.updateCustomer(customerUUID, name, contactNo, address, email);
            if (updated) {
                successMessage = "Profile updated successfully!";
                customer = customerDAO.getCustomerById(customerUUID); // Refresh customer data
            } else {
                errorMessage = "Failed to update profile.";
            }
        } catch (Exception e) {
            errorMessage = "Error updating profile: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
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
        .form-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
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
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                        <span class="text-white"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Guest" %></span>
                    </button>
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
<div class="container mx-auto px-4 py-16 min-h-screen flex items-center justify-center">
    <div class="max-w-lg w-full form-container p-8 rounded-xl shadow-2xl">
        <h2 class="text-2xl font-bold text-light text-center mb-4">Update Profile</h2>
        <form id="profileForm" method="post" action="<%= request.getContextPath() %>/views/customer/profileUpdate.jsp">
            <div class="mb-4">
                <label for="name" class="block text-sm font-medium text-light">Name</label>
                <input type="text" id="name" name="name" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable"
                       value="<%= customer != null && customer.getName() != null ? customer.getName() : "" %>" disabled required>
            </div>
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium text-light">Email</label>
                <input type="email" id="email" name="email" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable"
                       value="<%= customer != null && customer.getEmail() != null ? customer.getEmail() : "" %>" disabled required>
            </div>
            <div class="mb-4">
                <label for="contactNo" class="block text-sm font-medium text-light">Contact Number</label>
                <input type="text" id="contactNo" name="contactNo" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable"
                       value="<%= customer != null && customer.getContactNo() != null ? customer.getContactNo() : "" %>" disabled required>
            </div>
            <div class="mb-4">
                <label for="address" class="block text-sm font-medium text-light">Address</label>
                <textarea id="address" name="address" class="mt-1 p-2 w-full bg-dark/50 rounded-md text-light editable" disabled required><%= customer != null && customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
            </div>
            <button type="button" id="editButton" class="w-full bg-red-700 text-dark p-2 rounded-md hover:bg-red-500 transition">Edit</button>
            <button type="submit" id="updateButton" class="w-full bg-primary text-dark p-2 rounded-md hover:bg-primary-700 transition hidden">Update Profile</button>
        </form>
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
            <button onclick="confirmLogout()" class="bg-primary text-dark px-4 py-2 rounded-md hover:bg-primary-700">Yes</button>
            <button onclick="cancelLogout()" class="bg-gray-600 text-white px-4 py-2 rounded-md hover:bg-gray-500 ml-2">No</button>
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
            callback: function() {
                let editables = document.querySelectorAll('.editable');
                editables.forEach(input => {
                    input.disabled = true;
                    input.classList.remove('editing');
                });
                document.getElementById('editButton').classList.remove('hidden');
                document.getElementById('updateButton').classList.add('hidden');
            }
        }).showToast();
        <% } %>
    });
</script>

</body>
</html>