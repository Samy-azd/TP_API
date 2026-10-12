package com.example.tp.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class RateLimitFilter extends OncePerRequestFilter {

    private static final int MAX_REQUETES = 5;
    private static final long FENETRE_MS = 60_000;

    // Historique des requêtes par adresse IP (et par endpoint, pour tester chaque scénario séparément)
    private final Map<String, Deque<Long>> requests = new ConcurrentHashMap<>();

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String ip = request.getRemoteAddr() + " " + request.getRequestURI();

        Deque<Long> deque = requests.computeIfAbsent(ip, k -> new ArrayDeque<>());
        synchronized (deque) {
            long now = System.currentTimeMillis();
            while (!deque.isEmpty() && deque.peekFirst() < now - FENETRE_MS) {
                deque.pollFirst();
            }
            if (deque.size() >= MAX_REQUETES) {
                response.setHeader("Retry-After", "60");
                ReponseErreur.ecrire(response, 429, "Too Many Requests",
                        "Limite de 5 requêtes par minute dépassée");
                return;
            }
            deque.addLast(now);
        }

        filterChain.doFilter(request, response);
    }
}
