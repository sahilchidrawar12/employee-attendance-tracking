package com.attendancetracker.service;

import com.attendancetracker.model.PcAgent;
import com.attendancetracker.repository.PcAgentRepository;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.UUID;

@Service
public class AgentService {

    private final PcAgentRepository pcAgentRepository;

    public AgentService(PcAgentRepository pcAgentRepository) {
        this.pcAgentRepository = pcAgentRepository;
    }

    public PcAgent registerAgent(String hardwareId, String pcName, String osVersion) {
        return pcAgentRepository.findByHardwareId(hardwareId)
                .orElseGet(() -> pcAgentRepository.save(new PcAgent(
                        UUID.randomUUID(),
                        null,
                        hardwareId,
                        pcName,
                        osVersion,
                        "active",
                        OffsetDateTime.now()
                )));
    }

    public PcAgent heartbeat(String agentId, OffsetDateTime heartbeatAt) {
        return pcAgentRepository.findById(UUID.fromString(agentId))
                .map(agent -> {
                    agent.setLastHeartbeat(heartbeatAt);
                    agent.setStatus("active");
                    return pcAgentRepository.save(agent);
                })
                .orElseThrow(() -> new IllegalArgumentException("Agent not found"));
    }
}
