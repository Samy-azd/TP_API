package com.efrei.tp2.currency.service;

import com.efrei.tp2.currency.dto.ConversionRequest;
import com.efrei.tp2.currency.dto.ConversionResponse;
import com.efrei.tp2.currency.dto.UpdateRateRequest;
import com.efrei.tp2.currency.model.CurrencyTransaction;
import com.efrei.tp2.currency.model.CustomExchangeRate;
import com.efrei.tp2.currency.repository.CurrencyTransactionRepository;
import com.efrei.tp2.currency.repository.CustomExchangeRateRepository;
import com.efrei.tp2.exception.BadRequestException;
import com.efrei.tp2.exception.ResourceNotFoundException;
import org.springframework.cache.CacheManager;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class CurrencyService {

    private final CurrencyTransactionRepository transactionRepository;
    private final CustomExchangeRateRepository rateRepository;
    private final ExchangeRateClient exchangeRateClient;
    private final CacheManager cacheManager;

    public CurrencyService(CurrencyTransactionRepository transactionRepository,
                           CustomExchangeRateRepository rateRepository,
                           ExchangeRateClient exchangeRateClient,
                           CacheManager cacheManager) {
        this.transactionRepository = transactionRepository;
        this.rateRepository = rateRepository;
        this.exchangeRateClient = exchangeRateClient;
        this.cacheManager = cacheManager;
    }

    @Transactional
    public ConversionResponse convert(Double amount, String from, String to) {
        if (amount == null || amount <= 0) {
            throw new BadRequestException("Le montant à convertir doit être supérieur à 0");
        }
        if (from == null || to == null || from.isBlank() || to.isBlank()) {
            throw new BadRequestException("Les devises 'from' et 'to' sont obligatoires");
        }

        String fromUpper = from.trim().toUpperCase();
        String toUpper = to.trim().toUpperCase();

        Double rate;
        String source;

        // 1. Vérifier si un taux personnalisé local existe
        Optional<CustomExchangeRate> customRate = rateRepository.findByFromCurrencyIgnoreCaseAndToCurrencyIgnoreCase(fromUpper, toUpper);
        if (customRate.isPresent()) {
            rate = customRate.get().getRate();
            source = "LOCAL_CUSTOM";
        } else {
            // 2. Sinon appeler le client externe (avec @Cacheable)
            rate = exchangeRateClient.fetchRate(fromUpper, toUpper);
            source = "EXTERNAL_API";
        }

        Double convertedAmount = Math.round((amount * rate) * 10000.0) / 10000.0;

        CurrencyTransaction transaction = new CurrencyTransaction(
                fromUpper,
                toUpper,
                amount,
                rate,
                convertedAmount,
                source,
                LocalDateTime.now()
        );

        CurrencyTransaction saved = transactionRepository.save(transaction);

        return new ConversionResponse(
                saved.getId(),
                saved.getFromCurrency(),
                saved.getToCurrency(),
                saved.getAmount(),
                saved.getRate(),
                saved.getConvertedAmount(),
                saved.getRateSource(),
                saved.getTimestamp()
        );
    }

    @Transactional
    public ConversionResponse convertManual(ConversionRequest request) {
        String fromUpper = request.getFrom().trim().toUpperCase();
        String toUpper = request.getTo().trim().toUpperCase();
        Double rate = request.getRate();
        Double amount = request.getAmount();

        Double convertedAmount = Math.round((amount * rate) * 10000.0) / 10000.0;

        CurrencyTransaction transaction = new CurrencyTransaction(
                fromUpper,
                toUpper,
                amount,
                rate,
                convertedAmount,
                "MANUAL",
                LocalDateTime.now()
        );

        CurrencyTransaction saved = transactionRepository.save(transaction);

        return new ConversionResponse(
                saved.getId(),
                saved.getFromCurrency(),
                saved.getToCurrency(),
                saved.getAmount(),
                saved.getRate(),
                saved.getConvertedAmount(),
                saved.getRateSource(),
                saved.getTimestamp()
        );
    }

    @Transactional
    public CustomExchangeRate updateLocalRate(UpdateRateRequest request) {
        String fromUpper = request.getFrom().trim().toUpperCase();
        String toUpper = request.getTo().trim().toUpperCase();

        CustomExchangeRate rateEntity = rateRepository.findByFromCurrencyIgnoreCaseAndToCurrencyIgnoreCase(fromUpper, toUpper)
                .orElse(new CustomExchangeRate(fromUpper, toUpper, request.getRate(), LocalDateTime.now()));

        rateEntity.setRate(request.getRate());
        rateEntity.setUpdatedAt(LocalDateTime.now());

        // Éviction du cache pour garder la cohérence
        if (cacheManager.getCache("exchangeRates") != null) {
            cacheManager.getCache("exchangeRates").evict(fromUpper + "_" + toUpper);
        }

        return rateRepository.save(rateEntity);
    }

    @Transactional
    public void deleteTransaction(Long id) {
        CurrencyTransaction transaction = transactionRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Transaction introuvable avec l'id : " + id));
        transactionRepository.delete(transaction);
    }
}
