export interface VerdictSimilarity {
  caseId: number;
  name: string;
  optuzenoDavalacMita: boolean;
  optuzenoPrimalacMita: boolean;
  optuzeniSluzbenoLice: boolean;
  radnjaNezakonitaIliNeizvrsena: boolean;
  mitoVezanZaKazneniPostupak: boolean;
  trazioMitoNakon: boolean;
  prijavioMito: boolean;
  oslobadjajuceOkolnosti: number;
  primjenjeniPropisi: string[];
  utvrdjenaKrivicaUPresudi: boolean;
  similarity: number;
}