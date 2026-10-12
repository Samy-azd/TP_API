package com.efrei.tp2.calculator.controller;

import com.efrei.tp2.calculator.dto.CalculationRequest;
import com.efrei.tp2.calculator.model.Operation;
import com.efrei.tp2.calculator.service.CalculatorService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/calculator")
public class CalculatorController {

    private final CalculatorService calculatorService;

    public CalculatorController(CalculatorService calculatorService) {
        this.calculatorService = calculatorService;
    }

    @PostMapping
    public ResponseEntity<Operation> calculate(@Valid @RequestBody CalculationRequest request) {
        Operation saved = calculatorService.calculateAndSave(request);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    @GetMapping("/history")
    public ResponseEntity<Page<Operation>> getHistory(
            @PageableDefault(page = 0, size = 10, sort = "date", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<Operation> history = calculatorService.getHistory(pageable);
        return ResponseEntity.ok(history);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Operation> getById(@PathVariable Long id) {
        return ResponseEntity.ok(calculatorService.getById(id));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Operation> update(
            @PathVariable Long id,
            @Valid @RequestBody CalculationRequest request) {
        Operation updated = calculatorService.update(id, request);
        return ResponseEntity.ok(updated);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        calculatorService.delete(id);
        return ResponseEntity.ok(Map.of("message", "Opération supprimée avec succès"));
    }
}
