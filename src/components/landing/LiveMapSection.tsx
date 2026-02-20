import { useState, useEffect, useCallback } from "react";
import { motion } from "framer-motion";
import { Eye, EyeOff, Layers, Clock, AlertTriangle, Shield, MapPin } from "lucide-react";

const GRID_SIZE = 20;
const CELL = 28;

type Zone = "safe" | "moderate" | "danger";

const zoneColors: Record<Zone, string> = {
  safe: "rgba(22,163,74,0.18)",
  moderate: "rgba(245,158,11,0.22)",
  danger: "rgba(220,38,38,0.22)",
};

const generateGrid = (): Zone[][] => {
  const grid: Zone[][] = [];
  for (let r = 0; r < GRID_SIZE; r++) {
    const row: Zone[] = [];
    for (let c = 0; c < GRID_SIZE; c++) {
      const rand = Math.random();
      if (rand < 0.55) row.push("safe");
      else if (rand < 0.8) row.push("moderate");
      else row.push("danger");
    }
    row.push("safe");
    grid.push(row);
  }
  return grid;
};

const routePath = [
  [1, 1], [2, 1], [3, 1], [4, 2], [5, 3], [6, 4], [7, 5], [8, 5],
  [9, 6], [10, 7], [11, 8], [12, 9], [13, 10], [14, 10], [15, 11],
  [16, 12], [17, 13], [18, 14], [18, 15],
];

const riskMarkers = [
  { r: 5, c: 7, level: "danger" as Zone, score: 82 },
  { r: 10, c: 3, level: "moderate" as Zone, score: 54 },
  { r: 14, c: 15, level: "danger" as Zone, score: 76 },
  { r: 8, c: 12, level: "moderate" as Zone, score: 48 },
];

