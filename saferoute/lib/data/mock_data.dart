import '../models/data_models.dart';

class MockData {
  MockData._();

  static const List<AlertModel> alerts = [
    AlertModel(id: '1', message: '⚠️ High Risk Stop Nearby — T. Nagar Bus Stand', time: '2m ago', read: false, type: 'danger'),
    AlertModel(id: '2', message: '🚌 Bus Delay Alert — Route 21C delayed by 15 min', time: '8m ago', read: false, type: 'warning'),
    AlertModel(id: '3', message: '👥 Crowd Surge Warning — Broadway Terminal', time: '20m ago', read: false, type: 'warning'),
    AlertModel(id: '4', message: '🔄 Route Recalculated — Safer path via Anna Salai', time: '35m ago', read: true, type: 'primary'),
    AlertModel(id: '5', message: '🎪 Event Congestion Alert — Marina Beach area', time: '1h ago', read: true, type: 'danger'),
  ];

  static const List<CrimeDataModel> crimeData = [
    CrimeDataModel(area: 'T. Nagar', riskLevel: 'high', incidents: 23, trend: 'up'),
    CrimeDataModel(area: 'Anna Nagar', riskLevel: 'low', incidents: 5, trend: 'down'),
    CrimeDataModel(area: 'Guindy', riskLevel: 'moderate', incidents: 12, trend: 'stable'),
    CrimeDataModel(area: 'Tambaram', riskLevel: 'moderate', incidents: 14, trend: 'up'),
    CrimeDataModel(area: 'Adyar', riskLevel: 'low', incidents: 3, trend: 'down'),
    CrimeDataModel(area: 'Egmore', riskLevel: 'high', incidents: 19, trend: 'stable'),
    CrimeDataModel(area: 'Mylapore', riskLevel: 'low', incidents: 6, trend: 'down'),
    CrimeDataModel(area: 'Chrompet', riskLevel: 'moderate', incidents: 10, trend: 'up'),
  ];

  static const NextBusModel nextBus = NextBusModel(
    route: '21G',
    type: 'Ordinary',
    eta: '4 min',
    from: 'Tambaram',
    to: 'Broadway',
  );

  static const List<BusTypeModel> busTypes = [
    BusTypeModel(type: 'Ordinary', fare: '₹5–₹15', desc: 'Stops at all stops. Most frequent.', routes: '1A, 5C, 21G, 27C'),
    BusTypeModel(type: 'Express', fare: '₹8–₹25', desc: 'Limited stops. Faster travel.', routes: '100, 101, 102, 154'),
    BusTypeModel(type: 'Deluxe/AC', fare: '₹20–₹50', desc: 'Air-conditioned comfort rides.', routes: 'AC1, AC2, AC3'),
    BusTypeModel(type: 'Mini Bus', fare: '₹5–₹12', desc: 'Feeder routes in narrow streets.', routes: 'M1, M5, M12, M18'),
    BusTypeModel(type: 'Special/Event', fare: '₹10–₹30', desc: 'Event & college specials.', routes: 'SPL1, SPL2, EVT'),
  ];

  static const List<CrowdDataModel> crowdData = [
    CrowdDataModel(stop: 'Broadway', level: 'high', percent: 92),
    CrowdDataModel(stop: 'T. Nagar', level: 'high', percent: 87),
    CrowdDataModel(stop: 'Tambaram', level: 'moderate', percent: 65),
    CrowdDataModel(stop: 'Anna Nagar', level: 'low', percent: 30),
    CrowdDataModel(stop: 'Guindy', level: 'moderate', percent: 58),
    CrowdDataModel(stop: 'Egmore', level: 'high', percent: 78),
  ];

  static const List<DelayDataModel> delayData = [
    DelayDataModel(route: '21G', probability: 72, reason: 'Traffic congestion at Saidapet'),
    DelayDataModel(route: '5C', probability: 45, reason: 'Road work near Adyar'),
    DelayDataModel(route: '27C', probability: 15, reason: 'Normal operations'),
    DelayDataModel(route: '101 Express', probability: 33, reason: 'Signal issues at Guindy'),
  ];

