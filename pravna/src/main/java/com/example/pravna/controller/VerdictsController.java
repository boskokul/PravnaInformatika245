package com.example.pravna.controller;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.IOException;

import com.example.pravna.model.LegalDecisionResult;
import com.example.pravna.model.Verdict;
import com.example.pravna.service.LegalCaseService;
import com.example.pravna.service.VerdictsService;
import com.example.pravna.util.VerdictSimilarity;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.AutoConfigurationPackage;
import org.springframework.boot.autoconfigure.AutoConfigureOrder;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "http://localhost:5173")
@RestController
@RequestMapping("/verdicts")
public class VerdictsController {

    @Autowired
    private VerdictsService _verdictsService;
    @GetMapping(value = "/{filename}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> getVerdict(@PathVariable String filename) throws IOException {
        String path = Paths.get(System.getProperty("user.dir"), "data", "verdicts", "html", filename).toString();
        String content = Files.readString(Paths.get(path));
        if (content.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(content);
    }
    @PostMapping("/save")
    public ResponseEntity<Verdict> saveDecision(@Valid @RequestBody VerdictSimilarity result) {
        Verdict newverdict = _verdictsService.Save(result);
        System.out.println("Presuda sacuvana. ---- metapodaci");
        return ResponseEntity.ok(newverdict);
    }
}

