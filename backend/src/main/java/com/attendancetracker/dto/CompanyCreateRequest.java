package com.attendancetracker.dto;

public record CompanyCreateRequest(
        String name,
        String ownerName,
        String email,
        String phone,
        String city,
        String state,
        String planId,
        Integer maxUsers,
        String status,
        String notes
) {
}
