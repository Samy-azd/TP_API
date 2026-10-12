package com.efrei.tp2.currency.service;

import com.efrei.tp2.exception.BadRequestException;
import com.efrei.tp2.exception.ServiceUnavailableException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;
import reactor.util.retry.Retry;

import java.time.Duration;
import java.util.Map;

@Component
public class ExchangeRateClient {

    private static final Logger log = LoggerFactory.getLogger(ExchangeRateClient.class);
    private final WebClient webClient;

    public ExchangeRateClient(WebClient.Builder webClientBuilder) {
        HttpClient httpClient = HttpClient.create()
                .followRedirect(true)
                .responseTimeout(Duration.ofSeconds(5));

        this.webClient = webClientBuilder
                .clientConnector(new ReactorClientHttpConnector(httpClient))
                .baseUrl("https://api.frankfurter.dev/v1")
                .defaultHeader(HttpHeaders.USER_AGENT, "TP2-SpringBoot-API/1.0")
                .build();
    }

    @Cacheable(value = "exchangeRates", key = "#from.toUpperCase() + '_' + #to.toUpperCase()")
    public Double fetchRate(String from, String to) {
        log.info("Appel à l'API externe frankfurter pour la paire {} -> {}", from, to);

        if (from.equalsIgnoreCase(to)) {
            return 1.0;
        }

        try {
            FrankfurterResponse response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/latest")
                            .queryParam("from", from.toUpperCase())
                            .queryParam("to", to.toUpperCase())
                            .build())
                    .retrieve()
                    .bodyToMono(FrankfurterResponse.class)
                    .timeout(Duration.ofSeconds(5))
                    .retryWhen(Retry.backoff(3, Duration.ofMillis(500))
                            .doBeforeRetry(retrySignal ->
                                    log.warn("Nouvelle tentative ({}/3) vers l'API de taux externe...", retrySignal.totalRetries() + 1)))
                    .block();

            if (response == null || response.getRates() == null) {
                throw new ServiceUnavailableException("Réponse invalide de l'API externe de change");
            }

            Double rate = response.getRates().get(to.toUpperCase());
            if (rate == null) {
                throw new BadRequestException("Taux introuvable pour la devise : " + to);
            }

            return rate;
        } catch (BadRequestException e) {
            throw e;
        } catch (Exception e) {
            log.error("Échec de la récupération du taux externe après tentatives : {}", e.getMessage());
            throw new ServiceUnavailableException("Le service externe de taux de change est temporairement indisponible.");
        }
    }

    public static class FrankfurterResponse {
        private String base;
        private Map<String, Double> rates;

        public String getBase() {
            return base;
        }

        public void setBase(String base) {
            this.base = base;
        }

        public Map<String, Double> getRates() {
            return rates;
        }

        public void setRates(Map<String, Double> rates) {
            this.rates = rates;
        }
    }
}
