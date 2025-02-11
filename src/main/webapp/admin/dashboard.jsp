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
<nav class="fixed top-0 left-0 right-0 z-50 backdrop-blur-sm">
    <div class="container mx-auto px-4 py-2">
        <div class="flex h-16 items-center justify-between">
            <div class="text-2xl font-bold text-white flex items-center gap-2">
                <i data-lucide="settings" class="w-8 h-8 text-primary"></i>
                Admin Dashboard
            </div>
            <form action="${pageContext.request.contextPath}/Logout" method="get">
                <button type="submit" class="px-4 py-2 bg-red-500 text-white rounded-md flex items-center gap-2 hover:bg-red-700 transition">
                    <i data-lucide="log-out" class="w-5 h-5"></i>
                    Logout
                </button>
            </form>
        </div>
    </div>
</nav>

<!-- Dashboard Section -->
<section class="container mx-auto px-4 py-24">
    <h2 class="text-3xl font-bold mb-6">User Management</h2>

    <!-- Search & Filter Row -->
    <div class="flex items-center justify-between mb-6">
        <div class="flex gap-4 w-full">
            <input type="text" id="searchUser" placeholder="Search users..." class="px-4 py-2 w-80 bg-dark/20 border border-white/20 rounded-md text-white">
            <select id="userTypeFilter" class="px-4 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
                <option value="all">All Users</option>
                <option value="manager">Manager</option>
                <option value="customer">Customer</option>
                <option value="driver">Driver</option>
            </select>
        </div>
        <button onclick="openCreateManagerModal()" class="bg-primary px-4 py-2 text-black font-semibold rounded-md flex items-center gap-2 hover:bg-primary-700 transition whitespace-nowrap w-fit">
            <i data-lucide="user-plus" class="w-5 h-5"></i>
            Create Manager
        </button>


    </div>

    <!-- Users Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full bg-dark/50 border border-white/10 rounded-lg">
            <thead>
            <tr class="bg-dark/70">
                <th class="px-6 py-3 text-left text-sm font-semibold">Name</th>
                <th class="px-6 py-3 text-left text-sm font-semibold">Email</th>
                <th class="px-6 py-3 text-left text-sm font-semibold">Role</th>
                <th class="px-6 py-3 text-left text-sm font-semibold">Status</th>
                <th class="px-6 py-3 text-left text-sm font-semibold">Actions</th>
            </tr>
            </thead>
            <tbody id="userTableBody">
            <tr class="border-b border-white/10">
                <td class="px-6 py-4">John Doe</td>
                <td class="px-6 py-4">john.doe@example.com</td>
                <td class="px-6 py-4">Manager</td>
                <td class="px-6 py-4">Enabled</td>
                <td class="px-6 py-4">
                    <button class="bg-blue-500 px-4 py-2 text-white rounded-md hover:bg-blue-700">Edit</button>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</section>

<!-- Create Manager Modal -->
<div id="createManagerModal" class="fixed inset-0 bg-black/50 hidden flex justify-center items-center">
    <div class="bg-dark/90 p-8 rounded-lg border border-white/10 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6">Create Manager</h2>
        <form action="${pageContext.request.contextPath}/CreateManager" method="post">
            <div class="mb-4">
                <label for="name" class="block text-sm font-medium mb-2">Name</label>
                <input type="text" id="name" name="name" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
            </div>
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium mb-2">Email</label>
                <input type="email" id="email" name="email" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
            </div>
            <div class="mb-6">
                <label for="password" class="block text-sm font-medium mb-2">Password</label>
                <input type="password" id="password" name="password" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
            </div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeCreateManagerModal()" class="px-4 py-2 border border-white/20 text-white rounded-md hover:bg-white/10">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-primary text-black rounded-md hover:bg-primary-700">Create</button>
            </div>
        </form>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    lucide.createIcons();
    function openCreateManagerModal() { document.getElementById('createManagerModal').classList.remove('hidden'); }
    function closeCreateManagerModal() { document.getElementById('createManagerModal').classList.add('hidden'); }
</script>
</body>
</html>
