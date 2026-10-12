package com.efrei.tp2.bmi.controller;

import com.efrei.tp2.bmi.dto.BMIRequest;
import com.efrei.tp2.bmi.dto.BMIResponse;
import com.efrei.tp2.bmi.dto.BMIStatisticsResponse;
import com.efrei.tp2.bmi.service.BMIService;
import com.efrei.tp2.security.model.User;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/bmi")
public class BMICalculatorController {

    private final BMIService bmiService;

    public BMICalculatorController(BMIService bmiService) {
        this.bmiService = bmiService;
    }

    @PostMapping("/calculate")
    public ResponseEntity<BMIResponse> calculate(
            @Valid @RequestBody BMIRequest request,
            @AuthenticationPrincipal User currentUser) {
        BMIResponse response = bmiService.calculateAndSave(request, currentUser);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/history")
    public ResponseEntity<List<BMIResponse>> getHistory(@AuthenticationPrincipal User currentUser) {
        List<BMIResponse> history = bmiService.getHistory(currentUser);
        return ResponseEntity.ok(history);
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<BMIResponse> update(
            @PathVariable Long id,
            @Valid @RequestBody BMIRequest request,
            @AuthenticationPrincipal User currentUser) {
        BMIResponse response = bmiService.update(id, request, currentUser);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Map<String, String>> delete(
            @PathVariable Long id,
            @AuthenticationPrincipal User currentUser) {
        bmiService.delete(id, currentUser);
        return ResponseEntity.ok(Map.of("message", "Enregistrement BMI " + id + " supprimé avec succès"));
    }

    @GetMapping("/statistics")
    public ResponseEntity<BMIStatisticsResponse> getStatistics() {
        BMIStatisticsResponse statistics = bmiService.getStatistics();
        return ResponseEntity.ok(statistics);
    }
}
