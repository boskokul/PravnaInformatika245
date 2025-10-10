import { useEffect, useState } from "react";
import { Verdict } from "../types/Verdict";

export function MetaDataList({ verdictName }: { verdictName: string | null }) {
  const [verdict, setVerdict] = useState<Verdict | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchVerdict() {
      if (!verdictName) return;
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(
          `http://localhost:8085/verdicts/metadata/${verdictName}`,
          {
            headers: {
              Accept: "application/json",
            },
          }
        );
        if (!response.ok) {
          throw new Error(`Greška pri učitavanju presude: ${response.status}`);
        }
        const data: Verdict = await response.json();
        setVerdict(data);
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    fetchVerdict();
  }, [verdictName]);

  if (loading) return <div>Učitavanje podataka o presudi...</div>;
  if (error) return <div style={{ color: "red" }}>Greška: {error}</div>;
  if (!verdict) return <div>Nema pronađene presude.</div>;

  return (
    <div
      style={{
        padding: "1rem",
        border: "1px solid #ccc",
        borderRadius: 8,
        
      }}
    >
      <h2>Presuda: {verdict.name}</h2>

      <p><strong>Sud:</strong> {verdict.sud ?? "Nepoznato"}</p>
      <p><strong>Sudija:</strong> {verdict.sudija ?? "Nepoznato"}</p>
      <p><strong>Zapisničar:</strong> {verdict.zapisnicar ?? "Nepoznato"}</p>
      <p><strong>Okrivljeni:</strong> {verdict.okrivljeni ?? "Nepoznato"}</p>

      <h3>Podaci o slučaju</h3>
      <p><strong>Optuženi kao davalac mita:</strong> {verdict.optuzenoDavalacMita ? "Da" : "Ne"}</p>
      <p><strong>Optuženi kao primalac mita:</strong> {verdict.optuzenoPrimalacMita ? "Da" : "Ne"}</p>
      <p><strong>Optuženi je službeno lice:</strong> {verdict.optuzeniSluzbenoLice ? "Da" : "Ne"}</p>
      <p><strong>Radnja nezakonita ili neizvršena:</strong> {verdict.radnjaNezakonitaIliNeizvrsena ? "Da" : "Ne"}</p>
      <p><strong>Mito vezan za kazneni postupak:</strong> {verdict.mitoVezanZaKazneniPostupak ? "Da" : "Ne"}</p>
      <p><strong>Tražio mito nakon radnje:</strong> {verdict.trazioMitoNakon ? "Da" : "Ne"}</p>
      <p><strong>Prijavio mito:</strong> {verdict.prijavioMito ? "Da" : "Ne"}</p>
      <p><strong>Utvrdjena krivica u presudi:</strong> {verdict.utvrdjenaKrivicaUPresudi ? "Da" : "Ne"}</p>

      <h3>Primijenjeni propisi</h3>
      {verdict.primjenjeniPropisi?.length > 0 ? (
        <ul>
          {verdict.primjenjeniPropisi.map((propis, idx) => (
            <li key={idx}>{propis}</li>
          ))}
        </ul>
      ) : (
        <p>Nema navedenih propisa.</p>
      )}

      <h3>Ostalo</h3>
      <p><strong>Oslobađajuće okolnosti:</strong> {verdict.oslobadjajuceOkolnosti}</p>
    </div>
  );
}
