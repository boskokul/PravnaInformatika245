export default function Viewer({ filePath }: { filePath: string | null }) {
  return (
    <div
      style={{
        flex: 2,
        display: "flex",
        flexDirection: "column",
        height: "100vh",
        width: "700px",
      }}
    >
      {filePath ? (
        <iframe
          src={filePath}
          style={{
            flex: 1,
          }}
        />
      ) : (
        <p style={{ padding: "1rem", marginLeft: "25%" }}>
          Izaberite presudu da biste videli njen sadržaj
        </p>
      )}
    </div>
  );
}
