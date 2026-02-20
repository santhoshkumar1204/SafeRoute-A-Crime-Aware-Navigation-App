import { useState } from "react";
import { MapPin, Navigation, Shield, Clock, ArrowRight, Bus, Car, Footprints, Bike, Users, AlertTriangle } from "lucide-react";
import MapComponent from "@/components/MapComponent";
import { useAppState } from "@/contexts/AppStateContext";
import { mockCrowdData, mockDelayData, mockStopSafety } from "@/data/mockData";
import phoneIcon from "@/assets/phoneicon.jpeg";

const transportModes = [
  { key: "bus" as const, label: "Bus", icon: Bus, primary: true },
  { key: "car" as const, label: "Car", icon: Car },
  { key: "bike" as const, label: "Two-wheeler", icon: Bike },
  { key: "walk" as const, label: "Walking", icon: Footprints },
];

const NavigationPage = () => {
  const { routeState, setRouteState } = useAppState();
  const [source, setSource] = useState(routeState.source);
  const [destination, setDestination] = useState(routeState.destination);
  const [navigating, setNavigating] = useState(false);
  const [transport, setTransport] = useState("bus");
  const [busType, setBusType] = useState("all");

  const modes = [
    { key: "safest" as const, label: "Safest", icon: Shield, desc: "Avoids all high-risk zones" },
    { key: "balanced" as const, label: "Balanced", icon: Navigation, desc: "Balance of safety & speed" },
    { key: "fastest" as const, label: "Fastest", icon: Clock, desc: "Shortest travel time" },
  ];

  const handleStart = () => {
    setRouteState((s) => ({ ...s, source, destination }));
    setNavigating(true);
  };

  return (
    <div className="space-y-4 pb-20 lg:pb-0">
      <div className="grid lg:grid-cols-[350px_1fr] gap-4">
        {/* Controls */}
        <div className="space-y-4">
          {/* Hero with phone icon */}
          <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
            <div className="flex-1">
              <h3 className="font-display font-bold text-sm">Smart Route Scanner</h3>
              <p className="text-xs text-muted-foreground mt-1">AI-powered navigation with crime & transport intelligence</p>
            </div>
            <img src={phoneIcon} alt="Smart Navigation" className="w-20 h-20 rounded-xl object-cover flex-shrink-0" />
          </div>

          <div className="bg-card rounded-2xl shadow-card p-5 space-y-4">
            <h3 className="font-display font-semibold text-sm">Plan Your Route</h3>

            {/* Transport Mode */}
            <div className="flex gap-2">
              {transportModes.map((m) => {
                const Icon = m.icon;
                return (
                  <button key={m.key} onClick={() => setTransport(m.key)}
                    className={`flex-1 flex flex-col items-center gap-1 py-2.5 rounded-xl text-xs transition-colors ${
                      transport === m.key ? "bg-primary text-primary-foreground" : "bg-muted/50 hover:bg-muted"
                    } ${m.primary ? "ring-1 ring-primary/20" : ""}`}>
                    <Icon className="w-4 h-4" />
                    {m.label}
                  </button>
                );
              })}
            </div>

            {/* Bus type filter */}
            {transport === "bus" && (
              <div>
                <p className="text-xs font-medium text-muted-foreground mb-1.5">Bus Type</p>
                <select value={busType} onChange={(e) => setBusType(e.target.value)}
                  className="w-full px-3 py-2.5 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
                  <option value="all">All Types</option>
                  <option value="ordinary">Ordinary</option>
                  <option value="express">Express</option>
                  <option value="ac">Deluxe/AC</option>
                  <option value="mini">Mini Bus</option>
                  <option value="special">Special/Event</option>
                </select>
              </div>
            )}

            <div className="space-y-3">
              <div className="relative">
                <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-safe" />
                <input value={source} onChange={(e) => setSource(e.target.value)} placeholder="Source location" className="w-full pl-10 pr-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" />
              </div>
              <div className="relative">
                <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-danger" />
                <input value={destination} onChange={(e) => setDestination(e.target.value)} placeholder="Destination" className="w-full pl-10 pr-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" />
              </div>
            </div>

            <div className="space-y-2">
              <p className="text-xs font-medium text-muted-foreground">Route Mode</p>
              {modes.map((m) => {
                const Icon = m.icon;
                return (
                  <button key={m.key} onClick={() => setRouteState((s) => ({ ...s, mode: m.key }))}
                    className={`w-full flex items-center gap-3 p-3 rounded-xl text-sm transition-colors ${routeState.mode === m.key ? "bg-primary text-primary-foreground" : "bg-muted/50 hover:bg-muted"}`}>
                    <Icon className="w-4 h-4" />
                    <div className="text-left">
                      <p className="font-medium">{m.label}</p>
                      <p className="text-[10px] opacity-70">{m.desc}</p>
                    </div>
                  </button>
                );
              })}
            </div>

            <button onClick={handleStart} className="w-full py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity">
              Start Safe Navigation <ArrowRight className="w-4 h-4" />
            </button>
          </div>

          {/* Route Risk Score */}
          <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
            <h3 className="font-display font-semibold text-sm">Route Risk Score</h3>
            <div className="flex items-center gap-3">
              <div className="w-16 h-16 rounded-full bg-safe/10 flex items-center justify-center">
                <span className="text-xl font-bold text-safe">72%</span>
              </div>
              <div>
                <p className="text-sm font-medium">Moderate-Safe</p>
                <p className="text-xs text-muted-foreground">ETA: 18 min · 3.2 km</p>
              </div>
            </div>
            <div className="bg-muted/50 rounded-xl p-3 text-xs text-muted-foreground">
              <p className="font-medium text-foreground mb-1">🤖 AI Insight</p>
              This route avoids 3 high-risk zones and follows well-lit streets. Risk is lowest until 10 PM.
            </div>
          </div>

          {/* Bus-specific info */}
          {transport === "bus" && (
            <div className="bg-card rounded-2xl shadow-card p-5 space-y-3">
              <h3 className="font-display font-semibold text-sm flex items-center gap-2">
                <Bus className="w-4 h-4 text-primary" /> Stop Intelligence
              </h3>
              {mockStopSafety.slice(0, 3).map((s, i) => (
                <div key={i} className="flex items-center justify-between text-xs p-2.5 rounded-lg bg-muted/30">
                  <div className="flex items-center gap-2">
                    <div className={`w-2 h-2 rounded-full ${s.safety >= 80 ? "bg-safe" : s.safety >= 60 ? "bg-warning" : "bg-danger"}`} />
                    <span className="font-medium">{s.stop}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    {s.cctv && <span className="text-[10px] px-1.5 py-0.5 rounded bg-primary/10 text-primary">CCTV</span>}
                    {s.police && <span className="text-[10px] px-1.5 py-0.5 rounded bg-safe/10 text-safe">Police</span>}
                    <span className={`font-medium ${s.safety >= 80 ? "text-safe" : s.safety >= 60 ? "text-warning" : "text-danger"}`}>{s.safety}%</span>
                  </div>
                </div>
              ))}

              <div className="pt-2 border-t border-border space-y-2">
                <p className="text-xs font-medium flex items-center gap-1"><Users className="w-3 h-3" /> Crowd Levels</p>
                {mockCrowdData.slice(0, 3).map((c, i) => (
                  <div key={i} className="flex items-center justify-between text-xs">
                    <span>{c.stop}</span>
                    <span className={`font-medium ${c.level === "high" ? "text-danger" : c.level === "moderate" ? "text-warning" : "text-safe"}`}>{c.percent}%</span>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Map */}
        <div>
          <MapComponent showHeatmap showRoute showPoliceStations height="h-[calc(100vh-8rem)]" />
          {navigating && (
            <div className="mt-3 bg-danger/10 border border-danger/20 rounded-xl p-4 flex items-center justify-between">
              <div>
                <p className="text-sm font-semibold text-danger flex items-center gap-1"><AlertTriangle className="w-4 h-4" /> High Risk Zone Ahead</p>
                <p className="text-xs text-muted-foreground">Consider rerouting via Oak Street</p>
              </div>
              <button className="px-4 py-2 rounded-lg bg-primary text-primary-foreground text-xs font-medium">Reroute</button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default NavigationPage;
