package com.example.pravna.model;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.Map;

public class LegalDecisionResult {

    private String law;
    private String decision;
    private String explanation;
    private int minSentenceMonths;
    private int maxSentenceMonths;
    private String caseNumber;
    private String courtName;
    private String countryCode;
    private String judgeName;
    private String clerkName;
    private String defendantName;
    private int sentence;

    private final Map<String, String> lawArticlesToViolations = new HashMap<>() {{
        put("taken_bribe_lv1", "art_423_para_2");
        put("taken_bribe_lv2", "art_423_para_1");
        put("uzeo_mito_kazneni", "art_423_para_3");
        put("trazio_mito_kasnije", "art_423_para_4");
        put("given_bribe_lv1", "art_424_para_2");
        put("given_bribe_lv2", "art_424_para_1");
        put("oslobodjen_prijavio_mito", "art_424_para_3");
    }};

    public LegalDecisionResult() {
    }

    public LegalDecisionResult(String law, String decision, String explanation, int minSentenceMonths, int maxSentenceMonths,
                               String caseNumber, String courtName, String countryCode, String judgeName,
                               String clerkName, String defendantName, int sentence) {
        this.law = law;
        this.decision = decision;
        this.explanation = explanation;
        this.minSentenceMonths = minSentenceMonths;
        this.maxSentenceMonths = maxSentenceMonths;
        this.caseNumber = caseNumber;
        this.courtName = courtName;
        this.countryCode = countryCode;
        this.judgeName = judgeName;
        this.clerkName = clerkName;
        this.defendantName = defendantName;
        this.sentence = sentence;
    }

    // Getters and setters for all fields...

    public String getLaw() { return law; }

    public void setLaw(String law){ this.law = law; }
    public void setLawFromViolation(String violaion) {
        this.law = this.lawArticlesToViolations.get(violaion);
    }

    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }

    public String getExplanation() { return explanation; }
    public void setExplanation(String explanation) { this.explanation = explanation; }

    public int getMinSentenceMonths() { return minSentenceMonths; }
    public void setMinSentenceMonths(int minSentenceMonths) { this.minSentenceMonths = minSentenceMonths; }

    public int getMaxSentenceMonths() { return maxSentenceMonths; }
    public void setMaxSentenceMonths(int maxSentenceMonths) { this.maxSentenceMonths = maxSentenceMonths; }

    public String getCaseNumber() { return caseNumber; }
    public void setCaseNumber(String caseNumber) { this.caseNumber = caseNumber; }

    public String getCourtName() { return courtName; }
    public void setCourtName(String courtName) { this.courtName = courtName; }

    public String getCountryCode() { return countryCode; }
    public void setCountryCode(String countryCode) { this.countryCode = countryCode; }

    public String getJudgeName() { return judgeName; }
    public void setJudgeName(String judgeName) { this.judgeName = judgeName; }

    public String getClerkName() { return clerkName; }
    public void setClerkName(String clerkName) { this.clerkName = clerkName; }

    public String getDefendantName() { return defendantName; }
    public void setDefendantName(String defendantName) { this.defendantName = defendantName; }

    public int getSentence() { return sentence; }
    public void setSentence(int sentence) { this.sentence = sentence; }

    public String getSentenceString(){
        if(this.sentence > 0){
            return "Na " + String.valueOf(this.sentence) + " meseci zatvorkse kazne.";
        }
        else
            return "";
    }

    public String getDecisionString(){
        if(this.sentence > 0){
            return "Što je: Dana ... učinio delo iz " + this.getLaw() + " te ga sud";
        }
        else
            return "Da je: Dana ... učinio delo iz " + this.getLaw();
    }

    public String getExplanationString(){
        if(this.explanation != null && !this.explanation.isBlank() ){
            return this.explanation;
        }
        else
            return "Tekst obrazloženja";
    }
}
