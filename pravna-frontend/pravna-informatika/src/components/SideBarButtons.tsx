import { useNavigate } from "react-router-dom";

export default function SideBarButtons() {
  const navigate = useNavigate();
  return (
    <div
      style={{ width: "300px", borderLeft: "1px solid #ccc", padding: "1rem" }}
    >
      <h3>Unos nove presude</h3>
      <button onClick={() => navigate("/ruleBased")}>
        Nova presuda
      </button>
      <br />
      <br />
      <br />
      <br />
    </div>
  );
}
