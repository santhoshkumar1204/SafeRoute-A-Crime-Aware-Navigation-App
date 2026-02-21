import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/firestore_models.dart';

/// Central Firestore service — the single source of truth for all database
/// operations in SafeRoute.  Every method uses [FirebaseFirestore.instance]
/// and [FirebaseAuth.instance] so the caller never has to know Firestore
/// details.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  /// Lazy access — avoids crashes if accessed before Firebase.initializeApp.
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // ─────────────────── Collection References ───────────────────
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _tripsCol =>
      _db.collection('trips');
  CollectionReference<Map<String, dynamic>> get _reportsCol =>
      _db.collection('reports');
  CollectionReference<Map<String, dynamic>> get _alertsCol =>
      _db.collection('alerts');
  CollectionReference<Map<String, dynamic>> get _crowdReportsCol =>
      _db.collection('crowdReports');
  CollectionReference<Map<String, dynamic>> get _sustainabilityCol =>
      _db.collection('sustainability');
  DocumentReference<Map<String, dynamic>> get _analyticsDoc =>
      _db.collection('analytics').doc('global');

  /// Convenience getter for the currently-authenticated UID.
  String? get _uid => _auth.currentUser?.uid;

  // ═══════════════════════════════════════════════════════════════
  // 1.  USER
  // ═══════════════════════════════════════════════════════════════

  /// Creates / updates the user document on first sign-in.
  /// If the document already exists only [lastLogin] is refreshed.
  Future<void> createUserIfNotExists({
    required String uid,
    required String name,
    required String email,
    String? profilePhoto,
    String role = 'User',
    String provider = 'email',
    bool emailVerified = false,
  }) async {
    final docRef = _usersCol.doc(uid);
    final snap = await docRef.get();
    if (snap.exists) {
      await docRef.update({'lastLogin': FieldValue.serverTimestamp()});
    } else {
      final user = FirestoreUser(
        uid: uid,
        name: name,
        email: email,
        profilePhoto: profilePhoto,
        role: role,
        provider: provider,
        emailVerified: emailVerified,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await docRef.set({
        ...user.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Fetch the user document once.
  Future<FirestoreUser?> getUser(String uid) async {
    final snap = await _usersCol.doc(uid).get();
    if (!snap.exists) return null;
    return FirestoreUser.fromFirestore(snap);
  }

  /// Stream of user document changes.
  Stream<FirestoreUser?> streamUser(String uid) {
    return _usersCol.doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      return FirestoreUser.fromFirestore(snap);
    });
  }

  // ═══════════════════════════════════════════════════════════════
  // 2.  TRIPS
  // ═══════════════════════════════════════════════════════════════

  /// Persist a completed trip. Also updates sustainability & analytics.
  Future<void> saveTrip({
    required String source,
    required String destination,
    required String transportType,
    required int riskScore,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    // CO₂ saved estimate (kg) for public-transport trips.
    final double co2 = _transportIsBus(transportType) ? 2.3 : 0.0;

    final trip = FirestoreTrip(
      id: '',
      userId: uid,
      source: source,
      destination: destination,
      transportType: transportType,
      riskScore: riskScore,
      sustainabilityScore: co2,
      timestamp: DateTime.now(),
    );
    await _tripsCol.add(trip.toFirestore());

    // Side-effects
    await _incrementAnalytics(transportType: transportType);
    if (_transportIsBus(transportType)) {
      await _incrementSustainability(uid: uid, co2: co2);
    }
  }

  /// One-shot fetch of user's trips (newest first).
  Future<List<FirestoreTrip>> fetchTrips({String? userId}) async {
    final uid = userId ?? _uid;
    if (uid == null) return [];
    final snap = await _tripsCol
        .where('userId', isEqualTo: uid)
        .limit(50)
        .get();
    final trips = snap.docs.map((d) => FirestoreTrip.fromFirestore(d)).toList();
    trips.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return trips;
  }

  /// Real-time stream of user's trips (sorted client-side to avoid composite index).
  Stream<List<FirestoreTrip>> streamTrips({String? userId}) {
    final uid = userId ?? _uid;
    if (uid == null) return Stream.value([]);
    return _tripsCol
        .where('userId', isEqualTo: uid)
        .limit(50)
        .snapshots()
        .map((snap) {
          final trips = snap.docs.map((d) => FirestoreTrip.fromFirestore(d)).toList();
          trips.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return trips;
        })
        .transform(_errorToEmpty<List<FirestoreTrip>>([]));
  }

  // ═══════════════════════════════════════════════════════════════
  // 3.  REPORTS
  // ═══════════════════════════════════════════════════════════════

  /// Submit an incident report.  If severity ≥ 4 an alert is auto-created.
  Future<void> submitReport({
    required String category,
    required String description,
    required String location,
    int severity = 1,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    final report = FirestoreReport(
      id: '',
      userId: uid,
      category: category,
      description: description,
      location: location,
      timestamp: DateTime.now(),
      severity: severity,
    );
    await _reportsCol.add(report.toFirestore());

    // Update analytics counter
    await _analyticsDoc.set(
      {'totalReports': FieldValue.increment(1)},
      SetOptions(merge: true),
    );

    // High severity → auto alert
    if (severity >= 4) {
      await _alertsCol.add(FirestoreAlert(
        id: '',
        type: 'danger',
        message: '⚠️ $category reported: $description',
        area: location,
        timestamp: DateTime.now(),
        severity: 'high',
      ).toFirestore());
    }
  }

  /// Fetch all reports (newest first).
  Future<List<FirestoreReport>> fetchReports() async {
    final snap = await _reportsCol
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    return snap.docs.map((d) => FirestoreReport.fromFirestore(d)).toList();
  }

  /// Stream all reports in real-time.
  Stream<List<FirestoreReport>> streamReports() {
    return _reportsCol
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FirestoreReport.fromFirestore(d)).toList())
        .transform(_errorToEmpty<List<FirestoreReport>>([]));
  }

  // ═══════════════════════════════════════════════════════════════
  // 4.  ALERTS  (real-time)
  // ═══════════════════════════════════════════════════════════════

  /// Real-time stream of active alerts (newest first).
  Stream<List<FirestoreAlert>> listenToAlerts() {
    return _alertsCol
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FirestoreAlert.fromFirestore(d)).toList())
        .transform(_errorToEmpty<List<FirestoreAlert>>([]));
  }

  /// Fetch alerts once.
  Future<List<FirestoreAlert>> fetchAlerts() async {
    final snap = await _alertsCol
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    return snap.docs.map((d) => FirestoreAlert.fromFirestore(d)).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // 5.  ANALYTICS
  // ═══════════════════════════════════════════════════════════════

  /// Stream the global analytics document.
  Stream<FirestoreAnalytics> streamAnalytics() {
    return _analyticsDoc.snapshots().map((snap) {
      if (!snap.exists) return const FirestoreAnalytics();
      return FirestoreAnalytics.fromFirestore(snap);
    }).transform(_errorToEmpty<FirestoreAnalytics>(const FirestoreAnalytics()));
  }

  /// One-shot fetch.
  Future<FirestoreAnalytics> fetchAnalytics() async {
    final snap = await _analyticsDoc.get();
    if (!snap.exists) return const FirestoreAnalytics();
    return FirestoreAnalytics.fromFirestore(snap);
  }

  // ═══════════════════════════════════════════════════════════════
  // 6.  SUSTAINABILITY
  // ═══════════════════════════════════════════════════════════════

  /// Stream the current user's sustainability data.
  Stream<FirestoreSustainability> streamSustainability({String? userId}) {
    final uid = userId ?? _uid ?? '__none__';
    return _sustainabilityCol.doc(uid).snapshots().map((snap) {
      if (!snap.exists) {
        return FirestoreSustainability(userId: uid, lastUpdated: DateTime.now());
      }
      return FirestoreSustainability.fromFirestore(snap);
    }).transform(_errorToEmpty<FirestoreSustainability>(
        FirestoreSustainability(userId: uid, lastUpdated: DateTime.now())));
  }

  /// Fetch once.
  Future<FirestoreSustainability> fetchSustainability({String? userId}) async {
    final uid = userId ?? _uid ?? '__none__';
    final snap = await _sustainabilityCol.doc(uid).get();
    if (!snap.exists) {
      return FirestoreSustainability(userId: uid, lastUpdated: DateTime.now());
    }
    return FirestoreSustainability.fromFirestore(snap);
  }

  /// Called internally after a bus trip.
  Future<void> _incrementSustainability({
    required String uid,
    required double co2,
  }) async {
    await _sustainabilityCol.doc(uid).set({
      'totalCO2Saved': FieldValue.increment(co2),
      'busTripsCount': FieldValue.increment(1),
      'fuelSavedLiters': FieldValue.increment(1),
      // Rough: 1 tree ≈ 21 kg CO₂/year → every ~21 kg → +1
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Recompute treesEquivalent
    final snap = await _sustainabilityCol.doc(uid).get();
    if (snap.exists) {
      final totalCo2 = (snap.data()?['totalCO2Saved'] as num?)?.toDouble() ?? 0;
      final trees = (totalCo2 / 21).floor();
      await _sustainabilityCol.doc(uid).update({'treesEquivalent': trees});
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // 7.  CROWD REPORTS
  // ═══════════════════════════════════════════════════════════════

  Future<void> submitCrowdReport({
    required String busRoute,
    required String crowdLevel,
    int percent = 50,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final report = FirestoreCrowdReport(
      id: '',
      userId: uid,
      busRoute: busRoute,
      crowdLevel: crowdLevel,
      percent: percent,
      timestamp: DateTime.now(),
    );
    await _crowdReportsCol.add(report.toFirestore());
  }

  /// Stream crowd reports (newest first).
  Stream<List<FirestoreCrowdReport>> streamCrowdReports() {
    return _crowdReportsCol
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => FirestoreCrowdReport.fromFirestore(d)).toList())
        .transform(_errorToEmpty<List<FirestoreCrowdReport>>([]));
  }

  // ═══════════════════════════════════════════════════════════════
  //     HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// StreamTransformer that emits [fallback] instead of propagating errors,
  /// so StreamProviders never get stuck in loading state.
  StreamTransformer<T, T> _errorToEmpty<T>(T fallback) {
    return StreamTransformer<T, T>.fromHandlers(
      handleData: (data, sink) => sink.add(data),
      handleError: (error, stackTrace, sink) {
        debugPrint('Firestore stream error (recovered): $error');
        sink.add(fallback);
      },
    );
  }

  Future<void> _incrementAnalytics({required String transportType}) async {
    final updates = <String, dynamic>{
      'totalTrips': FieldValue.increment(1),
    };
    if (_transportIsBus(transportType)) {
      updates['busUsageStats.$transportType'] = FieldValue.increment(1);
    }
    await _analyticsDoc.set(updates, SetOptions(merge: true));
  }

  bool _transportIsBus(String t) {
    final lower = t.toLowerCase();
    return lower.contains('bus') ||
        lower.contains('ordinary') ||
        lower.contains('express') ||
        lower.contains('ac') ||
        lower.contains('mini') ||
        lower.contains('special') ||
        lower.contains('mtc');
  }

  // ═══════════════════════════════════════════════════════════════
  //     SEED — one-time helper to populate initial data
  // ═══════════════════════════════════════════════════════════════

  /// Seeds initial analytics doc if it doesn't exist yet.
  Future<void> seedAnalyticsIfNeeded() async {
    final snap = await _analyticsDoc.get();
    if (!snap.exists) {
      await _analyticsDoc.set(const FirestoreAnalytics(
        totalTrips: 0,
        totalReports: 0,
        highRiskAreas: ['T. Nagar', 'Egmore', 'Tambaram'],
        busUsageStats: {},
      ).toFirestore());
    }
  }

  /// Seeds a few initial alerts so the dashboard isn't empty on first run.
  Future<void> seedAlertsIfNeeded() async {
    final snap = await _alertsCol.limit(1).get();
    if (snap.docs.isNotEmpty) return;

    final seedAlerts = [
      FirestoreAlert(
        id: '',
        type: 'danger',
        message: '⚠️ High Risk Stop Nearby — T. Nagar Bus Stand',
        area: 'T. Nagar',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        severity: 'high',
      ),
      FirestoreAlert(
        id: '',
        type: 'warning',
        message: '🚌 Bus Delay Alert — Route 21C delayed by 15 min',
        area: 'Saidapet',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        severity: 'warning',
      ),
      FirestoreAlert(
        id: '',
        type: 'warning',
        message: '👥 Crowd Surge Warning — Broadway Terminal',
        area: 'Broadway',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        severity: 'warning',
      ),
      FirestoreAlert(
        id: '',
        type: 'primary',
        message: '🔄 Route Recalculated — Safer path via Anna Salai',
        area: 'Anna Salai',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
        severity: 'low',
      ),
      FirestoreAlert(
        id: '',
        type: 'danger',
        message: '🎪 Event Congestion Alert — Marina Beach area',
        area: 'Marina',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        severity: 'high',
      ),
    ];
    for (final alert in seedAlerts) {
      await _alertsCol.add(alert.toFirestore());
    }
  }
}
