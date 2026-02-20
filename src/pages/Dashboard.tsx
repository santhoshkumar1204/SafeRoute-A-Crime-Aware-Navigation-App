import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import {
  LayoutDashboard, Navigation, Map, Route, BarChart3, AlertTriangle,
  Users, Phone, Settings, HelpCircle, LogOut, Menu, Shield, Bell,
  TrendingUp, MapPin, Clock, ChevronRight
} from "lucide-react";
import logo from "@/assets/saferoute-logo.png";

const sidebarItems = [
  { icon: <LayoutDashboard />, label: "Dashboard", path: "/dashboard" },
  { icon: <Navigation />, label: "Start Navigation", path: "/dashboard/navigate" },
  { icon: <Map />, label: "Risk Heatmap", path: "/dashboard/heatmap" },
  { icon: <Route />, label: "My Trips", path: "/dashboard/trips" },
  { icon: <BarChart3 />, label: "Safety Analytics", path: "/dashboard/analytics" },
  { icon: <AlertTriangle />, label: "Report Incident", path: "/dashboard/report" },
  { icon: <Users />, label: "Community Alerts", path: "/dashboard/community" },
  { icon: <Phone />, label: "Emergency Center", path: "/dashboard/emergency" },
  { icon: <Settings />, label: "Settings", path: "/dashboard/settings" },
  { icon: <HelpCircle />, label: "Help & Support", path: "/dashboard/help" },
];

const Dashboard = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const location = useLocation();

  return (
    <div className="flex min-h-screen bg-secondary/30">
      {/* Sidebar */}
      <aside className={`fixed lg:sticky top-0 left-0 h-screen z-40 w-64 bg-card border-r border-border flex flex-col transition-transform ${sidebarOpen ? "translate-x-0" : "-translate-x-full"} lg:translate-x-0`}>
        <div className="flex items-center gap-2 p-4 border-b border-border">
          <div className="w-9 h-9 rounded-full bg-gradient-primary p-0.5">
            <img src={logo} alt="SafeRoute" className="w-full h-full rounded-full bg-card object-cover" />
          </div>
          <span className="font-display font-bold text-gradient-primary">SafeRoute</span>
        </div>

        <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
          {sidebarItems.map((item) => (
            <Link
              key={item.path}
              to={item.path}
              onClick={() => setSidebarOpen(false)}
              className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-colors [&>svg]:w-4 [&>svg]:h-4 ${
                location.pathname === item.path
                  ? "bg-primary text-primary-foreground font-medium"
                  : "text-muted-foreground hover:bg-muted"
              }`}
            >
              {item.icon}
              {item.label}
            </Link>
          ))}
        </nav>

        <div className="p-3 border-t border-border">
          <Link to="/" className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm text-muted-foreground hover:bg-muted [&>svg]:w-4 [&>svg]:h-4">
            <LogOut /> Logout
          </Link>
        </div>
      </aside>

      {/* Overlay */}
      {sidebarOpen && <div className="fixed inset-0 bg-foreground/20 z-30 lg:hidden" onClick={() => setSidebarOpen(false)} />}

      {/* Main */}
      <main className="flex-1 min-w-0">
        <header className="sticky top-0 z-20 bg-card/80 backdrop-blur-lg border-b border-border px-4 h-14 flex items-center justify-between">
          <button className="lg:hidden p-2" onClick={() => setSidebarOpen(true)}>
            <Menu className="w-5 h-5" />
          </button>
          <h1 className="font-display font-semibold">Dashboard</h1>
          <div className="flex items-center gap-3">
            <button className="relative p-2 rounded-lg hover:bg-muted">
              <Bell className="w-5 h-5" />
              <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-danger" />
            </button>
            <div className="w-8 h-8 rounded-full bg-gradient-primary text-primary-foreground flex items-center justify-center text-xs font-bold">JD</div>
          </div>
        </header>

        <div className="p-4 md:p-6 space-y-6">
          {/* Stats */}
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <StatCard icon={<Shield />} label="Today's Safety Score" value="87%" color="safe" />
            <StatCard icon={<AlertTriangle />} label="Nearby High Risk Areas" value="3" color="danger" />
            <StatCard icon={<Bell />} label="Recent Alerts" value="5" color="warning" />
            <StatCard icon={<Route />} label="Trips This Week" value="12" color="primary" />
          </div>

          {/* Charts placeholders */}
          <div className="grid lg:grid-cols-2 gap-4">
            <ChartPlaceholder title="Risk Trend (7 Days)" />
            <ChartPlaceholder title="Crime Density by Area" />
          </div>

          <div className="grid lg:grid-cols-3 gap-4">
            <div className="lg:col-span-2">
              <ChartPlaceholder title="Area Safety Comparison" height="h-64" />
            </div>
            <div className="bg-card rounded-2xl shadow-card p-5">
              <h3 className="font-display font-semibold text-sm mb-4">Community Activity</h3>
              <div className="space-y-3">
                {["Suspicious activity reported near Central Park", "New safe zone confirmed downtown", "Emergency resolved at 5th Avenue"].map((a, i) => (
                  <div key={i} className="flex items-start gap-3 text-xs">
                    <div className="w-2 h-2 rounded-full bg-primary mt-1.5 flex-shrink-0" />
                    <span className="text-muted-foreground">{a}</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};

const StatCard = ({ icon, label, value, color }: { icon: React.ReactNode; label: string; value: string; color: string }) => (
  <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
    <div className={`w-11 h-11 rounded-xl flex items-center justify-center [&>svg]:w-5 [&>svg]:h-5 ${
      color === "safe" ? "bg-safe/10 text-safe" :
      color === "danger" ? "bg-danger/10 text-danger" :
      color === "warning" ? "bg-warning/10 text-warning" :
      "bg-primary/10 text-primary"
    }`}>
      {icon}
    </div>
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

export default Dashboard;
