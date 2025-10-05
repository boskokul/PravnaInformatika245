package com.example.pravna.controller;

import com.example.pravna.model.LegalDecisionResult;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.pravna.model.LegalCaseFacts;
import com.example.pravna.service.LegalCaseService;

import jakarta.validation.Valid;

import java.io.IOException;

@CrossOrigin(origins = "http://localhost:5173")
@RestController
@RequestMapping("/api/legal-cases")
@RequiredArgsConstructor
public class LegalCaseController {

    private final LegalCaseService legalCaseService;

    @PostMapping("/decide")
    public ResponseEntity<LegalDecisionResult> makeDecision(@Valid @RequestBody LegalCaseFacts facts) throws IOException, InterruptedException {
        LegalDecisionResult decision = legalCaseService.makeDecision(facts);
        return ResponseEntity.ok(decision);
    }

    @PostMapping("/save-decision")
    public ResponseEntity<String> saveDecision(@Valid @RequestBody LegalDecisionResult result) {
        try {
            LegalCaseService.saveHtmlToResources(result, result.getCaseNumber() + ".html");
            LegalCaseService.saveAkomaNtosoToFile(result, result.getCaseNumber() + ".xml");
            return ResponseEntity.ok("Presuda je uspešno sačuvana.");
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Greška pri čuvanju presude: " + e.getMessage());
        }
    }

}