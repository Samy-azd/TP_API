package com.efrei.tp2.currency.repository;

import com.efrei.tp2.currency.model.CustomExchangeRate;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface CustomExchangeRateRepository extends JpaRepository<CustomExchangeRate, Long> {
    Optional<CustomExchangeRate> findByFromCurrencyIgnoreCaseAndToCurrencyIgnoreCase(String fromCurrency, String toCurrency);
}
