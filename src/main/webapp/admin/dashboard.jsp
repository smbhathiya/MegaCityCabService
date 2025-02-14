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
                            700: '#CC9F02'
                        }
                    },
                    backgroundColor: {
                        'dark': '#000000'
                    }
                }
            }
        }
    </script>
    <link rel="stylesheet" href="https://unpkg.com/lucide@latest/icons.css">
</head>
<body class="bg-dark text-white">
<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 z-50 backdrop-blur-sm bg-dark/80">
    <div class="container mx-auto px-4 py-2">
        <div class="flex h-16 items-center justify-between">
            <div class="text-2xl font-bold text-white flex items-center gap-2">
                <i data-lucide="settings" class="w-8 h-8 text-primary"></i>
                <span class="hidden sm:inline">Admin Dashboard</span>
            </div>
            <!-- Profile Dropdown -->
            <div class="relative">
                <button onclick="toggleProfileDropdown()" class="flex items-center gap-2 focus:outline-none" aria-label="Toggle profile dropdown">
                    <i data-lucide="user" class="w-6 h-6 text-primary"></i>
                    <span class="text-white">${userName}</span> <!-- Display user's name -->
                </button>
                <!-- Dropdown Menu -->
                <div id="profileDropdown" class="absolute right-0 mt-2 w-48 bg-dark/90 border border-white/10 rounded-lg shadow-lg hidden">
                    <div class="py-1">
                        <a href="#" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Profile</a>
                        <form action="${pageContext.request.contextPath}/Logout" method="get">
                            <button type="submit" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Dashboard Section -->
<section class="container mx-auto px-4 py-24">
    <h2 class="text-3xl font-bold mb-6">User Management</h2>

    <!-- Search & Filter Row -->
    <div class="flex flex-col sm:flex-row items-center justify-between gap-4 mb-6">
        <div class="flex gap-4 w-full sm:w-auto">
            <label for="searchUser" class="sr-only">Search users</label>
            <input type="text" id="searchUser" placeholder="Search users..." class="px-4 py-2 w-full sm:w-80 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            <label for="userTypeFilter" class="sr-only">Filter by user type</label>
            <select id="userTypeFilter" class="px-4 py-2 bg-dark border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
                <option value="all">All Users</option>
                <option value="manager">Manager</option>
                <option value="customer">Customer</option>
                <option value="driver">Driver</option>
            </select>
        </div>
        <button onclick="openCreateManagerModal()" class="bg-primary px-4 py-2 text-black font-semibold rounded-md flex items-center gap-2 hover:bg-primary-700 transition whitespace-nowrap w-full sm:w-fit">
            <i data-lucide="user-plus" class="w-5 h-5"></i>
            <span>Create Manager</span>
        </button>
    </div>

    <!-- Users Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full bg-dark/50 border border-white/10 rounded-lg">
            <thead>
            <tr class="bg-dark/70">
                <th class="px-4 sm:px-6 py-3 text-left text-sm font-semibold">Name</th>
                <th class="px-4 sm:px-6 py-3 text-left text-sm font-semibold">Email</th>
                <th class="px-4 sm:px-6 py-3 text-left text-sm font-semibold">Role</th>
                <th class="px-4 sm:px-6 py-3 text-left text-sm font-semibold">Status</th>
                <th class="px-4 sm:px-6 py-3 text-left text-sm font-semibold">Actions</th>
            </tr>
            </thead>
            <tbody id="userTableBody">
            <c:forEach var="user" items="${userList}">
                <tr class="border-b border-white/10" data-user-id="${user.id}">
                    <td class="px-4 sm:px-6 py-4">${user.name}</td>
                    <td class="px-4 sm:px-6 py-4">${user.email}</td>
                    <td class="px-4 sm:px-6 py-4">${user.role}</td>
                    <td class="px-4 sm:px-6 py-4">
                        <label class="relative inline-flex items-center cursor-pointer">
                            <input type="checkbox" ${user.enabled ? 'checked' : ''} class="sr-only peer" onchange="toggleUserStatus(this, ${user.id})">
                            <div class="w-11 h-6 bg-gray-700 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary"></div>
                            <span class="ml-3 text-sm">${user.enabled ? 'Enabled' : 'Disabled'}</span>
                        </label>
                    </td>
                    <td class="px-4 sm:px-6 py-4 flex gap-2">
                        <button onclick="openEditUserModal('${user.name}', '${user.email}', '${user.role}', ${user.id})" class="bg-blue-500 px-4 py-2 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">Edit</button>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
