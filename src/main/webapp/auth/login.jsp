<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Mega City Cabs</title>
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
                        dark: '#000000'
                    }
                }
            }
        };
    </script>
    <style>
        .background {
            /*background-image: url('../assets/cab2.webp');*/
            background-size: cover;
            background-position: center;
            height: 100vh;
        }
    </style>
</head>
<body class="bg-dark text-white background backdrop-blur-xl">
<!-- Navbar -->
<nav class="fixed top-0 left-0 right-0 ">
    <div class="container mx-auto px-4 sm:px-6 py-2">
        <div class="flex h-16 items-center justify-between">
            <div class="flex items-center gap-2">
                <a href="../index.jsp" class="flex items-center gap-2">
                    <i data-lucide="car" class="w-6 h-6 sm:w-8 sm:h-8 text-primary"></i>
                    <span class="text-xl sm:text-2xl font-bold text-white">Mega City Cabs</span>
                </a>
            </div>

            <div class="flex items-center gap-2 sm:gap-4">
                <a href="${pageContext.request.contextPath}/customer/customerRegister.jsp" class="px-3 sm:px-4 py-2 border border-primary text-primary rounded-md hover:bg-primary/10 transition flex items-center gap-2 text-sm sm:text-base">
                    <i data-lucide="user-plus" class="w-4 h-4 sm:w-5 sm:h-5"></i>
                    Register
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="min-h-screen flex items-center justify-center px-4">
    <div class="bg-dark/50 p-6 sm:p-8 rounded-lg border border-white/10 w-11/12 sm:w-full max-w-md">
        <h2 class="text-xl sm:text-2xl font-bold mb-4 sm:mb-6 text-center">Login</h2>
        <form action="${pageContext.request.contextPath}/UserLogin" method="post">
            <div class="mb-4">
                <label for="email" class="block text-sm font-medium mb-1 sm:mb-2">Email</label>
                <input type="email" id="email" name="email" class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white text-sm sm:text-base placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none" required>
            </div>
            <div class="mb-5 sm:mb-6">
                <label for="password" class="block text-sm font-medium mb-1 sm:mb-2">Password</label>
                <input type="password" id="password" name="password" class="w-full px-3 py-2 bg-dark/20 border border-white/20 rounded-md text-white text-sm sm:text-base placeholder-gray-400 focus:ring-2 focus:ring-primary focus:outline-none" required>
            </div>
            <button type="submit" class="w-full bg-primary text-black py-2 rounded-md hover:bg-primary-700 transition text-sm sm:text-base">Login</button>
        </form>
        <p class="mt-3 sm:mt-4 text-center text-gray-400 text-xs sm:text-sm">
            Don't have an account? <a href="${pageContext.request.contextPath}/customer/customerRegister.jsp" class="text-primary hover:underline">Register here</a>
        </p>
    </div>
</div>

<script src="https://unpkg.com/lucide@latest"></script>
<script>
    window.onload = function() {
        lucide.createIcons();
    };
</script>

<script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

<script>
    window.onload = function () {
        lucide.createIcons();

        var toastMessage = '<%= session.getAttribute("toastMessage") != null ? session.getAttribute("toastMessage") : "" %>';
        var toastType = '<%= session.getAttribute("toastType") != null ? session.getAttribute("toastType") : "" %>';
        var redirectURL = '<%= session.getAttribute("redirectURL") != null ? session.getAttribute("redirectURL") : "" %>';

        if (toastMessage !== "") {
            Toastify({
                text: toastMessage,
                duration: 3000,
                close: true,
                gravity: "top",
                position: "right",
                backgroundColor: toastType === "success" ? "green" : "red",
                stopOnFocus: true
            }).showToast();

            if (toastType === "success" && redirectURL !== "") {
                setTimeout(function () {
                    window.location.href = redirectURL;
                }, 3500);
            }

            <% session.removeAttribute("toastMessage"); %>
            <% session.removeAttribute("toastType"); %>
            <% session.removeAttribute("redirectURL"); %>
        }
    };
</script>
</body>
</html>

