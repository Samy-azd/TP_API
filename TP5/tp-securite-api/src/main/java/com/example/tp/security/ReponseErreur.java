package com.example.tp.security;

import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

// Écrit une erreur JSON au même format que GlobalExceptionHandler,
// pour les erreurs renvoyées par les filtres (avant d'atteindre les contrôleurs).
public final class ReponseErreur {

    private ReponseErreur() {}

    public static void ecrire(HttpServletResponse response, int status, String error, String message)
            throws IOException {
        response.setStatus(status);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(String.format(
                "{\"timestamp\":\"%s\",\"status\":%d,\"error\":\"%s\",\"message\":\"%s\"}",
                LocalDateTime.now(), status, error, message));
    }
}
