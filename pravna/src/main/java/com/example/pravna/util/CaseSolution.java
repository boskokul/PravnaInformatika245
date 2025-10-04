package com.example.pravna.util;

import es.ucm.fdi.gaia.jcolibri.cbrcore.Attribute;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CaseComponent;

public class CaseSolution  implements CaseComponent {
    private int id;
    private String verdict;
    private Integer sentenceMonths;
    private String additionalConditions;

    public String getVerdict() { return verdict; }
    public void setVerdict(String verdict) { this.verdict = verdict; }

    public Integer getSentenceMonths() { return sentenceMonths; }
    public void setSentenceMonths(Integer sentenceMonths) {
        this.sentenceMonths = sentenceMonths;
    }

    public String getAdditionalConditions() { return additionalConditions; }
    public void setAdditionalConditions(String conditions) {
        this.additionalConditions = conditions;
    }

    @Override
    public String toString() {
        return "Verdict: " + verdict +
                ", Sentence: " + sentenceMonths + " months" +
                (additionalConditions != null ? ", Conditions: " + additionalConditions : "");
    }

    @Override
    public Attribute getIdAttribute() {
        return new Attribute("id", this.getClass());
    }
}
