package com.efrei.tp2.calculator;

import com.efrei.tp2.calculator.dto.CalculationRequest;
import com.fasterxml.jackson.databind.ObjectMapper;
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
public class CalculatorControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    @DisplayName("POST /api/calculator - Succès Addition")
    void testCalculateSuccess() throws Exception {
        CalculationRequest request = new CalculationRequest(10.0, 5.0, "addition");

        mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.operateur").value("addition"))
                .andExpect(jsonPath("$.a").value(10.0))
                .andExpect(jsonPath("$.b").value(5.0))
                .andExpect(jsonPath("$.resultat").value(15.0))
                .andExpect(jsonPath("$.date").exists());
    }

    @Test
    @DisplayName("POST /api/calculator - Erreur Division par Zéro (400 Bad Request)")
    void testDivisionByZero() throws Exception {
        CalculationRequest request = new CalculationRequest(10.0, 0.0, "division");

        mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.error").value("Bad Request"))
                .andExpect(jsonPath("$.message").value("La division par zéro n'est pas autorisée"))
                .andExpect(jsonPath("$.path").value("/api/calculator"))
                .andExpect(jsonPath("$.timestamp").exists());
    }

    @Test
    @DisplayName("POST /api/calculator - Erreur Validation Données Manquantes (400 Bad Request)")
    void testValidationMissingFields() throws Exception {
        // 'b' is missing
        String invalidJson = "{\"a\": 10.0, \"operation\": \"addition\"}";

        mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400))
                .andExpect(jsonPath("$.error").value("Bad Request"))
                .andExpect(jsonPath("$.message", containsString("Le champ 'b' est obligatoire")));
    }

    @Test
    @DisplayName("GET /api/calculator/history - Pagination et Métadonnées")
    void testGetHistoryWithPagination() throws Exception {
        // First create an operation
        CalculationRequest request = new CalculationRequest(20.0, 4.0, "multiplication");
        mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated());

        mockMvc.perform(get("/api/calculator/history?page=0&size=10&sort=date,desc"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.page.totalElements").exists())
                .andExpect(jsonPath("$.page.totalPages").exists())
                .andExpect(jsonPath("$.page.size").value(10))
                .andExpect(jsonPath("$.page.number").value(0));
    }

    @Test
    @DisplayName("PUT /api/calculator/{id} - Mise à jour d'une opération")
    void testUpdateOperation() throws Exception {
        CalculationRequest createReq = new CalculationRequest(5.0, 5.0, "addition");
        String responseStr = mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createReq)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long id = objectMapper.readTree(responseStr).get("id").asLong();

        CalculationRequest updateReq = new CalculationRequest(5.0, 3.0, "soustraction");
        mockMvc.perform(put("/api/calculator/" + id)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(id))
                .andExpect(jsonPath("$.operateur").value("soustraction"))
                .andExpect(jsonPath("$.resultat").value(2.0));
    }

    @Test
    @DisplayName("DELETE /api/calculator/{id} - Suppression d'une opération")
    void testDeleteOperation() throws Exception {
        CalculationRequest createReq = new CalculationRequest(8.0, 2.0, "division");
        String responseStr = mockMvc.perform(post("/api/calculator")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(createReq)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long id = objectMapper.readTree(responseStr).get("id").asLong();

        mockMvc.perform(delete("/api/calculator/" + id))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Opération supprimée avec succès"));

        // Deleting again should return 404
        mockMvc.perform(delete("/api/calculator/" + id))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }
}
