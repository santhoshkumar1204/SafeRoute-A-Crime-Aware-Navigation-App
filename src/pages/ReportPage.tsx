import { useState } from "react";
import { MapPin, Camera, Send, Eye, EyeOff, AlertTriangle } from "lucide-react";

const categories = ["Theft", "Assault", "Vandalism", "Harassment", "Suspicious Activity", "Drug Activity", "Overcrowding", "Bus Delay", "Infrastructure Complaint", "Other"];

const dummyReports = [
  { id: 1, category: "Theft", severity: 3, desc: "Bike stolen near the park entrance", time: "15 min ago", anonymous: true },
  { id: 2, category: "Suspicious Activity", severity: 2, desc: "Unknown person loitering near school", time: "1 hr ago", anonymous: false },
  { id: 3, category: "Vandalism", severity: 1, desc: "Graffiti on main street wall", time: "3 hrs ago", anonymous: true },
];

const ReportPage = () => {
  const [category, setCategory] = useState("");
  const [severity, setSeverity] = useState(3);
  const [desc, setDesc] = useState("");
  const [anonymous, setAnonymous] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async () => {
    setSubmitting(true);
    await new Promise((r) => setTimeout(r, 1000));
    setSubmitting(false);
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3000);
    setCategory(""); setDesc(""); setSeverity(3);
  };

  return (
    <div className="space-y-6 pb-20 lg:pb-0">
      <div className="grid lg:grid-cols-2 gap-6">
        {/* Form */}
        <div className="bg-card rounded-2xl shadow-card p-6 space-y-4">
          <h3 className="font-display font-semibold">Report an Incident</h3>

          <div>
            <label className="text-sm font-medium mb-1.5 block">Location</label>
            <div className="relative">
              <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <input placeholder="Auto-detected: Central Park, NY" className="w-full pl-10 pr-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30" />
            </div>
          </div>

          <div>
            <label className="text-sm font-medium mb-1.5 block">Category</label>
            <select value={category} onChange={(e) => setCategory(e.target.value)} className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30">
              <option value="">Select category</option>
              {categories.map((c) => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>

          <div>
            <label className="text-sm font-medium mb-1.5 block">Severity (1-5)</label>
            <div className="flex gap-2">
              {[1, 2, 3, 4, 5].map((s) => (
                <button key={s} onClick={() => setSeverity(s)}
                  className={`w-10 h-10 rounded-xl text-sm font-bold transition-colors ${severity >= s ? "bg-danger text-danger-foreground" : "bg-muted text-muted-foreground"}`}>
                  {s}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-sm font-medium mb-1.5 block">Description</label>
            <textarea value={desc} onChange={(e) => setDesc(e.target.value)} placeholder="Describe the incident..." rows={3} className="w-full px-4 py-3 rounded-xl border border-input bg-background text-sm focus:outline-none focus:ring-2 focus:ring-primary/30 resize-none" />
          </div>

          <div>
            <label className="text-sm font-medium mb-1.5 block">Photo (optional)</label>
            <div className="border-2 border-dashed border-input rounded-xl p-6 text-center cursor-pointer hover:border-primary/30 transition-colors">
              <Camera className="w-8 h-8 text-muted-foreground mx-auto mb-2" />
              <p className="text-xs text-muted-foreground">Click to upload or drag & drop</p>
            </div>
          </div>

          <label className="flex items-center gap-2 text-sm">
            <button onClick={() => setAnonymous(!anonymous)} className={`w-9 h-5 rounded-full relative transition-colors ${anonymous ? "bg-primary" : "bg-muted"}`}>
              <span className={`absolute top-0.5 w-4 h-4 rounded-full bg-card shadow transition-transform ${anonymous ? "left-[18px]" : "left-0.5"}`} />
            </button>
            Report anonymously
          </label>

          {submitted && <div className="bg-safe/10 text-safe text-sm p-3 rounded-xl font-medium">✓ Report submitted successfully!</div>}

          <button onClick={handleSubmit} disabled={submitting}
            className="w-full py-3 rounded-xl bg-gradient-primary text-primary-foreground font-semibold flex items-center justify-center gap-2 hover:opacity-90 transition-opacity disabled:opacity-60">
            {submitting ? <div className="w-5 h-5 border-2 border-primary-foreground border-t-transparent rounded-full animate-spin" /> : <><Send className="w-4 h-4" /> Submit Report</>}
          </button>
        </div>

        {/* Recent Reports */}
        <div className="space-y-4">
          <h3 className="font-display font-semibold">Recent Community Reports</h3>
          {dummyReports.map((r) => (
            <div key={r.id} className="bg-card rounded-2xl shadow-card p-4 flex gap-4">
              <div className="w-10 h-10 rounded-xl bg-danger/10 text-danger flex items-center justify-center flex-shrink-0">
                <AlertTriangle className="w-5 h-5" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 mb-1">
                  <span className="text-xs font-semibold px-2 py-0.5 rounded-full bg-danger/10 text-danger">{r.category}</span>
                  <span className="text-[10px] text-muted-foreground">{r.time}</span>
                  {r.anonymous && <span className="text-[10px] text-muted-foreground flex items-center gap-0.5"><EyeOff className="w-3 h-3" /> Anon</span>}
                </div>
                <p className="text-sm text-muted-foreground">{r.desc}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default ReportPage;
