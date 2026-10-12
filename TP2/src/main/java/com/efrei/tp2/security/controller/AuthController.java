package com.efrei.tp2.security.controller;

import com.efrei.tp2.security.dto.AuthResponse;
import com.efrei.tp2.security.dto.LoginRequest;
import com.efrei.tp2.security.dto.RefreshTokenRequest;
import com.efrei.tp2.security.dto.RegisterRequest;
import com.efrei.tp2.security.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    public ResponseEntity<Map<String, String>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        Map<String, String> response = authService.refreshAccessToken(request);
        return ResponseEntity.ok(response);
    }
}
