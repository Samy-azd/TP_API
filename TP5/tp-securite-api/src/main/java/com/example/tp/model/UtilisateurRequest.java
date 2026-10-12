package com.example.tp.model;

import jakarta.validation.constraints.*;

public class UtilisateurRequest {
    @NotBlank(message = "Le nom est obligatoire")
    private String nom;

    @Email(message = "Email invalide")
    private String email;

    private String description;

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
