import { Shield, TrendingUp, MapPin, BarChart3, Bus, Users, Clock } from "lucide-react";
import { mockCrowdData, mockDelayData, mockCrimeData } from "@/data/mockData";

const AnalyticsPage = () => (
  <div className="space-y-6 pb-20 lg:pb-0">
    <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
      <StatCard icon={<Shield />} label="Avg Trip Safety" value="91%" color="safe" />
      <StatCard icon={<TrendingUp />} label="Monthly Risk Exposure" value="Low" color="primary" />
      <StatCard icon={<MapPin />} label="Areas Analyzed" value="47" color="warning" />
      <StatCard icon={<BarChart3 />} label="Safety Improvement" value="+12%" color="safe" />
    </div>

    {/* Crime Analytics */}
    <h3 className="font-display font-semibold text-sm flex items-center gap-2">🔍 Crime Analytics</h3>
    <div className="grid lg:grid-cols-2 gap-4">
      <ChartPlaceholder title="Risk Trends (30 Days)" height="h-64" />
      <ChartPlaceholder title="Time-Based Crime Patterns" height="h-64" />
    </div>

    <div className="bg-card rounded-2xl shadow-card p-5">
      <h3 className="font-display font-semibold text-sm mb-4">Hotspot Clusters</h3>
      <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-3">
        {mockCrimeData.map((c, i) => (
          <div key={i} className="p-3 rounded-xl bg-muted/30 flex items-center justify-between">
            <div>
              <p className="text-sm font-medium">{c.area}</p>
              <p className="text-[10px] text-muted-foreground">{c.incidents} incidents</p>
            </div>
            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${
              c.riskLevel === "high" ? "bg-danger/10 text-danger" : c.riskLevel === "moderate" ? "bg-warning/10 text-warning" : "bg-safe/10 text-safe"
            }`}>{c.trend === "up" ? "↑" : c.trend === "down" ? "↓" : "→"} {c.riskLevel}</span>
          </div>
        ))}
      </div>
    </div>

    {/* Transport Analytics */}
    <h3 className="font-display font-semibold text-sm flex items-center gap-2">
      <Bus className="w-4 h-4 text-primary" /> Transport Analytics
    </h3>
    <div className="grid lg:grid-cols-2 gap-4">
      <ChartPlaceholder title="Bus Punctuality Trends" height="h-56" />
      <ChartPlaceholder title="Peak Hour Congestion" height="h-56" />
    </div>

    <div className="grid lg:grid-cols-2 gap-4">
      <div className="bg-card rounded-2xl shadow-card p-5">
        <h3 className="font-display font-semibold text-sm mb-3 flex items-center gap-2">
          <Users className="w-4 h-4" /> Crowd Heatmap by Stop
        </h3>
        <div className="space-y-2">
          {mockCrowdData.map((c, i) => (
            <div key={i} className="flex items-center gap-3">
              <span className="text-xs w-24 flex-shrink-0">{c.stop}</span>
              <div className="flex-1 h-4 bg-muted/50 rounded-full overflow-hidden">
                <div className={`h-full rounded-full ${c.level === "high" ? "bg-danger" : c.level === "moderate" ? "bg-warning" : "bg-safe"}`} style={{ width: `${c.percent}%` }} />
              </div>
              <span className="text-xs font-medium w-10 text-right">{c.percent}%</span>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-card rounded-2xl shadow-card p-5">
        <h3 className="font-display font-semibold text-sm mb-3 flex items-center gap-2">
          <Clock className="w-4 h-4" /> Route Delay Ranking
        </h3>
        <div className="space-y-2">
          {mockDelayData.map((d, i) => (
            <div key={i} className="p-3 rounded-xl bg-muted/30">
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm font-medium">{d.route}</span>
                <span className={`text-xs font-medium ${d.probability >= 60 ? "text-danger" : d.probability >= 30 ? "text-warning" : "text-safe"}`}>{d.probability}% delay</span>
              </div>
              <p className="text-[10px] text-muted-foreground">{d.reason}</p>
            </div>
          ))}
        </div>
      </div>
    </div>

    {/* Risk History */}
    <div className="bg-card rounded-2xl shadow-card p-5">
      <h3 className="font-display font-semibold text-sm mb-4">Risk History</h3>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead><tr className="text-left text-muted-foreground border-b border-border">
            <th className="pb-2">Date</th><th className="pb-2">Route</th><th className="pb-2">Risk Score</th><th className="pb-2">Level</th>
          </tr></thead>
          <tbody className="divide-y divide-border">
            {[
              { date: "Feb 20", route: "Tambaram → Broadway (21G)", score: "23%", level: "Low" },
              { date: "Feb 19", route: "T. Nagar → Guindy (27C)", score: "41%", level: "Moderate" },
              { date: "Feb 18", route: "Home → Anna Nagar", score: "18%", level: "Low" },
              { date: "Feb 17", route: "Egmore → Downtown", score: "67%", level: "High" },
            ].map((r, i) => (
              <tr key={i}>
                <td className="py-2">{r.date}</td>
                <td className="py-2 text-muted-foreground">{r.route}</td>
                <td className="py-2 font-medium">{r.score}</td>
                <td className="py-2"><span className={`text-xs px-2 py-0.5 rounded-full ${r.level === "Low" ? "bg-safe/10 text-safe" : r.level === "Moderate" ? "bg-warning/10 text-warning" : "bg-danger/10 text-danger"}`}>{r.level}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  </div>
);

const StatCard = ({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: string; color: string }) => (
  <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
    <div className={`w-11 h-11 rounded-xl flex items-center justify-center [&>svg]:w-5 [&>svg]:h-5 ${color === "safe" ? "bg-safe/10 text-safe" : color === "warning" ? "bg-warning/10 text-warning" : "bg-primary/10 text-primary"}`}>{icon}</div>
    <div><p className="text-2xl font-bold">{value}</p><p className="text-xs text-muted-foreground">{label}</p></div>
  </div>
);

const ChartPlaceholder = ({ title, height = "h-48" }: { title: string; height?: string }) => (
  <div className="bg-card rounded-2xl shadow-card p-5">
    <h3 className="font-display font-semibold text-sm mb-4">{title}</h3>
    <div className={`${height} rounded-xl bg-muted/50 flex items-center justify-center`}>
      <div className="flex items-end gap-1.5">{[40, 65, 45, 80, 55, 70, 90, 60, 75, 50, 85, 42].map((h, i) => (
        <div key={i} className="w-4 rounded-t bg-primary/30" style={{ height: `${h}%` }} />
      ))}</div>
    </div>
  </div>
);

export default AnalyticsPage;
