package com.efrei.tp2.security.service;

import com.efrei.tp2.exception.BadRequestException;
import com.efrei.tp2.exception.ResourceNotFoundException;
import com.efrei.tp2.security.model.RefreshToken;
import com.efrei.tp2.security.model.User;
import com.efrei.tp2.security.repository.RefreshTokenRepository;
import com.efrei.tp2.security.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;
import java.util.UUID;

@Service
public class RefreshTokenService {

    private final RefreshTokenRepository refreshTokenRepository;
    private final UserRepository userRepository;

    public RefreshTokenService(RefreshTokenRepository refreshTokenRepository, UserRepository userRepository) {
        this.refreshTokenRepository = refreshTokenRepository;
        this.userRepository = userRepository;
    }

    public Optional<RefreshToken> findByToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }

    @Transactional
    public RefreshToken createRefreshToken(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("Utilisateur non trouvé : " + username));

        // Si un refresh token existe déjà pour cet utilisateur, le mettre à jour
        Optional<RefreshToken> existing = refreshTokenRepository.findByUser(user);
        RefreshToken refreshToken;
        if (existing.isPresent()) {
            refreshToken = existing.get();
            refreshToken.setToken(UUID.randomUUID().toString());
            refreshToken.setExpiryDate(Instant.now().plus(7, ChronoUnit.DAYS));
        } else {
            refreshToken = new RefreshToken(
                    user,
                    UUID.randomUUID().toString(),
                    Instant.now().plus(7, ChronoUnit.DAYS) // Valide 7 jours
            );
        }

        return refreshTokenRepository.save(refreshToken);
    }

    public RefreshToken verifyExpiration(RefreshToken token) {
        if (token.getExpiryDate().isBefore(Instant.now())) {
            refreshTokenRepository.delete(token);
            throw new BadRequestException("Le refresh token a expiré. Veuillez vous reconnecter.");
        }
        return token;
    }
}
