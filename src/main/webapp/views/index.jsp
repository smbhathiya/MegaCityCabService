<%@ page import="java.util.UUID" %>
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
                        },
                        dark: '#0A0A0A', // Slightly darker for better contrast
                        accent: '#1F1F1F' // New accent color for sections
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
        }
    </script>
    <style>
        body {
            background-color: #0A0A0A;
            color: white;
            font-family: 'Inter', sans-serif;
        }
        .section-bg {
            background-color: rgba(31, 31, 31, 0.8);
            border-radius: 1rem;
            backdrop-filter: blur(5px);
        }
        .hero-background {
            background-image: url('${pageContext.request.contextPath}/views/assests/cab2.webp');
            background-size: cover;
            background-position: center;
            position: relative;
            min-height: 100vh;
            display: flex;
            align-items: center;
        }
        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(to right, rgba(0, 0, 0, 0.85), rgba(0, 0, 0, 0.3));
        }
        .btn-primary {
            transition: transform 0.2s ease, background-color 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body class="bg-dark text-white">
<div>
    <!-- Navbar -->
    <nav class="fixed top-0 left-0 right-0 z-50 bg-dark/40 backdrop-blur-md shadow-md">
        <div class="container mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-2">
                    <a href="../index.jsp" class="flex items-center gap-2">
                        <i data-lucide="car" class="w-6 h-6 sm:w-8 sm:h-8 text-primary"></i>
                        <span class="text-xl sm:text-2xl font-bold text-white">Mega City Cabs</span>
                    </a>
                </div>
                <div class="flex items-center gap-6">
                    <%
                        Object userIdObj = session.getAttribute("userId");
                        String role = (String) session.getAttribute("userRole");
                        if (userIdObj == null || !(userIdObj instanceof UUID)) {
                    %>
                    <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                       class="px-5 py-2 border border-primary text-primary rounded-full hover:bg-primary/20 transition flex items-center gap-2">
                        <i data-lucide="user-plus" class="w-5 h-5"></i>
                        Register
                    </a>
                    <a href="${pageContext.request.contextPath}/views/auth/login.jsp"
                       class="px-5 py-2 bg-primary text-black rounded-full btn-primary flex items-center gap-2">
                        <i data-lucide="log-in" class="w-5 h-5"></i>
                        Login
                    </a>
                    <%
                    } else {
                        String userId = userIdObj.toString();
                        String dashboardUrl;
                        if ("admin".equals(role)) {
                            dashboardUrl = "/views/admin/dashboard.jsp";
                        } else if ("driver".equals(role)) {
                            dashboardUrl = "/views/driver/dashboard.jsp";
                        } else {
                            dashboardUrl = "/views/customer/dashboard.jsp";
                        }
                    %>
                    <a href="${pageContext.request.contextPath}<%= dashboardUrl %>"
                       class="px-5 py-2 bg-primary text-black rounded-full btn-primary flex items-center gap-2">
                        <i data-lucide="grid" class="w-5 h-5"></i>
                        Dashboard
                    </a>
                    <%
                        }
                    %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero-background">
        <div class="hero-overlay"></div>
        <div class="container mx-auto px-6 relative z-10">
            <div class="max-w-lg space-y-8 animate-fade-in">
                <span class="inline-flex bg-primary/20 text-primary px-4 py-2 rounded-full text-sm font-medium tracking-wide">
                    <i data-lucide="award" class="w-5 h-5 mr-2"></i>
                    #1 Cab Service in Colombo
                </span>
                <h1 class="text-5xl md:text-6xl font-extrabold tracking-tight leading-tight">
                    Your Premium Ride Awaits
                </h1>
                <p class="text-xl text-gray-300 flex items-center gap-3">
                    <i data-lucide="check-circle" class="w-6 h-6 text-primary"></i>
                    Luxury, comfort, and reliability at your fingertips.
                </p>
                <div class="flex gap-6">
                    <a href="/bookings/new"
                       class="px-8 py-3 bg-primary text-black rounded-full btn-primary font-semibold flex items-center gap-2">
                        <i data-lucide="calendar-check" class="w-5 h-5"></i>
                        Book Now
                    </a>
                    <a href="/vehicles"
                       class="px-8 py-3 border border-primary text-primary rounded-full hover:bg-primary/10 transition font-semibold flex items-center gap-2">
                        <i data-lucide="car" class="w-5 h-5"></i>
                        View Fleet
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Ride Process Section -->
    <section class="container mx-auto px-6 py-20 section-bg">
        <div class="text-center mb-16 animate-slide-up">
            <h2 class="text-4xl font-bold text-white mb-4">How It Works</h2>
            <p class="text-lg text-gray-300 max-w-2xl mx-auto">
                Simple steps to your perfect ride experience.
            </p>
        </div>
        <div class="grid md:grid-cols-3 gap-10">
            <div class="bg-accent p-8 rounded-xl border border-white/10 hover:shadow-lg transition-all duration-300 text-center">
                <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-2xl font-bold text-primary">1</span>
                </div>
                <h3 class="text-xl font-semibold mb-3 text-white">Book Your Ride</h3>
                <p class="text-gray-300">Select your destination and vehicle.</p>
            </div>
            <div class="bg-accent p-8 rounded-xl border border-white/10 hover:shadow-lg transition-all duration-300 text-center">
                <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-2xl font-bold text-primary">2</span>
                </div>
                <h3 class="text-xl font-semibold mb-3 text-white">Get Matched</h3>
                <p class="text-gray-300">Instant driver assignment.</p>
            </div>
            <div class="bg-accent p-8 rounded-xl border border-white/10 hover:shadow-lg transition-all duration-300 text-center">
                <div class="w-16 h-16 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-2xl font-bold text-primary">3</span>
                </div>
                <h3 class="text-xl font-semibold mb-3 text-white">Enjoy the Ride</h3>
                <p class="text-gray-300">Safe and comfortable journey.</p>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="container mx-auto px-6 py-20">
        <div class="grid md:grid-cols-2 gap-12 items-center">
            <div class="relative animate-slide-up">
                <img src="${pageContext.request.contextPath}/views/assests/cab1.webp" alt="Luxury Car Interior"
                     class="w-full rounded-xl shadow-2xl transition-transform duration-300 hover:scale-105">
                <div class="absolute -bottom-4 -left-4 w-24 h-24 bg-primary/20 rounded-full blur-2xl"></div>
            </div>
            <div class="space-y-8 animate-slide-up">
                <h2 class="text-4xl font-bold text-white">Why Mega City Cabs?</h2>
                <div class="space-y-6">
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
                    <div class="flex items-center gap-4">
                        <i data-lucide="check-circle" class="w-6 h-6 text-primary"></i>
                        <span class="text-lg text-gray-300"><%= benefit %></span>
                    </div>
                    <% } %>
                </div>
                <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                   class="inline-block px-8 py-3 bg-primary text-black rounded-full btn-primary font-semibold">
                    Join Now
                </a>
            </div>
        </div>
    </section>

    <!-- Reviews Section -->
    <section class="container mx-auto px-6 py-20 section-bg">
        <div class="text-center mb-16 animate-slide-up">
            <h2 class="text-4xl font-bold text-white mb-4">Customer Reviews</h2>
            <p class="text-lg text-gray-300 max-w-2xl mx-auto">
                Trusted by thousands for their daily rides.
            </p>
        </div>
        <div class="grid md:grid-cols-3 gap-10">
            <%
                String[][] reviews = {
                        {"Sarah Johnson", "Business Professional", "Exceptional service! Always punctual and comfortable.", "5"},
                        {"Michael Chen", "Tourist", "Best way to explore Colombo. Friendly drivers and clean cars.", "5"},
                        {"Priya Patel", "Regular Commuter", "Reliable, safe, and professional. My go-to cab service.", "5"}
                };
                for (String[] review : reviews) {
            %>
            <div class="bg-accent p-8 rounded-xl border border-white/10 hover:shadow-lg transition-all duration-300">
                <div class="flex gap-1 mb-4">
                    <% for (int i = 0; i < Integer.parseInt(review[3]); i++) { %>
                    <i data-lucide="star" class="w-5 h-5 text-primary fill-primary"></i>
                    <% } %>
                </div>
                <p class="text-gray-300 italic mb-6 text-lg">"<%= review[2] %>"</p>
                <div class="flex items-center gap-4">
                    <div>
                        <p class="font-semibold text-white text-lg"><%= review[0] %></p>
                        <p class="text-sm text-gray-400"><%= review[1] %></p>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </section>

    <footer class="bg-dark/50 py-12 mt-12 border-t border-white/10">
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