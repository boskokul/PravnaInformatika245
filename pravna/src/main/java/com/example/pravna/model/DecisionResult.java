package com.example.pravna.model;

/**
 * Result class containing parsed decision information
 */
@lombok.Data
public class DecisionResult {
    private java.util.List<ProvenConclusion> provenConclusions = new java.util.ArrayList<>();
    private Integer minSentenceMonths;
    private Integer maxSentenceMonths;

    public void addProvenConclusion(String conclusion, String defendant) {
        provenConclusions.add(new ProvenConclusion(conclusion, defendant));
    }

    public String getSummary() {
        StringBuilder sb = new StringBuilder();
        sb.append("Decision Summary:\n");
        sb.append("================\n\n");

        if (!provenConclusions.isEmpty()) {
            sb.append("Proven Conclusions:\n");
            for (ProvenConclusion pc : provenConclusions) {
                sb.append("  - ").append(pc.getConclusion()).append(" (").append(pc.getDefendant()).append(")\n");
            }
            sb.append("\n");
        }

        if (minSentenceMonths != null || maxSentenceMonths != null) {
            sb.append("Sentence:\n");
            if (minSentenceMonths != null) {
                sb.append("  Minimum: ").append(minSentenceMonths).append(" months\n");
            }
            if (maxSentenceMonths != null) {
                sb.append("  Maximum: ").append(maxSentenceMonths).append(" months\n");
            }
        }

        return sb.toString();
    }

}
