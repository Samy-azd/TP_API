package com.efrei.tp2.currency.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class ConversionRequest {

    @NotBlank(message = "La devise d'origine (from) est obligatoire")
    private String from;

    @NotBlank(message = "La devise de destination (to) est obligatoire")
    private String to;

    @NotNull(message = "Le montant (amount) est obligatoire")
    @DecimalMin(value = "0.0001", message = "Le montant doit être supérieur à 0")
    private Double amount;

    @NotNull(message = "Le taux de conversion manuel (rate) est obligatoire pour cet endpoint")
    @DecimalMin(value = "0.000001", message = "Le taux de conversion doit être strictement positif")
    private Double rate;

    public ConversionRequest() {
    }

    public ConversionRequest(String from, String to, Double amount, Double rate) {
        this.from = from;
        this.to = to;
        this.amount = amount;
        this.rate = rate;
    }

    public String getFrom() {
        return from;
    }

    public void setFrom(String from) {
        this.from = from;
    }

    public String getTo() {
        return to;
    }

    public void setTo(String to) {
        this.to = to;
    }

    public Double getAmount() {
        return amount;
    }

    public void setAmount(Double amount) {
        this.amount = amount;
    }

    public Double getRate() {
        return rate;
    }

    public void setRate(Double rate) {
        this.rate = rate;
    }
}
