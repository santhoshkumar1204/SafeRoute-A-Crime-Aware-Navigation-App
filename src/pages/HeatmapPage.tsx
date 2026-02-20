import { useState } from "react";
import { Download, Layers, Clock, Sun, Moon } from "lucide-react";
import MapComponent from "@/components/MapComponent";

const HeatmapPage = () => {
  const [showHeatmap, setShowHeatmap] = useState(true);
  const [timeFilter, setTimeFilter] = useState("all");
  const [severity, setSeverity] = useState("all");
  const [showAI, setShowAI] = useState(true);

  return (
    <div className="space-y-4 pb-20 lg:pb-0">
      <div className="grid lg:grid-cols-[1fr_280px] gap-4">
        <MapComponent showHeatmap={showHeatmap} showRoute={false} showPoliceStations height="h-[calc(100vh-8rem)]" />

        <div className="space-y-4">
          <div className="bg-card rounded-2xl shadow-card p-5 space-y-4">
            <h3 className="font-display font-semibold text-sm">Filters</h3>
            <Toggle label="Crime Heatmap" icon={<Layers className="w-4 h-4" />} active={showHeatmap} onToggle={() => setShowHeatmap(!showHeatmap)} />
            <Toggle label="AI Prediction" icon={<Sun className="w-4 h-4" />} active={showAI} onToggle={() => setShowAI(!showAI)} />
          </div>

          <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
            <h3 className="font-display font-semibold text-sm flex items-center gap-2"><Clock className="w-4 h-4" /> Time Filter</h3>
            {["all", "morning", "afternoon", "evening", "night"].map((t) => (
              <button key={t} onClick={() => setTimeFilter(t)}
                className={`w-full text-left px-3 py-2 rounded-lg text-sm capitalize transition-colors ${timeFilter === t ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}>
                {t === "all" ? "All Day" : t}
              </button>
            ))}
          </div>

          <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
            <h3 className="font-display font-semibold text-sm">Severity</h3>
            {["all", "low", "moderate", "high"].map((s) => (
              <button key={s} onClick={() => setSeverity(s)}
                className={`w-full text-left px-3 py-2 rounded-lg text-sm capitalize transition-colors ${severity === s ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}>
                {s === "all" ? "All Levels" : s}
              </button>
            ))}
          </div>

          <button className="w-full py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity text-sm">
            <Download className="w-4 h-4" /> Download PDF Report
          </button>
        </div>
      </div>
    </div>
  );
};

const Toggle = ({ label, icon, active, onToggle }: { label: string; icon: React.ReactNode; active: boolean; onToggle: () => void }) => (
  <button onClick={onToggle} className="flex items-center justify-between w-full text-sm">
    <span className="flex items-center gap-2">{icon} {label}</span>
    <span className={`w-9 h-5 rounded-full relative transition-colors ${active ? "bg-primary" : "bg-muted"}`}>
      <span className={`absolute top-0.5 w-4 h-4 rounded-full bg-card shadow transition-transform ${active ? "left-[18px]" : "left-0.5"}`} />
    </span>
  </button>
);

export default HeatmapPage;
