package com.attendancetracker.dto;

public record AttendanceRequest(
    String employeeId,
    Double latitude,
    Double longitude,
    String zoneName
) {
}
