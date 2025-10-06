package com.example.pravna.util;

import com.example.pravna.model.Verdict;
import es.ucm.fdi.gaia.jcolibri.cbrcore.Attribute;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CaseComponent;

import java.util.List;

public class VerdictSimilarity {
    private Long caseId;
    private String name;
    private Boolean optuzenoDavalacMita;
    private Boolean optuzenoPrimalacMita;
    private Boolean optuzeniSluzbenoLice;
    private Boolean radnjaNezakonitaIliNeizvrsena;
    private Boolean mitoVezanZaKazneniPostupak;
    private Boolean trazioMitoNakon;
    private Boolean prijavioMito;
    private Integer oslobadjajuceOkolnosti;
    private List<String> primjenjeniPropisi;
    private Boolean utvrdjenaKrivicaUPresudi;

    private double similarity;

    public double getSimilarity() {
        return similarity;
    }

    public void setSimilarity(double similarity) {
        this.similarity = similarity;
    }

    public Long getCaseId() {
        return caseId;
    }

    public void setCaseId(Long caseId) {
        this.caseId = caseId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Boolean getOptuzenoDavalacMita() {
        return optuzenoDavalacMita;
    }

    public void setOptuzenoDavalacMita(Boolean optuzenoDavalacMita) {
        this.optuzenoDavalacMita = optuzenoDavalacMita;
    }

    public Boolean getOptuzenoPrimalacMita() {
        return optuzenoPrimalacMita;
    }

    public void setOptuzenoPrimalacMita(Boolean optuzenoPrimalacMita) {
        this.optuzenoPrimalacMita = optuzenoPrimalacMita;
    }

    public Boolean getOptuzeniSluzbenoLice() {
        return optuzeniSluzbenoLice;
    }

    public void setOptuzeniSluzbenoLice(Boolean optuzeniSluzbenoLice) {
        this.optuzeniSluzbenoLice = optuzeniSluzbenoLice;
    }

    public Boolean getRadnjaNezakonitaIliNeizvrsena() {
        return radnjaNezakonitaIliNeizvrsena;
    }

    public void setRadnjaNezakonitaIliNeizvrsena(Boolean radnjaNezakonitaIliNeizvrsena) {
        this.radnjaNezakonitaIliNeizvrsena = radnjaNezakonitaIliNeizvrsena;
    }

    public Boolean getMitoVezanZaKazneniPostupak() {
        return mitoVezanZaKazneniPostupak;
    }

    public void setMitoVezanZaKazneniPostupak(Boolean mitoVezanZaKazneniPostupak) {
        this.mitoVezanZaKazneniPostupak = mitoVezanZaKazneniPostupak;
    }

    public Boolean getTrazioMitoNakon() {
        return trazioMitoNakon;
    }

    public void setTrazioMitoNakon(Boolean trazioMitoNakon) {
        this.trazioMitoNakon = trazioMitoNakon;
    }

    public Boolean getPrijavioMito() {
        return prijavioMito;
    }

    public void setPrijavioMito(Boolean prijavioMito) {
        this.prijavioMito = prijavioMito;
    }

    public Integer getOslobadjajuceOkolnosti() {
        return oslobadjajuceOkolnosti;
    }

    public void setOslobadjajuceOkolnosti(Integer oslobadjajuceOkolnosti) {
        this.oslobadjajuceOkolnosti = oslobadjajuceOkolnosti;
    }

    public List<String> getPrimjenjeniPropisi() {
        return primjenjeniPropisi;
    }

    public void setPrimjenjeniPropisi(List<String> primjenjeniPropisi) {
        this.primjenjeniPropisi = primjenjeniPropisi;
    }

    public Boolean getUtvrdjenaKrivicaUPresudi() {
        return utvrdjenaKrivicaUPresudi;
    }

    public void setUtvrdjenaKrivicaUPresudi(Boolean utvrdjenaKrivicaUPresudi) {
        this.utvrdjenaKrivicaUPresudi = utvrdjenaKrivicaUPresudi;
    }

    public VerdictSimilarity() {
        // Empty constructor for jCOLIBRI
    }
    public VerdictSimilarity(Verdict v) {
        this.caseId = v.getId();
        this.name = v.getName();
        this.primjenjeniPropisi = v.getPrimjenjeniPropisi();
        this.optuzeniSluzbenoLice = v.getOptuzeniSluzbenoLice();
        this.utvrdjenaKrivicaUPresudi = v.getUtvrdjenaKrivicaUPresudi();
        this.oslobadjajuceOkolnosti = v.getOslobadjajuceOkolnosti();
        this.radnjaNezakonitaIliNeizvrsena = v.getRadnjaNezakonitaIliNeizvrsena();
        this.prijavioMito = v.getPrijavioMito();
        this.trazioMitoNakon = v.getTrazioMitoNakon();
        this.mitoVezanZaKazneniPostupak = v.getMitoVezanZaKazneniPostupak();
        this.optuzenoPrimalacMita = v.getOptuzenoPrimalacMita();
        this.optuzenoDavalacMita = v.getOptuzenoDavalacMita();

    }
}
