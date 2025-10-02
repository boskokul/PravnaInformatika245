package com.example.pravna.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/verdicts")
@RequiredArgsConstructor
@Slf4j
public class VerdictsController {

    @GetMapping("/html/{name}")
    public ResponseEntity<String> getVerdict(@PathVariable String name) throws IOException {
        // build file path relative to resources
        String path = "law_and_verdicts/verdicts/html/" + name + ".html";
        ClassPathResource resource = new ClassPathResource(path);

        if (!resource.exists()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body("<h1>Verdict not found</h1>");
        }

        String html = StreamUtils.copyToString(resource.getInputStream(), StandardCharsets.UTF_8);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.TEXT_HTML);

        return new ResponseEntity<>(html, headers, HttpStatus.OK);
    }
}
