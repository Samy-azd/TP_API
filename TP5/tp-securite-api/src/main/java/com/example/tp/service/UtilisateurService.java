package com.example.tp.service;

import com.example.tp.model.Utilisateur;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class UtilisateurService {

    private final Map<Long, Utilisateur> utilisateurs = new ConcurrentHashMap<>();
    private final AtomicLong sequence = new AtomicLong();

    public Utilisateur sauvegarder(Utilisateur u) {
        u.setId(sequence.incrementAndGet());
        utilisateurs.put(u.getId(), u);
        return u;
    }

    public List<Utilisateur> lister() {
        return new ArrayList<>(utilisateurs.values());
    }
}
