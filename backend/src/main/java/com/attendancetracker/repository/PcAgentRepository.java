package com.attendancetracker.repository;

import com.attendancetracker.model.PcAgent;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface PcAgentRepository extends JpaRepository<PcAgent, UUID> {
    Optional<PcAgent> findByHardwareId(String hardwareId);
}
