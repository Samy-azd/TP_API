package com.efrei.tp2.currency.service;

import io.github.bucket4j.Bandwidth;
import io.github.bucket4j.Bucket;
import io.github.bucket4j.Refill;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class RateLimitingService {

    private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

    public Bucket resolveBucket(String ipAddress) {
        return buckets.computeIfAbsent(ipAddress, this::newBucket);
    }

    private Bucket newBucket(String ipAddress) {
        // 20 requêtes par minute par adresse IP
        Bandwidth limit = Bandwidth.classic(20, Refill.greedy(20, Duration.ofMinutes(1)));
        return Bucket.builder()
                .addLimit(limit)
                .build();
    }

    public void reset() {
        buckets.clear();
    }
}
