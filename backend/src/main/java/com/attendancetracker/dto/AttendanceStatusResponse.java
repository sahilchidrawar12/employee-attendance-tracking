package com.attendancetracker.dto;

public record AttendanceStatusResponse(
    boolean checkedIn,
    String currentZone,
    String lastCheckIn,
    String lastCheckOut
) {
}
