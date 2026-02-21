import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/data_models.dart';
import '../data/mock_data.dart';
import 'firebase_providers.dart';

// Map State
class MapState {
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;

  const MapState({
    this.showHeatmap = true,
    this.showRoute = true,
    this.showPoliceStations = false,
  });

  MapState copyWith(
      {bool? showHeatmap, bool? showRoute, bool? showPoliceStations}) {
    return MapState(
      showHeatmap: showHeatmap ?? this.showHeatmap,
      showRoute: showRoute ?? this.showRoute,
      showPoliceStations: showPoliceStations ?? this.showPoliceStations,
    );
  }
}

class MapNotifier extends StateNotifier<MapState> {
  MapNotifier() : super(const MapState());

  void toggleHeatmap() =>
      state = state.copyWith(showHeatmap: !state.showHeatmap);
  void toggleRoute() => state = state.copyWith(showRoute: !state.showRoute);
  void togglePoliceStations() =>
      state = state.copyWith(showPoliceStations: !state.showPoliceStations);
}

final mapProvider =
    StateNotifierProvider<MapNotifier, MapState>((ref) => MapNotifier());

// Route State
class RouteState {
  final String source;
  final String destination;
  final String mode;
  final double riskProbability;
  final String riskLevel;

  const RouteState({
    this.source = '',
    this.destination = '',
    this.mode = 'safest',
    this.riskProbability = 0.0,
    this.riskLevel = 'unknown',
  });

  RouteState copyWith({
    String? source,
    String? destination,
    String? mode,
    double? riskProbability,
    String? riskLevel,
  }) {
    return RouteState(
      source: source ?? this.source,
      destination: destination ?? this.destination,
      mode: mode ?? this.mode,
      riskProbability: riskProbability ?? this.riskProbability,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier() : super(const RouteState());

  void setSource(String s) => state = state.copyWith(source: s);
  void setDestination(String d) => state = state.copyWith(destination: d);
  void setMode(String m) => state = state.copyWith(mode: m);
}

final routeProvider =
    StateNotifierProvider<RouteNotifier, RouteState>((ref) => RouteNotifier());

// Risk State – now powered by Firebase via dashboardStatsProvider.
// Kept for backward-compatibility; the dashboard reads this provider.
class RiskState {
  final int todaySafetyScore;
  final int nearbyHighRiskAreas;
  final int recentAlerts;
  final int tripsThisWeek;

  const RiskState({
    this.todaySafetyScore = 0,
    this.nearbyHighRiskAreas = 0,
    this.recentAlerts = 0,
    this.tripsThisWeek = 0,
  });
}

final riskProvider = Provider<RiskState>((ref) {
  final stats = ref.watch(dashboardStatsProvider);
  return RiskState(
    todaySafetyScore: stats.todaySafetyScore,
    nearbyHighRiskAreas: stats.nearbyHighRiskAreas,
    recentAlerts: stats.recentAlerts,
    tripsThisWeek: stats.tripsThisWeek,
  );
});

// Notification State
class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super([]);

  int get unreadCount => state.where((n) => !n.read).length;

  void markAllRead() {
    state = [
      for (final n in state)
        NotificationModel(
            id: n.id, message: n.message, time: n.time, read: true),
    ];
  }

  void clearAll() => state = [];
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
        (ref) => NotificationNotifier());
