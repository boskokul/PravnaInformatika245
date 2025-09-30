package com.example.pravna.model;

/**
 * Represents a proven conclusion with defendant information
 */
@lombok.Data
@lombok.AllArgsConstructor
public class ProvenConclusion {
    private String conclusion;
    private String defendant;
}
