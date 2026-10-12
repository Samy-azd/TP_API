package com.example.tp.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
public class ApiKeyFilter extends OncePerRequestFilter {

    private static final String CLE_VALIDE = "ApiKey 123456abcdef";

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws IOException, jakarta.servlet.ServletException {
        String key = request.getHeader("Authorization");

        // Le login et les requêtes portant un JWT sont traités par AuthController / JwtFilter
        if (request.getRequestURI().startsWith("/auth/") || (key != null && key.startsWith("Bearer "))) {
            filterChain.doFilter(request, response);
            return;
        }

        if (key == null || !key.equals(CLE_VALIDE)) {
            ReponseErreur.ecrire(response, HttpServletResponse.SC_UNAUTHORIZED,
                    "Unauthorized", "Clé API absente ou invalide");
            return;
        }

        // Clé valide : le client est authentifié avec le rôle USER
        SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(
                "client-api", null, List.of(new SimpleGrantedAuthority("ROLE_USER"))));
        filterChain.doFilter(request, response);
    }
}
