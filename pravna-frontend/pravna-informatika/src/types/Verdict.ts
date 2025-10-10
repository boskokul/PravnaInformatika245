export interface Verdict {
  id: number;
  name: string;
  optuzenoDavalacMita: boolean;
  optuzenoPrimalacMita: boolean;
  optuzeniSluzbenoLice: boolean;
  radnjaNezakonitaIliNeizvrsena: boolean;
  mitoVezanZaKazneniPostupak: boolean;
  trazioMitoNakon: boolean;
  prijavioMito: boolean;
  primjenjeniPropisi: string[];
  oslobadjajuceOkolnosti: number;
  sudija?: string;
  zapisnicar?: string;
  okrivljeni?: string;
  sud?: string;
  utvrdjenaKrivicaUPresudi: boolean;
}