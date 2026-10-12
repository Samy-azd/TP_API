package com.efrei.tp2.currency;

import com.efrei.tp2.currency.dto.ConversionRequest;
import com.efrei.tp2.currency.dto.UpdateRateRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class CurrencyConverterControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private com.efrei.tp2.currency.service.RateLimitingService rateLimitingService;

    @BeforeEach
    void setUp() {
        rateLimitingService.reset();
    }

    @Test
    @DisplayName("POST /api/currency/convert - Taux manuel (Succès 201)")
    void testManualConversionSuccess() throws Exception {
        ConversionRequest request = new ConversionRequest("USD", "XYZ", 100.0, 1.25);

        mockMvc.perform(post("/api/currency/convert")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.from").value("USD"))
                .andExpect(jsonPath("$.to").value("XYZ"))
                .andExpect(jsonPath("$.amount").value(100.0))
                .andExpect(jsonPath("$.rate").value(1.25))
                .andExpect(jsonPath("$.convertedAmount").value(125.0))
                .andExpect(jsonPath("$.rateSource").value("MANUAL"));
    }

    @Test
    @DisplayName("PUT /api/currency/update-rate - Mise à jour taux local (200)")
    void testUpdateRateSuccess() throws Exception {
        UpdateRateRequest request = new UpdateRateRequest("EUR", "GBP", 0.85);

        mockMvc.perform(put("/api/currency/update-rate")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.fromCurrency").value("EUR"))
                .andExpect(jsonPath("$.toCurrency").value("GBP"))
                .andExpect(jsonPath("$.rate").value(0.85));

        // Vérifier que la conversion utilise ensuite ce taux local
        mockMvc.perform(get("/api/currency/convert?amount=100&from=EUR&to=GBP"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.convertedAmount").value(85.0))
                .andExpect(jsonPath("$.rateSource").value("LOCAL_CUSTOM"));
    }

    @Test
    @DisplayName("DELETE /api/currency/delete-transaction/{id} - Suppression transaction")
    void testDeleteTransaction() throws Exception {
        ConversionRequest createReq = new ConversionRequest("USD", "CAD", 50.0, 1.35);
        String responseStr = mockMvc.perform(post("/api/currency/convert")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createReq)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long id = objectMapper.readTree(responseStr).get("id").asLong();

        mockMvc.perform(delete("/api/currency/delete-transaction/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message", containsString("supprimée avec succès")));

        mockMvc.perform(delete("/api/currency/delete-transaction/" + id))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    @DisplayName("GET /api/currency/convert - Rate Limiting 20 req/min (Code 429)")
    void testRateLimitingExceeded() throws Exception {
        // Enregistrer un taux local pour tester sans dépendre d'Internet
        UpdateRateRequest rateReq = new UpdateRateRequest("TEST1", "TEST2", 2.0);
        mockMvc.perform(put("/api/currency/update-rate")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(rateReq)));

        // Effectuer 20 requêtes avec la même IP de test
        String testIp = "192.168.1.99";
        for (int i = 0; i < 20; i++) {
            mockMvc.perform(get("/api/currency/convert?amount=10&from=TEST1&to=TEST2")
                            .header("X-Forwarded-For", testIp))
                    .andExpect(status().isOk());
        }

        // La 21ème requête doit retourner 429 Too Many Requests
        mockMvc.perform(get("/api/currency/convert?amount=10&from=TEST1&to=TEST2")
                        .header("X-Forwarded-For", testIp))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.status").value(429))
                .andExpect(jsonPath("$.error").value("Too Many Requests"))
                .andExpect(jsonPath("$.message", containsString("Limite de débit dépassée")));
    }
}
