package com.attendancetracker.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "attendance_records")
public class AttendanceRecord {
    @Id
    private UUID id;
    private UUID employeeId;
    private UUID companyId;
    private UUID locationId;
    private OffsetDateTime checkInAt;
    private OffsetDateTime checkOutAt;
    private String status;
    private Integer distanceMeters;
    private OffsetDateTime createdAt;

    public AttendanceRecord() {
    }

    public AttendanceRecord(UUID id, UUID employeeId, UUID companyId, UUID locationId, OffsetDateTime checkInAt, String status, OffsetDateTime createdAt) {
        this.id = id;
        this.employeeId = employeeId;
        this.companyId = companyId;
        this.locationId = locationId;
        this.checkInAt = checkInAt;
        this.status = status;
        this.createdAt = createdAt;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(UUID employeeId) {
        this.employeeId = employeeId;
    }

    public UUID getCompanyId() {
        return companyId;
    }

    public void setCompanyId(UUID companyId) {
        this.companyId = companyId;
    }

    public UUID getLocationId() {
        return locationId;
    }

    public void setLocationId(UUID locationId) {
        this.locationId = locationId;
    }

    public OffsetDateTime getCheckInAt() {
        return checkInAt;
    }

    public void setCheckInAt(OffsetDateTime checkInAt) {
        this.checkInAt = checkInAt;
    }

    public OffsetDateTime getCheckOutAt() {
        return checkOutAt;
    }

    public void setCheckOutAt(OffsetDateTime checkOutAt) {
        this.checkOutAt = checkOutAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDistanceMeters() {
        return distanceMeters;
    }

    public void setDistanceMeters(Integer distanceMeters) {
        this.distanceMeters = distanceMeters;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(OffsetDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
