class AlertModel {
  final String id;
  final String message;
  final String time;
  final bool read;
  final String type;

  const AlertModel({
    required this.id,
    required this.message,
    required this.time,
    this.read = false,
    this.type = 'primary',
  });
}

class CrimeDataModel {
  final String area;
  final String riskLevel;
  final int incidents;
  final String trend;

  const CrimeDataModel({
    required this.area,
    required this.riskLevel,
    required this.incidents,
    required this.trend,
  });
}

class BusTypeModel {
  final String type;
  final String fare;
  final String desc;
  final String routes;

  const BusTypeModel({
    required this.type,
    required this.fare,
    required this.desc,
    required this.routes,
  });
}

class NextBusModel {
  final String route;
  final String type;
  final String eta;
  final String from;
  final String to;

  const NextBusModel({
    required this.route,
    required this.type,
    required this.eta,
    required this.from,
    required this.to,
  });
}

class CrowdDataModel {
  final String stop;
  final String level;
  final int percent;

  const CrowdDataModel({
    required this.stop,
    required this.level,
    required this.percent,
  });
}

class DelayDataModel {
  final String route;
  final int probability;
  final String reason;

  const DelayDataModel({
    required this.route,
    required this.probability,
    required this.reason,
  });
}

class TripModel {
  final int id;
  final String from;
  final String to;
  final String date;
  final String mode;
  final int safety;
  final String status;

  const TripModel({
    required this.id,
    required this.from,
    required this.to,
    required this.date,
    required this.mode,
    required this.safety,
    this.status = 'completed',
  });
}

class EventModel {
  final int id;
  final String name;
  final String area;
  final String impact;
  final String date;
  final int congestion;

  const EventModel({
    required this.id,
    required this.name,
    required this.area,
    required this.impact,
    required this.date,
    required this.congestion,
  });
}

class CommunityReportModel {
  final int id;
  final String category;
  final String desc;
  final String time;
  final int severity;

  const CommunityReportModel({
    required this.id,
    required this.category,
    required this.desc,
    required this.time,
    required this.severity,
  });
}

class GreenDataModel {
  final int co2Saved;
  final int fuelSaved;
  final int publicTransportTrips;
  final int treesEquivalent;

  const GreenDataModel({
    required this.co2Saved,
    required this.fuelSaved,
    required this.publicTransportTrips,
    required this.treesEquivalent,
  });
}

class StopSafetyModel {
  final String stop;
  final int safety;
  final bool cctv;
  final String lighting;
  final bool police;

  const StopSafetyModel({
    required this.stop,
    required this.safety,
    required this.cctv,
    required this.lighting,
    required this.police,
  });
}

class NotificationModel {
  final String id;
  final String message;
  final String time;
  bool read;

  NotificationModel({
    required this.id,
    required this.message,
    required this.time,
    this.read = false,
  });
}

class RiskHistoryModel {
  final String date;
  final String route;
  final String score;
  final String level;

  const RiskHistoryModel({
    required this.date,
    required this.route,
    required this.score,
    required this.level,
  });
}
