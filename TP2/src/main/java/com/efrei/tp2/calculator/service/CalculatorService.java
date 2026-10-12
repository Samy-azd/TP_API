package com.efrei.tp2.calculator.service;

import com.efrei.tp2.calculator.dto.CalculationRequest;
import com.efrei.tp2.calculator.model.Operation;
import com.efrei.tp2.calculator.repository.OperationRepository;
import com.efrei.tp2.exception.BadRequestException;
import com.efrei.tp2.exception.ResourceNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CalculatorService {

    private final OperationRepository operationRepository;

    public CalculatorService(OperationRepository operationRepository) {
        this.operationRepository = operationRepository;
    }

    public Operation calculateAndSave(CalculationRequest request) {
        String normalizedOp = normalizeOperation(request.getOperation());
        Double a = request.getA();
        Double b = request.getB();

        if ("division".equalsIgnoreCase(normalizedOp) && b == 0) {
            throw new BadRequestException("La division par zéro n'est pas autorisée");
        }

        Double result = performCalculation(normalizedOp, a, b);

        Operation operation = new Operation(normalizedOp, a, b, result, LocalDateTime.now());
        return operationRepository.save(operation);
    }

    public Page<Operation> getHistory(Pageable pageable) {
        return operationRepository.findAll(pageable);
    }

    public List<Operation> getAllHistory() {
        return operationRepository.findAll();
    }

    public Operation getById(Long id) {
        return operationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Opération introuvable avec l'id : " + id));
    }

    public Operation update(Long id, CalculationRequest request) {
        Operation existing = getById(id);

        String normalizedOp = normalizeOperation(request.getOperation());
        Double a = request.getA();
        Double b = request.getB();

        if ("division".equalsIgnoreCase(normalizedOp) && b == 0) {
            throw new BadRequestException("La division par zéro n'est pas autorisée");
        }

        Double result = performCalculation(normalizedOp, a, b);

        existing.setOperateur(normalizedOp);
        existing.setA(a);
        existing.setB(b);
        existing.setResultat(result);
        existing.setDate(LocalDateTime.now());

        return operationRepository.save(existing);
    }

    public void delete(Long id) {
        Operation existing = getById(id);
        operationRepository.delete(existing);
    }

    private String normalizeOperation(String operation) {
        if (operation == null) {
            throw new BadRequestException("L'opération ne peut pas être nulle");
        }
        String op = operation.trim().toLowerCase();
        return switch (op) {
            case "addition", "+", "add" -> "addition";
            case "soustraction", "-", "sub" -> "soustraction";
            case "multiplication", "*", "mul" -> "multiplication";
            case "division", "/", "div" -> "division";
            default -> throw new BadRequestException("Opération non supportée : '" + operation 
                    + "'. Opérations acceptées : addition, soustraction, multiplication, division");
        };
    }

    private Double performCalculation(String operation, Double a, Double b) {
        return switch (operation) {
            case "addition" -> a + b;
            case "soustraction" -> a - b;
            case "multiplication" -> a * b;
            case "division" -> a / b;
            default -> throw new BadRequestException("Opération inconnue : " + operation);
        };
    }
}
