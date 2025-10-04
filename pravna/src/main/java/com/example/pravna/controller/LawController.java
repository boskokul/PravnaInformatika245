package com.example.pravna.controller;

import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "http://localhost:5137")
@RestController
@RequestMapping("/law_html")
public class LawController {

    @GetMapping(value = "/{filename}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<Resource> getLaw(@PathVariable String filename) {
        Resource resource = new ClassPathResource("law_and_verdicts/law_html/" + filename);
        if (!resource.exists()) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(resource);
    }
}

