import 'package:cloud_firestore/cloud_firestore.dart';

/// ─── UserModel (Firestore-aware) ───────────────────────────────────────────
class FirestoreUser {
  final String uid;
  final String name;
  final String email;
  final String? profilePhoto;
  final String role;
  final DateTime createdAt;
  final DateTime lastLogin;

  const FirestoreUser({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePhoto,
    this.role = 'User',
    required this.createdAt,
    required this.lastLogin,
  });

  factory FirestoreUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FirestoreUser(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      profilePhoto: data['profilePhoto'] as String?,
      role: data['role'] as String? ?? 'User',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'profilePhoto': profilePhoto,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
        'lastLogin': Timestamp.fromDate(lastLogin),
      };

  FirestoreUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePhoto,
    String? role,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// ─── TripModel (Firestore) ─────────────────────────────────────────────────
class FirestoreTrip {
  final String id;
  final String userId;
  final String source;
  final String destination;
  final String transportType;
  final int riskScore;
  final double sustainabilityScore;
  final DateTime timestamp;
  final String status;

  const FirestoreTrip({
    required this.id,
    required this.userId,
    required this.source,
    required this.destination,
    required this.transportType,
    required this.riskScore,
    this.sustainabilityScore = 0.0,
    required this.timestamp,
    this.status = 'completed',
  });

  factory FirestoreTrip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FirestoreTrip(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      source: data['source'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      transportType: data['transportType'] as String? ?? '',
      riskScore: (data['riskScore'] as num?)?.toInt() ?? 0,
      sustainabilityScore: (data['sustainabilityScore'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'completed',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'source': source,
        'destination': destination,
        'transportType': transportType,
        'riskScore': riskScore,
        'sustainabilityScore': sustainabilityScore,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': status,
      };
}

/// ─── ReportModel (Firestore) ───────────────────────────────────────────────
class FirestoreReport {
  final String id;
  final String userId;
  final String category;
  final String description;
  final String location;
  final DateTime timestamp;
  final String status;
  final int severity;

  const FirestoreReport({
    required this.id,
    required this.userId,
    required this.category,
    required this.description,
    this.location = '',
    required this.timestamp,
    this.status = 'pending',
    this.severity = 1,
  });

  factory FirestoreReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FirestoreReport(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      severity: (data['severity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'category': category,
        'description': description,
        'location': location,
        'timestamp': Timestamp.fromDate(timestamp),
        'status': status,
        'severity': severity,
      };
}

/// ─── AlertModel (Firestore) ────────────────────────────────────────────────
class FirestoreAlert {
  final String id;
  final String type;
  final String message;
  final String area;
  final DateTime timestamp;
  final String severity;
  final bool read;

  const FirestoreAlert({
    required this.id,
    required this.type,
    required this.message,
    this.area = '',
    required this.timestamp,
    this.severity = 'warning',
    this.read = false,
  });

  factory FirestoreAlert.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FirestoreAlert(
      id: doc.id,
      type: data['type'] as String? ?? 'primary',
      message: data['message'] as String? ?? '',
      area: data['area'] as String? ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      severity: data['severity'] as String? ?? 'warning',
      read: data['read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type,
        'message': message,
        'area': area,
        'timestamp': Timestamp.fromDate(timestamp),
        'severity': severity,
        'read': read,
      };
}

/// ─── AnalyticsModel (Firestore) ────────────────────────────────────────────
class FirestoreAnalytics {
  final int totalTrips;
  final int totalReports;
  final List<String> highRiskAreas;
  final Map<String, int> busUsageStats;

  const FirestoreAnalytics({
    this.totalTrips = 0,
    this.totalReports = 0,
    this.highRiskAreas = const [],
    this.busUsageStats = const {},
  });

  factory FirestoreAnalytics.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirestoreAnalytics(
      totalTrips: (data['totalTrips'] as num?)?.toInt() ?? 0,
      totalReports: (data['totalReports'] as num?)?.toInt() ?? 0,
      highRiskAreas: List<String>.from(data['highRiskAreas'] ?? []),
      busUsageStats: Map<String, int>.from(
        (data['busUsageStats'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, (v as num).toInt()),
            ) ??
            {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'totalTrips': totalTrips,
        'totalReports': totalReports,
        'highRiskAreas': highRiskAreas,
        'busUsageStats': busUsageStats,
      };
}

/// ─── SustainabilityModel (Firestore) ───────────────────────────────────────
class FirestoreSustainability {
  final String userId;
  final double totalCO2Saved;
  final int busTripsCount;
  final int fuelSavedLiters;
  final int treesEquivalent;
  final DateTime lastUpdated;

  const FirestoreSustainability({
    required this.userId,
    this.totalCO2Saved = 0.0,
    this.busTripsCount = 0,
    this.fuelSavedLiters = 0,
    this.treesEquivalent = 0,
    required this.lastUpdated,
  });

  factory FirestoreSustainability.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return FirestoreSustainability(
      userId: doc.id,
      totalCO2Saved: (data['totalCO2Saved'] as num?)?.toDouble() ?? 0.0,
      busTripsCount: (data['busTripsCount'] as num?)?.toInt() ?? 0,
      fuelSavedLiters: (data['fuelSavedLiters'] as num?)?.toInt() ?? 0,
      treesEquivalent: (data['treesEquivalent'] as num?)?.toInt() ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'totalCO2Saved': totalCO2Saved,
        'busTripsCount': busTripsCount,
        'fuelSavedLiters': fuelSavedLiters,
        'treesEquivalent': treesEquivalent,
        'lastUpdated': Timestamp.fromDate(lastUpdated),
      };
}

/// ─── CrowdReportModel (Firestore) ──────────────────────────────────────────
class FirestoreCrowdReport {
  final String id;
  final String userId;
  final String busRoute;
  final String crowdLevel;
  final int percent;
  final DateTime timestamp;

  const FirestoreCrowdReport({
    required this.id,
    required this.userId,
    required this.busRoute,
    required this.crowdLevel,
    this.percent = 50,
    required this.timestamp,
  });

  factory FirestoreCrowdReport.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FirestoreCrowdReport(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      busRoute: data['busRoute'] as String? ?? '',
      crowdLevel: data['crowdLevel'] as String? ?? 'moderate',
      percent: (data['percent'] as num?)?.toInt() ?? 50,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'busRoute': busRoute,
        'crowdLevel': crowdLevel,
        'percent': percent,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
