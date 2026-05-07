package com.attendancetracker.service;

import com.attendancetracker.model.Company;
import com.attendancetracker.repository.CompanyRepository;
import com.razorpay.RazorpayException;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

@Service
public class SubscriptionService {

    private final CompanyRepository companyRepository;
    private final RazorpayService razorpayService;

    public SubscriptionService(CompanyRepository companyRepository, RazorpayService razorpayService) {
        this.companyRepository = companyRepository;
        this.razorpayService = razorpayService;
    }

    public Company createSubscription(UUID companyId, String planName, String billingCycle) throws RazorpayException {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        double amount = getPlanAmount(planName, billingCycle);
        String receipt = "sub_" + companyId + "_" + System.currentTimeMillis();

        // Create Razorpay order
        Map<String, Object> order = razorpayService.createOrder(amount, "INR", receipt);

        // Update company subscription
        company.setSubscriptionPlan(planName);
        company.setSubscriptionStatus("pending_payment");
        company.setMonthlyAmount(amount);
        company.setBillingCycle(billingCycle);
        company.setRazorpaySubscriptionId((String) order.get("id"));
        company.setAutoRenewal(true);
        company.setUpdatedAt(OffsetDateTime.now());

        return companyRepository.save(company);
    }

    public Company activateSubscription(UUID companyId, String paymentId, String signature) throws RazorpayException {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        // Verify payment
        boolean isValid = razorpayService.verifyPayment(company.getRazorpaySubscriptionId(), paymentId, signature);
        if (!isValid) {
            throw new RuntimeException("Invalid payment signature");
        }

        // Activate subscription
        OffsetDateTime now = OffsetDateTime.now();
        company.setSubscriptionStatus("active");
        company.setSubscriptionStartDate(now);
        company.setSubscriptionEndDate(calculateEndDate(now, company.getBillingCycle()));
        company.setNextBillingDate(calculateEndDate(now, company.getBillingCycle()));
        company.setUpdatedAt(now);

        return companyRepository.save(company);
    }

    public Company updateSubscriptionStatus(UUID companyId, String status) {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        company.setSubscriptionStatus(status);
        company.setUpdatedAt(OffsetDateTime.now());

        return companyRepository.save(company);
    }

    public Company toggleSubscription(UUID companyId, boolean enable) {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        if (enable) {
            if ("suspended".equals(company.getSubscriptionStatus()) ||
                "cancelled".equals(company.getSubscriptionStatus())) {
                company.setSubscriptionStatus("active");
            }
        } else {
            if ("active".equals(company.getSubscriptionStatus())) {
                company.setSubscriptionStatus("suspended");
            }
        }

        company.setUpdatedAt(OffsetDateTime.now());
        return companyRepository.save(company);
    }

    public Company upgradeSubscription(UUID companyId, String newPlan, String billingCycle) throws RazorpayException {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        double newAmount = getPlanAmount(newPlan, billingCycle);

        // Calculate prorated amount if upgrading mid-cycle
        double proratedAmount = calculateProratedAmount(company, newAmount);

        if (proratedAmount > 0) {
            String receipt = "upgrade_" + companyId + "_" + System.currentTimeMillis();
            razorpayService.createOrder(proratedAmount, "INR", receipt);
        }

        company.setSubscriptionPlan(newPlan);
        company.setMonthlyAmount(newAmount);
        company.setBillingCycle(billingCycle);
        company.setUpdatedAt(OffsetDateTime.now());

        return companyRepository.save(company);
    }

    private double getPlanAmount(String planName, String billingCycle) {
        double monthlyAmount = switch (planName.toLowerCase()) {
            case "starter" -> 999.0;
            case "professional" -> 2499.0;
            case "enterprise" -> 4999.0;
            default -> throw new RuntimeException("Invalid plan: " + planName);
        };

        return "yearly".equals(billingCycle) ? monthlyAmount * 12 * 0.8 : monthlyAmount; // 20% discount for yearly
    }

    private OffsetDateTime calculateEndDate(OffsetDateTime startDate, String billingCycle) {
        return "yearly".equals(billingCycle) ?
            startDate.plusYears(1) : startDate.plusMonths(1);
    }

    private double calculateProratedAmount(Company company, double newAmount) {
        if (company.getSubscriptionEndDate() == null || company.getMonthlyAmount() == null) {
            return newAmount;
        }

        OffsetDateTime now = OffsetDateTime.now();
        long daysRemaining = java.time.Duration.between(now, company.getSubscriptionEndDate()).toDays();
        long totalDays = "yearly".equals(company.getBillingCycle()) ? 365 : 30;

        double remainingAmount = (company.getMonthlyAmount() * daysRemaining) / totalDays;
        return Math.max(0, newAmount - remainingAmount);
    }

    public Map<String, Object> getSubscriptionDetails(UUID companyId) {
        Company company = companyRepository.findById(companyId)
            .orElseThrow(() -> new RuntimeException("Company not found"));

        return Map.of(
            "plan", company.getSubscriptionPlan(),
            "status", company.getSubscriptionStatus(),
            "startDate", company.getSubscriptionStartDate(),
            "endDate", company.getSubscriptionEndDate(),
            "amount", company.getMonthlyAmount(),
            "billingCycle", company.getBillingCycle(),
            "nextBillingDate", company.getNextBillingDate(),
            "autoRenewal", company.getAutoRenewal(),
            "razorpaySubscriptionId", company.getRazorpaySubscriptionId()
        );
    }
}