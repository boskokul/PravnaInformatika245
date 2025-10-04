import { useState } from "react";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import VerdictList from "./components/VerdictsList";
import Viewer from "./components/Viewer";
import SideBarButtons from "./components/SideBarButtons";
import RulesBased from "./components/RulesBased";
import CaseBased from "./components/CaseBased";

function App() {
  const [selectedFile, setSelectedFile] = useState<string | null>(null);

  return (
    <BrowserRouter>
      <Routes>
        <Route
          path="/"
          element={
            <div style={{ display: "flex", height: "100vh" }}>
              <div style={{ flex: 1 }}>
                <VerdictList onSelect={setSelectedFile} />
              </div>
              <div style={{ flex: 2 }}>
                <Viewer filePath={selectedFile} />
              </div>
              <div style={{ flex: 3 }}>
                <SideBarButtons />
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
