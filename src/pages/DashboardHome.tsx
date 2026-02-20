import { Shield, AlertTriangle, Bell, Route, Bus, Users, Leaf, TrendingUp } from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import { useAppState } from "@/contexts/AppStateContext";
import MapComponent from "@/components/MapComponent";
import { mockBusData, mockCrowdData, mockDelayData, mockGreenData, mockEvents } from "@/data/mockData";
import busIcon from "@/assets/busicon.jpeg";

const DashboardHome = () => {
  const { user } = useAuth();
  const { riskState } = useAppState();

  return (
    <div className="space-y-6 pb-20 lg:pb-0">
      <div className="bg-gradient-primary rounded-2xl p-6 text-primary-foreground">
        <h2 className="font-display font-bold text-xl">Welcome back, {user?.name}! 👋</h2>
        <p className="text-sm opacity-80 mt-1">Here's your safety & transport overview for today.</p>
      </div>

      {/* Stats */}
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <StatCard icon={<Shield />} label="Today's Safety Score" value={`${riskState.todaySafetyScore}%`} color="safe" />
        <StatCard icon={<AlertTriangle />} label="Nearby High Risk Areas" value={String(riskState.nearbyHighRiskAreas)} color="danger" />
        <StatCard icon={<Bell />} label="Recent Alerts" value={String(riskState.recentAlerts)} color="warning" />
        <StatCard icon={<Route />} label="Trips This Week" value={String(riskState.tripsThisWeek)} color="primary" />
      </div>

      {/* Map + charts */}
      <div className="grid lg:grid-cols-2 gap-4">
        <div>
          <h3 className="font-display font-semibold text-sm mb-3">Area Overview</h3>
          <MapComponent showHeatmap showRoute height="h-72" />
        </div>
        <ChartPlaceholder title="Risk Trend (7 Days)" />
      </div>

      {/* TN MTC Bus Intelligence */}
      <div>
        <h3 className="font-display font-semibold text-sm mb-3 flex items-center gap-2">
          <Bus className="w-4 h-4 text-primary" /> TN MTC Bus Intelligence
        </h3>
        <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
          <div className="bg-card rounded-2xl shadow-card p-5 relative overflow-hidden">
            <img src={busIcon} alt="Bus" className="absolute top-2 right-2 w-16 h-16 rounded-xl object-cover opacity-80" />
            <p className="text-xs text-muted-foreground mb-1">Next Bus</p>
            <p className="text-lg font-bold">{mockBusData.nextBus.route}</p>
            <p className="text-xs text-muted-foreground">{mockBusData.nextBus.type} · ETA: {mockBusData.nextBus.eta}</p>
            <p className="text-[10px] text-muted-foreground mt-1">{mockBusData.nextBus.from} → {mockBusData.nextBus.to}</p>
          </div>

          <StatCard icon={<Users />} label="Crowd at Nearest Stop" value={`${mockCrowdData[0].percent}%`} color={mockCrowdData[0].level === "high" ? "danger" : "warning"} />
          <StatCard icon={<TrendingUp />} label="Delay Risk (Route 21G)" value={`${mockDelayData[0].probability}%`} color="warning" />
        </div>
      </div>

      {/* Event alerts */}
      {mockEvents.length > 0 && (
        <div className="bg-warning/5 border border-warning/20 rounded-2xl p-4">
          <h3 className="font-display font-semibold text-sm mb-2 flex items-center gap-2">🎪 Active Events</h3>
          <div className="space-y-2">
            {mockEvents.map((e) => (
              <div key={e.id} className="flex items-center justify-between text-sm">
                <div>
                  <span className="font-medium">{e.name}</span>
                  <span className="text-xs text-muted-foreground ml-2">{e.area} · {e.date}</span>
                </div>
                <span className={`text-xs px-2 py-0.5 rounded-full ${e.impact === "high" ? "bg-danger/10 text-danger" : "bg-warning/10 text-warning"}`}>
                  {e.congestion}% congestion
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="grid lg:grid-cols-3 gap-4">
        <div className="lg:col-span-2">
          <ChartPlaceholder title="Crime Density by Area" height="h-64" />
        </div>
        <div className="bg-card rounded-2xl shadow-card p-5">
          <h3 className="font-display font-semibold text-sm mb-4">Community Activity</h3>
          <div className="space-y-3">
            {["Overcrowding reported on Bus 21G", "Suspicious activity near T. Nagar", "Street light outage at Guindy stop", "Bus delay at Tambaram resolved"].map((a, i) => (
              <div key={i} className="flex items-start gap-3 text-xs">
                <div className="w-2 h-2 rounded-full bg-primary mt-1.5 flex-shrink-0" />
                <span className="text-muted-foreground">{a}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Green Mobility */}
      <div className="bg-safe/5 border border-safe/20 rounded-2xl p-5">
        <h3 className="font-display font-semibold text-sm mb-3 flex items-center gap-2">
          <Leaf className="w-4 h-4 text-safe" /> Green Mobility Impact
        </h3>
        <div className="grid sm:grid-cols-4 gap-4">
          <MiniStat label="CO₂ Saved" value={`${mockGreenData.co2Saved} kg`} />
          <MiniStat label="Fuel Saved" value={`${mockGreenData.fuelSaved} L`} />
          <MiniStat label="Public Transport Trips" value={String(mockGreenData.publicTransportTrips)} />
          <MiniStat label="Trees Equivalent" value={String(mockGreenData.treesEquivalent)} />
        </div>
      </div>
    </div>
  );
};

const MiniStat = ({ label, value }: { label: string; value: string }) => (
  <div className="text-center">
    <p className="text-xl font-bold text-safe">{value}</p>
    <p className="text-[10px] text-muted-foreground">{label}</p>
  </div>
);

const StatCard = ({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: string; color: string }) => (
  <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
    <div className={`w-11 h-11 rounded-xl flex items-center justify-center [&>svg]:w-5 [&>svg]:h-5 ${
      color === "safe" ? "bg-safe/10 text-safe" :
      color === "danger" ? "bg-danger/10 text-danger" :
      color === "warning" ? "bg-warning/10 text-warning" :
      "bg-primary/10 text-primary"
    }`}>{icon}</div>
    <div>
      <p className="text-2xl font-bold">{value}</p>
      <p className="text-xs text-muted-foreground">{label}</p>
    </div>
  </div>
);

const ChartPlaceholder = ({ title, height = "h-48" }: { title: string; height?: string }) => (
  <div className="bg-card rounded-2xl shadow-card p-5">
    <h3 className="font-display font-semibold text-sm mb-4">{title}</h3>
    <div className={`${height} rounded-xl bg-muted/50 flex items-center justify-center`}>
      <div className="flex items-end gap-1.5">
        {[40, 65, 45, 80, 55, 70, 90, 60, 75, 50].map((h, i) => (
          <div key={i} className="w-4 rounded-t bg-primary/30" style={{ height: `${h}%` }} />
        ))}
      </div>
    </div>
  </div>
);

export default DashboardHome;
