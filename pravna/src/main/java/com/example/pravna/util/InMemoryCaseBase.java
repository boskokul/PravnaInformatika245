package com.example.pravna.util;

import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRCase;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRCaseBase;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CaseBaseFilter;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * A simple in-memory case base that does not depend on connectors.
 */
public class InMemoryCaseBase implements CBRCaseBase {
    private final List<CBRCase> cases = new ArrayList<>();

    @Override
    public void init(es.ucm.fdi.gaia.jcolibri.cbrcore.Connector connector) {
        // No-op (we don’t use connectors)
    }

    @Override
    public Collection<CBRCase> getCases() {
        return cases;
    }

    @Override
    public Collection<CBRCase> getCases(CaseBaseFilter caseBaseFilter) {
        return cases;
    }

    @Override
    public void learnCases(Collection<CBRCase> newCases) {
        cases.addAll(newCases);
    }

    @Override
    public void forgetCases(Collection<CBRCase> casesToForget) {
        cases.removeAll(casesToForget);
    }

    @Override
    public void close() {
        // No-op
    }
}
