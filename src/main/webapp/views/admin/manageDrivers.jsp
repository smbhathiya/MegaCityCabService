<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%@ page import="com.cabservice.megacitycabservice.dao.DriverDAO" %>
<%@ page import="com.cabservice.megacitycabservice.dao.CarAssignmentDAO" %>
<%@ page import="com.cabservice.megacitycabservice.model.Driver" %>
<%@ page import="com.cabservice.megacitycabservice.model.User" %>
<%@ page import="com.cabservice.megacitycabservice.model.Car" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="com.cabservice.megacitycabservice.util.PasswordUtil" %>
<%!
  private List<Driver> getAllDrivers() {
    try {
      DriverDAO dao = new DriverDAO();
      return dao.getAllDrivers();
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }

  private List<Car> getUnassignedCars() {
    try {
      CarAssignmentDAO dao = new CarAssignmentDAO();
      return dao.getUnassignedCars();
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
  }

  private String formatTimestamp(LocalDateTime dateTime) {
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    return dateTime.format(formatter);
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

  DriverDAO driverDAO = new DriverDAO();
  CarAssignmentDAO carAssignmentDAO = new CarAssignmentDAO();

  String action = request.getParameter("action");
  if ("add".equals(action)) {
    UUID userId = UUID.randomUUID();
    UUID driverId = UUID.randomUUID();
    LocalDateTime now = LocalDateTime.now();

    User newUser = new User();
    newUser.setId(userId);
    newUser.setName(request.getParameter("name"));
    newUser.setEmail(request.getParameter("email"));
    newUser.setPassword(PasswordUtil.hashPassword(request.getParameter("password")));
    newUser.setRole("driver");
    newUser.setEnabled(true);
    newUser.setCreatedAt(formatTimestamp(now));
    newUser.setUpdatedAt(formatTimestamp(now));

    Driver newDriver = new Driver();
    newDriver.setId(driverId);
    newDriver.setUserId(userId);
    newDriver.setLicenseNumber(request.getParameter("licenseNumber"));
    newDriver.setAvailabilityStatus("available");
    newDriver.setCreatedAt(formatTimestamp(now));
    newDriver.setUpdatedAt(formatTimestamp(now));

    try {
      driverDAO.addDriver(newUser, newDriver);
    } catch (Exception e) {
      e.printStackTrace();
    }
  } else if ("update".equals(action)) {
    UUID driverId = UUID.fromString(request.getParameter("id"));
    LocalDateTime now = LocalDateTime.now();

    Driver updatedDriver = new Driver();
    updatedDriver.setId(driverId);
    updatedDriver.setLicenseNumber(request.getParameter("licenseNumber"));
    updatedDriver.setAvailabilityStatus(request.getParameter("availabilityStatus"));
    updatedDriver.setUpdatedAt(formatTimestamp(now));

    String name = request.getParameter("name");

    try {
      driverDAO.updateDriver(updatedDriver, name);
    } catch (Exception e) {
      e.printStackTrace();
    }
  } else if ("delete".equals(action)) {
    UUID driverId = UUID.fromString(request.getParameter("id"));
    try {
      driverDAO.removeDriver(driverId);
    } catch (Exception e) {
      e.printStackTrace();
    }
  } else if ("assign".equals(action)) {
    UUID driverId = UUID.fromString(request.getParameter("driverId"));
    UUID carId = UUID.fromString(request.getParameter("carId"));
    try {
      carAssignmentDAO.assignCarToDriver(driverId, carId);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  List<Driver> drivers = getAllDrivers();
  List<Car> unassignedCars = getUnassignedCars();
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Drivers - Mega City Cabs</title>
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
    .custom-dropdown {
      position: relative;
      width: 100%;
    }
    .dropdown-button {
      width: 100%;
      padding: 0.75rem 1rem;
      background-color: rgba(42, 42, 42, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 9999px;
      color: white;
      text-align: left;
      cursor: pointer;
    }
    .dropdown-menu {
      position: absolute;
      top: 100%;
      left: 0;
      right: 0;
      background-color: #2A2A2A;
      border: 1px solid rgba(255, 255, 255, 0.1);
      border-radius: 0.5rem;
      max-height: 200px;
      overflow-y: auto;
      z-index: 10;
      display: none;
    }
    .dropdown-item {
      padding: 0.5rem 1rem;
      cursor: pointer;
    }
    .dropdown-item:hover {
      background-color: rgba(255, 255, 255, 0.1);
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
            <p class="text-sm text-light/70">Manage Drivers</p>
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
    <!-- Drivers Table -->
    <div class="table-container p-6 rounded-xl shadow-2xl animate-slide-up">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-3xl font-bold text-white">Driver List</h2>
        <button onclick="openAddDriverModal()" class="bg-primary px-6 py-3 text-black font-semibold rounded-full btn-primary flex items-center gap-2">
          <i data-lucide="plus" class="w-5 h-5"></i>
          Add New Driver
        </button>
      </div>
      <div class="overflow-x-auto">
        <table class="min-w-full border border-white/10 rounded-lg">
          <thead>
          <tr>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Name</th>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Email</th>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">License Number</th>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Availability</th>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Assigned Car</th>
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
          </tr>
          </thead>
          <tbody id="driverTableBody">
          <%
            if (drivers != null && !drivers.isEmpty()) {
              for (Driver driver : drivers) {
          %>
          <tr class="border-b border-white/10">
            <td class="px-6 py-4"><%= driver.getName() != null ? driver.getName() : "N/A" %></td>
            <td class="px-6 py-4"><%= driver.getEmail() != null ? driver.getEmail() : "N/A" %></td>
            <td class="px-6 py-4"><%= driver.getLicenseNumber() != null ? driver.getLicenseNumber() : "N/A" %></td>
            <td class="px-6 py-4"><%= driver.getAvailabilityStatus() != null ? driver.getAvailabilityStatus() : "N/A" %></td>
            <td class="px-6 py-4"><%= driver.getCarPlateNumber() != null ? driver.getCarPlateNumber() : "Not Assigned" %></td>
            <td class="px-6 py-4 flex gap-2">
              <button onclick="openUpdateDriverModal('<%= driver.getId() %>')"
                      class="bg-blue-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Edit</button>
              <button onclick="openAssignCarModal('<%= driver.getId() %>')"
                      class="bg-green-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Assign Car</button>
              <form method="post" action="<%= request.getContextPath() %>/views/admin/manageDrivers.jsp">
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="id" value="<%= driver.getId() %>">
                <button type="submit" onclick="return confirm('Are you sure you want to disable this driver?')"
                        class="bg-red-600 px-4 py-2 text-white rounded-full btn-primary font-semibold">Disable</button>
              </form>
            </td>
          </tr>
          <%
            }
          } else {
          %>
          <tr>
            <td colspan="6" class="text-center text-white py-4">No drivers available</td>
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

<!-- Add Driver Modal -->
<div id="addDriverModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeAddDriverModal(event)">
  <div class="bg-accent p-6 md:p-8 rounded-xl shadow-2xl w-full max-w-lg mx-4" onclick="event.stopPropagation()">
    <h2 class="text-2xl font-bold text-white mb-6">Add New Driver</h2>
    <form method="post" action="<%= request.getContextPath() %>/views/admin/manageDrivers.jsp" class="modal-form-grid">
      <input type="hidden" name="action" value="add">
      <div class="mb-4">
        <label for="driver_name" class="block text-sm font-medium text-gray-300 mb-2">Name</label>
        <input type="text" id="driver_name" name="name" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="driver_email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
        <input type="email" id="driver_email" name="email" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="driver_password" class="block text-sm font-medium text-gray-300 mb-2">Password</label>
        <input type="password" id="driver_password" name="password" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="license_number" class="block text-sm font-medium text-gray-300 mb-2">License Number</label>
        <input type="text" id="license_number" name="licenseNumber" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="flex gap-4 justify-end modal-full-width mt-4">
        <button type="button" onclick="closeAddDriverModal()" class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10">Cancel</button>
        <button type="submit" class="px-6 py-2 bg-primary text-dark rounded-full btn-primary font-semibold">Add</button>
      </div>
    </form>
  </div>
</div>

<!-- Update Driver Modal -->
<div id="updateDriverModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeUpdateDriverModal(event)">
  <div class="bg-accent p-6 md:p-8 rounded-xl shadow-2xl w-full max-w-lg mx-4" onclick="event.stopPropagation()">
    <h2 class="text-2xl font-bold text-white mb-6">Update Driver</h2>
    <form method="post" action="<%= request.getContextPath() %>/views/admin/manageDrivers.jsp" class="modal-form-grid">
      <input type="hidden" name="action" value="update">
      <input type="hidden" id="update_driver_id" name="id">
      <div class="mb-4">
        <label for="update_driver_name" class="block text-sm font-medium text-gray-300 mb-2">Name</label>
        <input type="text" id="update_driver_name" name="name" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="update_driver_email" class="block text-sm font-medium text-gray-300 mb-2">Email</label>
        <input type="email" id="update_driver_email" name="email" required readonly
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="update_license_number" class="block text-sm font-medium text-gray-300 mb-2">License Number</label>
        <input type="text" id="update_license_number" name="licenseNumber" required
               class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
      </div>
      <div class="mb-4">
        <label for="update_availability_status" class="block text-sm font-medium text-gray-300 mb-2">Availability</label>
        <select id="update_availability_status" name="availabilityStatus" required
                class="w-full px-4 py-3 bg-dark/50 border border-white/10 rounded-full text-white focus:outline-none focus:ring-2 focus:ring-primary">
          <option value="available">Available</option>
          <option value="on-trip">On Trip</option>
          <option value="inactive">Inactive</option>
        </select>
      </div>
      <div class="flex gap-4 justify-end modal-full-width mt-4">
        <button type="button" onclick="closeUpdateDriverModal()" class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10">Cancel</button>
        <button type="submit" class="px-6 py-2 bg-primary text-dark rounded-full btn-primary font-semibold">Update</button>
      </div>
    </form>
  </div>
</div>

<!-- Assign Car Modal -->
<div id="assignCarModal" class="hidden fixed inset-0 bg-black/60 flex items-center justify-center z-50" onclick="closeAssignCarModal(event)">
  <div class="bg-accent p-6 md:p-8 rounded-xl shadow-2xl w-full max-w-md mx-4" onclick="event.stopPropagation()">
    <h2 class="text-2xl font-bold text-white mb-6">Assign Car to Driver</h2>
    <form method="post" action="<%= request.getContextPath() %>/views/admin/manageDrivers.jsp">
      <input type="hidden" name="action" value="assign">
      <input type="hidden" id="assign_driver_id" name="driverId">
      <input type="hidden" id="selected_car_id" name="carId">
      <div class="mb-6">
        <label class="block text-sm font-medium text-gray-300 mb-2">Select Car</label>
        <div class="custom-dropdown">
          <div id="car_dropdown_button" class="dropdown-button">-- Select a Car --</div>
          <div id="car_dropdown_menu" class="dropdown-menu">
            <% if (unassignedCars != null && !unassignedCars.isEmpty()) {
              for (Car car : unassignedCars) {
            %>
            <div class="dropdown-item" data-car-id="<%= car.getId() %>"
                 onclick="selectCar('<%= car.getId() %>', '<%= car.getBrand() %>', '<%= car.getModel() %>', '<%= car.getPlateNumber() %>', '<%= car.getCapacity() %>')">
              <span><%= car.getBrand() != null ? car.getBrand() : "N/A" %></span>
              <span> <%= car.getModel() != null ? car.getModel() : "N/A" %></span>
              <span> - <%= car.getPlateNumber() != null ? car.getPlateNumber() : "N/A" %></span>
              <span> (Capacity: <%= car.getCapacity() %>)</span>
            </div>
            <% }
            } else { %>
            <div class="dropdown-item">No available cars</div>
            <% } %>
          </div>
        </div>
      </div>
      <div class="flex gap-4 justify-end">
        <button type="button" onclick="closeAssignCarModal()" class="px-6 py-2 border border-white/20 text-white rounded-full hover:bg-white/10">Cancel</button>
        <button type="submit" class="px-6 py-2 bg-primary text-dark rounded-full btn-primary font-semibold">Assign</button>
      </div>
    </form>
  </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>

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

  function openAddDriverModal() {
    document.getElementById('addDriverModal').classList.remove('hidden');
  }

  function closeAddDriverModal(event) {
    if (!event || event.target === document.getElementById('addDriverModal')) {
      document.getElementById('addDriverModal').classList.add('hidden');
    }
  }

  function openUpdateDriverModal(driverId) {
    <% if (drivers != null) { %>
    const drivers = <%= new com.google.gson.Gson().toJson(drivers) %>;
    const driver = drivers.find(d => d.id === driverId);
    if (driver) {
      document.getElementById('update_driver_id').value = driver.id;
      document.getElementById('update_driver_name').value = driver.name || '';
      document.getElementById('update_driver_email').value = driver.email || '';
      document.getElementById('update_license_number').value = driver.licenseNumber || '';
      document.getElementById('update_availability_status').value = driver.availabilityStatus || 'available';
      document.getElementById('updateDriverModal').classList.remove('hidden');
    }
    <% } %>
  }

  function closeUpdateDriverModal(event) {
    if (!event || event.target === document.getElementById('updateDriverModal')) {
      document.getElementById('updateDriverModal').classList.add('hidden');
    }
  }

  function openAssignCarModal(driverId) {
    document.getElementById('assign_driver_id').value = driverId;
    document.getElementById('selected_car_id').value = '';
    document.getElementById('car_dropdown_button').textContent = '-- Select a Car --';
    document.getElementById('assignCarModal').classList.remove('hidden');
  }

  function closeAssignCarModal(event) {
    if (!event || event.target === document.getElementById('assignCarModal')) {
      document.getElementById('assignCarModal').classList.add('hidden');
    }
  }

  function selectCar(carId, brand, model, plateNumber, capacity) {
    document.getElementById('selected_car_id').value = carId;
    const dropdownButton = document.getElementById('car_dropdown_button');
    dropdownButton.innerHTML = '';
    const brandSpan = document.createElement('span');
    brandSpan.textContent = brand;
    const modelSpan = document.createElement('span');
    modelSpan.textContent = ' ' + model;
    const plateSpan = document.createElement('span');
    plateSpan.textContent = ' - ' + plateNumber;
    const capacitySpan = document.createElement('span');
    capacitySpan.textContent = ' (Capacity: ' + capacity + ')';
    dropdownButton.appendChild(brandSpan);
    dropdownButton.appendChild(modelSpan);
    dropdownButton.appendChild(plateSpan);
    dropdownButton.appendChild(capacitySpan);
    document.getElementById('car_dropdown_menu').style.display = 'none';
  }

  const dropdownButton = document.getElementById('car_dropdown_button');
  const dropdownMenu = document.getElementById('car_dropdown_menu');
  dropdownButton.onclick = (e) => {
    e.stopPropagation();
    dropdownMenu.style.display = dropdownMenu.style.display === 'block' ? 'none' : 'block';
  };

  document.addEventListener("click", function (e) {
    if (!dropdownButton.contains(e.target) && !dropdownMenu.contains(e.target)) {
      dropdownMenu.style.display = 'none';
    }
  });
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