package com.example.pravna.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;


/**
 * Model class representing facts about a legal case involving bribery (corruption).
 * Used for rule-based reasoning and decision making in the legal case system.
 */
@Entity
@Table(name = "legal_case_facts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class LegalCaseFacts {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    /**
     * Case identifier URI
     */
    @Column(name = "case_uri", unique = true)
    private String caseUri;

    /**
     * Case name/identifier
     */
    @Column(name = "name", nullable = false)
    @NotBlank(message = "Case name is required")
    private String name;

    /**
     * Name of the defendant
     */
    @Column(name = "defendant", nullable = false)
    @NotBlank(message = "Defendant name is required")
    private String defendant;

    /**
     * Whether the defendant is a bribe giver (davalac mita)
     */
    @Column(name = "optuzeno_davalac_mita", nullable = false)
    @NotNull(message = "Bribe giver status must be specified")
    private Boolean optuzenoDavalacMita;

    /**
     * Whether the defendant is a bribe receiver (primalac mita)
     */
    @Column(name = "optuzeno_primalac_mita", nullable = false)
    @NotNull(message = "Bribe receiver status must be specified")
    private Boolean optuzenoPrimalacMita;

    /**
     * Whether the defendant is an official person (sluzbeno lice)
     */
    @Column(name = "optuzeni_sluzbeno_lice", nullable = false)
    @NotNull(message = "Official person status must be specified")
    private Boolean optuzeniSluzbenoLice;

    /**
     * Whether the action was illegal or a mandatory action was not performed
     * (radnja nezakonita ili neizvrsena)
     */
    @Column(name = "radnja_nezakonita_ili_neizvrsena", nullable = false)
    @NotNull(message = "Action legality status must be specified")
    private Boolean radnjaNezakonitaIliNeizvrsena;

    /**
     * Whether the bribe is related to criminal proceedings
     * (mito vezan za kazneni postupak)
     */
    @Column(name = "mito_vezan_za_kazneni_postupak", nullable = false)
    @NotNull(message = "Criminal proceedings relation must be specified")
    private Boolean mitoVezanZaKazneniPostupak;

    /**
     * Whether the bribe was demanded after the illegal action or
     * after the mandatory action was not performed (trazio mito nakon)
     */
    @Column(name = "trazio_mito_nakon", nullable = false)
    @NotNull(message = "Post-action bribe demand status must be specified")
    private Boolean trazioMitoNakon;

    /**
     * Whether the defendant reported the bribe before it was discovered
     * (prijavio mito)
     */
    @Column(name = "prijavio_mito", nullable = false)
    @NotNull(message = "Self-reporting status must be specified")
    private Boolean prijavioMito;

    /**
     * Converts string values ("yes"/"no") to Boolean
     */
    public static Boolean parseYesNo(String value) {
        if (value == null) return null;
        return "yes".equalsIgnoreCase(value.trim());
    }

    /**
     * Creates LegalCaseFacts from RDF-like string values
     */
    public static LegalCaseFacts fromRdfValues(
            String caseUri,
            String name,
            String defendant,
            String optuzenoDavalacMita,
            String optuzenoPrimalacMita,
            String optuzeniSluzbenoLice,
            String radnjaNezakonitaIliNeizvrsena,
            String mitoVezanZaKazneniPostupak,
            String trazioMitoNakon,
            String prijavioMito) {

        return LegalCaseFacts.builder()
                .caseUri(caseUri)
                .name(name)
                .defendant(defendant)
                .optuzenoDavalacMita(parseYesNo(optuzenoDavalacMita))
                .optuzenoPrimalacMita(parseYesNo(optuzenoPrimalacMita))
                .optuzeniSluzbenoLice(parseYesNo(optuzeniSluzbenoLice))
                .radnjaNezakonitaIliNeizvrsena(parseYesNo(radnjaNezakonitaIliNeizvrsena))
                .mitoVezanZaKazneniPostupak(parseYesNo(mitoVezanZaKazneniPostupak))
                .trazioMitoNakon(parseYesNo(trazioMitoNakon))
                .prijavioMito(parseYesNo(prijavioMito))
                .build();
    }

    /**
     * Checks if all required fields are present for reasoning
     */
    public boolean isComplete() {
        return name != null && !name.isBlank() &&
                defendant != null && !defendant.isBlank() &&
                optuzenoDavalacMita != null &&
                optuzenoPrimalacMita != null &&
                optuzeniSluzbenoLice != null &&
                radnjaNezakonitaIliNeizvrsena != null &&
                mitoVezanZaKazneniPostupak != null &&
                trazioMitoNakon != null &&
                prijavioMito != null;
    }
}