  static const List<TripModel> trips = [
    TripModel(id: 1, from: 'Home', to: 'Office', date: 'Feb 20', mode: 'Bus 21G', safety: 88),
    TripModel(id: 2, from: 'Office', to: 'T. Nagar', date: 'Feb 19', mode: 'Bus 27C', safety: 72),
    TripModel(id: 3, from: 'Home', to: 'Guindy', date: 'Feb 18', mode: 'Walking + Bus', safety: 65),
    TripModel(id: 4, from: 'Anna Nagar', to: 'Broadway', date: 'Feb 17', mode: 'Express 101', safety: 91),
    TripModel(id: 5, from: 'Tambaram', to: 'Central', date: 'Feb 16', mode: 'Bus 21G', safety: 79),
  ];

  static const List<EventModel> events = [
    EventModel(id: 1, name: 'Marina Beach Festival', area: 'Marina', impact: 'high', date: 'Feb 20', congestion: 85),
    EventModel(id: 2, name: 'Cricket Match — Chepauk', area: 'Chepauk', impact: 'high', date: 'Feb 21', congestion: 90),
    EventModel(id: 3, name: 'Temple Festival — Mylapore', area: 'Mylapore', impact: 'moderate', date: 'Feb 22', congestion: 60),
  ];

  static const List<CommunityReportModel> communityReports = [
    CommunityReportModel(id: 1, category: 'Overcrowding', desc: 'Bus 21G extremely packed at Tambaram', time: '10m ago', severity: 4),
    CommunityReportModel(id: 2, category: 'Harassment', desc: 'Verbal harassment near T. Nagar bus stop', time: '25m ago', severity: 5),
    CommunityReportModel(id: 3, category: 'Delay', desc: 'Route 5C stuck for 30 mins at Adyar', time: '40m ago', severity: 3),
    CommunityReportModel(id: 4, category: 'Infrastructure', desc: 'Street light out near Guindy bus stop', time: '1h ago', severity: 2),
    CommunityReportModel(id: 5, category: 'Suspicious Activity', desc: 'Unknown person loitering near Egmore station', time: '2h ago', severity: 4),
    CommunityReportModel(id: 6, category: 'Theft', desc: 'Phone snatching reported at Broadway', time: '3h ago', severity: 5),
  ];

  static const GreenDataModel greenData = GreenDataModel(
    co2Saved: 128,
    fuelSaved: 42,
    publicTransportTrips: 47,
    treesEquivalent: 6,
  );

  static const List<StopSafetyModel> stopSafety = [
    StopSafetyModel(stop: 'Broadway', safety: 62, cctv: true, lighting: 'good', police: true),
    StopSafetyModel(stop: 'T. Nagar', safety: 55, cctv: true, lighting: 'moderate', police: false),
    StopSafetyModel(stop: 'Tambaram', safety: 71, cctv: false, lighting: 'poor', police: true),
    StopSafetyModel(stop: 'Anna Nagar', safety: 89, cctv: true, lighting: 'good', police: true),
    StopSafetyModel(stop: 'Guindy', safety: 68, cctv: true, lighting: 'moderate', police: false),
  ];

  static List<NotificationModel> notifications = [
    NotificationModel(id: '1', message: 'High risk alert near Central Park', time: '2m ago', read: false),
    NotificationModel(id: '2', message: 'New safe zone confirmed downtown', time: '15m ago', read: false),
    NotificationModel(id: '3', message: 'Weekly safety report ready', time: '1h ago', read: true),
  ];

  static const List<RiskHistoryModel> riskHistory = [
    RiskHistoryModel(date: 'Feb 20', route: 'Tambaram → Broadway (21G)', score: '23%', level: 'Low'),
    RiskHistoryModel(date: 'Feb 19', route: 'T. Nagar → Guindy (27C)', score: '41%', level: 'Moderate'),
    RiskHistoryModel(date: 'Feb 18', route: 'Home → Anna Nagar', score: '18%', level: 'Low'),
    RiskHistoryModel(date: 'Feb 17', route: 'Egmore → Downtown', score: '67%', level: 'High'),
  ];

  static const List<String> reportCategories = [
    'Theft', 'Assault', 'Vandalism', 'Harassment', 'Suspicious Activity',
    'Drug Activity', 'Overcrowding', 'Bus Delay', 'Infrastructure Complaint', 'Other',
  ];

  static const List<String> communityFilterCategories = [
    'All', 'Overcrowding', 'Harassment', 'Delay', 'Infrastructure', 'Suspicious Activity', 'Theft',
  ];
}
