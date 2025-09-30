package com.example.pravna.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.pravna.model.LegalCaseFacts;
import com.example.pravna.service.LegalCaseService;

import jakarta.validation.Valid;

import java.io.IOException;

@RestController
@RequestMapping("/api/legal-cases")
@RequiredArgsConstructor
@Slf4j
public class LegalCaseController {

    private final LegalCaseService legalCaseService;

    @PostMapping("/decide")
    public ResponseEntity<String> makeDecision(@Valid @RequestBody LegalCaseFacts facts) throws IOException, InterruptedException {
        log.info("Received request to process legal case for defendant: {}", facts.getDefendant());
        String decision = legalCaseService.makeDecision(facts);
        return ResponseEntity.ok(decision);
    }
}