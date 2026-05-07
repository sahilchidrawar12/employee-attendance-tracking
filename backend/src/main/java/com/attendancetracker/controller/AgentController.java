package com.attendancetracker.controller;

import com.attendancetracker.dto.AgentRegistrationRequest;
import com.attendancetracker.dto.HeartbeatRequest;
import com.attendancetracker.model.PcAgent;
import com.attendancetracker.service.AgentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/agent")
public class AgentController {

    private final AgentService agentService;

    public AgentController(AgentService agentService) {
        this.agentService = agentService;
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> registerAgent(@RequestBody AgentRegistrationRequest request) {
        PcAgent agent = agentService.registerAgent(request.hardwareId(), request.pcName(), request.osVersion());
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "agentId", agent.getId().toString(),
                        "status", agent.getStatus(),
                        "hardwareId", agent.getHardwareId()
                )
        ));
    }

    @PostMapping("/heartbeat")
    public ResponseEntity<Map<String, Object>> heartbeat(@RequestBody HeartbeatRequest request) {
        PcAgent agent = agentService.heartbeat(request.agentId(), OffsetDateTime.parse(request.timestamp()));
        return ResponseEntity.ok(Map.of(
                "success", true,
                "data", Map.of(
                        "agentId", agent.getId().toString(),
                        "lastHeartbeat", agent.getLastHeartbeat().toString()
                )
        ));
    }
}
