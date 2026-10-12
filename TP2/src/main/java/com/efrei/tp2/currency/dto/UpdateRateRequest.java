package com.efrei.tp2.currency.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class UpdateRateRequest {

    @NotBlank(message = "La devise d'origine (from) est obligatoire")
    private String from;

    @NotBlank(message = "La devise de destination (to) est obligatoire")
    private String to;

    @NotNull(message = "Le taux de change (rate) est obligatoire")
    @DecimalMin(value = "0.000001", message = "Le taux doit être strictement positif")
    private Double rate;

    public UpdateRateRequest() {
    }

    public UpdateRateRequest(String from, String to, Double rate) {
        this.from = from;
        this.to = to;
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

    public Double getRate() {
        return rate;
    }

    public void setRate(Double rate) {
        this.rate = rate;
    }
}
