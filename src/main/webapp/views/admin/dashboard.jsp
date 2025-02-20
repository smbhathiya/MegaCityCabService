<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
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
        }
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.3);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        table {
            background-color: #2A2A2A;
        }
        th {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
        }
    </style>
</head>
<body class="bg-dark text-white">

<!-- Navbar (Imported from Customer Dashboard) -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="settings" class="w-10 h-10 text-primary"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Admin Dashboard</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-3 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-8 h-8 text-primary"></i>
                        <span class="text-lg text-white font-medium">${userName}</span>
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

<!-- Dashboard Section -->
<section class="container mx-auto px-6 py-28">
    <h2 class="text-4xl font-bold text-white mb-8 animate-fade-in">User Management</h2>

    <!-- Search & Filter Row -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-6 mb-10 animate-slide-up">
        <div class="flex gap-4 w-full sm:w-auto">
            <div class="relative w-full sm:w-80">
                <input type="text" id="searchUser" placeholder="Search users..."
                       class="w-full bg-accent rounded-full py-3 px-6 border border-white/10 text-light placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary/50">
                <i data-lucide="search" class="absolute right-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400"></i>
            </div>
            <select id="userTypeFilter"
                    class="px-6 py-3 bg-accent rounded-full border border-white/10 text-white focus:outline-none focus:ring-2 focus:ring-primary/50">
                <option value="all">All Users</option>
                <option value="manager">Manager</option>
                <option value="customer">Customer</option>
                <option value="driver">Driver</option>
            </select>
        </div>
        <button onclick="openCreateManagerModal()"
                class="bg-primary px-6 py-3 text-black font-semibold rounded-full btn-primary flex items-center gap-2 w-full sm:w-auto">
            <i data-lucide="user-plus" class="w-5 h-5"></i>
            Create Manager
        </button>
    </div>

    <!-- Users Table -->
    <div class="overflow-x-auto card p-6 animate-slide-up">
        <table class="min-w-full border border-white/10 rounded-xl">
            <thead>
            <tr>
                <th class="px-6 py-4 text-left text-sm font-semibold text-white">Name</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-white">Email</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-white">Role</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-white">Status</th>
                <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
            </tr>
            </thead>
            <tbody id="userTableBody"></tbody>
        </table>
    </div>
</section>

