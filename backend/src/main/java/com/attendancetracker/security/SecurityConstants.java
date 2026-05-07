package com.attendancetracker.security;

public final class SecurityConstants {
    public static final String AUTH_HEADER = "Authorization";
    public static final String TOKEN_PREFIX = "Bearer ";
    public static final String JWT_SECRET = "change-this-secret";
    public static final long EXPIRATION_MS = 86_400_000L;
    private SecurityConstants() {
    }
}
