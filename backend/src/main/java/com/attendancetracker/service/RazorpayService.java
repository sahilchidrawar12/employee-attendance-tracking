package com.attendancetracker.service;

import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class RazorpayService {

    private final RazorpayClient razorpayClient;
    private final String razorpayKeySecret;

    public RazorpayService(@Value("${razorpay.key-id:}") String keyId,
                          @Value("${razorpay.key-secret:}") String keySecret) {
        this.razorpayKeySecret = keySecret;
        if (keyId != null && !keyId.isEmpty() && keySecret != null && !keySecret.isEmpty()) {
            try {
                this.razorpayClient = new RazorpayClient(keyId, keySecret);
            } catch (RazorpayException e) {
                throw new RuntimeException("Failed to initialize Razorpay client", e);
            }
        } else {
            this.razorpayClient = null;
        }
    }

    public Map<String, Object> createOrder(double amount, String currency, String receipt) throws RazorpayException {
        if (razorpayClient == null) {
            throw new RazorpayException("Razorpay not configured");
        }

        JSONObject orderRequest = new JSONObject();
        orderRequest.put("amount", (int)(amount * 100)); // Amount in paisa
        orderRequest.put("currency", currency);
        orderRequest.put("receipt", receipt);

        Order order = razorpayClient.orders.create(orderRequest);

        return Map.of(
            "id", order.get("id"),
            "amount", order.get("amount"),
            "currency", order.get("currency"),
            "receipt", order.get("receipt"),
            "status", order.get("status")
        );
    }

    public boolean verifyPayment(String orderId, String paymentId, String signature) throws RazorpayException {
        if (razorpayClient == null) {
            throw new RazorpayException("Razorpay not configured");
        }

        JSONObject attributes = new JSONObject();
        attributes.put("razorpay_order_id", orderId);
        attributes.put("razorpay_payment_id", paymentId);
        attributes.put("razorpay_signature", signature);

        try {
            // Use Utils class for signature verification
            com.razorpay.Utils.verifyPaymentSignature(attributes, razorpayKeySecret);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Map<String, Object> getPaymentDetails(String paymentId) throws RazorpayException {
        if (razorpayClient == null) {
            throw new RazorpayException("Razorpay not configured");
        }

        com.razorpay.Payment payment = razorpayClient.payments.fetch(paymentId);

        return Map.of(
            "id", payment.get("id"),
            "amount", payment.get("amount"),
            "currency", payment.get("currency"),
            "status", payment.get("status"),
            "method", payment.get("method"),
            "order_id", payment.get("order_id"),
            "captured", payment.get("captured")
        );
    }

    public Map<String, Object> refundPayment(String paymentId, int amount) throws RazorpayException {
        if (razorpayClient == null) {
            throw new RazorpayException("Razorpay not configured");
        }

        JSONObject refundRequest = new JSONObject();
        refundRequest.put("amount", amount);

        com.razorpay.Refund refund = razorpayClient.payments.refund(paymentId, refundRequest);

        return Map.of(
            "id", refund.get("id"),
            "payment_id", refund.get("payment_id"),
            "amount", refund.get("amount"),
            "status", refund.get("status")
        );
    }
}