package com.example.pravna.controller;

import com.example.pravna.model.LegalCaseFacts;
import com.example.pravna.model.LegalDecisionResult;
import com.example.pravna.service.CBRService;
import com.example.pravna.util.CaseData;
import com.example.pravna.util.VerdictSimilarity;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.List;

@CrossOrigin(origins = "http://localhost:5173")
@RestController
@RequestMapping("/api/case-based-reasoning")
@RequiredArgsConstructor
public class CBRConstoller {
    @Autowired
    private CBRService _cbrService;
    @PostMapping("/decide")
    public ResponseEntity<List<VerdictSimilarity>> makeDecision(@Valid @RequestBody LegalCaseFacts facts) throws IOException, InterruptedException {
        CaseData newCase = new CaseData(facts);
        List<VerdictSimilarity> decision = _cbrService.findTop5Similar(newCase);
        return ResponseEntity.ok(decision);
    }
}
