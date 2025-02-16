<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Mega City Cabs - Premium Ride Experience</title>
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
  <style>
    body {
      background-color: black;
      color: white;
    }
    .section-bg {
      background-color: rgba(255, 255, 255, 0.05);
    }
    .hero-background {
      background-image: url('assests/cab2.webp');
      background-size: cover;
      background-position: center;
      position: relative;
      height: 100vh;
    }
    .hero-overlay {
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: linear-gradient(to right, rgba(0,0,0,0.8), rgba(0,0,0,0.4));
    }
  </style>
</head>
<body class="bg-dark text-white">
<div>
  <!-- Navbar -->
  <nav class="fixed top-0 left-0 right-0 z-50 backdrop-blur-sm">
    <div class="container mx-auto px-4 py-2">
      <div class="flex h-16 items-center justify-between">
        <div class="text-2xl font-bold text-white flex items-center gap-2">
          <i data-lucide="car" class="w-8 h-8 text-primary"></i>
          Mega City Cabs
        </div>
        <div class="flex items-center gap-4">
          <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp" class="px-4 py-2 border border-primary text-primary rounded-md hover:bg-primary/10 transition flex items-center gap-2">
            <i data-lucide="user-plus" class="w-5 h-5"></i>
            Register
          </a>
          <a href="${pageContext.request.contextPath}/views/auth/login.jsp" class="px-4 py-2 bg-primary text-black rounded-md flex items-center gap-2 hover:bg-primary-700 transition">
            <i data-lucide="log-in" class="w-5 h-5"></i>
            Login
          </a>
        </div>
      </div>
    </div>
  </nav>

  <!-- Hero Section -->
  <section class="relative hero-background flex items-center ">
    <div class="hero-overlay backdrop-blur-sm"></div>
    <div class="container mx-auto px-4 relative z-10 flex ">
      <div class="max-w-2xl space-y-6">
                <span class="inline-flex bg-primary/20 text-primary px-3 py-1 rounded-full text-sm gap-2">
                    <i data-lucide="award" class="w-4 h-4"></i>
                    #1 Cab Service in Colombo
                </span>
        <h1 class="text-4xl sm:text-5xl font-bold tracking-tight text-white">
          Your Premium Ride Experience Awaits
        </h1>
        <p class="text-lg text-gray-300 flex gap-2">
          <i data-lucide="check-circle" class="w-6 h-6 text-primary"></i>
          Experience luxury, comfort, and reliability with our professional cab service.
        </p>
        <div class="flex gap-4">
          <a href="/bookings/new" class="px-6 py-3 bg-primary text-black rounded-md hover:bg-primary-700 transition flex gap-2">
            <i data-lucide="calendar-check" class="w-5 h-5"></i>
            Book Now
          </a>
          <a href="/vehicles" class="px-6 py-3 border border-gray-700 text-white rounded-md hover:bg-white/10 transition flex items-center gap-2">
            <i data-lucide="car" class="w-5 h-5"></i>
            View Fleet
          </a>
        </div>
      </div>
    </div>
  </section>

  <!-- Ride Process Section -->
  <section class="container mx-auto px-4 section-bg py-16">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-bold text-white mb-4">How It Works</h2>
      <p class="text-gray-300 max-w-2xl mx-auto">
        Simple, fast, and reliable. Your perfect ride is just a few steps away.
      </p>
    </div>
    <div class="grid md:grid-cols-3 gap-8">
      <div class="bg-dark/50 p-6 rounded-lg border border-white/10 text-center">
        <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl font-bold text-primary">1</span>
        </div>
        <h3 class="text-xl font-semibold mb-2 text-white">Book Your Ride</h3>
        <p class="text-gray-300">Choose your destination and vehicle type</p>
      </div>
      <div class="bg-dark/50 p-6 rounded-lg border border-white/10 text-center">
        <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl font-bold text-primary">2</span>
        </div>
        <h3 class="text-xl font-semibold mb-2 text-white">Get Matched</h3>
        <p class="text-gray-300">Professional driver assigned instantly</p>
      </div>
      <div class="bg-dark/50 p-6 rounded-lg border border-white/10 text-center">
        <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-4">
          <span class="text-2xl font-bold text-primary">3</span>
        </div>
        <h3 class="text-xl font-semibold mb-2 text-white">Enjoy the Ride</h3>
        <p class="text-gray-300">Safe and comfortable journey guaranteed</p>
      </div>
    </div>
  </section>

  <!-- Benefits Section -->
  <section class="container mx-auto px-4 py-16">
    <div class="grid md:grid-cols-2 gap-12 items-center ">
      <div>
        <img src="assests/cab1.webp" alt="Luxury Car Interior" class="w-3/4 rounded-lg shadow-xl p-5 items-center">
      </div>
      <div>
        <h2 class="text-3xl font-bold mb-8 text-white">Why Choose Mega City Cabs</h2>
        <div class="space-y-4">
          <%
            String[] benefits = {
                    "Professional and courteous drivers",
                    "Modern and well-maintained vehicles",
                    "Competitive transparent pricing",
                    "Real-time ride tracking",
                    "Multiple payment options",
                    "24/7 customer support"
            };

            for (String benefit : benefits) {
          %>
          <div class="flex items-center gap-3">
            <i data-lucide="check-circle" class="w-6 h-6 text-primary"></i>
            <span class="text-gray-300"><%= benefit %></span>
          </div>
          <% } %>
        </div>
        <a href="customer/customerRegister.jsp" class="mt-8 inline-block px-6 py-3 bg-primary text-black rounded-md hover:bg-primary-700 transition">
          Join Now
        </a>
      </div>
    </div>
  </section>

  <!-- Reviews Section -->
  <section class="container mx-auto px-4 py-16 section-bg">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-bold text-white mb-4">What Our Customers Say</h2>
      <p class="text-gray-300 max-w-2xl mx-auto">
        Hear from our satisfied riders who trust Mega City Cabs for their daily transportation needs.
      </p>
    </div>
    <div class="grid md:grid-cols-3 gap-8">
      <%
        String[][] reviews = {
                {"Sarah Johnson", "Business Professional", "Exceptional service! Always punctual and comfortable.", "5"},
                {"Michael Chen", "Tourist", "Best way to explore Colombo. Friendly drivers and clean cars.", "5"},
                {"Priya Patel", "Regular Commuter", "Reliable, safe, and professional. My go-to cab service.", "5"}
        };

        for (String[] review : reviews) {
      %>
      <div class="bg-dark/50 p-6 rounded-lg border border-white/10">
        <div class="flex gap-1 mb-4">
          <% for(int i = 0; i < Integer.parseInt(review[3]); i++) { %>
          <i data-lucide="star" class="w-5 h-5 text-primary fill-primary"></i>
          <% } %>
        </div>
        <p class="text-gray-300 italic mb-4">"<%= review[2] %>"</p>
        <div class="flex items-center gap-3">
          <div>
            <p class="font-semibold text-white"><%= review[0] %></p>
            <p class="text-sm text-gray-400"><%= review[1] %></p>
          </div>
        </div>
      </div>
      <% } %>
    </div>
  </section>

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
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
  lucide.createIcons();
</script>
</body>
</html>