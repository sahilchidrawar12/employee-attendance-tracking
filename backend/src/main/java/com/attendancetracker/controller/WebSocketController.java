package com.attendancetracker.controller;

import com.attendancetracker.model.AttendanceRecord;
import com.attendancetracker.model.PcAgent;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.time.OffsetDateTime;
import java.util.Map;

@Controller
public class WebSocketController {

    private final SimpMessagingTemplate messagingTemplate;

    public WebSocketController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/attendance/update")
    @SendTo("/topic/attendance")
    public Map<String, Object> handleAttendanceUpdate(Map<String, Object> attendanceData) {
        return Map.of(
            "type", "attendance_update",
            "data", attendanceData,
            "timestamp", OffsetDateTime.now()
        );
    }

    @MessageMapping("/location/update")
    @SendTo("/topic/location")
    public Map<String, Object> handleLocationUpdate(Map<String, Object> locationData) {
        return Map.of(
            "type", "location_update",
            "data", locationData,
            "timestamp", OffsetDateTime.now()
        );
    }

    @MessageMapping("/agent/status")
    @SendTo("/topic/agent")
    public Map<String, Object> handleAgentStatusUpdate(Map<String, Object> agentData) {
        return Map.of(
            "type", "agent_status",
            "data", agentData,
            "timestamp", OffsetDateTime.now()
        );
    }

    // Methods to send updates from services
    public void sendAttendanceUpdate(AttendanceRecord record) {
        Map<String, Object> data = Map.of(
            "employeeId", record.getEmployeeId(),
            "type", record.getStatus(),
            "timestamp", record.getCheckInAt() != null ? record.getCheckInAt() : record.getCreatedAt(),
            "location", record.getLocationId() != null ? Map.of(
                "locationId", record.getLocationId()
            ) : null
        );
        messagingTemplate.convertAndSend("/topic/attendance", Map.of(
            "type", "attendance_update",
            "data", data,
            "timestamp", OffsetDateTime.now()
        ));
    }

    public void sendAgentStatusUpdate(PcAgent agent) {
        Map<String, Object> data = Map.of(
            "agentId", agent.getId(),
            "hardwareId", agent.getHardwareId(),
            "status", agent.getStatus(),
            "lastHeartbeat", agent.getLastHeartbeat(),
            "pcName", agent.getPcName(),
            "osVersion", agent.getOsVersion()
        );
        messagingTemplate.convertAndSend("/topic/agent", Map.of(
            "type", "agent_status",
            "data", data,
            "timestamp", OffsetDateTime.now()
        ));
    }

    public void sendAlert(String companyId, String alertType, String message, Map<String, Object> data) {
        Map<String, Object> alertData = Map.of(
            "companyId", companyId,
            "alertType", alertType,
            "message", message,
            "data", data,
            "timestamp", OffsetDateTime.now()
        );
        messagingTemplate.convertAndSend("/topic/alerts/" + companyId, Map.of(
            "type", "alert",
            "data", alertData,
            "timestamp", OffsetDateTime.now()
        ));
    }
}