package com.attendancetracker.controller;

import com.attendancetracker.dto.CompanyCreateRequest;
import com.attendancetracker.service.CompanyService;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/super-admin/companies")
public class CompanyController {

    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> listCompanies(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit
    ) {
        Page<?> companyPage = companyService.listCompanies(page, limit);
        return ResponseEntity.ok(Map.of(
                "items", companyPage.getContent(),
                "total", companyPage.getTotalElements()
        ));
    }

    @PostMapping
    public ResponseEntity<Map<String, Object>> createCompany(@RequestBody CompanyCreateRequest request) {
        var company = companyService.createCompany(request);
        return ResponseEntity.ok(Map.of("success", true, "companyId", company.getId().toString()));
    }

    @PutMapping("/{companyId}")
    public ResponseEntity<Map<String, Object>> updateCompany(@PathVariable String companyId,
                                                             @RequestBody CompanyCreateRequest request) {
        companyService.updateCompany(UUID.fromString(companyId), request);
        return ResponseEntity.ok(Map.of("success", true));
    }
}
