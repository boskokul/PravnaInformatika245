package com.example.pravna.util;

import es.ucm.fdi.gaia.jcolibri.cbrcore.Attribute;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRCase;

import javax.persistence.criteria.CriteriaBuilder;

public class LegalCase extends CBRCase {
    private CaseData description;
    private CaseSolution solution;

    public LegalCase() {
        this.description = new CaseData();
        this.solution = new CaseSolution();
    }

    @Override
    public CaseData getDescription() {
        return description;
    }

    @Override
    public CaseSolution getSolution() {
        return solution;
    }


    public void setDescription(CaseData description) {
        this.description = description;
    }

    public void setSolution(CaseSolution solution) {
        this.solution = solution;
    }



    @Override
    public String toString() {
        return "LegalCase{" +
                "description=" + description.getName() +
                ", solution=" + solution +
                '}';
    }
}
