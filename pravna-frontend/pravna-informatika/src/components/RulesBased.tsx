import { useState } from "react";

export default function RulesBased() {
  const [formData, setFormData] = useState({
    name: "",
    defendant: "",
    optuzenoDavalacMita: false,
    optuzenoPrimalacMita: false,
    optuzeniSluzbenoLice: false,
    radnjaNezakonitaIliNeizvrsena: false,
    mitoVezanZaKazneniPostupak: false,
    trazioMitoNakon: false,
    prijavioMito: false,
  });

  const [verdict, setVerdict] = useState<{
    decision: string;
    law: string;
    sentence: string;
  } | null>(null);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const res = await fetch("http://localhost:8085/api/legal-cases/decide", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formData),
    });

    const resultText = await res.text();

    const parsed = {
      decision: "Ovde cu odluku",
      law: "Ovde cu zakon",
      sentence: resultText,
    };

    setVerdict(parsed);
  };

  return (
    <div style={{ display: "flex", gap: "2rem", padding: "2rem" }}>
      {/* Form Section */}
      <div style={{ flex: 1 }}>
        <h2>Unos činjenica za presudu</h2>
        <form
          onSubmit={handleSubmit}
          style={{
            display: "grid",
            gap: "1rem",
            gridTemplateColumns: "1fr",
            maxWidth: "400px",
          }}
        >
          <input
            name="name"
            placeholder="Oznaka slučaja"
            onChange={handleChange}
            required
          />
          <input
            name="defendant"
            placeholder="Okrivljeni"
            onChange={handleChange}
            required
          />
          <label>
            <input
              type="checkbox"
              name="optuzenoDavalacMita"
              onChange={handleChange}
            />{" "}
            Optuženi je dao mita
          </label>
          <label>
            <input
              type="checkbox"
              name="optuzenoPrimalacMita"
              onChange={handleChange}
            />{" "}
            Optuženi je primio mito
          </label>
          <label>
            <input
              type="checkbox"
              name="optuzeniSluzbenoLice"
              onChange={handleChange}
            />{" "}
            Optuženi je službeno lice
          </label>
          <label>
            <input
              type="checkbox"
              name="radnjaNezakonitaIliNeizvrsena"
              onChange={handleChange}
            />{" "}
            Nezakonita radnja ili neizvršena obaveza
          </label>
          <label>
            <input
              type="checkbox"
              name="mitoVezanZaKazneniPostupak"
              onChange={handleChange}
            />{" "}
            Mito vezan za krivični postupak
          </label>
          <label>
            <input
              type="checkbox"
              name="trazioMitoNakon"
              onChange={handleChange}
            />{" "}
            Tražio mito nakon dela
          </label>
          <label>
            <input
              type="checkbox"
              name="prijavioMito"
              onChange={handleChange}
            />{" "}
            Prijavio mito pre otkrivanja
          </label>
          <button type="submit" style={{ marginTop: "1rem" }}>
            Pošalji na odlučivanje
          </button>
        </form>
      </div>

      {verdict && (
        <div
          style={{
            flex: 1,
            border: "1px solid #ccc",
            padding: "1rem",
            borderRadius: "8px",
            backgroundColor: "#f9f9f9",
            color: "black",
          }}
        >
          <h3>Rezultat presude</h3>
          <p>
            <strong>Odluka:</strong> {verdict.decision}
          </p>
          <p>
            <strong>Pravni osnov:</strong> {verdict.law}
          </p>
          <p>
            <strong>Izrečena kazna:</strong> {verdict.sentence}
          </p>
        </div>
      )}
    </div>
  );
}
