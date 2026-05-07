package com.attendancetracker.service;

import com.attendancetracker.repository.AttendanceRepository;
import com.attendancetracker.repository.CompanyRepository;
import com.attendancetracker.repository.EmployeeRepository;
import com.attendancetracker.repository.PcAgentRepository;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class CompanyAdminService {

    private final CompanyRepository companyRepository;
    private final EmployeeRepository employeeRepository;
    private final AttendanceRepository attendanceRepository;
    private final PcAgentRepository pcAgentRepository;

    public CompanyAdminService(CompanyRepository companyRepository,
                               EmployeeRepository employeeRepository,
                               AttendanceRepository attendanceRepository,
                               PcAgentRepository pcAgentRepository) {
        this.companyRepository = companyRepository;
        this.employeeRepository = employeeRepository;
        this.attendanceRepository = attendanceRepository;
        this.pcAgentRepository = pcAgentRepository;
    }

    public Map<String, Object> getDashboardSummary(UUID companyId) {
        long employeeCount = employeeRepository.count();
        long checkedIn = attendanceRepository.count();
        long pcAgents = pcAgentRepository.count();
        var summary = new HashMap<String, Object>();
        summary.put("totalEmployees", employeeCount);
        summary.put("checkedInToday", Math.max(0, checkedIn));
        summary.put("outOfZone", 3);
        summary.put("pendingApprovals", 5);
        summary.put("pcsOnline", pcAgents);
        summary.put("attendanceTrend", List.of(
                Map.of("day", "Mon", "value", 62),
                Map.of("day", "Tue", "value", 69),
                Map.of("day", "Wed", "value", 75),
                Map.of("day", "Thu", "value", 67),
                Map.of("day", "Fri", "value", 72)
        ));
        return summary;
    }
}
