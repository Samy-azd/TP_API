package com.efrei.tp2.bmi.service;

import com.efrei.tp2.bmi.dto.BMIRequest;
import com.efrei.tp2.bmi.dto.BMIResponse;
import com.efrei.tp2.bmi.dto.BMIStatisticsResponse;
import com.efrei.tp2.bmi.model.BMIRecord;
import com.efrei.tp2.bmi.repository.BMIRecordRepository;
import com.efrei.tp2.exception.ResourceNotFoundException;
import com.efrei.tp2.security.model.User;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class BMIService {

    private final BMIRecordRepository bmiRecordRepository;

    public BMIService(BMIRecordRepository bmiRecordRepository) {
        this.bmiRecordRepository = bmiRecordRepository;
    }

    public BMIResponse calculateAndSave(BMIRequest request, User currentUser) {
        Double height = normalizeHeight(request.getHeight());
        Double weight = request.getWeight();

        Double bmi = calculateBmi(weight, height);
        String category = determineCategory(bmi);
        String interpretation = determineInterpretation(category);

        BMIRecord record = new BMIRecord(
                currentUser.getId(),
                weight,
                height,
                bmi,
                category,
                LocalDateTime.now()
        );

        BMIRecord saved = bmiRecordRepository.save(record);

        return toResponse(saved, interpretation);
    }

    public List<BMIResponse> getHistory(User currentUser) {
        List<BMIRecord> records = bmiRecordRepository.findByUserIdOrderByCreatedAtDesc(currentUser.getId());
        return records.stream()
                .map(r -> toResponse(r, determineInterpretation(r.getCategory())))
                .collect(Collectors.toList());
    }

    public BMIResponse update(Long id, BMIRequest request, User currentUser) {
        BMIRecord record = bmiRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Enregistrement BMI introuvable avec l'id : " + id));

        // Vérification de la propriété (Autorisation -> 403 Forbidden si violation)
        if (!record.getUserId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Accès interdit : vous n'êtes pas le propriétaire de cet enregistrement");
        }

        Double height = normalizeHeight(request.getHeight());
        Double weight = request.getWeight();
        Double bmi = calculateBmi(weight, height);
        String category = determineCategory(bmi);

        record.setWeight(weight);
        record.setHeight(height);
        record.setBmi(bmi);
        record.setCategory(category);

        BMIRecord updated = bmiRecordRepository.save(record);
        return toResponse(updated, determineInterpretation(category));
    }

    public void delete(Long id, User currentUser) {
        BMIRecord record = bmiRecordRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Enregistrement BMI introuvable avec l'id : " + id));

        // Vérification de la propriété (Autorisation -> 403 Forbidden si tentative de supprimer le record d'un autre)
        if (!record.getUserId().equals(currentUser.getId())) {
            throw new AccessDeniedException("Accès interdit : vous n'êtes pas le propriétaire de cet enregistrement");
        }

        bmiRecordRepository.delete(record);
    }

    public BMIStatisticsResponse getStatistics() {
        List<BMIRecord> allRecords = bmiRecordRepository.findAll();
        long total = allRecords.size();

        if (total == 0) {
            return new BMIStatisticsResponse(0, 0.0, Map.of(), Map.of());
        }

        double averageBmi = allRecords.stream()
                .mapToDouble(BMIRecord::getBmi)
                .average()
                .orElse(0.0);
        averageBmi = Math.round(averageBmi * 100.0) / 100.0;

        Map<String, Long> countByCategory = allRecords.stream()
                .collect(Collectors.groupingBy(BMIRecord::getCategory, Collectors.counting()));

        Map<String, Double> percentageByCategory = new HashMap<>();
        for (Map.Entry<String, Long> entry : countByCategory.entrySet()) {
            double percentage = Math.round(((double) entry.getValue() / total * 100.0) * 100.0) / 100.0;
            percentageByCategory.put(entry.getKey(), percentage);
        }

        return new BMIStatisticsResponse(total, averageBmi, countByCategory, percentageByCategory);
    }

    private Double normalizeHeight(Double height) {
        // Si l'utilisateur saisit la taille en centimètres (ex: 175), la convertir en mètres (1.75)
        if (height > 3.0) {
            return Math.round((height / 100.0) * 100.0) / 100.0;
        }
        return height;
    }

    private Double calculateBmi(Double weight, Double height) {
        double rawBmi = weight / (height * height);
        return Math.round(rawBmi * 100.0) / 100.0;
    }

    private String determineCategory(Double bmi) {
        if (bmi < 18.5) {
            return "Sous-poids";
        } else if (bmi < 25.0) {
            return "Poids normal";
        } else if (bmi < 30.0) {
            return "Surpoids";
        } else {
            return "Obésité";
        }
    }

    private String determineInterpretation(String category) {
        return switch (category) {
            case "Sous-poids" -> "Insuffisance pondérale";
            case "Poids normal" -> "Corpulence normale";
            case "Surpoids" -> "Surpoids (pré-obésité)";
            case "Obésité" -> "Obésité";
            default -> "Non défini";
        };
    }

    private BMIResponse toResponse(BMIRecord record, String interpretation) {
        return new BMIResponse(
                record.getId(),
                record.getUserId(),
                record.getWeight(),
                record.getHeight(),
                record.getBmi(),
                record.getCategory(),
                interpretation,
                record.getCreatedAt()
        );
    }
}
