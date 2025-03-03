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
                        dark: '#0A0A0A',
                        accent: '#1F1F1F'
                    },
                    animation: {
                        'fade-in': 'fadeIn 0.8s ease-in-out',
                        'slide-up': 'slideUp 0.8s ease-out',
                        'pulse-slow': 'pulseSlow 2s infinite'
                    },
                    keyframes: {
                        fadeIn: {
                            '0%': { opacity: '0' },
                            '100%': { opacity: '1' }
                        },
                        slideUp: {
                            '0%': { transform: 'translateY(30px)', opacity: '0' },
                            '100%': { transform: 'translateY(0)', opacity: '1' }
                        },
                        pulseSlow: {
                            '0%, 100%': { transform: 'scale(1)' },
                            '50%': { transform: 'scale(1.05)' }
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
            background-color: rgba(31, 31, 31, 0.85);
            border-radius: 1.5rem;
            backdrop-filter: blur(8px);
        }
        .hero-background {
            background-image: url('${pageContext.request.contextPath}/views/assests/cab2.webp');
            background-size: cover;
            background-position: center;
            position: relative;
            min-height: 100vh;
            display: flex;
            align-items: center;
            overflow: hidden;
            padding-top: 5rem; /* Adjusted to account for navbar height */
        }
        .hero-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(120deg, rgba(0, 0, 0, 0.9), rgba(0, 0, 0, 0.2));
        }
        .btn-primary {
            transition: transform 0.3s ease, background-color 0.3s ease, box-shadow 0.3s ease;
        }
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 16px rgba(252, 198, 3, 0.3);
        }
        .navbar-scrolled {
            background-color: rgba(10, 10, 10, 0.95);
            backdrop-filter: blur(12px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }
        .card-hover {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .card-hover:hover {
            transform: translateY(-8px);
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.4);
        }
    </style>
</head>
<body class="bg-dark text-white">
<div>
    <!-- Navbar -->
    <nav id="navbar" class="fixed top-0 left-0 right-0 z-50 bg-dark/40 backdrop-blur-md transition-all duration-300">
        <div class="container mx-auto px-6 py-4">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/" class="flex items-center gap-3">
                        <i data-lucide="car" class="w-10 h-10 text-primary animate-pulse-slow"></i>
                        <div>
                            <span class="text-3xl font-extrabold text-light tracking-tight">Mega City Cabs</span>
                            <p class="text-sm text-light/70 hidden md:block">Your Premium Ride Partner</p>
                        </div>
                    </a>
                </div>
                <div class="flex items-center gap-6">
                    <%
                        Object userIdObj = session.getAttribute("userId");
                        String role = (String) session.getAttribute("role");
                        if (userIdObj == null || !(userIdObj instanceof UUID)) {
                    %>
                    <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                       class="px-6 py-2 border border-primary text-primary rounded-full hover:bg-primary/20 transition flex items-center gap-2 text-lg font-semibold">
                        <i data-lucide="user-plus" class="w-5 h-5"></i>
                        Register
                    </a>
                    <a href="${pageContext.request.contextPath}/views/auth/login.jsp"
                       class="px-6 py-2 bg-primary text-black rounded-full btn-primary flex items-center gap-2 text-lg font-semibold">
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
                       class="px-6 py-2 bg-primary text-black rounded-full btn-primary flex items-center gap-2 text-lg font-semibold">
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
            <div class="max-w-xl space-y-8 animate-fade-in">
                <span class="inline-flex bg-primary/20 text-primary px-5 py-2 rounded-full text-base font-semibold tracking-wide animate-pulse-slow">
                    <i data-lucide="award" class="w-6 h-6 mr-2"></i>
                    #1 Cab Service in Colombo
                </span>
                <h1 class="text-4xl md:text-6xl font-extrabold tracking-tight leading-tight">
                    Your Luxury Ride Awaits You
                </h1>
                <p class="text-lg md:text-xl text-gray-200 flex items-center gap-4">
                    <i data-lucide="check-circle" class="w-6 h-6 text-primary"></i>
                    Seamless comfort and reliability guaranteed.
                </p>
                <div class="flex gap-6">
                    <a href="/bookings/new"
                       class="px-8 py-4 bg-primary text-black rounded-full btn-primary font-semibold text-lg flex items-center gap-2">
                        <i data-lucide="calendar-check" class="w-6 h-6"></i>
                        Book Now
                    </a>
                    <a href="/vehicles"
                       class="px-8 py-4 border border-primary text-primary rounded-full hover:bg-primary/10 transition font-semibold text-lg flex items-center gap-2">
                        <i data-lucide="car" class="w-6 h-6"></i>
                        View Fleet
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Ride Process Section -->
    <section class="container mx-auto px-6 py-24 section-bg">
        <div class="text-center mb-16 animate-slide-up">
            <h2 class="text-5xl font-extrabold text-white mb-6">How It Works</h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
                Effortless steps to an exceptional ride experience.
            </p>
        </div>
        <div class="grid md:grid-cols-3 gap-12">
            <div class="bg-accent p-8 rounded-2xl border border-white/10 card-hover text-center">
                <div class="w-20 h-20 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-3xl font-bold text-primary">1</span>
                </div>
                <h3 class="text-2xl font-semibold mb-4 text-white">Book Your Ride</h3>
                <p class="text-lg text-gray-300">Choose your destination and vehicle type.</p>
            </div>
            <div class="bg-accent p-8 rounded-2xl border border-white/10 card-hover text-center">
                <div class="w-20 h-20 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-3xl font-bold text-primary">2</span>
                </div>
                <h3 class="text-2xl font-semibold mb-4 text-white">Get Matched</h3>
                <p class="text-lg text-gray-300">Paired with a professional driver instantly.</p>
            </div>
            <div class="bg-accent p-8 rounded-2xl border border-white/10 card-hover text-center">
                <div class="w-20 h-20 bg-primary/20 rounded-full flex items-center justify-center mx-auto mb-6">
                    <span class="text-3xl font-bold text-primary">3</span>
                </div>
                <h3 class="text-2xl font-semibold mb-4 text-white">Enjoy the Ride</h3>
                <p class="text-lg text-gray-300">Relax in a safe, luxurious journey.</p>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="container mx-auto px-6 py-24">
        <div class="grid md:grid-cols-2 gap-16 items-center">
            <div class="relative animate-slide-up">
                <img src="${pageContext.request.contextPath}/views/assests/cab1.webp" alt="Luxury Car Interior"
                     class="w-full rounded-2xl shadow-2xl transition-transform duration-500 hover:scale-105 animate-pulse-slow">
                <div class="absolute -bottom-6 -left-6 w-32 h-32 bg-primary/10 rounded-full blur-3xl"></div>
            </div>
            <div class="space-y-10 animate-slide-up">
                <h2 class="text-5xl font-extrabold text-white">Why Choose Mega City Cabs?</h2>
                <div class="space-y-8">
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
                    <div class="flex items-center gap-5">
                        <i data-lucide="check-circle" class="w-8 h-8 text-primary animate-pulse-slow"></i>
                        <span class="text-xl text-gray-200"><%= benefit %></span>
                    </div>
                    <% } %>
                </div>
                <a href="${pageContext.request.contextPath}/views/customer/customerRegister.jsp"
                   class="inline-block px-10 py-4 bg-primary text-black rounded-full btn-primary font-semibold text-lg">
                    Join Now
                </a>
            </div>
        </div>
    </section>

    <!-- Reviews Section -->
    <section class="container mx-auto px-6 py-24 section-bg">
        <div class="text-center mb-16 animate-slide-up">
            <h2 class="text-5xl font-extrabold text-white mb-6">What Our Riders Say</h2>
            <p class="text-xl text-gray-300 max-w-3xl mx-auto">
                Loved by thousands for premium transportation.
            </p>
        </div>
        <div class="grid md:grid-cols-3 gap-12">
            <%
                String[][] reviews = {
                        {"Sarah Johnson", "Business Professional", "Exceptional service! Always punctual and comfortable.", "5"},
                        {"Michael Chen", "Tourist", "Best way to explore Colombo. Friendly drivers and clean cars.", "5"},
                        {"Priya Patel", "Regular Commuter", "Reliable, safe, and professional. My go-to cab service.", "5"}
                };
                for (String[] review : reviews) {
            %>
            <div class="bg-accent p-8 rounded-2xl border border-white/10 card-hover">
                <div class="flex gap-2 mb-6">
                    <% for (int i = 0; i < Integer.parseInt(review[3]); i++) { %>
                    <i data-lucide="star" class="w-6 h-6 text-primary fill-primary animate-pulse-slow"></i>
                    <% } %>
                </div>
                <p class="text-gray-200 italic mb-6 text-lg leading-relaxed">"<%= review[2] %>"</p>
                <div class="flex items-center gap-4">
                    <div>
                        <p class="font-semibold text-white text-xl"><%= review[0] %></p>
                        <p class="text-sm text-gray-400"><%= review[1] %></p>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </section>

    <!-- Footer (Unchanged) -->
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

    // Navbar scroll effect
    window.addEventListener('scroll', () => {
        const navbar = document.getElementById('navbar');
        if (window.scrollY > 50) {
            navbar.classList.add('navbar-scrolled');
        } else {
            navbar.classList.remove('navbar-scrolled');
        }
    });
</script>

</body>
</html>