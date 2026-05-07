package com.attendancetracker.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "super_admins")
public class SuperAdmin {
    @Id
    private UUID id;
    private String email;
    private String passwordHash;
    private OffsetDateTime createdAt;
    private OffsetDateTime lastLogin;
    private String status;

    public SuperAdmin() {
    }

    public SuperAdmin(UUID id, String email, String passwordHash, OffsetDateTime createdAt, String status) {
        this.id = id;
        this.email = email;
        this.passwordHash = passwordHash;
        this.createdAt = createdAt;
        this.status = status;
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getLastLogin() { return lastLogin; }
    public void setLastLogin(OffsetDateTime lastLogin) { this.lastLogin = lastLogin; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
