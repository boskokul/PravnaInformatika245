package com.example.pravna.service;

import com.example.pravna.model.Verdict;
import com.example.pravna.repository.VerdictsRepository;
import com.example.pravna.util.VerdictSimilarity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Service;
@Service
public class VerdictsService {

    @Autowired
    VerdictsRepository _verdictReposiroty;
    public Verdict Save(VerdictSimilarity newVerdict)
    {
        Verdict v = new Verdict();
        v.setName(newVerdict.getName());
        v.setPrijavioMito(newVerdict.getPrijavioMito());
        v.setOptuzenoDavalacMita(newVerdict.getOptuzenoDavalacMita());
        v.setOptuzeniSluzbenoLice(newVerdict.getOptuzeniSluzbenoLice());
        v.setOslobadjajuceOkolnosti(2);//to change
        v.setPrimjenjeniPropisi(newVerdict.getPrimjenjeniPropisi());
        v.setMitoVezanZaKazneniPostupak(newVerdict.getMitoVezanZaKazneniPostupak());
        v.setPrijavioMito(newVerdict.getPrijavioMito());
        v.setOptuzenoPrimalacMita(newVerdict.getOptuzenoPrimalacMita());
        v.setRadnjaNezakonitaIliNeizvrsena(newVerdict.getRadnjaNezakonitaIliNeizvrsena());
        v.setTrazioMitoNakon(newVerdict.getTrazioMitoNakon());
        v.setUtvrdjenaKrivicaUPresudi(newVerdict.getUtvrdjenaKrivicaUPresudi());

        return _verdictReposiroty.save(v);
    }
}
