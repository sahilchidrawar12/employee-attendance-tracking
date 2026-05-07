package com.attendancetracker.dto;

public record AgentRegistrationRequest(String token, String hardwareId, String pcName, String osVersion) {
}
