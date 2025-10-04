import { useNavigate } from "react-router-dom";

export default function SideBarButtons() {
  const navigate = useNavigate();
  return (
    <div
      style={{ width: "300px", borderLeft: "1px solid #ccc", padding: "1rem" }}
    >
      <h3>Unos nove presude</h3>
      <button onClick={() => navigate("/ruleBased")}>
        Presuđivanje po pravilima
      </button>
      <br />
      <br />
      <button onClick={() => navigate("/caseBased")}>
        Presudjivanje po slučajevima
      </button>
      <br />
      <br />
    </div>
  );
}
