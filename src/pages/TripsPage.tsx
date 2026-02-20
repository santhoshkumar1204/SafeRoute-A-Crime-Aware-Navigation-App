import { MapPin, Clock, Shield, Bus } from "lucide-react";
import { mockTrips } from "@/data/mockData";

const TripsPage = () => (
  <div className="space-y-6 pb-20 lg:pb-0">
    <div className="grid sm:grid-cols-3 gap-4">
      <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
        <div className="w-11 h-11 rounded-xl bg-primary/10 text-primary flex items-center justify-center"><Bus className="w-5 h-5" /></div>
        <div><p className="text-2xl font-bold">{mockTrips.length}</p><p className="text-xs text-muted-foreground">Total Trips</p></div>
      </div>
      <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
        <div className="w-11 h-11 rounded-xl bg-safe/10 text-safe flex items-center justify-center"><Shield className="w-5 h-5" /></div>
        <div><p className="text-2xl font-bold">79%</p><p className="text-xs text-muted-foreground">Avg Safety</p></div>
      </div>
      <div className="bg-card rounded-2xl shadow-card p-5 flex items-center gap-4">
        <div className="w-11 h-11 rounded-xl bg-warning/10 text-warning flex items-center justify-center"><Clock className="w-5 h-5" /></div>
        <div><p className="text-2xl font-bold">4.2 km</p><p className="text-xs text-muted-foreground">Avg Distance</p></div>
      </div>
    </div>

    <div className="bg-card rounded-2xl shadow-card p-5">
      <h3 className="font-display font-semibold text-sm mb-4">Recent Trips</h3>
      <div className="space-y-3">
        {mockTrips.map((trip) => (
          <div key={trip.id} className="flex items-center justify-between p-4 rounded-xl bg-muted/30 hover:bg-muted/50 transition-colors">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
                <MapPin className="w-5 h-5" />
              </div>
              <div>
                <p className="text-sm font-medium">{trip.from} → {trip.to}</p>
                <p className="text-[10px] text-muted-foreground">{trip.date} · {trip.mode}</p>
              </div>
            </div>
            <span className={`text-xs px-2.5 py-1 rounded-full font-medium ${
              trip.safety >= 80 ? "bg-safe/10 text-safe" : trip.safety >= 60 ? "bg-warning/10 text-warning" : "bg-danger/10 text-danger"
            }`}>
              {trip.safety}% Safe
            </span>
          </div>
        ))}
      </div>
    </div>
  </div>
);

export default TripsPage;
