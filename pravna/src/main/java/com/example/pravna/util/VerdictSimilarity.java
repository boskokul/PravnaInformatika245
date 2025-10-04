package com.example.pravna.util;

import com.example.pravna.model.Verdict;
import es.ucm.fdi.gaia.jcolibri.cbrcore.Attribute;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CaseComponent;

import java.util.List;

public class VerdictSimilarity implements CaseComponent {
    private Long caseId;
    private String name;
    private Boolean optuzeniSluzbenoLice;
    private Boolean optuzeniDavalacMita;
    private Boolean optuzeniPrimalacMita;
    private Boolean optuzeniZahtevaoMito;
    private Boolean optuzebiPrihvatioObecanjeMita;
    private Boolean radnjaNezakonita;
    private Boolean radnjaNeizvrsavanja;
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

    public Boolean getOptuzeniSluzbenoLice() {
        return optuzeniSluzbenoLice;
    }

    public void setOptuzeniSluzbenoLice(Boolean optuzeniSluzbenoLice) {
        this.optuzeniSluzbenoLice = optuzeniSluzbenoLice;
    }

    public Boolean getOptuzeniDavalacMita() {
        return optuzeniDavalacMita;
    }

    public void setOptuzeniDavalacMita(Boolean optuzeniDavalacMita) {
        this.optuzeniDavalacMita = optuzeniDavalacMita;
    }

    public Boolean getOptuzeniPrimalacMita() {
        return optuzeniPrimalacMita;
    }

    public void setOptuzeniPrimalacMita(Boolean optuzeniPrimalacMita) {
        this.optuzeniPrimalacMita = optuzeniPrimalacMita;
    }

    public Boolean getOptuzeniZahtevaoMito() {
        return optuzeniZahtevaoMito;
    }

    public void setOptuzeniZahtevaoMito(Boolean optuzeniZahtevaoMito) {
        this.optuzeniZahtevaoMito = optuzeniZahtevaoMito;
    }

    public Boolean getOptuzebiPrihvatioObecanjeMita() {
        return optuzebiPrihvatioObecanjeMita;
    }

    public void setOptuzebiPrihvatioObecanjeMita(Boolean optuzebiPrihvatioObecanjeMita) {
        this.optuzebiPrihvatioObecanjeMita = optuzebiPrihvatioObecanjeMita;
    }

    public Boolean getRadnjaNezakonita() {
        return radnjaNezakonita;
    }

    public void setRadnjaNezakonita(Boolean radnjaNezakonita) {
        this.radnjaNezakonita = radnjaNezakonita;
    }

    public Boolean getRadnjaNeizvrsavanja() {
        return radnjaNeizvrsavanja;
    }

    public void setRadnjaNeizvrsavanja(Boolean radnjaNeizvrsavanja) {
        this.radnjaNeizvrsavanja = radnjaNeizvrsavanja;
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

    @Override
    public Attribute getIdAttribute() {
        return new Attribute("id", this.getClass());
    }

    public VerdictSimilarity() {
        // Empty constructor for jCOLIBRI
    }
    public VerdictSimilarity(Verdict v) {
        this.caseId = v.getId();
        this.name = v.getName();
        this.optuzebiPrihvatioObecanjeMita = v.isOptuzebiPrihvatioObecanjeMita();
        this.primjenjeniPropisi = v.getPrimjenjeniPropisi();
        this.optuzeniDavalacMita = v.isOptuzeniDavalacMita();
        this.optuzeniPrimalacMita = v.isOptuzeniPrimalacMita();
        this.optuzeniSluzbenoLice = v.isOptuzeniSluzbenoLice();
        this.utvrdjenaKrivicaUPresudi = v.isUtvrdjenaKrivicaUPresudi();
        this.optuzeniZahtevaoMito = v.isOptuzeniZahtevaoMito();
        this.oslobadjajuceOkolnosti = v.getOslobadjajuceOkolnosti();
        this.radnjaNeizvrsavanja = v.isRadnjaNezakonita();
        this.radnjaNezakonita = v.isRadnjaNezakonita();
    }
}
