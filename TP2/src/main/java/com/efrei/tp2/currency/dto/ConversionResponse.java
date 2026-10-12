package com.efrei.tp2.currency.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.time.LocalDateTime;

public class ConversionResponse {

    private Long id;
    private String from;
    private String to;
    private Double amount;
    private Double rate;
    private Double convertedAmount;
    private String rateSource;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private LocalDateTime timestamp;

    public ConversionResponse() {
    }

    public ConversionResponse(Long id, String from, String to, Double amount, Double rate, Double convertedAmount, String rateSource, LocalDateTime timestamp) {
        this.id = id;
        this.from = from;
        this.to = to;
        this.amount = amount;
        this.rate = rate;
        this.convertedAmount = convertedAmount;
        this.rateSource = rateSource;
        this.timestamp = timestamp;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public Double getConvertedAmount() {
        return convertedAmount;
    }

    public void setConvertedAmount(Double convertedAmount) {
        this.convertedAmount = convertedAmount;
    }

    public String getRateSource() {
        return rateSource;
    }

    public void setRateSource(String rateSource) {
        this.rateSource = rateSource;
    }

    public LocalDateTime getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(LocalDateTime timestamp) {
        this.timestamp = timestamp;
    }
}
