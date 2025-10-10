import { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import VerdictList from "./components/VerdictsList";
import Viewer from "./components/Viewer";
import SideBarButtons from "./components/SideBarButtons";
import RulesBased from "./components/RulesBased";
import CaseBased from "./components/CaseBased";
import { MetaDataList } from "./components/MetaDataList";
import { Verdict } from "./types/Verdict";

function App() {
  const [selectedFile, setSelectedFile] = useState<string | null>(null);
  const [verdictData, setVerdictData] = useState<string | null>(null);

  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/"
          element={
            <div style={{ display: "flex", height: "100vh" }}>
              {/* Left column - Verdict list */}
              <div style={{ flex: 1 }}>
                <VerdictList
                  onSelect={setSelectedFile}
                  onSelectVerdict={setVerdictData}
                />
              </div>

              {/* Middle column - Viewer */}
              <div style={{ flex: 2 }}>
                <Viewer filePath={selectedFile} />
              </div>

              {/* Right column - Sidebar + metadata */}
              <div
                style={{
                  flex: 3,
                  display: "flex",
                  flexDirection: "column",
                  overflowY: "auto",
                  padding: "1rem",
                  marginLeft: "6rem", 
                  borderLeft: "1px solid #ddd", // optional subtle separator
                }}
              >
                <SideBarButtons />
                <div style={{ marginTop: "2rem" }}>
                  {verdictData && <MetaDataList verdictName={verdictData} />}
                </div>
              </div>
            </div>
          }
        />
        <Route path="/ruleBased" element={<RulesBased />} />
        <Route path="/caseBased" element={<CaseBased />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
