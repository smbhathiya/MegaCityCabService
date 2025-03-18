<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.CarDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Car" %>
<%@ page import="java.util.List" %>
<%!
    private List<Car> getAllCars() {
        try {
            CarDAO dao = new CarDAO();
            return dao.getAllCars();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
%>
<%
    UUID adminUUID = (UUID) session.getAttribute("userId");
    String adminId = adminUUID != null ? adminUUID.toString() : null;
    String role = (String) session.getAttribute("role");
    if (adminId == null || !"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
        return;
    }

    // Handle form submissions
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        Car newCar = new Car();
        newCar.setId(UUID.randomUUID());
        newCar.setPlateNumber(request.getParameter("plate_number"));
        newCar.setModel(request.getParameter("model"));
        newCar.setBrand(request.getParameter("brand"));
        newCar.setYear(Integer.parseInt(request.getParameter("year")));
        newCar.setColor(request.getParameter("color"));
        newCar.setCapacity(Integer.parseInt(request.getParameter("capacity")));
        newCar.setStatus("available");
        try {
            CarDAO dao = new CarDAO();
            dao.addCar(newCar);
        } catch (Exception e) {
            e.printStackTrace();
        }
    } else if ("update".equals(action)) {
        Car updatedCar = new Car();
        updatedCar.setId(UUID.fromString(request.getParameter("id")));
        updatedCar.setPlateNumber(request.getParameter("plate_number"));
        updatedCar.setModel(request.getParameter("model"));
        updatedCar.setBrand(request.getParameter("brand"));
        updatedCar.setYear(Integer.parseInt(request.getParameter("year")));
        updatedCar.setColor(request.getParameter("color"));
        updatedCar.setCapacity(Integer.parseInt(request.getParameter("capacity")));
        updatedCar.setStatus(request.getParameter("status"));
        try {
            CarDAO dao = new CarDAO();
            dao.updateCar(updatedCar);
        } catch (Exception e) {
            e.printStackTrace();
        }
    } else if ("delete".equals(action)) {
        String carId = request.getParameter("id");
        try {
            CarDAO dao = new CarDAO();
            dao.removeCar(carId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    List<Car> cars = getAllCars();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Cars - Mega City Cabs</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
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
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    <style>
        body {
            background-color: #1A1A1A;
            font-family: 'Inter', sans-serif;
        }
        .form-container, .table-container {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
            backdrop-filter: blur(10px);
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
        input:focus, select:focus {
            transition: all 0.3s ease;
        }
        table {
            background-color: #2A2A2A;
        }
        th {
            background: linear-gradient(135deg, rgba(42, 42, 42, 0.9), rgba(26, 26, 26, 0.8));
        }
        @media (min-width: 768px) {
            .modal-form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
            }
            .modal-full-width {
                grid-column: span 2;
            }
        }
        @media (max-width: 767px) {
            .modal-form-grid {
                display: flex;
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body class="bg-dark text-white min-h-screen flex flex-col">

<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Manage Cars</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <div class="relative">
                    <button onclick="toggleProfileDropdown()" class="flex items-center gap-3 focus:outline-none" aria-label="Toggle profile dropdown">
                        <i data-lucide="user" class="w-8 h-8 text-primary"></i>
                        <span class="text-lg text-white font-medium"><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Guest" %></span>
                    </button>
                    <div id="profileDropdown" class="absolute right-0 mt-2 w-56 bg-dark/95 border border-white/10 rounded-xl shadow-lg hidden">
                        <div class="py-2">
                            <a href="${pageContext.request.contextPath}/views/admin/dashboard.jsp" class="block px-4 py-2 text-sm text-white hover:bg-white/10">Dashboard</a>
                            <button onclick="showLogoutModal()" class="w-full text-left px-4 py-2 text-sm text-white hover:bg-white/10">Logout</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="flex-1 pt-28 pb-12 px-6">
    <div class="container mx-auto">
        <!-- Cars Table -->
        <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-3xl font-bold text-white">Car List</h2>
                <button onclick="openAddCarModal()" class="bg-primary px-6 py-3 text-black font-semibold rounded-full btn-primary flex items-center gap-2">
                    <i data-lucide="plus" class="w-5 h-5"></i>
                    Add New Car
                </button>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full border border-white/10 rounded-lg">
                    <thead>
                    <tr>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Plate Number</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Model</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Brand</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Year</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Color</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Capacity</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Status</th>
                        <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
                    </tr>
                    </thead>
                    <tbody id="carTableBody">
                    <%
                        if (cars != null && !cars.isEmpty()) {
                            for (Car car : cars) {
                    %>
                    <tr class="border-b border-white/10">
                        <td class="px-6 py-4"><%= car.getPlateNumber() != null ? car.getPlateNumber() : "N/A" %></td>
                        <td class="px-6 py-4"><%= car.getModel() != null ? car.getModel() : "N/A" %></td>
                        <td class="px-6 py-4"><%= car.getBrand() != null ? car.getBrand() : "N/A" %></td>
                        <td class="px-6 py-4"><%= car.getYear() %></td>
                        <td class="px-6 py-4"><%= car.getColor() != null ? car.getColor() : "N/A" %></td>
                        <td class="px-6 py-4"><%= car.getCapacity() %></td>
                        <td class="px-6 py-4"><%= car.getStatus() != null ? car.getStatus() : "N/A" %></td>
                        <td class="px-6 py-4 flex gap-2">
                            <button onclick="openUpdateModal('<%= car.getId() %>')"
                                    class="bg-blue-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Edit</button>
                            <form method="post" action="<%= request.getContextPath() %>/views/admin/manageCars.jsp">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<%= car.getId() %>">
                                <button type="submit" onclick="return confirm('Are you sure you want to remove this car?')"
                                        class="bg-red-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Remove</button>
                            </form>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="8" class="text-center text-white py-4">No cars available</td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
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

<!-- Add Car Modal -->
<div id="addCarModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeAddCarModal(event)">
    <div class="bg-accent p-6 md:p-8 rounded-xl shadow-2xl w-full max-w-lg mx-4" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold text-white mb-6">Add New Car</h2>
        <form method="post" action="<%= request.getContextPath() %>/views/admin/manageCars.jsp" class="modal-form-grid">
            <input type="hidden" name="action" value="add">
            <div class="mb-4">
                <label for="plate_number" class="block text-sm font-medium text-gray-300 mb-2">Plate Number</label>
                <input type="text" id="plate_number" name="plate_number" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="model" class="block text-sm font-medium text-gray-300 mb-2">Model</label>
                <input type="text" id="model" name="model" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="brand" class="block text-sm font-medium text-gray-300 mb-2">Brand</label>
                <input type="text" id="brand" name="brand" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="year" class="block text-sm font-medium text-gray-300 mb-2">Year</label>
                <input type="number" id="year" name="year" required min="1900" max="<%= java.time.Year.now().getValue() %>"
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="color" class="block text-sm font-medium text-gray-300 mb-2">Color</label>
                <input type="text" id="color" name="color" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="capacity" class="block text-sm font-medium text-gray-300 mb-2">Capacity</label>
                <input type="number" id="capacity" name="capacity" required min="1"
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="flex gap-4 justify-end modal-full-width mt-4">
                <button type="button" onclick="closeAddCarModal()" class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10">Cancel</button>
                <button type="submit" class="px-6 py-2 bg-primary text-dark rounded-full btn-primary font-semibold">Add</button>
            </div>
        </form>
    </div>
</div>

<!-- Update Car Modal -->
<div id="updateCarModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeUpdateModal(event)">
    <div class="bg-accent p-6 md:p-8 rounded-xl shadow-2xl w-full max-w-lg mx-4" onclick="event.stopPropagation()">
        <h2 class="text-2xl font-bold text-white mb-6">Update Car</h2>
        <form method="post" action="<%= request.getContextPath() %>/views/admin/manageCars.jsp" class="modal-form-grid">
            <input type="hidden" name="action" value="update">
            <input type="hidden" id="update_car_id" name="id">
            <div class="mb-4">
                <label for="update_plate_number" class="block text-sm font-medium text-gray-300 mb-2">Plate Number</label>
                <input type="text" id="update_plate_number" name="plate_number" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="update_model" class="block text-sm font-medium text-gray-300 mb-2">Model</label>
                <input type="text" id="update_model" name="model" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="update_brand" class="block text-sm font-medium text-gray-300 mb-2">Brand</label>
                <input type="text" id="update_brand" name="brand" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="update_year" class="block text-sm font-medium text-gray-300 mb-2">Year</label>
                <input type="number" id="update_year" name="year" required min="1900" max="<%= java.time.Year.now().getValue() %>"
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="update_color" class="block text-sm font-medium text-gray-300 mb-2">Color</label>
                <input type="text" id="update_color" name="color" required
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4">
                <label for="update_capacity" class="block text-sm font-medium text-gray-300 mb-2">Capacity</label>
                <input type="number" id="update_capacity" name="capacity" required min="1"
                       class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
            </div>
            <div class="mb-4 modal-full-width">
                <label for="update_status" class="block text-sm font-medium text-gray-300 mb-2">Status</label>
                <select id="update_status" name="status" required
                        class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
                    <option value="available">Available</option>
                    <option value="in-use">In Use</option>
                    <option value="maintenance">Maintenance</option>
                </select>
            </div>
            <div class="flex gap-4 justify-end modal-full-width mt-4">
                <button type="button" onclick="closeUpdateModal()" class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10">Cancel</button>
                <button type="submit" class="px-6 py-2 bg-primary text-dark rounded-full btn-primary font-semibold">Update</button>
            </div>
        </form>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

<script>
    lucide.createIcons();

    // Toggle Profile Dropdown
    function toggleProfileDropdown() {
        document.getElementById('profileDropdown').classList.toggle('hidden');
    }

    // Logout Modal Functions
    function showLogoutModal() {
        document.getElementById('logoutModal').classList.remove('hidden');
    }

    function cancelLogout() {
        document.getElementById('logoutModal').classList.add('hidden');
    }

    function confirmLogout() {
        fetch('<%= request.getContextPath() %>/logout', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include'
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
                    text: "An unexpected error occurred during logout.",
                    duration: 3000,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "red" },
                    stopOnFocus: true
                }).showToast();
            });
    }

    function openAddCarModal() {
        document.getElementById('addCarModal').classList.remove('hidden');
    }

    function closeAddCarModal(event) {
        if (!event || event.target === document.getElementById('addCarModal')) {
            document.getElementById('addCarModal').classList.add('hidden');
        }
    }

    function openUpdateModal(carId) {
        <% if (cars != null) { %>
        const cars = <%= new com.google.gson.Gson().toJson(cars) %>;
        const car = cars.find(c => c.id === carId);
        if (car) {
            document.getElementById('update_car_id').value = car.id;
            document.getElementById('update_plate_number').value = car.plateNumber || '';
            document.getElementById('update_model').value = car.model || '';
            document.getElementById('update_brand').value = car.brand || '';
            document.getElementById('update_year').value = car.year || '';
            document.getElementById('update_color').value = car.color || '';
            document.getElementById('update_capacity').value = car.capacity || '';
            document.getElementById('update_status').value = car.status || '';
            document.getElementById('updateCarModal').classList.remove('hidden');
        }
        <% } %>
    }

    function closeUpdateModal(event) {
        if (!event || event.target === document.getElementById('updateCarModal')) {
            document.getElementById('updateCarModal').classList.add('hidden');
        }
    }
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