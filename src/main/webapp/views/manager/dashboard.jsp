<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard - Mega City Cabs</title>
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
<!-- Sidebar -->
<div class="flex h-screen">
    <div class="w-64 bg-dark/80 p-6">
        <h2 class="text-2xl font-bold text-white mb-6">Manager Dashboard</h2>
        <ul>
            <li><a href="javascript:void(0);" onclick="showSection('vehicles')" class="text-white py-2 block hover:bg-primary hover:text-black">Vehicles Management</a></li>
            <li><a href="javascript:void(0);" onclick="showSection('drivers')" class="text-white py-2 block hover:bg-primary hover:text-black">Driver Management</a></li>
            <li><a href="javascript:void(0);" onclick="showSection('assignments')" class="text-white py-2 block hover:bg-primary hover:text-black">Driver Assignment</a></li>
            <li><a href="javascript:void(0);" onclick="showSection('status')" class="text-white py-2 block hover:bg-primary hover:text-black">Status Monitoring</a></li>
            <li><a href="javascript:void(0);" onclick="showSection('tools')" class="text-white py-2 block hover:bg-primary hover:text-black">Other Tools</a></li>
        </ul>
    </div>

    <!-- Main Content Area -->
    <div class="flex-1 p-6">
        <!-- Vehicles Management Section -->
        <section id="vehicles" class="section hidden">
            <h3 class="text-2xl font-bold mb-4">Vehicles Management</h3>
            <div class="mb-4">
                <button onclick="openVehicleModal()" class="bg-primary px-4 py-2 text-black font-semibold rounded-md hover:bg-primary-700 transition">Add New Vehicle</button>
            </div>
            <table class="min-w-full bg-dark/50 border border-white/10 rounded-lg">
                <thead>
                <tr class="bg-dark/70">
                    <th class="px-6 py-3 text-left text-sm font-semibold">Vehicle ID</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Model</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Status</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Actions</th>
                </tr>
                </thead>
                <tbody id="vehicleTableBody">
                <!-- Example Row -->
                <tr class="border-b border-white/10">
                    <td class="px-6 py-4">V001</td>
                    <td class="px-6 py-4">Toyota Corolla</td>
                    <td class="px-6 py-4">Available</td>
                    <td class="px-6 py-4">
                        <button class="bg-blue-500 px-4 py-2 text-white rounded-md hover:bg-blue-700">Edit</button>
                    </td>
                </tr>
                </tbody>
            </table>
        </section>

        <!-- Driver Management Section -->
        <section id="drivers" class="section hidden mt-10">
            <h3 class="text-2xl font-bold mb-4">Driver Management</h3>
            <div class="mb-4">
                <button onclick="openDriverModal()" class="bg-primary px-4 py-2 text-black font-semibold rounded-md hover:bg-primary-700 transition">Add New Driver</button>
            </div>
            <table class="min-w-full bg-dark/50 border border-white/10 rounded-lg">
                <thead>
                <tr class="bg-dark/70">
                    <th class="px-6 py-3 text-left text-sm font-semibold">Driver ID</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Name</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Status</th>
                    <th class="px-6 py-3 text-left text-sm font-semibold">Actions</th>
                </tr>
                </thead>
                <tbody id="driverTableBody">
                <!-- Example Row -->
                <tr class="border-b border-white/10">
                    <td class="px-6 py-4">D001</td>
                    <td class="px-6 py-4">Jane Doe</td>
                    <td class="px-6 py-4">Available</td>
                    <td class="px-6 py-4">
                        <button class="bg-blue-500 px-4 py-2 text-white rounded-md hover:bg-blue-700">Edit</button>
                    </td>
                </tr>
                </tbody>
            </table>
        </section>

        <!-- Driver Assignment Section -->
        <section id="assignments" class="section hidden mt-10">
            <h3 class="text-2xl font-bold mb-4">Driver Assignment</h3>
            <form>
                <label for="vehicleSelect" class="block text-sm font-medium">Assign Vehicle</label>
                <select id="vehicleSelect" class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
                    <option value="V001">Toyota Corolla</option>
                    <option value="V002">Honda Civic</option>
                </select>
                <label for="driverSelect" class="block text-sm font-medium mt-4">Assign Driver</label>
                <select id="driverSelect" class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
                    <option value="D001">Jane Doe</option>
                    <option value="D002">John Smith</option>
                </select>
                <button type="submit" class="bg-primary px-4 py-2 mt-4 text-black font-semibold rounded-md hover:bg-primary-700 transition">Assign Driver</button>
            </form>
        </section>

        <!-- Status Monitoring Section -->
        <section id="status" class="section hidden mt-10">
            <h3 class="text-2xl font-bold mb-4">Status Monitoring</h3>
            <div class="mb-4">
                <button onclick="checkStatus()" class="bg-primary px-4 py-2 text-black font-semibold rounded-md hover:bg-primary-700 transition">Check Status</button>
            </div>
            <!-- Status will be displayed here after checking -->
            <div id="statusResult" class="text-white">Status information will appear here...</div>
        </section>

        <!-- Other Tools Section -->
        <section id="tools" class="section hidden mt-10">
            <h3 class="text-2xl font-bold mb-4">Other Tools</h3>
            <!-- Additional management tools can be added here -->
        </section>
    </div>
