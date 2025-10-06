import { useState } from "react";
import { VerdictSimilarity } from "../types/VerdictSimilarity";
import Viewer from "./Viewer";

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
    decision: string | null;
    law_article: string | null;
    law_paragraph: string | null;
    sentence: number | null;
    explanation: string | null;
    caseNumber: string | null;
    courtName: string | null;
    countryCode: string | null;
    judgeName: string | null;
    clerkName: string | null;
    defendantName: string | null;
    minSentenceMonths: number | null;
    maxSentenceMonths: number | null;
  } | null>(null);

  const [similarVerdicts, setSimilarVerdicts] = useState<VerdictSimilarity[] | null>(null); // for case based reasoning
  const [selectedFile, setSelectedFile] = useState<string | null>(null); // for file show in cbr
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

    const result = await res.json();

    setVerdict(result);
    setSimilarVerdicts(null);
  };

  const handleCBR = async (e?: React.SyntheticEvent) => {
    e?.preventDefault();
    const res = await fetch("http://localhost:8085/api/case-based-reasoning/decide", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(formData),
    });

    const result = await res.json();

    setSimilarVerdicts(result);
    console.log(similarVerdicts);
  };

  const handleSaveVerdict = async (e?: React.SyntheticEvent) => {
    e?.preventDefault();
    const res = await fetch(
      "http://localhost:8085/api/legal-cases/save-decision",
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(verdict),
      }
    );

    const result = await res.json();

    // setVerdict(result);
  };

  return (
    <div style={{ display: "flex", gap: "2rem", padding: "2rem" }}>
      <div style={{ flex: 1 }}>
        <h2>Unos činjenica za presudu</h2>
        <form
          
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
            Optuženi je dao mito
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
          <button type="button" style={{ marginTop: "1rem" }} onClick={handleSubmit}>
            Pošalji na odlučivanje
          </button>
          <button type="button" style={{ marginTop: "1rem" }} onClick={handleCBR}>
            Dobavi slične slučajeve
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
            width: "auto",
          }}
        >
          <h3>Rezultat presude po pravilima</h3>
          <form
            style={{ display: "grid", gap: "1rem", gridTemplateColumns: "1fr" }}
            onSubmit={(e) => {
              e.preventDefault();
              alert("Presuda je sačuvana ili prosleđena dalje.");
            }}
          >
            <label>
              <strong>Broj predmeta:</strong>
              <input
                disabled
                type="text"
                value={verdict.caseNumber ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, caseNumber: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Sud:</strong>
              <input
                type="text"
                value={verdict.courtName ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, courtName: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Oznaka države:</strong>
              <input
                type="text"
                value={verdict.countryCode ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, countryCode: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Sudija:</strong>
              <input
                type="text"
                value={verdict.judgeName ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, judgeName: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Zapisničar:</strong>
              <input
                type="text"
                value={verdict.clerkName ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, clerkName: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Okrivljeni:</strong>
              <input
                disabled
                type="text"
                value={verdict.defendantName ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, defendantName: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Prema članu zakona broj:</strong>
              <input
                type="text"
                value={verdict.law_article ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, law_article: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Paragraf broj:</strong>
              <input
                type="text"
                value={verdict.law_paragraph ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, law_paragraph: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Minimalna predložena kazna (meseci):</strong>
              <input
                disabled
                type="number"
                value={verdict.minSentenceMonths ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev
                      ? { ...prev, minSentenceMonths: Number(e.target.value) }
                      : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Maksimalna predložena kazna (meseci):</strong>
              <input
                disabled
                type="number"
                value={verdict.maxSentenceMonths ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev
                      ? { ...prev, maxSentenceMonths: Number(e.target.value) }
                      : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Konačna kazna (meseci):</strong>
              <input
                type="number"
                value={verdict.sentence ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, sentence: Number(e.target.value) } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Odluka:</strong>
              <textarea
                rows={4}
                style={{ resize: "vertical", minHeight: "100px" }}
                value={verdict.decision ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, decision: e.target.value } : prev
                  )
                }
              />
            </label>

            <label>
              <strong>Obrazloženje:</strong>
              <textarea
                rows={4}
                style={{ resize: "vertical", minHeight: "100px" }}
                value={verdict.explanation ?? ""}
                onChange={(e) =>
                  setVerdict((prev) =>
                    prev ? { ...prev, explanation: e.target.value } : prev
                  )
                }
              />
            </label>

            <button type="submit" onClick={handleSaveVerdict}>
              Sačuvaj presudu
            </button>
          </form>
        </div>
      )}


      {similarVerdicts && (
        <div
          style={{
            display: "grid",
            gap: "1rem",
            gridTemplateColumns: "1fr",
            maxWidth: "400px",
          }}
        >
        <h3>Slične presude</h3>
          <div style={{ display: "flex", height: "100vh" }}>
          <div
            style={{
              flex: 1,
              width: "300px",
              borderRight: "1px solid #ccc",
              padding: "1rem",
              height: "100vh",
              overflowY: "auto",
              boxSizing: "border-box",
            }}
          >
            <ul style={{ padding: 0, margin: 0, listStyle: "none" }}>
              {similarVerdicts.map((v, index) => (
                <li key={index} style={{ marginBottom: "1.5rem" }}>
                  <button
                    style={{
                      background: "none",
                      border: "none",
                      color: "#007bff",
                      cursor: "pointer",
                      textAlign: "left",
                      fontSize: "1rem",
                      fontWeight: "bold",
                      marginBottom: "0.5rem",
                    }}
                    onClick={() => setSelectedFile("http://localhost:8085/verdicts/" + v.name+".html")}
                  >
                  {v.name}
                  </button>

                  {/* Only show fields that are true */}
                  <ul style={{ margin: 0, paddingLeft: "1rem", fontSize: "0.9rem" }}>
                    {Object.entries(v)
                      .filter(([key, value]) => value === true && key !== "name")
                      .map(([key]) => (
                        <li key={key} style={{ color: "#555" }}>
                          {key}
                        </li>
                      ))}
                  </ul>
                </li>
              ))}
            </ul>
          </div>
          <div style={{ flex: 2 }}>
              <Viewer filePath={selectedFile} />
          </div>
        </div>
        {/* NOVA FORMA ZA CUVANJE PRESUDE */}
      </div>

      )}
    </div>
  );
}
