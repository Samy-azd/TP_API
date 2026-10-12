package com.efrei.tp2.currency.controller;

import com.efrei.tp2.currency.dto.ConversionRequest;
import com.efrei.tp2.currency.dto.ConversionResponse;
import com.efrei.tp2.currency.dto.UpdateRateRequest;
import com.efrei.tp2.currency.model.CustomExchangeRate;
import com.efrei.tp2.currency.service.CurrencyService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/currency")
public class CurrencyConverterController {

    private final CurrencyService currencyService;

    public CurrencyConverterController(CurrencyService currencyService) {
        this.currencyService = currencyService;
    }

    @GetMapping("/convert")
    public ResponseEntity<ConversionResponse> convert(
            @RequestParam Double amount,
            @RequestParam String from,
            @RequestParam String to) {
        ConversionResponse response = currencyService.convert(amount, from, to);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/convert")
    public ResponseEntity<ConversionResponse> convertManual(@Valid @RequestBody ConversionRequest request) {
        ConversionResponse response = currencyService.convertManual(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @PutMapping("/update-rate")
    public ResponseEntity<CustomExchangeRate> updateRate(@Valid @RequestBody UpdateRateRequest request) {
        CustomExchangeRate updated = currencyService.updateLocalRate(request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/delete-transaction/{id}")
    public ResponseEntity<Map<String, String>> deleteTransaction(@PathVariable Long id) {
        currencyService.deleteTransaction(id);
        return ResponseEntity.ok(Map.of("message", "Transaction " + id + " supprimée avec succès"));
    }
}
