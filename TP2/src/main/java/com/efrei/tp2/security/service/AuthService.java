package com.efrei.tp2.security.service;

import com.efrei.tp2.exception.BadRequestException;
import com.efrei.tp2.security.dto.AuthResponse;
import com.efrei.tp2.security.dto.LoginRequest;
import com.efrei.tp2.security.dto.RefreshTokenRequest;
import com.efrei.tp2.security.dto.RegisterRequest;
import com.efrei.tp2.security.model.RefreshToken;
import com.efrei.tp2.security.model.User;
import com.efrei.tp2.security.repository.UserRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final RefreshTokenService refreshTokenService;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       RefreshTokenService refreshTokenService) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenService = refreshTokenService;
    }

    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new BadRequestException("Ce nom d'utilisateur est déjà pris : " + request.getUsername());
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new BadRequestException("Cette adresse email est déjà utilisée : " + request.getEmail());
        }

        String hashedPassword = passwordEncoder.encode(request.getPassword());
        User user = new User(request.getUsername(), hashedPassword, request.getEmail(), "ROLE_USER");
        userRepository.save(user);

        String accessToken = jwtService.generateToken(user.getUsername(), user.getRole());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getUsername());

        return new AuthResponse(accessToken, refreshToken.getToken(), user.getUsername(), user.getEmail());
    }

    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new BadRequestException("Nom d'utilisateur ou mot de passe incorrect"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadRequestException("Nom d'utilisateur ou mot de passe incorrect");
        }

        String accessToken = jwtService.generateToken(user.getUsername(), user.getRole());
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user.getUsername());

        return new AuthResponse(accessToken, refreshToken.getToken(), user.getUsername(), user.getEmail());
    }

    public Map<String, String> refreshAccessToken(RefreshTokenRequest request) {
        String tokenStr = request.getRefreshToken();
        return refreshTokenService.findByToken(tokenStr)
                .map(refreshTokenService::verifyExpiration)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String newAccessToken = jwtService.generateToken(user.getUsername(), user.getRole());
                    return Map.of(
                            "accessToken", newAccessToken,
                            "refreshToken", tokenStr,
                            "tokenType", "Bearer"
                    );
                })
                .orElseThrow(() -> new BadRequestException("Refresh token invalide"));
    }
}
