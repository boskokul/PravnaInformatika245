package com.example.pravna.service;

import com.example.pravna.model.Verdict;
import com.example.pravna.repository.VerdictsRepository;
import com.example.pravna.util.*;
import es.ucm.fdi.gaia.jcolibri.casebase.LinealCaseBase;
import es.ucm.fdi.gaia.jcolibri.cbrcore.Attribute;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRCase;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRCaseBase;
import es.ucm.fdi.gaia.jcolibri.cbrcore.CBRQuery;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.NNConfig;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.NNScoringMethod;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.similarity.global.Average;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.similarity.local.Equal;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.NNretrieval.similarity.local.Interval;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.RetrievalResult;
import es.ucm.fdi.gaia.jcolibri.method.retrieve.selection.SelectCases;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Service

public class CBRService {
    @Autowired
    private VerdictsRepository _verdictRepository;
    private NNConfig simConfig;
    private CBRCaseBase caseBase;


    @PostConstruct
    public void init(){
        simConfig = new NNConfig();

        simConfig.setDescriptionSimFunction(new Average());
        configureSimilarities();
        this.caseBase = new InMemoryCaseBase();
        loadCasesFromDatabase();
    }

    private void loadCasesFromDatabase() {
        List<Verdict> verdicts = _verdictRepository.findAll();

        List<CBRCase> cases = verdicts.stream().map(verdict -> {
            CaseData caseData = new CaseData(verdict);
            CBRCase cbrCase = new CBRCase();
            cbrCase.setDescription(caseData);
            return cbrCase;
        }).collect(Collectors.toList());

        caseBase.learnCases(cases);

        System.out.println("Loaded " + cases.size() + " cases from the database into the CBR case base.");
    }

    private void configureSimilarities() {
        // Boolean atributi
        List<String> booleanAttrs = Arrays.asList(
                "optuzenoDavalacMita", "optuzenoPrimalacMita", "optuzeniSluzbenoLice", "radnjaNezakonitaIliNeizvrsena",
                "mitoVezanZaKazneniPostupak", "trazioMitoNakon", "prijavioMito"
        );
        for (String attr : booleanAttrs)
            simConfig.addMapping(new Attribute(attr, CaseData.class), new Equal());

        //razmisliti da li da promijenimo interval u gausovu slicnost
        simConfig.addMapping(
                new Attribute("oslobadjajuceOkolnosti", CaseData.class),
                new Interval(5) //ako su razliciti za vise od 5, nisu slicni
        );

    }

    public List<VerdictSimilarity> findTop5Similar(CaseData input){
        // novi slucaj
        CBRQuery query = new CBRQuery();
        query.setDescription(input);

        // eval. slicnosti
        Collection<RetrievalResult> eval = NNScoringMethod.evaluateSimilarity(caseBase.getCases(), query, simConfig);

        // ispis svih presuda u bazi
        System.out.println("\nSve presude u bazi:");
        for (RetrievalResult nse : eval)
            System.out.println(nse.get_case().getDescription() + " -> " + nse.getEval());

        // top 5 presuda
        eval = SelectCases.selectTopKRR(eval, 5);
        System.out.println("Top 5 presuda:");
        for (RetrievalResult nse : eval)
            System.out.println(nse.get_case().getDescription() + " -> " + nse.getEval());

        // vracamo listu VerdictSimilarity objekata
        return eval.stream().map(r -> {
            CaseData dto = (CaseData) r.get_case().getDescription();
            VerdictSimilarity vs = new VerdictSimilarity();
            vs.setName(dto.getName());
            vs.setCaseId(dto.getCaseId());
            vs.setPrijavioMito(dto.getPrijavioMito());
            vs.setTrazioMitoNakon(dto.getTrazioMitoNakon());
            vs.setMitoVezanZaKazneniPostupak(dto.getMitoVezanZaKazneniPostupak());
            vs.setOptuzeniSluzbenoLice(dto.getOptuzeniSluzbenoLice());
            vs.setPrimjenjeniPropisi(dto.getPrimjenjeniPropisi());
            vs.setOslobadjajuceOkolnosti(dto.getOslobadjajuceOkolnosti());
            vs.setRadnjaNezakonitaIliNeizvrsena(dto.getRadnjaNezakonitaIliNeizvrsena());
            vs.setOptuzenoPrimalacMita(dto.getOptuzenoPrimalacMita());
            vs.setUtvrdjenaKrivicaUPresudi(dto.getUtvrdjenaKrivicaUPresudi());
            vs.setOptuzenoDavalacMita(dto.getOptuzenoDavalacMita());

            vs.setSimilarity(r.getEval());
            return vs;
        }).collect(Collectors.toList());
    }


    //pozvati kod generisanja presude
    //paziti da learnCases vjerovatno cuva i atribute u fajl, pa ne treba duplirati, ali provjeriti. Sacuvati metapodatke rucno kod generisanja presude
    public void addCaseToBase(CaseData dto) throws ExecutionException {
        // napravimo novi CBRCase
        CBRCase newCase = new CBRCase();
        newCase.setDescription(dto);

        // dodavanje ga u memorijsku bazu
        caseBase.learnCases(Collections.singletonList(newCase));

        System.out.println("Novi slucaj dodat u bazu: " + dto);
    }




}
