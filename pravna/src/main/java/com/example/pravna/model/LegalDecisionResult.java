package com.example.pravna.model;

import java.util.regex.*;
import java.util.HashMap;
import java.util.Map;

public class LegalDecisionResult {
    private int law_article;
    private int law_paragraph;
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

    public LegalDecisionResult(String decision, String explanation, int minSentenceMonths, int maxSentenceMonths,
                               String caseNumber, String courtName, String countryCode, String judgeName,
                               String clerkName, String defendantName, int sentence, int law_article, int law_paragraph) {
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
        this.law_article = law_article;
        this.law_paragraph = law_paragraph;
    }

    // Getters and setters for all fields...
    public void setLawFromViolation(String violaion) {

        var law = this.lawArticlesToViolations.get(violaion);
        Pattern pattern = Pattern.compile("art_(\\d+)_para_(\\d+)");
        Matcher matcher = pattern.matcher(law);

        if (matcher.matches()) {
            int article = Integer.parseInt(matcher.group(1));
            int paragraph = Integer.parseInt(matcher.group(2));
            this.law_article = article;
            this.law_paragraph = paragraph;
        } else {
            System.out.println("Invalid format");
        }
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
            return "Što je: Dana ... učinio delo iz " + this.getLawHTML() + " te ga sud";
        }
        else
            return "Da je: Dana ... učinio delo iz " + this.getLawHTML();
    }

    public String getExplanationString(){
        if(this.explanation != null && !this.explanation.isBlank() ){
            return this.explanation;
        }
        else
            return "Tekst obrazloženja";
    }

    public int getLaw_paragraph() {
        return law_paragraph;
    }

    public void setLaw_paragraph(int law_paragraph) {
        this.law_paragraph = law_paragraph;
    }

    public int getLaw_article() {
        return law_article;
    }

    public void setLaw_article(int law_article) {
        this.law_article = law_article;
    }

    public String getLawHTML(){
        if(this.law_paragraph>0 && this.law_article > 0) {

            return "<a href=\"../../law_html/criminal_law_acoma_ntoso.html#"
                    + "art_" + this.getLaw_article() + "_para_" + this.getLaw_paragraph()
                    + "\">čl." + this.getLaw_article() + "st." + this.getLaw_paragraph() +" Krivičnog zakonika</a> ,";
        }else {
            return "";
        }
    }
}
