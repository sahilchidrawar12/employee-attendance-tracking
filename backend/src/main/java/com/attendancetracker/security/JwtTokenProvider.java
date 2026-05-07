package com.attendancetracker.security;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;

import java.time.Duration;
import java.util.Date;

public class JwtTokenProvider {

    private final Algorithm algorithm;
    private final long expirationMs;

    public JwtTokenProvider(String secret, long expirationMs) {
        this.algorithm = Algorithm.HMAC256(secret);
        this.expirationMs = expirationMs;
    }

    public String generateToken(String userId, String email, String role, String companyId) {
        return JWT.create()
                .withSubject(userId)
                .withClaim("email", email)
                .withClaim("role", role)
                .withClaim("companyId", companyId)
                .withExpiresAt(new Date(System.currentTimeMillis() + expirationMs))
                .sign(algorithm);
    }

    public DecodedJWT validateToken(String token) {
        return JWT.require(algorithm).build().verify(token);
    }
}
