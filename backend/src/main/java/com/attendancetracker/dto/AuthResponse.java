package com.attendancetracker.dto;

public record AuthResponse(String token, UserDto user) {
}
