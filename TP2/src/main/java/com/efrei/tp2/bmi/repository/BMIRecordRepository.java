package com.efrei.tp2.bmi.repository;

import com.efrei.tp2.bmi.model.BMIRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface BMIRecordRepository extends JpaRepository<BMIRecord, Long> {
    List<BMIRecord> findByUserIdOrderByCreatedAtDesc(Long userId);
}
