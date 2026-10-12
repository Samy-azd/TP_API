package com.efrei.tp2.bmi.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;

public class BMIRequest {

    @NotNull(message = "Le poids (en kg) est obligatoire")
    @DecimalMin(value = "10.0", message = "Le poids doit être d'au moins 10 kg")
    @DecimalMax(value = "500.0", message = "Le poids doit être inférieur à 500 kg")
    private Double weight;

    @NotNull(message = "La taille est obligatoire (en mètres, ex: 1.75, ou en cm, ex: 175)")
    @DecimalMin(value = "0.5", message = "La taille doit être d'au moins 0.5 mètre (ou 50 cm)")
    @DecimalMax(value = "300.0", message = "La taille doit être inférieure à 300")
    private Double height;

    public BMIRequest() {
    }

    public BMIRequest(Double weight, Double height) {
        this.weight = weight;
        this.height = height;
    }

    public Double getWeight() {
        return weight;
    }

    public void setWeight(Double weight) {
        this.weight = weight;
    }

    public Double getHeight() {
        return height;
    }

    public void setHeight(Double height) {
        this.height = height;
    }
}
