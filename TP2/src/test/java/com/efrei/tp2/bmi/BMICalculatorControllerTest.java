package com.efrei.tp2.bmi;

import com.efrei.tp2.bmi.dto.BMIRequest;
import com.efrei.tp2.security.dto.LoginRequest;
import com.efrei.tp2.security.dto.RefreshTokenRequest;
import com.efrei.tp2.security.dto.RegisterRequest;
import com.fasterxml.jackson.databind.JsonNode;
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
public class BMICalculatorControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    private String userAToken;
    private String userARefreshToken;
    private String userBToken;

    @BeforeEach
    void setupUsers() throws Exception {
        // Enregistrer User A s'il n'existe pas encore
        RegisterRequest userAReq = new RegisterRequest("alice", "password123", "alice@example.com");
        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userAReq)));

        // Login User A
        LoginRequest loginA = new LoginRequest("alice", "password123");
        String resA = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginA)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode nodeA = objectMapper.readTree(resA);
        userAToken = nodeA.get("accessToken").asText();
        userARefreshToken = nodeA.get("refreshToken").asText();

        // Enregistrer User B s'il n'existe pas encore
        RegisterRequest userBReq = new RegisterRequest("bob", "password456", "bob@example.com");
        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(userBReq)));

        // Login User B
        LoginRequest loginB = new LoginRequest("bob", "password456");
        String resB = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginB)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        userBToken = objectMapper.readTree(resB).get("accessToken").asText();
    }

    @Test
    @DisplayName("GET /api/bmi/history - Sans jeton JWT renvoie 401 Unauthorized")
    void testUnauthorizedWithoutToken() throws Exception {
        mockMvc.perform(get("/api/bmi/history"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401))
                .andExpect(jsonPath("$.error").value("Unauthorized"))
                .andExpect(jsonPath("$.message", containsString("jeton JWT manquant ou invalide")));
    }

    @Test
    @DisplayName("POST /api/bmi/calculate - Succès avec JWT valide (201 Created)")
    void testCalculateBMISuccess() throws Exception {
        BMIRequest request = new BMIRequest(70.0, 1.75);

        mockMvc.perform(post("/api/bmi/calculate")
                        .header("Authorization", "Bearer " + userAToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").exists())
                .andExpect(jsonPath("$.weight").value(70.0))
                .andExpect(jsonPath("$.height").value(1.75))
                .andExpect(jsonPath("$.bmi").value(22.86))
                .andExpect(jsonPath("$.category").value("Poids normal"))
                .andExpect(jsonPath("$.interpretation").value("Corpulence normale"));
    }

    @Test
    @DisplayName("POST /api/auth/refresh - Renouvellement de jeton JWT (200 OK)")
    void testRefreshTokenSuccess() throws Exception {
        RefreshTokenRequest refreshReq = new RefreshTokenRequest(userARefreshToken);

        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(refreshReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").exists())
                .andExpect(jsonPath("$.tokenType").value("Bearer"));
    }

    @Test
    @DisplayName("DELETE /api/bmi/delete/{id} - Tentative suppression par un autre utilisateur renvoie 403 Forbidden")
    void testForbiddenDeleteByOtherUser() throws Exception {
        // User A crée un enregistrement BMI
        BMIRequest request = new BMIRequest(85.0, 1.80);
        String createRes = mockMvc.perform(post("/api/bmi/calculate")
                        .header("Authorization", "Bearer " + userAToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();

        Long recordId = objectMapper.readTree(createRes).get("id").asLong();

        // User B tente de supprimer l'enregistrement de User A -> doit renvoyer 403 Forbidden
        mockMvc.perform(delete("/api/bmi/delete/" + recordId)
                        .header("Authorization", "Bearer " + userBToken))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.status").value(403))
                .andExpect(jsonPath("$.error").value("Forbidden"))
                .andExpect(jsonPath("$.message", containsString("pas le propriétaire")));
    }

    @Test
    @DisplayName("GET /api/bmi/statistics - Statistiques globales (200 OK)")
    void testGetStatistics() throws Exception {
        mockMvc.perform(get("/api/bmi/statistics")
                        .header("Authorization", "Bearer " + userAToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalRecords").exists())
                .andExpect(jsonPath("$.averageBmi").exists());
    }
}
