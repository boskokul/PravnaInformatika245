package com.example.pravna.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

@CrossOrigin(origins = "http://localhost:5137")
@RestController
@RequestMapping("/law_html")
public class LawController {

    @GetMapping(value = "/{filename}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> getLaw(@PathVariable String filename) throws IOException {
        String path = Paths.get(System.getProperty("user.dir"), "data", "law_html", filename).toString();
        String content = Files.readString(Paths.get(path));
        if (content.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(content);
    }
}

