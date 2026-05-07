package com.attendancetracker.repository;

import com.attendancetracker.model.AttendanceRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface AttendanceRepository extends JpaRepository<AttendanceRecord, UUID> {
    Optional<AttendanceRecord> findTopByEmployeeIdAndCheckOutAtIsNullOrderByCreatedAtDesc(UUID employeeId);
    Optional<AttendanceRecord> findTopByEmployeeIdOrderByCreatedAtDesc(UUID employeeId);
}
