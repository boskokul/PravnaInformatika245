import { useEffect, useState } from "react";
import { Verdict } from "../types/Verdict";

export default function VerdictList({
  onSelect, onSelectVerdict
}: {
  onSelect: (file: string) => void;
  onSelectVerdict: (verdict: string) => void;
}) {
  const [verdicts, setVerdicts] = useState<string[]>([]);

  useEffect(() => {
    fetch("http://localhost:8085/api/legal-cases/html-files")
      .then((res) => res.json())
      .then((data) => setVerdicts(data))
      .catch((err) => console.error("Failed to fetch verdicts:", err));
  }, []);

  

  return (
    <div
      style={{
        width: "300px",
        borderRight: "1px solid #ccc",
        padding: "1rem",
        height: "100vh",
        overflowY: "auto",
        boxSizing: "border-box",
      }}
    >
      <ul style={{ padding: 0, margin: 0, listStyle: "none" }}>
        {verdicts.map((v) => (
          <li key={v} style={{ marginBottom: "1rem" }}>
            <button
              onClick={() =>{ onSelect("http://localhost:8085/verdicts/" + v); onSelectVerdict(v.slice(0, v.length-5))}}
            >
              presuda {v.slice(0, -5)}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