<!-- Create Manager Modal -->
<div id="createManagerModal" class="fixed inset-0 bg-dark/90 hidden flex justify-center items-center p-6 z-50"
     onclick="closeCreateManagerModal(event)">
    <div class="bg-accent p-8 rounded-xl shadow-2xl w-full max-w-md" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold text-white mb-6">Create Manager</h2>
        <form id="createManagerForm" action="${pageContext.request.contextPath}/CreateManager" method="post">
            <div class="mb-6">
                <label for="name" class="block text-sm font-medium text-gray-300 mb-2">Name</label>
                <input type="text" id="name" name="name" required
                       class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-6">
                <label for="email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
                <input type="email" id="email" name="email" required
                       class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-6">
                <label for="password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
                <input type="password" id="password" name="password" required
                       class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div id="createManagerError" class="text-red-500 text-sm mb-6 hidden"></div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeCreateManagerModal()"
                        class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-primary">
                    Cancel
                </button>
                <button type="submit"
                        class="px-6 py-2 bg-primary text-black rounded-full btn-primary font-semibold">
                    Create
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Edit User Modal -->
<div id="editUserModal" class="fixed inset-0 bg-dark/90 hidden flex justify-center items-center p-6 z-50"
     onclick="closeEditUserModal(event)">
    <div class="bg-accent p-8 rounded-xl shadow-2xl w-full max-w-md" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold text-white mb-6">Edit User</h2>
        <form id="editUserForm" action="${pageContext.request.contextPath}/EditUser" method="post">
            <input type="hidden" id="editUserId" name="userId">
            <div class="mb-6">
                <label for="editName" class="block text-sm font-medium text-gray-300 mb-2">Name</label>
                <input type="text" id="editName" name="name" required
                       class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-6">
                <label for="editEmail" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
                <input type="email" id="editEmail" name="email" required
                       class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-6">
                <label for="editRole" class="block text-sm font-medium text-gray-300 mb-2">Role</label>
                <select id="editRole" name="role"
                        class="w-full px-4 py-3 bg-dark/20 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
                    <option value="manager">Manager</option>
                    <option value="customer">Customer</option>
                    <option value="driver">Driver</option>
                </select>
            </div>
            <div id="editUserError" class="text-red-500 text-sm mb-6 hidden"></div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeEditUserModal()"
                        class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-primary">
                    Cancel
                </button>
                <button type="submit"
                        class="px-6 py-2 bg-primary text-black rounded-full btn-primary font-semibold">
                    Save
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Footer (Imported from Customer Dashboard) -->
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

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    lucide.createIcons();

    function toggleProfileDropdown() {
        document.getElementById('profileDropdown').classList.toggle('hidden');
    }

    document.addEventListener('click', function (event) {
        const dropdown = document.getElementById('profileDropdown');
        const profileButton = document.querySelector('button[onclick="toggleProfileDropdown()"]');
        if (!dropdown.contains(event.target) && !profileButton.contains(event.target)) {
            dropdown.classList.add('hidden');
        }
    });

    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    function cancelLogout() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

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
                    alert("Logout failed: " + data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert("An unexpected error occurred during logout.");
            });
    }

    function openCreateManagerModal() {
        document.getElementById('createManagerModal').classList.remove('hidden');
    }

    function closeCreateManagerModal(event) {
        if (event && event.target === document.getElementById('createManagerModal')) {
            document.getElementById('createManagerModal').classList.add('hidden');
        } else if (!event) {
            document.getElementById('createManagerModal').classList.add('hidden');
        }
    }

    function openEditUserModal(name, email, role, userId) {
        document.getElementById('editName').value = name;
        document.getElementById('editEmail').value = email;
        document.getElementById('editRole').value = role.toLowerCase();
        document.getElementById('editUserId').value = userId;
        document.getElementById('editUserModal').classList.remove('hidden');
    }

    function closeEditUserModal(event) {
        if (event && event.target === document.getElementById('editUserModal')) {
            document.getElementById('editUserModal').classList.add('hidden');
        } else if (!event) {
            document.getElementById('editUserModal').classList.add('hidden');
        }
    }

    function toggleUserStatus(checkbox, userId) {
        const statusText = checkbox.parentElement.querySelector('span');
        const isEnabled = checkbox.checked;

        fetch('${pageContext.request.contextPath}/UpdateUserStatus', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({userId, isEnabled})
        }).then(response => {
            if (response.ok) {
                statusText.textContent = isEnabled ? 'Enabled' : 'Disabled';
            } else {
                checkbox.checked = !isEnabled;
                statusText.textContent = !isEnabled ? 'Enabled' : 'Disabled';
            }
        }).catch(error => {
            console.error('Error updating status:', error);
            checkbox.checked = !isEnabled;
            statusText.textContent = !isEnabled ? 'Enabled' : 'Disabled';
        });
    }

    document.getElementById('searchUser').addEventListener('input', function () {
        const searchTerm = this.value.toLowerCase();
        const rows = document.querySelectorAll('#userTableBody tr');
        rows.forEach(row => {
            const name = row.querySelector('td').textContent.toLowerCase();
            row.style.display = name.includes(searchTerm) ? '' : 'none';
        });
    });

    function fetchUsers() {
        fetch('${pageContext.request.contextPath}/getAllUsers')
            .then(response => response.json())
            .then(users => {
                const userTableBody = document.getElementById('userTableBody');
                userTableBody.innerHTML = '';

                users.forEach(user => {
                    const row = document.createElement('tr');
                    row.className = 'border-b border-white/10';

                    row.innerHTML = `
                        <td class="px-6 py-4">${user.name}</td>
                        <td class="px-6 py-4">${user.email}</td>
                        <td class="px-6 py-4">${user.role}</td>
                        <td class="px-6 py-4">
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" ${user.isEnabled ? 'checked' : ''} class="sr-only peer" onchange="toggleUserStatus(this, ${user.id})">
                                <div class="w-11 h-6 bg-gray-700 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                                <span class="ml-3 text-sm">${user.isEnabled ? 'Enabled' : 'Disabled'}</span>
                            </label>
                        </td>
                        <td class="px-6 py-4 flex gap-2">
                            <button onclick="openEditUserModal('${user.name}', '${user.email}', '${user.role}', ${user.id})" class="bg-blue-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Edit</button>
                        </td>
                    `;

                    userTableBody.appendChild(row);
                });
            })
            .catch(error => console.error('Error fetching users:', error));
    }

    document.addEventListener('DOMContentLoaded', fetchUsers);
</script>

<!-- Logout Confirmation Modal -->
<div id="logoutModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50">
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