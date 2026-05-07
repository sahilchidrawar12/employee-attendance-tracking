package com.attendancetracker.service;

import com.attendancetracker.dto.AttendanceRequest;
import com.attendancetracker.model.AttendanceRecord;
import com.attendancetracker.model.Employee;
import com.attendancetracker.repository.AttendanceRepository;
import com.attendancetracker.repository.EmployeeRepository;
import com.attendancetracker.repository.LocationRepository;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final EmployeeRepository employeeRepository;
    private final LocationRepository locationRepository;

    public AttendanceService(AttendanceRepository attendanceRepository,
                             EmployeeRepository employeeRepository,
                             LocationRepository locationRepository) {
        this.attendanceRepository = attendanceRepository;
        this.employeeRepository = employeeRepository;
        this.locationRepository = locationRepository;
    }

    public AttendanceRecord punchIn(AttendanceRequest request) {
        UUID employeeId = UUID.fromString(request.employeeId());
        Optional<Employee> employee = employeeRepository.findById(employeeId);
        if (employee.isEmpty()) {
            throw new IllegalArgumentException("Employee not found");
        }

        AttendanceRecord openRecord = attendanceRepository
            .findTopByEmployeeIdAndCheckOutAtIsNullOrderByCreatedAtDesc(employeeId)
            .orElse(null);

        if (openRecord != null) {
            throw new IllegalStateException("Employee is already checked in");
        }

        AttendanceRecord record = new AttendanceRecord();
        record.setId(UUID.randomUUID());
        record.setEmployeeId(employeeId);
        record.setCompanyId(employee.get().getCompanyId());
        record.setCheckInAt(OffsetDateTime.now());
        record.setStatus("checked_in");
        record.setLocationId(findNearestLocation(employee.get().getCompanyId(), request.latitude(), request.longitude()));
        record.setDistanceMeters(calculateDistanceMeters(request.latitude(), request.longitude(), request.latitude(), request.longitude()));
        record.setCreatedAt(OffsetDateTime.now());

        Employee emp = employee.get();
        emp.setLastCheckIn(record.getCheckInAt());
        employeeRepository.save(emp);

        return attendanceRepository.save(record);
    }

    public AttendanceRecord punchOut(AttendanceRequest request) {
        UUID employeeId = UUID.fromString(request.employeeId());
        AttendanceRecord record = attendanceRepository
            .findTopByEmployeeIdAndCheckOutAtIsNullOrderByCreatedAtDesc(employeeId)
            .orElseThrow(() -> new IllegalStateException("No active check-in found"));

        record.setCheckOutAt(OffsetDateTime.now());
        record.setStatus("checked_out");
        record.setDistanceMeters(calculateDistanceMeters(request.latitude(), request.longitude(), request.latitude(), request.longitude()));

        Optional<Employee> employee = employeeRepository.findById(employeeId);
        employee.ifPresent(emp -> {
            emp.setLastCheckOut(record.getCheckOutAt());
            employeeRepository.save(emp);
        });

        return attendanceRepository.save(record);
    }

    public Optional<AttendanceRecord> getActiveAttendance(UUID employeeId) {
        return attendanceRepository.findTopByEmployeeIdAndCheckOutAtIsNullOrderByCreatedAtDesc(employeeId);
    }

    public Optional<AttendanceRecord> getLastAttendance(UUID employeeId) {
        return attendanceRepository.findTopByEmployeeIdOrderByCreatedAtDesc(employeeId);
    }

    private UUID findNearestLocation(UUID companyId, Double latitude, Double longitude) {
        return locationRepository.findByCompanyId(companyId).stream()
            .min((left, right) -> Double.compare(
                calculateDistanceMeters(latitude, longitude, left.getLatitude(), left.getLongitude()),
                calculateDistanceMeters(latitude, longitude, right.getLatitude(), right.getLongitude())
            ))
            .map(location -> location.getId())
            .orElse(null);
    }

    private int calculateDistanceMeters(Double lat1, Double lon1, Double lat2, Double lon2) {
        double earthRadius = 6371000;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return (int) (earthRadius * c);
    }
}