</div>

<!-- Modals for Adding Vehicles/Drivers -->
<!-- Add Vehicle Modal -->
<div id="vehicleModal" class="fixed inset-0 bg-black/50 hidden flex justify-center items-center">
    <div class="bg-dark/90 p-8 rounded-lg border border-white/10 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6">Add New Vehicle</h2>
        <form action="${pageContext.request.contextPath}/AddVehicle" method="post">
            <div class="mb-4">
                <label for="vehicleModel" class="block text-sm font-medium mb-2">Model</label>
                <input type="text" id="vehicleModel" name="model" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
            </div>
            <div class="mb-4">
                <label for="vehicleStatus" class="block text-sm font-medium mb-2">Status</label>
                <select id="vehicleStatus" name="status" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
                    <option value="available">Available</option>
                    <option value="on-hire">On Hire</option>
                </select>
            </div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeVehicleModal()" class="px-4 py-2 border border-white/20 text-white rounded-md hover:bg-white/10">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-primary text-black rounded-md hover:bg-primary-700">Add Vehicle</button>
            </div>
        </form>
    </div>
</div>

<!-- Add Driver Modal -->
<div id="driverModal" class="fixed inset-0 bg-black/50 hidden flex justify-center items-center">
    <div class="bg-dark/90 p-8 rounded-lg border border-white/10 w-full max-w-md">
        <h2 class="text-2xl font-bold mb-6">Add New Driver</h2>
        <form action="${pageContext.request.contextPath}/AddDriver" method="post">
            <div class="mb-4">
                <label for="driverName" class="block text-sm font-medium mb-2">Name</label>
                <input type="text" id="driverName" name="name" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
            </div>
            <div class="mb-4">
                <label for="driverStatus" class="block text-sm font-medium mb-2">Status</label>
                <select id="driverStatus" name="status" required class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white">
                    <option value="available">Available</option>
                    <option value="on-duty">On Duty</option>
                </select>
            </div>
            <div class="flex justify-end gap-4">
                <button type="button" onclick="closeDriverModal()" class="px-4 py-2 border border-white/20 text-white rounded-md hover:bg-white/10">Cancel</button>
                <button type="submit" class="px-4 py-2 bg-primary text-black rounded-md hover:bg-primary-700">Add Driver</button>
            </div>
        </form>
    </div>
</div>

<script>
    // Show specific section and hide others
    function showSection(sectionId) {
        // Hide all sections
        document.querySelectorAll('.section').forEach(function(section) {
            section.classList.add('hidden');
        });

        // Show the clicked section
        document.getElementById(sectionId).classList.remove('hidden');
    }

    // Open Vehicle Modal
    function openVehicleModal() {
        document.getElementById('vehicleModal').classList.remove('hidden');
    }

    // Close Vehicle Modal
    function closeVehicleModal() {
        document.getElementById('vehicleModal').classList.add('hidden');
    }

    // Open Driver Modal
    function openDriverModal() {
        document.getElementById('driverModal').classList.remove('hidden');
    }

    // Close Driver Modal
    function closeDriverModal() {
        document.getElementById('driverModal').classList.add('hidden');
    }

    // Function to check status (you can add real status check logic)
    function checkStatus() {
        document.getElementById('statusResult').innerHTML = "The status is checked!";
    }
</script>
</body>
</html>
