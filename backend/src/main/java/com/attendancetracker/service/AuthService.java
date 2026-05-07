package com.attendancetracker.service;

import com.attendancetracker.model.Employee;
import com.attendancetracker.model.SuperAdmin;
import com.attendancetracker.repository.EmployeeRepository;
import com.attendancetracker.repository.SuperAdminRepository;
import com.attendancetracker.security.JwtTokenProvider;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class AuthService {

    private final JwtTokenProvider jwtTokenProvider;
    private final EmployeeRepository employeeRepository;
    private final SuperAdminRepository superAdminRepository;
    private final BCryptPasswordEncoder passwordEncoder;

    public AuthService(JwtTokenProvider jwtTokenProvider,
                      EmployeeRepository employeeRepository,
                      SuperAdminRepository superAdminRepository) {
        this.jwtTokenProvider = jwtTokenProvider;
        this.employeeRepository = employeeRepository;
        this.superAdminRepository = superAdminRepository;
        this.passwordEncoder = new BCryptPasswordEncoder(12);
    }

    public String authenticateSuperAdmin(String email, String password) {
        Optional<SuperAdmin> superAdmin = superAdminRepository.findByEmail(email);
        if (superAdmin.isPresent() && passwordEncoder.matches(password, superAdmin.get().getPasswordHash())) {
            SuperAdmin admin = superAdmin.get();
            admin.setLastLogin(OffsetDateTime.now());
            superAdminRepository.save(admin);
            return jwtTokenProvider.generateToken(admin.getId().toString(), email, "super_admin", null);
        }
        return null;
    }

    public String authenticateEmployee(String email, String password) {
        Optional<Employee> employee = employeeRepository.findByEmail(email);
        if (employee.isPresent() && passwordEncoder.matches(password, employee.get().getPassword())) {
            Employee emp = employee.get();
            if (!"active".equals(emp.getStatus())) {
                return null; // Employee not active
            }
            return jwtTokenProvider.generateToken(
                emp.getId().toString(),
                email,
                "employee",
                emp.getCompanyId() != null ? emp.getCompanyId().toString() : null
            );
        }
        return null;
    }

    public Employee registerEmployee(String email, String password, String firstName, String lastName, UUID companyId) {
        if (employeeRepository.findByEmail(email).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        Employee employee = new Employee();
        employee.setId(UUID.randomUUID());
        employee.setEmail(email);
        employee.setPassword(passwordEncoder.encode(password));
        employee.setFirstName(firstName);
        employee.setLastName(lastName);
        employee.setCompanyId(companyId);
        employee.setRole("employee");
        employee.setStatus("active");
        employee.setEmailVerified(false);
        employee.setCreatedAt(OffsetDateTime.now());
        employee.setUpdatedAt(OffsetDateTime.now());

        return employeeRepository.save(employee);
    }

    public boolean changePassword(String email, String oldPassword, String newPassword) {
        Optional<Employee> employee = employeeRepository.findByEmail(email);
        if (employee.isPresent() && passwordEncoder.matches(oldPassword, employee.get().getPassword())) {
            Employee emp = employee.get();
            emp.setPassword(passwordEncoder.encode(newPassword));
            emp.setUpdatedAt(OffsetDateTime.now());
            employeeRepository.save(emp);
            return true;
        }
        return false;
    }

    public String generatePasswordResetToken(String email) {
        Optional<Employee> employee = employeeRepository.findByEmail(email);
        if (employee.isPresent()) {
            Employee emp = employee.get();
            String resetToken = UUID.randomUUID().toString();
            emp.setResetToken(resetToken);
            emp.setResetTokenExpiry(OffsetDateTime.now().plusHours(1)); // 1 hour expiry
            employeeRepository.save(emp);
            return resetToken;
        }
        return null;
    }

    public boolean resetPassword(String token, String newPassword) {
        Optional<Employee> employee = employeeRepository.findByResetToken(token);
        if (employee.isPresent()) {
            Employee emp = employee.get();
            if (emp.getResetTokenExpiry().isAfter(OffsetDateTime.now())) {
                emp.setPassword(passwordEncoder.encode(newPassword));
                emp.setResetToken(null);
                emp.setResetTokenExpiry(null);
                emp.setUpdatedAt(OffsetDateTime.now());
                employeeRepository.save(emp);
                return true;
            }
        }
        return false;
    }

    public Employee getEmployeeByEmail(String email) {
        return employeeRepository.findByEmail(email).orElse(null);
    }

    public Employee getEmployeeById(UUID employeeId) {
        return employeeRepository.findById(employeeId).orElse(null);
    }
}
