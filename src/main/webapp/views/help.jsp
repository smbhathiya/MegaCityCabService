<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help - Mega City Cabs</title>
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
                        fadeIn: { '0%': { opacity: '0' }, '100%': { opacity: '1' } },
                        slideUp: { '0%': { transform: 'translateY(20px)', opacity: '0' }, '100%': { transform: 'translateY(0)', opacity: '1' } }
                    }
                }
            }
        };
    </script>
    <style>
        body { background-color: #1A1A1A; font-family: 'Inter', sans-serif; }
        .card { background-color: #2A2A2A; border-radius: 1rem; padding: 1.5rem; }
        .btn-primary { transition: transform 0.2s ease, background-color 0.3s ease; }
        .btn-primary:hover { transform: translateY(-2px); }
    </style>
</head>
<body class="bg-dark text-light">
<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 bg-dark/95 backdrop-blur-lg z-50 shadow-md">
    <div class="container mx-auto px-6 py-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-4">
                <a href="../index.jsp" class="flex items-center gap-3">
                    <i data-lucide="car" class="w-10 h-10 text-primary animate-pulse-slow"></i>
                    <div>
                        <span class="text-3xl font-bold text-light tracking-tight">Mega City Cabs</span>
                        <p class="text-sm text-light/70">Help Center</p>
                    </div>
                </a>
            </div>
            <div class="flex items-center gap-6">
                <a href="<%= request.getContextPath() %>/views/auth/login.jsp" class="text-primary hover:text-primary-700">Login</a>
                <a href="<%= request.getContextPath() %>/views/auth/register.jsp" class="bg-primary text-dark px-4 py-2 rounded-full btn-primary font-semibold">Sign Up</a>
            </div>
        </div>
    </div>
</nav>

<!-- Main Content -->
<main class="pt-28 pb-12 px-6">
    <div class="container mx-auto">
        <h1 class="text-4xl font-bold text-white mb-8 text-center">Welcome to Mega City Cabs Help Center</h1>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Introduction</h2>
            <p class="text-light/80">Mega City Cabs provides reliable transportation services across the city. Customers can book rides easily, while drivers work with us to provide these services. Only registered users can access full features.</p>
        </div>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">How to Create an Account</h2>
            <p class="text-light/80">To get started:</p>
            <ul class="list-disc list-inside text-light/80">
                <li><strong>For Customers:</strong> Click "Sign Up" above, fill in your name, email, and password, select "Customer" role, and submit. You’ll receive a confirmation email. Only registered customers can book rides.</li>
                <li><strong>For Drivers:</strong> You cannot self-register as a driver. Please contact Mega City Cabs at <a href="mailto:info@megacitycabs.com" class="text-primary hover:text-primary-700">info@megacitycabs.com</a> or call <span class="text-primary">+1-800-CAB-HELP</span> to register and get approved.</li>
                <li>After registration, log in to access your dashboard.</li>
            </ul>
        </div>

        <div class="card mb-6">
            <h2 class="text-2xl font-bold text-white mb-4">Using Mega City Cabs</h2>
            <p class="text-light/80">As a guest, you can browse our services. To book a ride, you must register as a customer. Registered customers can add bookings via their dashboard. Drivers, once approved, manage trips through their dashboard.</p>
        </div>

        <div class="card">
            <h2 class="text-2xl font-bold text-white mb-4">Need More Help?</h2>
            <p class="text-light/80">For additional assistance, contact us:</p>
            <ul class="list-disc list-inside text-light/80">
                <li>Email: <a href="mailto:info@megacitycabs.com" class="text-primary hover:text-primary-700">info@megacitycabs.com</a></li>
                <li>Phone: <span class="text-primary">+1-800-CAB-HELP</span></li>
            </ul>
            <p class="text-light/80 mt-2">Registered users can access detailed help after logging in via their dashboards.</p>
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
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="twitter" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="linkedin" class="w-6 h-6"></i></a>
                <a href="#" class="text-primary hover:text-primary-700"><i data-lucide="github" class="w-6 h-6"></i></a>
            </div>
        </div>
    </div>
</footer>

<script>
    lucide.createIcons();
</script>
</body>
</html>