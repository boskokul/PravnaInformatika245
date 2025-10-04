package com.example.pravna.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Entity
@Table(name = "verdicts")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Verdict {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name", nullable = false)
    @NotBlank(message = "Case name is required")
    private String name; // broj predmeta

    @Column(name = "optuzeniSluzbenoLice", nullable = false)
    @NotBlank(message = "Case optuzeniSluzbenoLice is required")
    private boolean optuzeniSluzbenoLice;

    @Column(name = "optuzeniDavalacMita", nullable = false)
    @NotBlank(message = "Case optuzeniDavalacMita is required")
    private boolean optuzeniDavalacMita;

    @Column(name = "optuzeniPrimalacMita", nullable = false)
    @NotBlank(message = "Case optuzeniPrimalacMita is required")
    private boolean optuzeniPrimalacMita;

    @Column(name = "optuzeniZahtevaoMito", nullable = false)
    @NotBlank(message = "Case optuzeniZahtevaoMito is required")
    private boolean optuzeniZahtevaoMito;

    @Column(name = "optuzebiPrihvatioObecanjeMita", nullable = false)
    @NotBlank(message = "Case optuzebiPrihvatioObecanjeMita is required")
    private boolean optuzebiPrihvatioObecanjeMita;

    @Column(name = "radnjaNezakonita", nullable = false)
    @NotBlank(message = "Case radnjaNezakonita is required")
    private boolean radnjaNezakonita; // da li mito dato da se obavi nesto sto se ne smije

    @Column(name = "radnjaNeizvrsavanja", nullable = false)
    @NotBlank(message = "Case radnjaNeizvrsavanja is required")
    private boolean radnjaNeizvrsavanja;

    @Column(name = "oslobadjajuceOkolnosti", nullable = false)
    @NotBlank(message = "Case oslobadjajuceOkolnosti is required")
    private int oslobadjajuceOkolnosti;


    @Column(name = "utvrdjenaKrivicaUPresudi", nullable = false)
    @NotBlank(message = "Case name is required")
    private boolean utvrdjenaKrivicaUPresudi;

    @Column(name = "primjenjeniPropisi", nullable = false)
    private List<String> primjenjeniPropisi;

    @Column(name = "duzinaKazne", nullable = false)
    private int duzinaKazne; // mjeseci


}
