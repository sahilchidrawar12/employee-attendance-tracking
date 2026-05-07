package com.attendancetracker.controller;

import com.attendancetracker.model.Company;
import com.attendancetracker.service.SubscriptionService;
import com.razorpay.RazorpayException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/super-admin/subscriptions")
public class SubscriptionController {

    private final SubscriptionService subscriptionService;

    public SubscriptionController(SubscriptionService subscriptionService) {
        this.subscriptionService = subscriptionService;
    }

    @PostMapping("/create")
    public ResponseEntity<Map<String, Object>> createSubscription(@RequestBody Map<String, Object> request) throws RazorpayException {
        UUID companyId = UUID.fromString((String) request.get("companyId"));
        String planName = (String) request.get("planName");
        String billingCycle = (String) request.get("billingCycle");

        Company company = subscriptionService.createSubscription(companyId, planName, billingCycle);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Subscription created successfully",
            "data", Map.of(
                "companyId", company.getId(),
                "plan", company.getSubscriptionPlan(),
                "status", company.getSubscriptionStatus(),
                "amount", company.getMonthlyAmount(),
                "billingCycle", company.getBillingCycle(),
                "razorpayOrderId", company.getRazorpaySubscriptionId()
            )
        ));
    }

    @PostMapping("/activate")
    public ResponseEntity<Map<String, Object>> activateSubscription(@RequestBody Map<String, Object> request) throws RazorpayException {
        UUID companyId = UUID.fromString((String) request.get("companyId"));
        String paymentId = (String) request.get("paymentId");
        String signature = (String) request.get("signature");

        Company company = subscriptionService.activateSubscription(companyId, paymentId, signature);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Subscription activated successfully",
            "data", Map.of(
                "companyId", company.getId(),
                "status", company.getSubscriptionStatus(),
                "startDate", company.getSubscriptionStartDate(),
                "endDate", company.getSubscriptionEndDate()
            )
        ));
    }

    @PutMapping("/{companyId}/status")
    public ResponseEntity<Map<String, Object>> updateSubscriptionStatus(
            @PathVariable UUID companyId,
            @RequestBody Map<String, Object> request) {

        String status = (String) request.get("status");
        Company company = subscriptionService.updateSubscriptionStatus(companyId, status);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Subscription status updated successfully",
            "data", Map.of(
                "companyId", company.getId(),
                "status", company.getSubscriptionStatus()
            )
        ));
    }

    @PutMapping("/{companyId}/toggle")
    public ResponseEntity<Map<String, Object>> toggleSubscription(
            @PathVariable UUID companyId,
            @RequestBody Map<String, Object> request) {

        boolean enable = Boolean.parseBoolean(request.get("enable").toString());
        Company company = subscriptionService.toggleSubscription(companyId, enable);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", enable ? "Subscription enabled" : "Subscription disabled",
            "data", Map.of(
                "companyId", company.getId(),
                "status", company.getSubscriptionStatus()
            )
        ));
    }

    @PutMapping("/{companyId}/upgrade")
    public ResponseEntity<Map<String, Object>> upgradeSubscription(
            @PathVariable UUID companyId,
            @RequestBody Map<String, Object> request) throws RazorpayException {

        String newPlan = (String) request.get("newPlan");
        String billingCycle = (String) request.get("billingCycle");

        Company company = subscriptionService.upgradeSubscription(companyId, newPlan, billingCycle);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Subscription upgraded successfully",
            "data", Map.of(
                "companyId", company.getId(),
                "plan", company.getSubscriptionPlan(),
                "amount", company.getMonthlyAmount(),
                "billingCycle", company.getBillingCycle()
            )
        ));
    }

    @GetMapping("/{companyId}")
    public ResponseEntity<Map<String, Object>> getSubscriptionDetails(@PathVariable UUID companyId) {
        Map<String, Object> details = subscriptionService.getSubscriptionDetails(companyId);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "data", details
        ));
    }

    @GetMapping("/plans")
    public ResponseEntity<Map<String, Object>> getAvailablePlans() {
        return ResponseEntity.ok(Map.of(
            "success", true,
            "data", Map.of(
                "plans", new Object[] {
                    Map.of(
                        "name", "starter",
                        "displayName", "Starter",
                        "monthlyPrice", 999,
                        "yearlyPrice", 9599, // 20% discount
                        "features", new String[] {
                            "Up to 10 employees",
                            "Basic attendance tracking",
                            "Mobile app access",
                            "Email support"
                        }
                    ),
                    Map.of(
                        "name", "professional",
                        "displayName", "Professional",
                        "monthlyPrice", 2499,
                        "yearlyPrice", 23999,
                        "features", new String[] {
                            "Up to 50 employees",
                            "Advanced analytics",
                            "GPS zone management",
                            "PC activity monitoring",
                            "Priority support"
                        }
                    ),
                    Map.of(
                        "name", "enterprise",
                        "displayName", "Enterprise",
                        "monthlyPrice", 4999,
                        "yearlyPrice", 47999,
                        "features", new String[] {
                            "Unlimited employees",
                            "Custom integrations",
                            "Advanced reporting",
                            "Dedicated support",
                            "White-label option"
                        }
                    )
                }
            )
        ));
    }
}