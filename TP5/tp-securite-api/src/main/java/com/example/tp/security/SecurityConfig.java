package com.example.tp.security;

import jakarta.servlet.http.HttpServletResponse;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http, RateLimitFilter rateLimitFilter,
                                           ApiKeyFilter apiKeyFilter, JwtFilter jwtFilter) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(s -> s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/login", "/error").permitAll()
                .requestMatchers("/utilisateurs/admin").hasRole("ADMIN")
                .anyRequest().authenticated())
            .exceptionHandling(e -> e
                .authenticationEntryPoint((req, res, ex) -> ReponseErreur.ecrire(res,
                        HttpServletResponse.SC_UNAUTHORIZED, "Unauthorized", "Authentification requise"))
                .accessDeniedHandler((req, res, ex) -> ReponseErreur.ecrire(res,
                        HttpServletResponse.SC_FORBIDDEN, "Forbidden", "Accès réservé au rôle admin")))
            // Ordre : rate limiting -> clé API -> JWT
            .addFilterBefore(rateLimitFilter, UsernamePasswordAuthenticationFilter.class)
            .addFilterAfter(apiKeyFilter, RateLimitFilter.class)
            .addFilterAfter(jwtFilter, ApiKeyFilter.class);
        return http.build();
    }

    // Les filtres sont des @Component : on empêche Spring Boot de les enregistrer
    // une seconde fois en dehors de la chaîne Spring Security.
    @Bean
    public FilterRegistrationBean<RateLimitFilter> rateLimitRegistration(RateLimitFilter f) {
        return desactiver(f);
    }

    @Bean
    public FilterRegistrationBean<ApiKeyFilter> apiKeyRegistration(ApiKeyFilter f) {
        return desactiver(f);
    }

    @Bean
    public FilterRegistrationBean<JwtFilter> jwtRegistration(JwtFilter f) {
        return desactiver(f);
    }

    private <T extends jakarta.servlet.Filter> FilterRegistrationBean<T> desactiver(T filtre) {
        FilterRegistrationBean<T> registration = new FilterRegistrationBean<>(filtre);
        registration.setEnabled(false);
        return registration;
    }
}
