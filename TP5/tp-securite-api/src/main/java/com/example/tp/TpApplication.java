package com.example.tp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.security.servlet.UserDetailsServiceAutoConfiguration;

// L'authentification est gérée par nos propres filtres (clé API / JWT) :
// on désactive l'utilisateur par défaut généré par Spring Security.
@SpringBootApplication(exclude = UserDetailsServiceAutoConfiguration.class)
public class TpApplication {
    public static void main(String[] args) {
        SpringApplication.run(TpApplication.class, args);
    }
}