</section>

<!-- Create Manager Modal -->
<div id="createManagerModal" class="fixed inset-0 bg-black/50 hidden flex justify-center items-center p-4" onclick="closeCreateManagerModal(event)">
    <div class="bg-dark/90 p-6 sm:p-8 rounded-lg border border-white/10 w-full max-w-md" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold mb-6">Create Manager</h2>
        <form id="createManagerForm" action="${pageContext.request.contextPath}/CreateManager" method="post">
            <div class="mb-4">
                <label for="name" class="block text-sm font-medium mb-2">Name</label>
                <input type="text" id="name" name="name" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium mb-2">Email</label>
                <input type="email" id="email" name="email" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-6">
                <label for="password" class="block text-sm font-medium mb-2">Password</label>
                <input type="password" id="password" name="password" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div id="createManagerError" class="text-red-500 text-sm mb-4 hidden"></div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeCreateManagerModal()" class="px-4 py-2 border border-white/20 text-white rounded-md hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-primary">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-primary text-black rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary">Create</button>
            </div>
        </form>
    </div>
</div>

<!-- Edit User Modal -->
<div id="editUserModal" class="fixed inset-0 bg-black/50 hidden flex justify-center items-center p-4" onclick="closeEditUserModal(event)">
    <div class="bg-dark/90 p-6 sm:p-8 rounded-lg border border-white/10 w-full max-w-md" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold mb-6">Edit User</h2>
        <form id="editUserForm" action="${pageContext.request.contextPath}/EditUser" method="post">
            <input type="hidden" id="editUserId" name="userId">
            <div class="mb-4">
                <label for="editName" class="block text-sm font-medium mb-2">Name</label>
                <input type="text" id="editName" name="name" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="editEmail" class="block text-sm font-medium mb-2">Email</label>
                <input type="email" id="editEmail" name="email" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="editRole" class="block text-sm font-medium mb-2">Role</label>
                <select id="editRole" name="role" class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white focus:outline-none focus:ring-2 focus:ring-primary">
                    <option value="manager">Manager</option>
                    <option value="customer">Customer</option>
                    <option value="driver">Driver</option>
                </select>
            </div>
            <div id="editUserError" class="text-red-500 text-sm mb-4 hidden"></div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeEditUserModal()" class="px-4 py-2 border border-white/20 text-white rounded-md hover:bg-white/10 focus:outline-none focus:ring-2 focus:ring-primary">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-primary text-black rounded-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-primary">Save</button>
            </div>
        </form>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    lucide.createIcons();

    // Toggle Profile Dropdown
    function toggleProfileDropdown() {
        const dropdown = document.getElementById('profileDropdown');
        dropdown.classList.toggle('hidden');
    }

    // Close Profile Dropdown when clicking outside
    document.addEventListener('click', function(event) {
        const dropdown = document.getElementById('profileDropdown');
        const profileButton = document.querySelector('button[onclick="toggleProfileDropdown()"]');
        if (!dropdown.contains(event.target) && !profileButton.contains(event.target)) {
            dropdown.classList.add('hidden');
        }
    });

    // Modal Functions
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

    // Toggle User Status
    function toggleUserStatus(checkbox, userId) {
        const statusText = checkbox.parentElement.querySelector('span');
        const isEnabled = checkbox.checked;

        fetch('/UpdateUserStatus', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ userId, isEnabled })
        }).then(response => {
            if (response.ok) {
                statusText.textContent = isEnabled ? 'Enabled' : 'Disabled';
            } else {
                checkbox.checked = !isEnabled; // Revert if the request fails
            }
        });
    }

    // Search Functionality
    document.getElementById('searchUser').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase();
        const rows = document.querySelectorAll('#userTableBody tr');
        rows.forEach(row => {
            const name = row.querySelector('td').textContent.toLowerCase();
            row.style.display = name.includes(searchTerm) ? '' : 'none';
        });
    });
</script>
</body>
</html>