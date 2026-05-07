package com.attendancetracker.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name = "companies")
public class Company {
    @Id
    private UUID id;
    private String name;
    private String ownerName;
    private String email;
    private String phone;
    private UUID planId;
    private Integer maxUsers;
    private String status;
    private String logoUrl;
    private String address;
    private String city;
    private String state;
    private String timezone;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;

    // Subscription fields
    private String subscriptionStatus; // active, inactive, suspended, cancelled
    private String subscriptionPlan; // starter, professional, enterprise
    private OffsetDateTime subscriptionStartDate;
    private OffsetDateTime subscriptionEndDate;
    private String razorpaySubscriptionId;
    private Double monthlyAmount;
    private String billingCycle; // monthly, yearly
    private OffsetDateTime nextBillingDate;
    private Boolean autoRenewal;

    public Company() {
    }

    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public UUID getPlanId() { return planId; }
    public void setPlanId(UUID planId) { this.planId = planId; }
    public Integer getMaxUsers() { return maxUsers; }
    public void setMaxUsers(Integer maxUsers) { this.maxUsers = maxUsers; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLogoUrl() { return logoUrl; }
    public void setLogoUrl(String logoUrl) { this.logoUrl = logoUrl; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getState() { return state; }
    public void setState(String state) { this.state = state; }
    public String getTimezone() { return timezone; }
    public void setTimezone(String timezone) { this.timezone = timezone; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Subscription getters and setters
    public String getSubscriptionStatus() { return subscriptionStatus; }
    public void setSubscriptionStatus(String subscriptionStatus) { this.subscriptionStatus = subscriptionStatus; }
    public String getSubscriptionPlan() { return subscriptionPlan; }
    public void setSubscriptionPlan(String subscriptionPlan) { this.subscriptionPlan = subscriptionPlan; }
    public OffsetDateTime getSubscriptionStartDate() { return subscriptionStartDate; }
    public void setSubscriptionStartDate(OffsetDateTime subscriptionStartDate) { this.subscriptionStartDate = subscriptionStartDate; }
    public OffsetDateTime getSubscriptionEndDate() { return subscriptionEndDate; }
    public void setSubscriptionEndDate(OffsetDateTime subscriptionEndDate) { this.subscriptionEndDate = subscriptionEndDate; }
    public String getRazorpaySubscriptionId() { return razorpaySubscriptionId; }
    public void setRazorpaySubscriptionId(String razorpaySubscriptionId) { this.razorpaySubscriptionId = razorpaySubscriptionId; }
    public Double getMonthlyAmount() { return monthlyAmount; }
    public void setMonthlyAmount(Double monthlyAmount) { this.monthlyAmount = monthlyAmount; }
    public String getBillingCycle() { return billingCycle; }
    public void setBillingCycle(String billingCycle) { this.billingCycle = billingCycle; }
    public OffsetDateTime getNextBillingDate() { return nextBillingDate; }
    public void setNextBillingDate(OffsetDateTime nextBillingDate) { this.nextBillingDate = nextBillingDate; }
    public Boolean getAutoRenewal() { return autoRenewal; }
    public void setAutoRenewal(Boolean autoRenewal) { this.autoRenewal = autoRenewal; }
}
