package com.example.tp.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;

@Component
public class JwtUtil {

    // Génère une clé secrète robuste (256 bits minimum pour HS256)
    private final SecretKey secretKey = Keys.hmacShaKeyFor(
            "mySecretKeyMySecretKeyMySecretKey123!".getBytes()
    );

    public String generateToken(String username, String role) {
        return Jwts.builder()
                .subject(username)
                .claim("role", role)
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + 3600_000)) // 1h
                .signWith(secretKey)
                .compact();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public String extraireRole(String token) {
        return claims(token).get("role", String.class);
    }

    public String extraireUsername(String token) {
        return claims(token).getSubject();
    }

    private Claims claims(String token) {
        return Jwts.parser().verifyWith(secretKey).build().parseSignedClaims(token).getPayload();
    }
}
