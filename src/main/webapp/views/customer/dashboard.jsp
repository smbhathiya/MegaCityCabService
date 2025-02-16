<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<html>
<head>
    <title>Dashboard</title>
</head>
<body>

<h2>Welcome to Dashboard</h2>

<form action="${pageContext.request.contextPath}/Logout" method="get">
    <button type="submit">Logout</button>
</form>

</body>
</html>
