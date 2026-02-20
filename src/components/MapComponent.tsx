import { useState, useEffect } from "react";

const GRID = 16;
const CELL = 30;

type Zone = "safe" | "moderate" | "danger";

const zoneColors: Record<Zone, string> = {
  safe: "rgba(22,163,74,0.18)",
  moderate: "rgba(245,158,11,0.22)",
  danger: "rgba(220,38,38,0.22)",
};

const generateGrid = (): Zone[][] => {
  const grid: Zone[][] = [];
  for (let r = 0; r < GRID; r++) {
    const row: Zone[] = [];
    for (let c = 0; c < GRID; c++) {
      const rand = Math.random();
      row.push(rand < 0.55 ? "safe" : rand < 0.8 ? "moderate" : "danger");
    }
    grid.push(row);
  }
  return grid;
};

const routePath = [
  [1,1],[2,1],[3,2],[4,3],[5,4],[6,5],[7,5],[8,6],[9,7],[10,8],[11,9],[12,10],[13,11],[14,12],
];

interface MapComponentProps {
  showHeatmap?: boolean;
  showRoute?: boolean;
  showPoliceStations?: boolean;
  height?: string;
  className?: string;
  loading?: boolean;
}

const MapComponent = ({ showHeatmap = true, showRoute = true, showPoliceStations = false, height = "h-80", className = "", loading = false }: MapComponentProps) => {
  const [grid] = useState(generateGrid);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    if (!showRoute) return;
    const interval = setInterval(() => setProgress((p) => (p + 1) % routePath.length), 600);
    return () => clearInterval(interval);
  }, [showRoute]);

  if (loading) {
    return (
      <div className={`${height} rounded-2xl bg-muted/50 animate-pulse flex items-center justify-center ${className}`}>
        <div className="w-8 h-8 border-4 border-primary border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className={`${height} rounded-2xl bg-card shadow-card overflow-hidden relative ${className}`}>
      <div className="w-full h-full overflow-auto flex items-center justify-center p-2">
        <svg width={GRID * CELL + 20} height={GRID * CELL + 20} className="flex-shrink-0">
          {Array.from({ length: GRID + 1 }).map((_, i) => (
            <g key={i}>
              <line x1={10} y1={i * CELL + 10} x2={GRID * CELL + 10} y2={i * CELL + 10} stroke="hsl(214 32% 91%)" strokeWidth={0.5} />
              <line x1={i * CELL + 10} y1={10} x2={i * CELL + 10} y2={GRID * CELL + 10} stroke="hsl(214 32% 91%)" strokeWidth={0.5} />
            </g>
          ))}

          {showHeatmap && grid.map((row, r) =>
            row.map((zone, c) => (
              <rect key={`${r}-${c}`} x={c * CELL + 10} y={r * CELL + 10} width={CELL} height={CELL} fill={zoneColors[zone]} rx={3} />
            ))
          )}

          {showRoute && (
            <>
              <polyline
                points={routePath.map(([r, c]) => `${c * CELL + CELL / 2 + 10},${r * CELL + CELL / 2 + 10}`).join(" ")}
                fill="none" stroke="hsl(224 76% 48%)" strokeWidth={3} strokeLinecap="round" strokeLinejoin="round" opacity={0.8}
              />
              {routePath[progress] && (
                <>
                  <circle cx={routePath[progress][1] * CELL + CELL / 2 + 10} cy={routePath[progress][0] * CELL + CELL / 2 + 10} r={10} fill="hsl(224 76% 48%)" opacity={0.2} className="animate-pulse" />
                  <circle cx={routePath[progress][1] * CELL + CELL / 2 + 10} cy={routePath[progress][0] * CELL + CELL / 2 + 10} r={5} fill="hsl(224 76% 48%)" />
                </>
              )}
              <circle cx={routePath[0][1] * CELL + CELL / 2 + 10} cy={routePath[0][0] * CELL + CELL / 2 + 10} r={6} fill="hsl(142 76% 36%)" />
              <circle cx={routePath[routePath.length - 1][1] * CELL + CELL / 2 + 10} cy={routePath[routePath.length - 1][0] * CELL + CELL / 2 + 10} r={6} fill="hsl(0 72% 51%)" />
            </>
          )}

          {showPoliceStations && (
            <>
              {[[3,12],[8,3],[13,14]].map(([r,c], i) => (
                <g key={i}>
                  <circle cx={c * CELL + CELL / 2 + 10} cy={r * CELL + CELL / 2 + 10} r={8} fill="hsl(224 76% 48% / 0.2)" />
                  <text x={c * CELL + CELL / 2 + 10} y={r * CELL + CELL / 2 + 14} textAnchor="middle" fontSize={12}>🏛</text>
                </g>
              ))}
            </>
          )}
        </svg>
      </div>

      {/* Legend */}
      <div className="absolute bottom-2 left-2 right-2 flex flex-wrap gap-3 justify-center text-[10px] bg-card/80 backdrop-blur-sm rounded-lg p-1.5">
        <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-safe/40" /> Low Risk</span>
        <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-moderate/40" /> Moderate</span>
        <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded bg-danger/40" /> High Risk</span>
        {showRoute && <span className="flex items-center gap-1"><span className="w-2.5 h-2.5 rounded-full bg-primary" /> Route</span>}
      </div>
    </div>
  );
};

export default MapComponent;
