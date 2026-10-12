package com.efrei.tp2.calculator.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.LocalDateTime;

@Entity
@Table(name = "operations")
public class Operation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String operateur;

    private Double a;

    private Double b;

    private Double resultat;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime date;

    public Operation() {
    }

    public Operation(String operateur, Double a, Double b, Double resultat, LocalDateTime date) {
        this.operateur = operateur;
        this.a = a;
        this.b = b;
        this.resultat = resultat;
        this.date = date;
    }

    public Operation(Long id, String operateur, Double a, Double b, Double resultat, LocalDateTime date) {
        this.id = id;
        this.operateur = operateur;
        this.a = a;
        this.b = b;
        this.resultat = resultat;
        this.date = date;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getOperateur() {
        return operateur;
    }

    public void setOperateur(String operateur) {
        this.operateur = operateur;
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

    public Double getResultat() {
        return resultat;
    }

    public void setResultat(Double resultat) {
        this.resultat = resultat;
    }

    public LocalDateTime getDate() {
        return date;
    }

    public void setDate(LocalDateTime date) {
        this.date = date;
    }
}
