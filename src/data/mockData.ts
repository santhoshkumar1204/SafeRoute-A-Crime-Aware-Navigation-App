export const mockAlerts = [
  { id: "1", message: "⚠️ High Risk Stop Nearby — T. Nagar Bus Stand", time: "2m ago", read: false, type: "danger" },
  { id: "2", message: "🚌 Bus Delay Alert — Route 21C delayed by 15 min", time: "8m ago", read: false, type: "warning" },
  { id: "3", message: "👥 Crowd Surge Warning — Broadway Terminal", time: "20m ago", read: false, type: "warning" },
  { id: "4", message: "🔄 Route Recalculated — Safer path via Anna Salai", time: "35m ago", read: true, type: "primary" },
  { id: "5", message: "🎪 Event Congestion Alert — Marina Beach area", time: "1h ago", read: true, type: "danger" },
];

export const mockCrimeData = [
  { area: "T. Nagar", riskLevel: "high", incidents: 23, trend: "up" },
  { area: "Anna Nagar", riskLevel: "low", incidents: 5, trend: "down" },
  { area: "Guindy", riskLevel: "moderate", incidents: 12, trend: "stable" },
  { area: "Tambaram", riskLevel: "moderate", incidents: 14, trend: "up" },
  { area: "Adyar", riskLevel: "low", incidents: 3, trend: "down" },
  { area: "Egmore", riskLevel: "high", incidents: 19, trend: "stable" },
  { area: "Mylapore", riskLevel: "low", incidents: 6, trend: "down" },
  { area: "Chrompet", riskLevel: "moderate", incidents: 10, trend: "up" },
];

export const mockBusData = {
  nextBus: { route: "21G", type: "Ordinary", eta: "4 min", from: "Tambaram", to: "Broadway" },
  busTypes: [
    { type: "Ordinary", fare: "₹5–₹15", desc: "Stops at all stops. Most frequent.", routes: "1A, 5C, 21G, 27C" },
    { type: "Express", fare: "₹8–₹25", desc: "Limited stops. Faster travel.", routes: "100, 101, 102, 154" },
    { type: "Deluxe/AC", fare: "₹20–₹50", desc: "Air-conditioned comfort rides.", routes: "AC1, AC2, AC3" },
    { type: "Mini Bus", fare: "₹5–₹12", desc: "Feeder routes in narrow streets.", routes: "M1, M5, M12, M18" },
    { type: "Special/Event", fare: "₹10–₹30", desc: "Event & college specials.", routes: "SPL1, SPL2, EVT" },
  ],
};

export const mockCrowdData = [
  { stop: "Broadway", level: "high", percent: 92 },
  { stop: "T. Nagar", level: "high", percent: 87 },
  { stop: "Tambaram", level: "moderate", percent: 65 },
  { stop: "Anna Nagar", level: "low", percent: 30 },
  { stop: "Guindy", level: "moderate", percent: 58 },
  { stop: "Egmore", level: "high", percent: 78 },
];

export const mockDelayData = [
  { route: "21G", probability: 72, reason: "Traffic congestion at Saidapet" },
  { route: "5C", probability: 45, reason: "Road work near Adyar" },
  { route: "27C", probability: 15, reason: "Normal operations" },
  { route: "101 Express", probability: 33, reason: "Signal issues at Guindy" },
];

export const mockTrips = [
  { id: 1, from: "Home", to: "Office", date: "Feb 20", mode: "Bus 21G", safety: 88, status: "completed" },
  { id: 2, from: "Office", to: "T. Nagar", date: "Feb 19", mode: "Bus 27C", safety: 72, status: "completed" },
  { id: 3, from: "Home", to: "Guindy", date: "Feb 18", mode: "Walking + Bus", safety: 65, status: "completed" },
  { id: 4, from: "Anna Nagar", to: "Broadway", date: "Feb 17", mode: "Express 101", safety: 91, status: "completed" },
  { id: 5, from: "Tambaram", to: "Central", date: "Feb 16", mode: "Bus 21G", safety: 79, status: "completed" },
];

export const mockEvents = [
  { id: 1, name: "Marina Beach Festival", area: "Marina", impact: "high", date: "Feb 20", congestion: 85 },
  { id: 2, name: "Cricket Match — Chepauk", area: "Chepauk", impact: "high", date: "Feb 21", congestion: 90 },
  { id: 3, name: "Temple Festival — Mylapore", area: "Mylapore", impact: "moderate", date: "Feb 22", congestion: 60 },
];

export const mockCommunityReports = [
  { id: 1, category: "Overcrowding", desc: "Bus 21G extremely packed at Tambaram", time: "10m ago", severity: 4 },
  { id: 2, category: "Harassment", desc: "Verbal harassment near T. Nagar bus stop", time: "25m ago", severity: 5 },
  { id: 3, category: "Delay", desc: "Route 5C stuck for 30 mins at Adyar", time: "40m ago", severity: 3 },
  { id: 4, category: "Infrastructure", desc: "Street light out near Guindy bus stop", time: "1h ago", severity: 2 },
  { id: 5, category: "Suspicious Activity", desc: "Unknown person loitering near Egmore station", time: "2h ago", severity: 4 },
  { id: 6, category: "Theft", desc: "Phone snatching reported at Broadway", time: "3h ago", severity: 5 },
];

export const mockGreenData = {
  co2Saved: 128,
  fuelSaved: 42,
  publicTransportTrips: 47,
  treesEquivalent: 6,
};

export const mockStopSafety = [
  { stop: "Broadway", safety: 62, cctv: true, lighting: "good", police: true },
  { stop: "T. Nagar", safety: 55, cctv: true, lighting: "moderate", police: false },
  { stop: "Tambaram", safety: 71, cctv: false, lighting: "poor", police: true },
  { stop: "Anna Nagar", safety: 89, cctv: true, lighting: "good", police: true },
  { stop: "Guindy", safety: 68, cctv: true, lighting: "moderate", police: false },
];
