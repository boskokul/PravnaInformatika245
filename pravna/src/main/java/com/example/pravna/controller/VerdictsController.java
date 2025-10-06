package com.example.pravna.controller;
import java.nio.file.Paths;
import java.nio.file.Files;
import java.io.IOException;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "http://localhost:5173")
@RestController
@RequestMapping("/verdicts")
public class VerdictsController {

    @GetMapping(value = "/{filename}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> getVerdict(@PathVariable String filename) throws IOException {
        String path = Paths.get(System.getProperty("user.dir"), "data", "verdicts", "html", filename).toString();
        String content = Files.readString(Paths.get(path));
        if (content.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(content);
    }
}

