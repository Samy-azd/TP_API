package com.example.tp.controller;

import com.example.tp.model.LoginRequest;
import com.example.tp.security.JwtUtil;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;

@RestController
@RequestMapping("/auth")
public class AuthController {

    // Identifiants simulés : username -> { mot de passe, rôle }
    private static final Map<String, String[]> COMPTES = Map.of(
            "admin", new String[]{"admin123", "admin"},
            "user", new String[]{"user123", "user"}
    );

    private final JwtUtil jwtUtil;

    public AuthController(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@Valid @RequestBody LoginRequest request) {
        String[] compte = COMPTES.get(request.getUsername());

        if (compte == null || !compte[0].equals(request.getPassword())) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(Map.of(
                    "timestamp", LocalDateTime.now(),
                    "status", 401,
                    "error", "Unauthorized",
                    "message", "Identifiants invalides"
            ));
        }

        String role = compte[1];
        return ResponseEntity.ok(Map.of(
                "token", jwtUtil.generateToken(request.getUsername(), role),
                "role", role
        ));
    }
}
