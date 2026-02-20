import { Phone, MapPin, Share2, Shield, Navigation } from "lucide-react";

const EmergencyPage = () => (
  <div className="space-y-6 pb-20 lg:pb-0">
    {/* SOS Button */}
    <div className="bg-danger/5 border-2 border-danger/20 rounded-2xl p-8 text-center">
      <button className="w-32 h-32 rounded-full bg-danger text-danger-foreground mx-auto flex items-center justify-center hover:bg-danger/90 transition-colors shadow-lg glow-primary">
        <div className="text-center">
          <Phone className="w-10 h-10 mx-auto mb-1" />
          <span className="text-sm font-bold">SOS</span>
        </div>
      </button>
      <p className="text-sm text-muted-foreground mt-4">Tap to alert emergency services instantly</p>
    </div>

    <div className="grid sm:grid-cols-2 gap-4">
      <button className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4 hover:shadow-card-hover transition-shadow text-left w-full">
        <div className="w-11 h-11 rounded-xl bg-primary/10 text-primary flex items-center justify-center"><Share2 className="w-5 h-5" /></div>
        <div><p className="font-semibold text-sm">Share Live Location</p><p className="text-xs text-muted-foreground">Send your real-time location to contacts</p></div>
      </button>
      <button className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4 hover:shadow-card-hover transition-shadow text-left w-full">
        <div className="w-11 h-11 rounded-xl bg-safe/10 text-safe flex items-center justify-center"><Shield className="w-5 h-5" /></div>
        <div><p className="font-semibold text-sm">Safe Zone Nearby</p><p className="text-xs text-muted-foreground">Navigate to nearest safe zone</p></div>
      </button>
    </div>

    <div className="grid lg:grid-cols-2 gap-6">
      {/* Nearby Police */}
      <div className="bg-card rounded-2xl shadow-card p-5">
        <h3 className="font-display font-semibold text-sm mb-4">Nearby Police Stations</h3>
        <div className="space-y-3">
          {[
            { name: "Central Police Station", dist: "0.8 km", phone: "911" },
            { name: "Downtown Precinct", dist: "1.2 km", phone: "911" },
            { name: "North District HQ", dist: "2.1 km", phone: "911" },
          ].map((s, i) => (
            <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-muted/50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-primary/10 text-primary flex items-center justify-center"><Navigation className="w-4 h-4" /></div>
                <div><p className="text-sm font-medium">{s.name}</p><p className="text-[10px] text-muted-foreground">{s.dist} away</p></div>
              </div>
              <button className="text-xs px-3 py-1.5 rounded-lg bg-primary text-primary-foreground font-medium">Call</button>
            </div>
          ))}
        </div>
      </div>

      {/* Nearby Hospitals */}
      <div className="bg-card rounded-2xl shadow-card p-5">
        <h3 className="font-display font-semibold text-sm mb-4">Nearby Hospitals</h3>
        <div className="space-y-3">
          {[
            { name: "City General Hospital", dist: "0.5 km", phone: "555-0100" },
            { name: "St. Mary's Medical", dist: "1.4 km", phone: "555-0200" },
            { name: "Emergency Care Clinic", dist: "1.8 km", phone: "555-0300" },
          ].map((h, i) => (
            <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-muted/50">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-lg bg-danger/10 text-danger flex items-center justify-center"><MapPin className="w-4 h-4" /></div>
                <div><p className="text-sm font-medium">{h.name}</p><p className="text-[10px] text-muted-foreground">{h.dist} away</p></div>
              </div>
              <button className="text-xs px-3 py-1.5 rounded-lg bg-danger text-danger-foreground font-medium">Call</button>
            </div>
          ))}
        </div>
      </div>
    </div>

    {/* Emergency Contacts */}
    <div className="bg-card rounded-2xl shadow-card p-5">
      <h3 className="font-display font-semibold text-sm mb-4">Emergency Contacts</h3>
      <div className="grid sm:grid-cols-2 gap-3">
        {[
          { name: "Emergency Services", number: "911" },
          { name: "Mom", number: "+1 555-1234" },
          { name: "Dad", number: "+1 555-5678" },
          { name: "Best Friend", number: "+1 555-9012" },
        ].map((c, i) => (
          <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-muted/50">
            <div><p className="text-sm font-medium">{c.name}</p><p className="text-xs text-muted-foreground">{c.number}</p></div>
            <button className="w-8 h-8 rounded-lg bg-safe/10 text-safe flex items-center justify-center"><Phone className="w-4 h-4" /></button>
          </div>
        ))}
      </div>
    </div>
  </div>
);

export default EmergencyPage;
