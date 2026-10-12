package com.example.tp.controller;

import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;
import java.time.LocalTime;
import java.util.concurrent.Executors;

@RestController
public class HorlogeController {

    @GetMapping("/horloge")
    public SseEmitter streamHorloge() {
        SseEmitter emitter = new SseEmitter(0L); // pas de timeout
        Executors.newSingleThreadExecutor().execute(() -> {
            try {
                for (int i = 0; i < 20; i++) {
                    emitter.send("Heure actuelle : " + LocalTime.now());
                    Thread.sleep(1000);
                }
                emitter.complete();
            } catch (Exception e) {
                emitter.completeWithError(e);
            }
        });
        return emitter;
    }
}
