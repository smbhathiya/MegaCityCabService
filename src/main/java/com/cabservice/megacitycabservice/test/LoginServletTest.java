package com.cabservice.megacitycabservice.test;

import com.cabservice.megacitycabservice.dao.UserDAO;
import com.cabservice.megacitycabservice.model.User;
import com.cabservice.megacitycabservice.servlet.auth.LoginServlet;
import com.cabservice.megacitycabservice.util.PasswordUtil;
import com.google.gson.Gson;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.Map;
import java.util.UUID;

import static org.mockito.Mockito.*;
import static org.junit.jupiter.api.Assertions.*;

class LoginServletTest {

    private LoginServlet loginServlet;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private UserDAO userDAO;

    private StringWriter responseWriter;
    private Gson gson;

    @BeforeEach
    void setUp() throws Exception {
        MockitoAnnotations.openMocks(this);
        loginServlet = new LoginServlet(userDAO);
        loginServlet.init();
        responseWriter = new StringWriter();
        when(response.getWriter()).thenReturn(new PrintWriter(responseWriter));
        gson = new Gson();
    }

    @Test
    void testSuccessfulLogin() throws Exception {
        String email = "test@gmail.com";
        String password = "1111";
        String hashedPassword = PasswordUtil.hashPassword(password);
        UUID fixedUserId = UUID.fromString("2ecf7a13-81aa-4908-afb2-0193bcfac739");
        User user = new User(fixedUserId, "Test User", email, hashedPassword, "customer", true, null, null);

        String jsonRequest = "{\"email\":\"" + email + "\",\"password\":\"" + password + "\"}";
        when(request.getContentType()).thenReturn("application/json");
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(jsonRequest)));
        when(userDAO.getUserByEmail(email)).thenReturn(user);
        when(request.getSession(false)).thenReturn(null);
        when(request.getSession(true)).thenReturn(session);
        when(session.getId()).thenReturn("session123");

        try (var mockedStatic = mockStatic(PasswordUtil.class)) {
            when(PasswordUtil.hashPassword(anyString())).thenCallRealMethod();
            when(PasswordUtil.checkPassword(password, hashedPassword)).thenReturn(true);

            loginServlet.doPost(request, response);

            String jsonResponse = responseWriter.toString();
            System.out.println("Response: " + jsonResponse);
            Map<String, String> responseMap = gson.fromJson(jsonResponse, Map.class);
            assertEquals("success", responseMap.get("status"), "Expected success status");
            assertEquals("customer", responseMap.get("role"), "Expected customer role");
            assertEquals("Login successful.", responseMap.get("message"), "Expected success message");

            verify(session).setAttribute(eq("sessionId"), anyString());
            verify(session).setAttribute("userId", fixedUserId);
            verify(session).setAttribute("userName", "Test User");
            verify(session).setAttribute("userEmail", email);
            verify(session).setAttribute("role", "customer");
            verify(session).setMaxInactiveInterval(30 * 60);
            verify(response).addCookie(any(Cookie.class));
        }
    }

    @Test
    void testInvalidCredentials() throws Exception {
        // Arrange
        String email = "test@example.com";
        String password = "wrongpassword";
        String correctPassword = "password123";
        String hashedPassword = PasswordUtil.hashPassword(correctPassword);
        User user = new User(UUID.randomUUID(), "Test User", email, hashedPassword, "customer", true, null, null);

        String jsonRequest = "{\"email\":\"" + email + "\",\"password\":\"" + password + "\"}";
        when(request.getContentType()).thenReturn("application/json");
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(jsonRequest)));
        when(userDAO.getUserByEmail(email)).thenReturn(user);

        try (var mockedStatic = mockStatic(PasswordUtil.class)) {
            when(PasswordUtil.hashPassword(anyString())).thenCallRealMethod();
            when(PasswordUtil.checkPassword(password, hashedPassword)).thenReturn(false);

            loginServlet.doPost(request, response);

            String jsonResponse = responseWriter.toString();
            System.out.println("Response: " + jsonResponse);
            Map<String, String> responseMap = gson.fromJson(jsonResponse, Map.class);
            assertEquals("error", responseMap.get("status"), "Expected error status");
            assertEquals("Invalid email or password.", responseMap.get("message"), "Expected invalid credentials message");
            verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
            verifyNoInteractions(session);
        }
    }

    @Test
    void testMissingEmailOrPassword() throws Exception {
        String jsonRequest = "{\"email\":\"\",\"password\":\"\"}";
        when(request.getContentType()).thenReturn("application/json");
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(jsonRequest)));

        loginServlet.doPost(request, response);

        String jsonResponse = responseWriter.toString();
        System.out.println("Response: " + jsonResponse);
        Map<String, String> responseMap = gson.fromJson(jsonResponse, Map.class);
        assertEquals("error", responseMap.get("status"), "Expected error status");
        assertEquals("Email and password are required.", responseMap.get("message"), "Expected missing credentials message");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        verifyNoInteractions(userDAO, session);
    }

    @Test
    void testInvalidContentType() throws Exception {
        when(request.getContentType()).thenReturn("text/plain");

        loginServlet.doPost(request, response);

        String jsonResponse = responseWriter.toString();
        System.out.println("Response: " + jsonResponse);
        Map<String, String> responseMap = gson.fromJson(jsonResponse, Map.class);
        assertEquals("error", responseMap.get("status"), "Expected error status");
        assertEquals("Content-Type must be application/json", responseMap.get("message"), "Expected invalid content type message");
        verify(response).setStatus(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE);
        verifyNoInteractions(userDAO, session);
    }

    @Test
    void testNonExistentUser() throws Exception {
        String email = "nonexistent@example.com";
        String password = "password123";
        String jsonRequest = "{\"email\":\"" + email + "\",\"password\":\"" + password + "\"}";
        when(request.getContentType()).thenReturn("application/json");
        when(request.getReader()).thenReturn(new BufferedReader(new StringReader(jsonRequest)));
        when(userDAO.getUserByEmail(email)).thenReturn(null);

        loginServlet.doPost(request, response);

        String jsonResponse = responseWriter.toString();
        System.out.println("Response: " + jsonResponse);
        Map<String, String> responseMap = gson.fromJson(jsonResponse, Map.class);
        assertEquals("error", responseMap.get("status"), "Expected error status");
        assertEquals("Invalid email or password.", responseMap.get("message"), "Expected invalid credentials message");
        verify(response).setStatus(HttpServletResponse.SC_BAD_REQUEST);
        verifyNoInteractions(session);
    }
}