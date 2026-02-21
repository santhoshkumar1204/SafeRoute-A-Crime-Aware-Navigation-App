import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/firestore_models.dart';
import '../services/firebase_service.dart';

// ═══════════════════════════════════════════════════════════════════
//  Firebase-backed providers that replace mock data.
//  UI code uses these providers; it never touches FirebaseService directly.
//
//  When Firebase is NOT initialised (e.g. web without config), every
//  StreamProvider emits an empty list / default value so the UI still works.
// ═══════════════════════════════════════════════════════════════════

/// Whether Firebase has been successfully initialised on this platform.
bool get _firebaseReady {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
}

/// Singleton instance of [FirebaseService].
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

// ────────────────────── TRIPS ──────────────────────────────────────

/// Real-time stream of the current user's trips.
final tripsStreamProvider = StreamProvider<List<FirestoreTrip>>((ref) {
  if (!_firebaseReady) return Stream.value([]);
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.streamTrips();
  } catch (_) {
    return Stream.value([]);
  }
});

// ────────────────────── ALERTS ─────────────────────────────────────

/// Real-time stream of alerts.
final alertsStreamProvider = StreamProvider<List<FirestoreAlert>>((ref) {
  if (!_firebaseReady) return Stream.value([]);
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.listenToAlerts();
  } catch (_) {
    return Stream.value([]);
  }
});

// ────────────────────── REPORTS ────────────────────────────────────

/// Real-time stream of community reports.
final reportsStreamProvider = StreamProvider<List<FirestoreReport>>((ref) {
  if (!_firebaseReady) return Stream.value([]);
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.streamReports();
  } catch (_) {
    return Stream.value([]);
  }
});

/// StateNotifier for submitting reports.
class ReportSubmissionNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _svc;

  ReportSubmissionNotifier(this._svc) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String category,
    required String description,
    required String location,
    int severity = 1,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.submitReport(
        category: category,
        description: description,
        location: location,
        severity: severity,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final reportSubmissionProvider =
    StateNotifierProvider<ReportSubmissionNotifier, AsyncValue<void>>((ref) {
  return ReportSubmissionNotifier(ref.watch(firebaseServiceProvider));
});

// ────────────────────── ANALYTICS ──────────────────────────────────

/// Real-time stream of global analytics.
final analyticsStreamProvider = StreamProvider<FirestoreAnalytics>((ref) {
  if (!_firebaseReady) {
    return Stream.value(const FirestoreAnalytics(
      totalTrips: 0, totalReports: 0, highRiskAreas: [], busUsageStats: {}));
  }
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.streamAnalytics();
  } catch (_) {
    return Stream.value(const FirestoreAnalytics(
      totalTrips: 0, totalReports: 0, highRiskAreas: [], busUsageStats: {}));
  }
});

// ────────────────────── SUSTAINABILITY ─────────────────────────────

/// Real-time stream of the current user's sustainability data.
final sustainabilityStreamProvider =
    StreamProvider<FirestoreSustainability>((ref) {
  if (!_firebaseReady) {
    return Stream.value(FirestoreSustainability(
      userId: '', totalCO2Saved: 0, busTripsCount: 0,
      fuelSavedLiters: 0, treesEquivalent: 0, lastUpdated: DateTime.now()));
  }
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.streamSustainability();
  } catch (_) {
    return Stream.value(FirestoreSustainability(
      userId: '', totalCO2Saved: 0, busTripsCount: 0,
      fuelSavedLiters: 0, treesEquivalent: 0, lastUpdated: DateTime.now()));
  }
});

// ────────────────────── CROWD REPORTS ──────────────────────────────

/// Real-time stream of crowd reports.
final crowdReportsStreamProvider =
    StreamProvider<List<FirestoreCrowdReport>>((ref) {
  if (!_firebaseReady) return Stream.value([]);
  try {
    final svc = ref.watch(firebaseServiceProvider);
    return svc.streamCrowdReports();
  } catch (_) {
    return Stream.value([]);
  }
});

// ────────────────────── DASHBOARD STATS ────────────────────────────

/// Aggregated dashboard statistics derived from live Firebase streams.
class DashboardStats {
  final int todaySafetyScore;
  final int nearbyHighRiskAreas;
  final int recentAlerts;
  final int tripsThisWeek;

  const DashboardStats({
    this.todaySafetyScore = 87,
    this.nearbyHighRiskAreas = 3,
    this.recentAlerts = 0,
    this.tripsThisWeek = 0,
  });
}

final dashboardStatsProvider = Provider<DashboardStats>((ref) {
  final alertsAsync = ref.watch(alertsStreamProvider);
  final tripsAsync = ref.watch(tripsStreamProvider);
  final analyticsAsync = ref.watch(analyticsStreamProvider);

  final alertCount = alertsAsync.when(
    data: (list) => list.length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  final now = DateTime.now();
  final weekAgo = now.subtract(const Duration(days: 7));
  final tripsThisWeek = tripsAsync.when(
    data: (list) => list.where((t) => t.timestamp.isAfter(weekAgo)).length,
    loading: () => 0,
    error: (_, __) => 0,
  );

  final highRiskCount = analyticsAsync.when(
    data: (a) => a.highRiskAreas.length,
    loading: () => 3,
    error: (_, __) => 3,
  );

  return DashboardStats(
    todaySafetyScore: 87,
    nearbyHighRiskAreas: highRiskCount,
    recentAlerts: alertCount,
    tripsThisWeek: tripsThisWeek,
  );
});

// ────────────────────── TRIP SAVE ACTION ───────────────────────────

/// Simple provider to save a trip from the navigation page.
class TripSaveNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _svc;
  TripSaveNotifier(this._svc) : super(const AsyncValue.data(null));

  Future<bool> save({
    required String source,
    required String destination,
    required String transportType,
    required int riskScore,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.saveTrip(
        source: source,
        destination: destination,
        transportType: transportType,
        riskScore: riskScore,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final tripSaveProvider =
    StateNotifierProvider<TripSaveNotifier, AsyncValue<void>>((ref) {
  return TripSaveNotifier(ref.watch(firebaseServiceProvider));
});

// ────────────────────── CROWD REPORT SUBMIT ───────────────────────

class CrowdReportNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseService _svc;
  CrowdReportNotifier(this._svc) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String busRoute,
    required String crowdLevel,
    int percent = 50,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _svc.submitCrowdReport(
        busRoute: busRoute,
        crowdLevel: crowdLevel,
        percent: percent,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final crowdReportSubmitProvider =
    StateNotifierProvider<CrowdReportNotifier, AsyncValue<void>>((ref) {
  return CrowdReportNotifier(ref.watch(firebaseServiceProvider));
});

// ────────────────────── FIREBASE AUTH USER ─────────────────────────

/// Exposes the current Firebase Auth user as a stream.
final firebaseAuthUserProvider = StreamProvider<User?>((ref) {
  if (!_firebaseReady) return Stream.value(null);
  try {
    return FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    return Stream.value(null);
  }
});
