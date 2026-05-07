package com.attendancetracker.service;

import com.attendancetracker.dto.CompanyCreateRequest;
import com.attendancetracker.model.Company;
import com.attendancetracker.repository.CompanyRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class CompanyService {

    private final CompanyRepository companyRepository;

    public CompanyService(CompanyRepository companyRepository) {
        this.companyRepository = companyRepository;
    }

    public Page<Company> listCompanies(int page, int limit) {
        return companyRepository.findAll(PageRequest.of(page - 1, limit));
    }

    public Company createCompany(CompanyCreateRequest request) {
        Company company = new Company();
        company.setId(UUID.randomUUID());
        company.setName(request.name());
        company.setOwnerName(request.ownerName());
        company.setEmail(request.email());
        company.setPhone(request.phone());
        company.setCity(request.city());
        company.setState(request.state());
        company.setPlanId(request.planId() != null ? UUID.fromString(request.planId()) : null);
        company.setMaxUsers(request.maxUsers());
        company.setStatus(request.status() != null ? request.status() : "active");
        company.setCreatedAt(OffsetDateTime.now());
        company.setUpdatedAt(OffsetDateTime.now());
        return companyRepository.save(company);
    }

    public Company updateCompany(UUID companyId, CompanyCreateRequest request) {
        return companyRepository.findById(companyId)
                .map(company -> {
                    company.setName(request.name());
                    company.setOwnerName(request.ownerName());
                    company.setEmail(request.email());
                    company.setPhone(request.phone());
                    company.setCity(request.city());
                    company.setState(request.state());
                    if (request.planId() != null) {
                        company.setPlanId(UUID.fromString(request.planId()));
                    }
                    company.setMaxUsers(request.maxUsers());
                    company.setStatus(request.status());
                    company.setUpdatedAt(OffsetDateTime.now());
                    return companyRepository.save(company);
                })
                .orElseThrow(() -> new IllegalArgumentException("Company not found"));
    }
}