const LiveMapSection = () => {
  const [grid] = useState(generateGrid);
  const [showHeatmap, setShowHeatmap] = useState(true);
  const [showPrediction, setShowPrediction] = useState(true);
  const [timeOfDay, setTimeOfDay] = useState("evening");
  const [hoveredMarker, setHoveredMarker] = useState<number | null>(null);
  const [routeProgress, setRouteProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setRouteProgress((p) => (p + 1) % routePath.length);
    }, 600);
    return () => clearInterval(interval);
  }, []);

  return (
    <section id="live-map" className="py-20 bg-secondary/30">
      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl md:text-4xl font-display font-bold mb-4">
            Live Crime <span className="text-gradient-primary">Heatmap Prototype</span>
          </h2>
          <p className="text-muted-foreground max-w-2xl mx-auto">
            Interactive map showing AI-predicted crime risk zones with real-time route analysis
          </p>
        </motion.div>

        <div className="grid lg:grid-cols-[1fr_300px] gap-6">
          {/* Map */}
          <motion.div
            initial={{ opacity: 0 }}
            whileInView={{ opacity: 1 }}
            viewport={{ once: true }}
            className="relative bg-card rounded-2xl shadow-card overflow-hidden p-4"
          >
            <div className="overflow-auto">
              <svg width={GRID_SIZE * CELL + 20} height={GRID_SIZE * CELL + 20} className="mx-auto">
                {/* Street grid */}
                {Array.from({ length: GRID_SIZE + 1 }).map((_, i) => (
                  <g key={i}>
                    <line x1={10} y1={i * CELL + 10} x2={GRID_SIZE * CELL + 10} y2={i * CELL + 10} stroke="hsl(214 32% 91%)" strokeWidth={0.5} />
                    <line x1={i * CELL + 10} y1={10} x2={i * CELL + 10} y2={GRID_SIZE * CELL + 10} stroke="hsl(214 32% 91%)" strokeWidth={0.5} />
                  </g>
                ))}

                {/* Heatmap zones */}
                {showHeatmap && grid.map((row, r) =>
                  row.map((zone, c) => (
                    <rect
                      key={`${r}-${c}`}
                      x={c * CELL + 10}
                      y={r * CELL + 10}
                      width={CELL}
                      height={CELL}
                      fill={zoneColors[zone]}
                      rx={4}
                    />
                  ))
                )}

                {/* Route line */}
                <polyline
                  points={routePath.map(([r, c]) => `${c * CELL + CELL / 2 + 10},${r * CELL + CELL / 2 + 10}`).join(" ")}
                  fill="none"
                  stroke="hsl(224 76% 48%)"
                  strokeWidth={3}
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  opacity={0.8}
                />

                {/* Moving dot */}
                {routePath[routeProgress] && (
                  <g>
                    <circle
                      cx={routePath[routeProgress][1] * CELL + CELL / 2 + 10}
                      cy={routePath[routeProgress][0] * CELL + CELL / 2 + 10}
                      r={10}
                      fill="hsl(224 76% 48%)"
                      opacity={0.2}
                      className="animate-pulse-ring"
                    />
                    <circle
                      cx={routePath[routeProgress][1] * CELL + CELL / 2 + 10}
                      cy={routePath[routeProgress][0] * CELL + CELL / 2 + 10}
                      r={5}
                      fill="hsl(224 76% 48%)"
                    />
                  </g>
                )}

                {/* Start / End markers */}
                <circle cx={routePath[0][1] * CELL + CELL / 2 + 10} cy={routePath[0][0] * CELL + CELL / 2 + 10} r={6} fill="hsl(142 76% 36%)" />
                <circle cx={routePath[routePath.length - 1][1] * CELL + CELL / 2 + 10} cy={routePath[routePath.length - 1][0] * CELL + CELL / 2 + 10} r={6} fill="hsl(0 72% 51%)" />

                {/* Risk markers */}
                {showPrediction && riskMarkers.map((m, i) => (
                  <g key={i} onMouseEnter={() => setHoveredMarker(i)} onMouseLeave={() => setHoveredMarker(null)} className="cursor-pointer">
                    <circle
                      cx={m.c * CELL + CELL / 2 + 10}
                      cy={m.r * CELL + CELL / 2 + 10}
                      r={12}
                      fill={m.level === "danger" ? "hsl(0 72% 51% / 0.3)" : "hsl(38 92% 50% / 0.3)"}
                      className="animate-pulse"
                    />
                    <text
                      x={m.c * CELL + CELL / 2 + 10}
                      y={m.r * CELL + CELL / 2 + 14}
                      textAnchor="middle"
                      fontSize={10}
                      fontWeight="bold"
                      fill={m.level === "danger" ? "hsl(0 72% 51%)" : "hsl(38 92% 50%)"}
                    >
                      ⚠
                    </text>
                    {hoveredMarker === i && (
                      <g>
                        <rect x={m.c * CELL + CELL / 2 - 50 + 10} y={m.r * CELL - 20 + 10} width={110} height={28} rx={8} fill="hsl(222 47% 11%)" />
                        <text x={m.c * CELL + CELL / 2 + 5 + 10} y={m.r * CELL - 2 + 10} textAnchor="middle" fontSize={10} fill="white">
                          Risk Score: {m.score}%
                        </text>
                      </g>
                    )}
                  </g>
                ))}
              </svg>
            </div>

            {/* Legend */}
            <div className="flex flex-wrap gap-4 mt-4 justify-center text-xs">
              <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-safe/30" /> Low Risk</span>
              <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-moderate/30" /> Moderate</span>
              <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded bg-danger/30" /> High Risk</span>
              <span className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-primary" /> Route</span>
            </div>
          </motion.div>

          {/* Controls */}
          <div className="space-y-4">
            <div className="bg-card rounded-2xl shadow-card p-5 space-y-4">
              <h3 className="font-display font-semibold text-sm">Map Controls</h3>
              <ToggleControl icon={<Layers className="w-4 h-4" />} label="Crime Heatmap" active={showHeatmap} onToggle={() => setShowHeatmap(!showHeatmap)} />
              <ToggleControl icon={<Eye className="w-4 h-4" />} label="AI Prediction" active={showPrediction} onToggle={() => setShowPrediction(!showPrediction)} />
            </div>

            <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
              <h3 className="font-display font-semibold text-sm flex items-center gap-2"><Clock className="w-4 h-4" /> Time of Day</h3>
              {["morning", "afternoon", "evening", "night"].map((t) => (
                <button
                  key={t}
                  onClick={() => setTimeOfDay(t)}
                  className={`w-full text-left px-3 py-2 rounded-lg text-sm capitalize transition-colors ${timeOfDay === t ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                >
                  {t}
                </button>
              ))}
            </div>

            <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
              <h3 className="font-display font-semibold text-sm flex items-center gap-2"><MapPin className="w-4 h-4" /> Quick Toggle</h3>
              <p className="text-xs text-muted-foreground">Police Stations</p>
              <p className="text-xs text-muted-foreground">Community Reports</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

const ToggleControl = ({ icon, label, active, onToggle }: { icon: React.ReactNode; label: string; active: boolean; onToggle: () => void }) => (
  <button onClick={onToggle} className="flex items-center justify-between w-full text-sm">
    <span className="flex items-center gap-2">{icon} {label}</span>
    <span className={`w-9 h-5 rounded-full relative transition-colors ${active ? "bg-primary" : "bg-muted"}`}>
      <span className={`absolute top-0.5 w-4 h-4 rounded-full bg-card shadow transition-transform ${active ? "left-[18px]" : "left-0.5"}`} />
    </span>
  </button>
);

export default LiveMapSection;
