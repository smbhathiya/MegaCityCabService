<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.UUID" %>
<%
  UUID adminUUID = (UUID) session.getAttribute("userId");
  String adminId = adminUUID != null ? adminUUID.toString() : null;
  String role = (String) session.getAttribute("role");
  if (adminId == null || !"admin".equals(role)) {
    response.sendRedirect(request.getContextPath() + "/views/auth/login.jsp");
    return;
  }
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
            <span class="text-lg text-white font-medium">${userName}</span>
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
            <th class="px-6 py-4 text-left text-sm font-semibold text-white">Actions</th>
          </tr>
          </thead>
          <tbody id="driverTableBody"></tbody>
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
    <form id="addDriverForm" onsubmit="addDriver(event)" class="modal-form-grid">
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
    <form id="updateDriverForm" onsubmit="updateDriver(event)" class="modal-form-grid">
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

  document.addEventListener("DOMContentLoaded", function () {
    fetchDrivers();
  });

  function fetchDrivers() {
    const tbody = document.getElementById('driverTableBody');
    tbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Loading...</td></tr>';

    fetch('<%= request.getContextPath() %>/admin/drivers', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include'
    })
            .then(response => {
              if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
              return response.json();
            })
            .then(drivers => {
              console.log('Fetched drivers:', drivers);
              tbody.innerHTML = '';
              drivers.forEach(driver => {
                console.log('Processing driver:', driver);
                const row = document.createElement('tr');
                row.className = 'border-b border-white/10';

                row.appendChild(createCell(driver.name));
                row.appendChild(createCell(driver.email));
                row.appendChild(createCell(driver.licenseNumber));
                row.appendChild(createCell(driver.availabilityStatus));

                const actionCell = document.createElement('td');
                actionCell.className = "px-6 py-4 flex gap-2";

                const editBtn = document.createElement('button');
                editBtn.className = "bg-blue-600 px-4 py-2 text-white rounded-full btn-primary font-semibold edit-btn";
                editBtn.textContent = "Edit";
                editBtn.dataset.id = driver.id;

                const removeBtn = document.createElement('button');
                removeBtn.className = "bg-red-600 px-4 py-2 text-white rounded-full btn-primary font-semibold remove-btn";
                removeBtn.textContent = "Remove";
                removeBtn.dataset.id = driver.id;

                actionCell.appendChild(editBtn);
                actionCell.appendChild(removeBtn);
                row.appendChild(actionCell);

                tbody.appendChild(row);
              });
            })
            .catch(error => {
              console.error('Error fetching drivers:', error);
              tbody.innerHTML = '<tr><td colspan="5" class="text-center text-white py-4">Error loading data</td></tr>';
              Toastify({
                text: "Error fetching drivers: " + error.message,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "red" },
                stopOnFocus: true
              }).showToast();
            });
  }

  function createCell(text) {
    const td = document.createElement('td');
    td.className = "px-6 py-4";
    td.textContent = text || 'N/A';
    return td;
  }

  document.addEventListener("click", function (event) {
    if (event.target.classList.contains("edit-btn")) {
      const driverId = event.target.dataset.id;
      openUpdateDriverModal(driverId);
    } else if (event.target.classList.contains("remove-btn")) {
      const driverId = event.target.dataset.id;
      removeDriver(driverId);
    }
  });

  function openAddDriverModal() {
    document.getElementById('addDriverModal').classList.remove('hidden');
  }

  function closeAddDriverModal(event) {
    if (!event || event.target === document.getElementById('addDriverModal')) {
      document.getElementById('addDriverModal').classList.add('hidden');
    }
  }

  function addDriver(event) {
    event.preventDefault();
    const formData = {
      name: document.getElementById('driver_name').value,
      email: document.getElementById('driver_email').value,
      password: document.getElementById('driver_password').value,
      licenseNumber: document.getElementById('license_number').value
    };

    fetch('<%= request.getContextPath() %>/admin/drivers?action=add', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify(formData)
    })
            .then(response => response.json())
            .then(data => {
              if (data.status === "success") {
                Toastify({
                  text: data.message,
                  duration: 1500,
                  close: true,
                  gravity: "top",
                  position: "right",
                  style: { background: "green" },
                  stopOnFocus: true
                }).showToast();
                closeAddDriverModal();
                document.getElementById('addDriverForm').reset();
                fetchDrivers();
              } else {
                Toastify({
                  text: data.message || "Failed to add driver",
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
              console.error('Error adding driver:', error);
              Toastify({
                text: "Error adding driver: " + error.message,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "red" },
                stopOnFocus: true
              }).showToast();
            });
  }

  function openUpdateDriverModal(driverId) {
    fetch('<%= request.getContextPath() %>/admin/drivers', {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include'
    })
            .then(response => {
              if (!response.ok) throw new Error(`HTTP error! Status: ${response.status}`);
              return response.json();
            })
            .then(drivers => {
              const driver = drivers.find(d => d.id === driverId);
              if (driver) {
                document.getElementById('update_driver_id').value = driver.id;
                document.getElementById('update_driver_name').value = driver.name || '';
                document.getElementById('update_driver_email').value = driver.email || '';
                document.getElementById('update_license_number').value = driver.licenseNumber || '';
                document.getElementById('update_availability_status').value = driver.availabilityStatus || 'available';
                document.getElementById('updateDriverModal').classList.remove('hidden');
              } else {
                Toastify({
                  text: "Driver not found",
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
              console.error('Error fetching driver details:', error);
              Toastify({
                text: "Error loading driver details: " + error.message,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "red" },
                stopOnFocus: true
              }).showToast();
            });
  }

  function closeUpdateDriverModal(event) {
    if (!event || event.target === document.getElementById('updateDriverModal')) {
      document.getElementById('updateDriverModal').classList.add('hidden');
    }
  }

  function updateDriver(event) {
    event.preventDefault();
    const formData = {
      id: document.getElementById('update_driver_id').value,
      name: document.getElementById('update_driver_name').value,
      email: document.getElementById('update_driver_email').value,
      licenseNumber: document.getElementById('update_license_number').value,
      availabilityStatus: document.getElementById('update_availability_status').value
    };

    fetch('<%= request.getContextPath() %>/admin/drivers?action=update', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify(formData)
    })
            .then(response => response.json())
            .then(data => {
              if (data.status === "success") {
                Toastify({
                  text: data.message,
                  duration: 1500,
                  close: true,
                  gravity: "top",
                  position: "right",
                  style: { background: "green" },
                  stopOnFocus: true
                }).showToast();
                closeUpdateDriverModal();
                fetchDrivers();
              } else {
                Toastify({
                  text: data.message || "Failed to update driver",
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
              console.error('Error updating driver:', error);
              Toastify({
                text: "Error updating driver: " + error.message,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                style: { background: "red" },
                stopOnFocus: true
              }).showToast();
            });
  }

  function removeDriver(driverId) {
    if (confirm("Are you sure you want to remove this driver?")) {
      fetch('<%= request.getContextPath() %>/admin/drivers?id=' + driverId, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'include'
      })
              .then(response => response.json())
              .then(data => {
                if (data.status === "success") {
                  Toastify({
                    text: data.message,
                    duration: 1500,
                    close: true,
                    gravity: "top",
                    position: "right",
                    style: { background: "green" },
                    stopOnFocus: true
                  }).showToast();
                  fetchDrivers();
                } else {
                  Toastify({
                    text: data.message || "Failed to remove driver",
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
                console.error('Error removing driver:', error);
                Toastify({
                  text: "Error removing driver: " + error.message,
                  duration: 3000,
                  close: true,
                  gravity: "top",
                  position: "right",
                  style: { background: "red" },
                  stopOnFocus: true
                }).showToast();
              });
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