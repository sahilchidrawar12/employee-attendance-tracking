package com.attendancetracker.controller;

import com.attendancetracker.service.CompanyAdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/company-admin")
public class CompanyAdminController {

    private final CompanyAdminService companyAdminService;

    public CompanyAdminController(CompanyAdminService companyAdminService) {
        this.companyAdminService = companyAdminService;
    }

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getDashboard(@RequestParam(required = false) String companyId) {
        var summary = companyAdminService.getDashboardSummary(companyId != null ? UUID.fromString(companyId) : null);
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/employees")
    public ResponseEntity<Map<String, Object>> listEmployees(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit
    ) {
        return ResponseEntity.ok(Map.of(
                "items", List.of(),
                "total", 0
        ));
    }

    @PostMapping("/employees")
    public ResponseEntity<Map<String, Object>> createEmployee(@RequestBody Map<String, Object> payload) {
        return ResponseEntity.ok(Map.of("success", true, "employeeId", UUID.randomUUID().toString()));
    }
}
