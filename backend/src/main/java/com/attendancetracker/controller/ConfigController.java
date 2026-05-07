package com.attendancetracker.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/config")
public class ConfigController {

    @Value("${app.name:Employee Attendance Tracker}")
    private String appName;

    @Value("${app.version:1.0.0}")
    private String appVersion;

    @Value("${google.maps.api-key:}")
    private String googleMapsApiKey;

    @Value("${app.timezone:UTC}")
    private String timezone;

    @Value("${app.location-update-interval:30000}")
    private Long locationUpdateInterval;

    @Value("${app.zone-check-interval:10000}")
    private Long zoneCheckInterval;

    @GetMapping("/app-settings")
    public ResponseEntity<Map<String, Object>> getAppSettings() {
        return ResponseEntity.ok(Map.of(
            "appName", appName,
            "appVersion", appVersion,
            "timezone", timezone,
            "locationUpdateInterval", locationUpdateInterval,
            "zoneCheckInterval", zoneCheckInterval,
            "maxFileSizeBytes", 10485760,
            "features", Map.of(
                "liveTracking", true,
                "websocketEnabled", true,
                "googleMapsEnabled", true,
                "subscribedPlansEnabled", true
            )
        ));
    }

    @GetMapping("/mobile-settings")
    public ResponseEntity<Map<String, Object>> getMobileSettings() {
        return ResponseEntity.ok(Map.of(
            "apiBaseUrl", "${app.url:http://localhost:8080}",
            "wsBaseUrl", "${app.ws.url:ws://localhost:8080}",
            "googleMapsApiKey", googleMapsApiKey,
            "locationAccuracy", "high",
            "locationUpdateInterval", locationUpdateInterval,
            "zoneCheckInterval", zoneCheckInterval,
            "wsReconnectInterval", 5000,
            "wsMaxRetries", 5
        ));
    }

    @GetMapping("/features")
    public ResponseEntity<Map<String, Object>> getFeatures() {
        return ResponseEntity.ok(Map.of(
            "attendance", Map.of(
                "enabled", true,
                "punchInOutRequired", true,
                "gpsVerificationRequired", true
            ),
            "tracking", Map.of(
                "enabled", true,
                "realTimeLocation", true,
                "zoneBasedTracking", true,
                "activityTracking", true
            ),
            "workspace", Map.of(
                "enabled", true,
                "onlineStatus", true,
                "screenshotCapture", false
            ),
            "geofencing", Map.of(
                "enabled", true,
                "allowedZoneRadius", 500,
                "warningZoneRadius", 1000
            ),
            "notifications", Map.of(
                "enabled", true,
                "punchNotifications", true,
                "zoneAlerts", true,
                "absenteeAlerts", true
            ),
            "subscription", Map.of(
                "enabled", true,
                "razorpayEnabled", true,
                "autoRenewal", true
            )
        ));
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "attendance-tracker-api",
            "version", appVersion,
            "timestamp", System.currentTimeMillis()
        ));
    }
}
