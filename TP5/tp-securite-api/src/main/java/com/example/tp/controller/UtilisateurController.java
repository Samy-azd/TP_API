package com.example.tp.controller;

import com.example.tp.model.Utilisateur;
import com.example.tp.model.UtilisateurRequest;
import com.example.tp.service.UtilisateurService;
import jakarta.validation.Valid;
import org.apache.commons.text.StringEscapeUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/utilisateurs")
public class UtilisateurController {

    private final UtilisateurService service;

    public UtilisateurController(UtilisateurService service) {
        this.service = service;
    }

    // Accessible à tout utilisateur authentifié (clé API ou JWT)
    @GetMapping("/user")
    public Map<String, Object> espaceUser(Authentication auth) {
        return Map.of(
                "message", "Accès autorisé à l'espace utilisateur",
                "utilisateur", auth.getName(),
                "roles", auth.getAuthorities().toString()
        );
    }

    // Réservé au rôle admin (voir SecurityConfig)
    @GetMapping("/admin")
    public Map<String, Object> espaceAdmin(Authentication auth) {
        return Map.of(
                "message", "Accès autorisé à l'espace administrateur",
                "utilisateur", auth.getName(),
                "roles", auth.getAuthorities().toString()
        );
    }

    @PostMapping
    public ResponseEntity<Utilisateur> creer(@Valid @RequestBody UtilisateurRequest request) {
        Utilisateur u = new Utilisateur();
        u.setNom(StringEscapeUtils.escapeHtml4(request.getNom()));
        u.setEmail(request.getEmail());
        // Neutralisation XSS du texte libre avant stockage
        u.setDescription(StringEscapeUtils.escapeHtml4(request.getDescription()));
        return ResponseEntity.status(HttpStatus.CREATED).body(service.sauvegarder(u));
    }

    @GetMapping
    public List<Utilisateur> lister() {
        return service.lister();
    }
}
