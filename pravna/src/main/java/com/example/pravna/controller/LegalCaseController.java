package com.example.pravna.controller;

import com.example.pravna.model.LegalDecisionResult;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.pravna.model.LegalCaseFacts;
import com.example.pravna.service.LegalCaseService;

import jakarta.validation.Valid;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

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
            LegalCaseService.saveHtmlToFile(result, result.getCaseNumber() + ".html");
            LegalCaseService.saveAkomaNtosoToFile(result, result.getCaseNumber() + ".xml");
            return ResponseEntity.ok("Presuda je uspešno sačuvana.");
        } catch (IOException e) {
            return ResponseEntity.status(500).body("Greška pri čuvanju presude: " + e.getMessage());
        }
    }

    @GetMapping("/html-files")
    public List<String> getHtmlFiles() {

        File folder = new File(Paths.get(System.getProperty("user.dir"), "data", "verdicts", "html").toString());
        File[] files = folder.listFiles((dir, name) -> name.toLowerCase().endsWith(".html"));

        List<String> htmlFileNames = new ArrayList<>();
        if (files != null) {
            for (File file : files) {
                htmlFileNames.add(file.getName());
            }
        }
        return htmlFileNames;
    }
}