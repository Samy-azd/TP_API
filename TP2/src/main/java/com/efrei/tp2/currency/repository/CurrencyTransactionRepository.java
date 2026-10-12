package com.efrei.tp2.currency.repository;

import com.efrei.tp2.currency.model.CurrencyTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CurrencyTransactionRepository extends JpaRepository<CurrencyTransaction, Long> {
}
