import { useState } from "react";
import { useAuth } from "@/contexts/AuthContext";
import { User, Bell, MapPin, Lock, Moon, Globe } from "lucide-react";

const SettingsPage = () => {
  const { user } = useAuth();
  const [darkMode, setDarkMode] = useState(false);
  const [notifs, setNotifs] = useState({ alerts: true, reports: true, updates: false });

  const toggleDark = () => {
    setDarkMode(!darkMode);
    document.documentElement.classList.toggle("dark");
  };

  return (
    <div className="space-y-6 max-w-2xl pb-20 lg:pb-0">
      {/* Profile */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-4">
        <h3 className="font-display font-semibold flex items-center gap-2"><User className="w-4 h-4" /> Profile</h3>
        <div className="grid sm:grid-cols-2 gap-4">
          <div><label className="text-sm font-medium mb-1 block">Name</label><input defaultValue={user?.name} className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" /></div>
          <div><label className="text-sm font-medium mb-1 block">Email</label><input defaultValue={user?.email} className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" /></div>
        </div>
        <button className="px-6 py-2.5 rounded-xl bg-gradient-primary text-primary-foreground text-sm font-semibold hover:opacity-90 transition-opacity">Save Changes</button>
      </div>

      {/* Notifications */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-4">
        <h3 className="font-display font-semibold flex items-center gap-2"><Bell className="w-4 h-4" /> Notifications</h3>
        <Toggle label="Crime Alerts" active={notifs.alerts} onToggle={() => setNotifs({ ...notifs, alerts: !notifs.alerts })} />
        <Toggle label="Community Reports" active={notifs.reports} onToggle={() => setNotifs({ ...notifs, reports: !notifs.reports })} />
        <Toggle label="Product Updates" active={notifs.updates} onToggle={() => setNotifs({ ...notifs, updates: !notifs.updates })} />
      </div>

      {/* Location */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-3">
        <h3 className="font-display font-semibold flex items-center gap-2"><MapPin className="w-4 h-4" /> Location</h3>
        <p className="text-sm text-muted-foreground">Location access is required for navigation and safety features.</p>
        <button className="px-5 py-2.5 rounded-xl bg-primary/10 text-primary text-sm font-medium">Grant Location Permission</button>
      </div>

      {/* Privacy */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-3">
        <h3 className="font-display font-semibold flex items-center gap-2"><Lock className="w-4 h-4" /> Privacy</h3>
        <Toggle label="Share location with emergency contacts" active={true} onToggle={() => {}} />
        <Toggle label="Anonymous reporting by default" active={false} onToggle={() => {}} />
      </div>

      {/* Appearance */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-3">
        <h3 className="font-display font-semibold flex items-center gap-2"><Moon className="w-4 h-4" /> Appearance</h3>
        <Toggle label="Dark Mode" active={darkMode} onToggle={toggleDark} />
      </div>

      {/* Language */}
      <div className="bg-card rounded-2xl shadow-card p-6 space-y-3">
        <h3 className="font-display font-semibold flex items-center gap-2"><Globe className="w-4 h-4" /> Language</h3>
        <select className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
          <option>English</option><option>Spanish</option><option>French</option><option>Hindi</option>
        </select>
      </div>
    </div>
  );
};

const Toggle = ({ label, active, onToggle }: { label: string; active: boolean; onToggle: () => void }) => (
  <button onClick={onToggle} className="flex items-center justify-between w-full text-sm">
    <span>{label}</span>
    <span className={`w-9 h-5 rounded-full relative transition-colors ${active ? "bg-primary" : "bg-muted"}`}>
      <span className={`absolute top-0.5 w-4 h-4 rounded-full bg-card shadow transition-transform ${active ? "left-[18px]" : "left-0.5"}`} />
    </span>
  </button>
);

export default SettingsPage;
