package com.example.pravna.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    public ResponseEntity<String> makeDecision(@Valid @RequestBody LegalCaseFacts facts) throws IOException, InterruptedException {
        String decision = legalCaseService.makeDecision(facts);
        return ResponseEntity.ok(decision);
    }
}