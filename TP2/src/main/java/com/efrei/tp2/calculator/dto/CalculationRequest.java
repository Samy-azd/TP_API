package com.efrei.tp2.calculator.dto;

import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class CalculationRequest {

    @NotNull(message = "Le champ 'a' est obligatoire")
    @DecimalMin(value = "-1000000000", message = "La valeur de 'a' doit être supérieure ou égale à -1 000 000 000")
    @DecimalMax(value = "1000000000", message = "La valeur de 'a' doit être inférieure ou égale à 1 000 000 000")
    private Double a;

    @NotNull(message = "Le champ 'b' est obligatoire")
    @DecimalMin(value = "-1000000000", message = "La valeur de 'b' doit être supérieure ou égale à -1 000 000 000")
    @DecimalMax(value = "1000000000", message = "La valeur de 'b' doit être inférieure ou égale à 1 000 000 000")
    private Double b;

    @NotBlank(message = "Le champ 'operation' est obligatoire (addition, soustraction, multiplication, division)")
    private String operation;

    public CalculationRequest() {
    }

    public CalculationRequest(Double a, Double b, String operation) {
        this.a = a;
        this.b = b;
        this.operation = operation;
    }

    public Double getA() {
        return a;
    }

    public void setA(Double a) {
        this.a = a;
    }

    public Double getB() {
        return b;
    }

    public void setB(Double b) {
        this.b = b;
    }

    public String getOperation() {
        return operation;
    }

    public void setOperation(String operation) {
        this.operation = operation;
    }
}
