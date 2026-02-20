import { useState } from "react";
import { Link, useLocation, Outlet, useNavigate } from "react-router-dom";
import {
  LayoutDashboard, Navigation, Map, Route, BarChart3, AlertTriangle,
  Users, Phone, Settings, HelpCircle, LogOut, Menu, X, ChevronDown, Bus
} from "lucide-react";
import { useAuth } from "@/contexts/AuthContext";
import NotificationPanel from "@/components/NotificationPanel";
import logo from "@/assets/saferoute-logo.png";

const sidebarItems = [
  { icon: LayoutDashboard, label: "Dashboard", path: "/dashboard" },
  { icon: Navigation, label: "Start Navigation", path: "/navigation" },
  { icon: Map, label: "Risk Heatmap", path: "/heatmap" },
  { icon: Bus, label: "MTC Bus Services", path: "/transport-types" },
  { icon: Route, label: "My Trips", path: "/trips" },
  { icon: BarChart3, label: "Safety Analytics", path: "/analytics" },
  { icon: AlertTriangle, label: "Report Incident", path: "/report" },
  { icon: Users, label: "Community Alerts", path: "/community" },
  { icon: Phone, label: "Emergency Center", path: "/emergency" },
  { icon: Settings, label: "Settings", path: "/settings" },
  { icon: HelpCircle, label: "Help & Support", path: "/help" },
];

const DashboardLayout = () => {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const { user, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  const pageTitle = sidebarItems.find((i) => i.path === location.pathname)?.label || "Dashboard";

  return (
    <div className="flex min-h-screen bg-secondary/30">
      {/* Sidebar */}
      <aside className={`fixed lg:sticky top-0 left-0 h-screen z-40 w-64 bg-card border-r border-border flex flex-col transition-transform ${sidebarOpen ? "translate-x-0" : "-translate-x-full"} lg:translate-x-0`}>
        <div className="flex items-center gap-2 p-4 border-b border-border">
          <div className="w-9 h-9 rounded-full bg-gradient-primary p-0.5">
            <img src={logo} alt="SafeRoute" className="w-full h-full rounded-full bg-card object-cover" />
          </div>
          <span className="font-display font-bold text-gradient-primary">SafeRoute</span>
          <button className="lg:hidden ml-auto p-1" onClick={() => setSidebarOpen(false)}>
            <X className="w-5 h-5" />
          </button>
        </div>

        <nav className="flex-1 p-3 space-y-1 overflow-y-auto">
          {sidebarItems.map((item) => {
            const Icon = item.icon;
            return (
              <Link
                key={item.label}
                to={item.path}
                onClick={() => setSidebarOpen(false)}
                className={`flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm transition-colors ${
                  location.pathname === item.path
                    ? "bg-primary text-primary-foreground font-medium"
                    : "text-muted-foreground hover:bg-muted"
                }`}
              >
                <Icon className="w-4 h-4" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="p-3 border-t border-border">
          <button onClick={handleLogout} className="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm text-muted-foreground hover:bg-muted w-full">
            <LogOut className="w-4 h-4" /> Logout
          </button>
        </div>
      </aside>

      {/* Overlay */}
      {sidebarOpen && <div className="fixed inset-0 bg-foreground/20 z-30 lg:hidden" onClick={() => setSidebarOpen(false)} />}

      {/* Main */}
      <main className="flex-1 min-w-0">
        <header className="sticky top-0 z-20 bg-card/80 backdrop-blur-lg border-b border-border px-4 h-14 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <button className="lg:hidden p-2" onClick={() => setSidebarOpen(true)}>
              <Menu className="w-5 h-5" />
            </button>
            <h1 className="font-display font-semibold">{pageTitle}</h1>
          </div>
          <div className="flex items-center gap-3">
            <NotificationPanel />
            <div className="relative">
              <button onClick={() => setUserMenuOpen(!userMenuOpen)} className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-gradient-primary text-primary-foreground flex items-center justify-center text-xs font-bold">
                  {user?.name?.slice(0, 2).toUpperCase() || "U"}
                </div>
                <span className="hidden sm:inline text-sm font-medium">{user?.name}</span>
                <ChevronDown className="w-3 h-3 text-muted-foreground" />
              </button>
              {userMenuOpen && (
                <>
                  <div className="fixed inset-0 z-40" onClick={() => setUserMenuOpen(false)} />
                  <div className="absolute right-0 top-full mt-2 w-48 bg-card rounded-xl shadow-card-hover border border-border p-2 z-50">
                    <p className="px-3 py-2 text-xs text-muted-foreground">{user?.email}</p>
                    <Link to="/settings" onClick={() => setUserMenuOpen(false)} className="flex items-center gap-2 px-3 py-2 text-sm rounded-lg hover:bg-muted">
                      <Settings className="w-4 h-4" /> Settings
                    </Link>
                    <button onClick={handleLogout} className="flex items-center gap-2 px-3 py-2 text-sm rounded-lg hover:bg-muted w-full text-left text-danger">
                      <LogOut className="w-4 h-4" /> Logout
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </header>

        <div className="p-4 md:p-6">
          <Outlet />
        </div>
      </main>

      {/* Mobile bottom nav */}
      <div className="fixed bottom-0 left-0 right-0 bg-card border-t border-border flex justify-around py-2 lg:hidden z-30">
        {[sidebarItems[0], sidebarItems[1], sidebarItems[2], sidebarItems[4], sidebarItems[7]].map((item) => {
          const Icon = item.icon;
          return (
            <Link key={item.label} to={item.path} className={`flex flex-col items-center gap-0.5 text-[10px] px-2 py-1 ${location.pathname === item.path ? "text-primary" : "text-muted-foreground"}`}>
              <Icon className="w-5 h-5" />
              {item.label.split(" ")[0]}
            </Link>
          );
        })}
      </div>
    </div>
  );
};

export default DashboardLayout;
