package com.attendancetracker.controller;

import com.attendancetracker.dto.AuthResponse;
import com.attendancetracker.dto.LoginRequest;
import com.attendancetracker.dto.RegisterRequest;
import com.attendancetracker.dto.UserDto;
import com.attendancetracker.model.Employee;
import com.attendancetracker.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/super-admin/login")
    public ResponseEntity<Map<String, Object>> superAdminLogin(@RequestBody LoginRequest request) {
        String token = authService.authenticateSuperAdmin(request.email(), request.password());
        if (token == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", Map.of("message", "Invalid credentials")));
        }

        AuthResponse response = new AuthResponse(token, new UserDto("super-admin", request.email(), "super_admin", null));
        return ResponseEntity.ok(Map.of("success", true, "data", response));
    }

    @PostMapping("/employee/login")
    public ResponseEntity<Map<String, Object>> employeeLogin(@RequestBody LoginRequest request) {
        String token = authService.authenticateEmployee(request.email(), request.password());
        if (token == null) {
            return ResponseEntity.status(401).body(Map.of("success", false, "error", Map.of("message", "Invalid credentials")));
        }

        Employee employee = authService.getEmployeeByEmail(request.email());
        AuthResponse response = new AuthResponse(token, new UserDto(
            employee.getId().toString(),
            employee.getEmail(),
            employee.getRole(),
            employee.getCompanyId() != null ? employee.getCompanyId().toString() : null
        ));
        return ResponseEntity.ok(Map.of("success", true, "data", response));
    }

    @PostMapping("/employee/register")
    public ResponseEntity<Map<String, Object>> registerEmployee(@RequestBody RegisterRequest request) {
        try {
            // For now, assume companyId comes from somewhere else or is null for individual registration
            // In production, this would be handled differently
            UUID companyId = null; // This should come from invitation or company context
            Employee employee = authService.registerEmployee(
                request.email(),
                request.password(),
                request.firstName(),
                request.lastName(),
                companyId
            );

            return ResponseEntity.ok(Map.of("success", true, "message", "Registration successful", "data", Map.of(
                "id", employee.getId(),
                "email", employee.getEmail(),
                "firstName", employee.getFirstName(),
                "lastName", employee.getLastName()
            )));
        } catch (RuntimeException e) {
            return ResponseEntity.status(400).body(Map.of("success", false, "error", Map.of("message", e.getMessage())));
        }
    }

    @PostMapping("/employee/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String resetToken = authService.generatePasswordResetToken(email);
        if (resetToken == null) {
            return ResponseEntity.status(404).body(Map.of("success", false, "error", Map.of("message", "Email not found")));
        }

        // In production, send email with reset link
        // For now, return the token for testing
        return ResponseEntity.ok(Map.of("success", true, "message", "Password reset token generated", "resetToken", resetToken));
    }

    @PostMapping("/employee/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String newPassword = request.get("newPassword");

        boolean success = authService.resetPassword(token, newPassword);
        if (!success) {
            return ResponseEntity.status(400).body(Map.of("success", false, "error", Map.of("message", "Invalid or expired token")));
        }

        return ResponseEntity.ok(Map.of("success", true, "message", "Password reset successful"));
    }

    @PostMapping("/employee/change-password")
    public ResponseEntity<Map<String, Object>> changePassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        String oldPassword = request.get("oldPassword");
        String newPassword = request.get("newPassword");

        boolean success = authService.changePassword(email, oldPassword, newPassword);
        if (!success) {
            return ResponseEntity.status(400).body(Map.of("success", false, "error", Map.of("message", "Invalid credentials")));
        }

        return ResponseEntity.ok(Map.of("success", true, "message", "Password changed successfully"));
    }

    @GetMapping("/employee/profile/{employeeId}")
    public ResponseEntity<Map<String, Object>> getEmployeeProfile(@PathVariable String employeeId) {
        try {
            Employee employee = authService.getEmployeeById(UUID.fromString(employeeId));
            if (employee == null) {
                return ResponseEntity.status(404).body(Map.of("success", false, "error", Map.of("message", "Employee not found")));
            }

            return ResponseEntity.ok(Map.of("success", true, "data", Map.of(
                "id", employee.getId().toString(),
                "email", employee.getEmail(),
                "firstName", employee.getFirstName(),
                "lastName", employee.getLastName(),
                "companyId", employee.getCompanyId() != null ? employee.getCompanyId().toString() : null,
                "designation", employee.getDesignation() != null ? employee.getDesignation() : "",
                "department", employee.getDepartment() != null ? employee.getDepartment() : "",
                "active", employee.isActive()
            )));
        } catch (Exception e) {
            return ResponseEntity.status(400).body(Map.of("success", false, "error", Map.of("message", e.getMessage())));
        }
    }
}
