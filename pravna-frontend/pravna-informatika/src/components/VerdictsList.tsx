const verdicts = [
  "K30-16.html",
  "K51-23.html",
  "K70-22.html",
  "K82-18.html",
  "K99-18.html",
  "K112-23.html",
  "K114-09.html",
  "K132-07.html",
  "K200-22.html",
  "K242-08.html",
  "K244-09.html",
  "K315-24.html",
  "K366-18.html",
  "K537-24.html",
  "K677-09.html",
];
export default function VerdictList({
  onSelect,
}: {
  onSelect: (file: string) => void;
}) {
  return (
    <div
      style={{
        width: "300px",
        borderRight: "1px solid #ccc",
        padding: "1rem",
        height: "100vh", // full height of the window
        overflowY: "auto", // enables vertical scrolling
        boxSizing: "border-box", // ensures padding doesn't exceed height
      }}
    >
      <ul style={{ padding: 0, margin: 0, listStyle: "none" }}>
        {verdicts.map((v) => (
          <li key={v} style={{ marginBottom: "1rem" }}>
            <button
              onClick={() => onSelect("http://localhost:8085/verdicts/" + v)}
            >
              presuda {v.slice(0, -5)}
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}
