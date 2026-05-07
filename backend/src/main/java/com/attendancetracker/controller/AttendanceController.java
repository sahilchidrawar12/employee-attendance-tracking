package com.attendancetracker.controller;

import com.attendancetracker.dto.AttendanceRequest;
import com.attendancetracker.dto.AttendanceStatusResponse;
import com.attendancetracker.model.AttendanceRecord;
import com.attendancetracker.service.AttendanceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;

    public AttendanceController(AttendanceService attendanceService) {
        this.attendanceService = attendanceService;
    }

    @PostMapping("/punch-in")
    public ResponseEntity<Map<String, Object>> punchIn(@RequestBody AttendanceRequest request) {
        try {
            AttendanceRecord record = attendanceService.punchIn(request);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Punched in successfully",
                "data", Map.of(
                    "attendanceId", record.getId().toString(),
                    "checkInAt", record.getCheckInAt().toString(),
                    "status", record.getStatus()
                )
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", Map.of("message", e.getMessage())
            ));
        }
    }

    @PostMapping("/punch-out")
    public ResponseEntity<Map<String, Object>> punchOut(@RequestBody AttendanceRequest request) {
        try {
            AttendanceRecord record = attendanceService.punchOut(request);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Punched out successfully",
                "data", Map.of(
                    "attendanceId", record.getId().toString(),
                    "checkOutAt", record.getCheckOutAt().toString(),
                    "status", record.getStatus()
                )
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", Map.of("message", e.getMessage())
            ));
        }
    }

    @GetMapping("/status/{employeeId}")
    public ResponseEntity<Map<String, Object>> getStatus(@PathVariable String employeeId) {
        try {
            UUID id = UUID.fromString(employeeId);
            var active = attendanceService.getActiveAttendance(id);
            var last = attendanceService.getLastAttendance(id);
            return ResponseEntity.ok(Map.of(
                "success", true,
                "data", new AttendanceStatusResponse(
                    active.isPresent(),
                    active.map(record -> record.getStatus()).orElse("outside_zone"),
                    last.map(record -> record.getCheckInAt().toString()).orElse(""),
                    last.map(record -> record.getCheckOutAt() != null ? record.getCheckOutAt().toString() : "").orElse("")
                )
            ));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of(
                "success", false,
                "error", Map.of("message", e.getMessage())
            ));
        }
    }
}
