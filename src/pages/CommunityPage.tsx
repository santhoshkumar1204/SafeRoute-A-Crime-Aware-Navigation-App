import { useState } from "react";
import { AlertTriangle, Users, Filter, EyeOff } from "lucide-react";
import { mockCommunityReports } from "@/data/mockData";

const categories = ["All", "Overcrowding", "Harassment", "Delay", "Infrastructure", "Suspicious Activity", "Theft"];

const CommunityPage = () => {
  const [filter, setFilter] = useState("All");
  const filtered = filter === "All" ? mockCommunityReports : mockCommunityReports.filter((r) => r.category === filter);

  return (
    <div className="space-y-6 pb-20 lg:pb-0">
      <div className="bg-card rounded-2xl shadow-card p-5">
        <div className="flex items-center gap-2 mb-4">
          <Filter className="w-4 h-4 text-muted-foreground" />
          <h3 className="font-display font-semibold text-sm">Filter by Category</h3>
        </div>
        <div className="flex flex-wrap gap-2">
          {categories.map((c) => (
            <button key={c} onClick={() => setFilter(c)}
              className={`px-3 py-1.5 rounded-lg text-xs font-medium transition-colors ${filter === c ? "bg-primary text-primary-foreground" : "bg-muted hover:bg-muted/80 text-muted-foreground"}`}>
              {c}
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-3">
        <h3 className="font-display font-semibold text-sm flex items-center gap-2">
          <Users className="w-4 h-4" /> Community Reports ({filtered.length})
        </h3>
        {filtered.map((r) => (
          <div key={r.id} className="bg-card rounded-2xl shadow-card p-4 flex gap-4">
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 ${
              r.severity >= 4 ? "bg-danger/10 text-danger" : r.severity >= 3 ? "bg-warning/10 text-warning" : "bg-primary/10 text-primary"
            }`}>
              <AlertTriangle className="w-5 h-5" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-1 flex-wrap">
                <span className={`text-xs font-semibold px-2 py-0.5 rounded-full ${
                  r.severity >= 4 ? "bg-danger/10 text-danger" : r.severity >= 3 ? "bg-warning/10 text-warning" : "bg-primary/10 text-primary"
                }`}>{r.category}</span>
                <span className="text-[10px] text-muted-foreground">{r.time}</span>
                <span className="text-[10px] text-muted-foreground flex items-center gap-0.5"><EyeOff className="w-3 h-3" /> Anon</span>
              </div>
              <p className="text-sm text-muted-foreground">{r.desc}</p>
              <div className="flex gap-1 mt-1.5">
                {Array.from({ length: 5 }).map((_, i) => (
                  <div key={i} className={`w-4 h-1.5 rounded-full ${i < r.severity ? "bg-danger" : "bg-muted"}`} />
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default CommunityPage;
