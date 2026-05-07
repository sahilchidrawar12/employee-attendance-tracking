package com.attendancetracker.repository;

import com.attendancetracker.model.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmployeeRepository extends JpaRepository<Employee, UUID> {
    Optional<Employee> findByEmail(String email);
    Optional<Employee> findByResetToken(String resetToken);
    List<Employee> findByCompanyId(UUID companyId);
    List<Employee> findByCompanyIdAndStatus(UUID companyId, String status);
    long countByCompanyId(UUID companyId);
    long countByCompanyIdAndStatus(UUID companyId, String status);
}
