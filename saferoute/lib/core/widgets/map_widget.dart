import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_state_provider.dart';

class MapWidget extends ConsumerStatefulWidget {
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;
  final double? height;
  final bool isInteractive;

  const MapWidget({
    super.key,
    this.showHeatmap = true,
    this.showRoute = true,
    this.showPoliceStations = false,
    this.height,
    this.isInteractive = true,
  });

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget> {
  final MapController _mapController = MapController();

  LatLng? _source;
  LatLng? _destination;
  String _sourceName = "Select Start Point";
  String _destName = "Select Destination";

  List<LatLng> _shortestPath = [];
  List<LatLng> _optimalPath = [];
  List<CircleMarker> _heatmaps = [];
  List<Marker> _policeStations = [];
  List<Marker> _riskMarkers = [];
  double? _shortestDistance;
  double? _optimalCost;
  double? _topRiskScore;
  double? _safetyScore;
  bool _isLoadingRoute = false;
  String? _routeError;

  final LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _loadMTCData();
  }

  double safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) {
      if (value.isNaN || value.isInfinite) return 0.0;
      return value;
    }
    if (value is String) {
      final d = double.tryParse(value);
      if (d == null || d.isNaN || d.isInfinite) return 0.0;
      return d;
    }
    return 0.0;
  }

  bool _isValidLatLng(double lat, double lon) {
    return lat >= -90 &&
        lat <= 90 &&
        lon >= -180 &&
        lon <= 180 &&
        (lat != 0 || lon != 0);
  }

  Future<LatLng?> _forwardGeocode(String query) async {
    if (query.isEmpty) return null;
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1');
      final response =
          await http.get(url, headers: {'User-Agent': 'SafeRouteHackathon'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return null;
  }

  Future<String> _getAddress(LatLng point) async {
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}');
      final response =
          await http.get(url, headers: {'User-Agent': 'SafeRouteHackathon'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'].toString().split(',');
        return address.isNotEmpty ? address[0] : "Custom Point";
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
    }
    return "Lat: ${point.latitude.toStringAsFixed(3)}";
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) async {
    if (!widget.isInteractive) return;

    setState(() {
      if (_source == null || (_source != null && _destination != null)) {
        _source = point;
        _destination = null;
        _shortestPath = [];
        _optimalPath = [];
        _riskMarkers = [];
        _shortestDistance = null;
        _optimalCost = null;
        _topRiskScore = null;
        _safetyScore = null;
        _routeError = null;
        _sourceName = "Fetching address...";
      } else {
        _destination = point;
        _destName = "Fetching address...";
      }
    });

    if (_destination == null) {
      final name = await _getAddress(point);
      setState(() => _sourceName = name);
    } else {
      final name = await _getAddress(point);
      setState(() {
        _destName = name;
      });
    }
  }

  Future<void> _loadMTCData() async {
    try {
      final String csvData =
          await rootBundle.loadString('assets/structured_bus_segments.csv');
      final List<String> lines = csvData.split('\n');
      final random = Random(42);

      List<CircleMarker> generatedHeatmaps = [];
      List<Marker> generatedPolice = [];

      // Generate localized heatmaps for demo
      for (int i = 0; i < 15; i++) {
        final point = LatLng(
            12.9 + random.nextDouble() * 0.2, 80.2 + random.nextDouble() * 0.1);
        Color zoneColor = AppColors.safe.withOpacity(0.3);
        double val = random.nextDouble();
        if (val > 0.8)
          zoneColor = AppColors.danger.withOpacity(0.4);
        else if (val > 0.5) zoneColor = AppColors.moderate.withOpacity(0.4);

        generatedHeatmaps.add(CircleMarker(
          point: point,
          color: zoneColor,
          radius: 600 + random.nextInt(400).toDouble(),
          useRadiusInMeter: true,
        ));

        if (val > 0.9) {
          generatedPolice.add(Marker(
            point: point,
            child: const Icon(Icons.local_police, color: Colors.blue, size: 20),
          ));
        }
      }

      if (mounted) {
        setState(() {
          _heatmaps = generatedHeatmaps;
          _policeStations = generatedPolice;
        });
      }
    } catch (e) {
      debugPrint("Error loading CSV: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RouteState>(routeProvider, (previous, next) async {
      bool shouldRoute = false;

      // Handle Source Change
      if (next.source.isNotEmpty && (previous?.source != next.source)) {
        final coords = await _forwardGeocode(next.source);
        if (coords != null) {
          setState(() {
            _source = coords;
            _sourceName = next.source;
          });
          shouldRoute = true;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Could not find location: ${next.source}")),
            );
          }
        }
      }

      // Handle Destination Change
      if (next.destination.isNotEmpty &&
          (previous?.destination != next.destination)) {
        final coords = await _forwardGeocode(next.destination);
        if (coords != null) {
          setState(() {
            _destination = coords;
            _destName = next.destination;
          });
          shouldRoute = true;
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text("Could not find location: ${next.destination}")),
            );
          }
        }
      }

      // Handle Mode Change
      if (previous?.mode != next.mode) {
        shouldRoute = true;
      }

      // Trigger Navigation if we have both points and a relevant change occurred
      if (shouldRoute && _source != null && _destination != null) {
        _startSafeNavigation();
      }
    });

    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _chennaiCenter,
                initialZoom: 12.0,
                onTap: _handleMapTap,
              ),
              children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                if (widget.showHeatmap) CircleLayer(circles: _heatmaps),
                if (widget.showPoliceStations)
                  MarkerLayer(markers: _policeStations),
                if (widget.showRoute && _shortestPath.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                          points: _shortestPath,
                          color: Colors.blue,
                          strokeWidth: 4),
                    ],
                  ),
                if (widget.showRoute && _optimalPath.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                          points: _optimalPath,
                          color: Colors.green,
                          strokeWidth: 4),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_source != null)
                      Marker(
                          point: _source!,
                          child: const Icon(Icons.radio_button_checked,
                              color: Colors.blue, size: 20)),
                    if (_destination != null)
                      Marker(
                          point: _destination!,
                          child: const Icon(Icons.location_on,
                              color: Colors.red, size: 30)),
                    ..._riskMarkers,
                  ],
                ),
              ],
            ),
            if (_routeError != null)
              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: Text(
                    _routeError!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (_source != null && _destination != null)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: _buildSafetyCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _shortestDistance != null
                    ? "${_shortestDistance!.toStringAsFixed(2)} km"
                    : "Route info",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_safetyScore != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Safety ${_safetyScore!.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          if (_routeError != null) ...[
            const SizedBox(height: 8),
            Text(
              _routeError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(_sourceName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(_destName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoadingRoute ? null : _startSafeNavigation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoadingRoute
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text("Start Safe Navigation",
                    style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _startSafeNavigation() async {
    if (_source == null || _destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select source and destination on the map")),
      );
      return;
    }

    // Get current mode from Riverpod provider (if we need to use it, otherwise use safety_factor=5.0 as default for Safe)
    // The previous request asked to use "mode" but this one says A* = distance + risk * safety_factor
    // We will send safety_factor=5.0 to represent "Safe" behavior by default in this button for now,
    // or map the mode to a factor.
    final mode = ref.read(routeProvider).mode;
    double safetyFactor = 5.0;
    if (mode == 'fastest') safetyFactor = 0.0;
    if (mode == 'balanced') safetyFactor = 2.0;
    if (mode == 'safest') safetyFactor = 10.0;

    setState(() {
      _isLoadingRoute = true;
      _routeError = null;
      _shortestPath = [];
      _optimalPath = [];
      _riskMarkers = [];
      _shortestDistance = null;
      _optimalCost = null;
      _topRiskScore = null;
      _safetyScore = null;
    });

    try {
      String defaultUrl = "http://127.0.0.1:8000/api";
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        defaultUrl = "http://10.0.2.2:8000/api";
      }

      final baseUrl = dotenv.env['BASE_URL'] ?? defaultUrl;
      debugPrint("Using Base URL: $baseUrl");
      final url = Uri.parse("$baseUrl/safest-route");

      final body = jsonEncode({
        "source": {
          "lat": _source!.latitude,
          "lon": _source!.longitude,
        },
        "destination": {
          "lat": _destination!.latitude,
          "lon": _destination!.longitude,
        },
        "safety_factor": safetyFactor,
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      debugPrint("safest-route status: ${response.statusCode}");
      debugPrint("BACKEND RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        setState(() {
          _routeError = "Backend error: ${response.statusCode}";
        });
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      List<LatLng> parsePath(String key) {
        if (data[key] == null) return [];
        final list = data[key] as List<dynamic>;
        return list
            .map((e) {
              final lat = safeDouble(e["lat"]);
              final lon = safeDouble(e["lon"]);
              if (!_isValidLatLng(lat, lon)) return null;
              return LatLng(lat, lon);
            })
            .where((e) => e != null)
            .cast<LatLng>()
            .toList();
      }

      final shortestPath = parsePath("shortest_path");
      final optimalPath = parsePath("optimal_path");

      final riskZones = data["risk_zones"] as List<dynamic>;
      final markers = <Marker>[];
      double? topRisk;
      double totalRisk = 0.0;
      int validRiskZones = 0;

      for (final zone in riskZones) {
        final z = zone as Map<String, dynamic>;
        final lat = safeDouble(z["lat"]);
        final lon = safeDouble(z["lon"]);
        final score = safeDouble(z["risk_score"]);

        if (!_isValidLatLng(lat, lon)) continue;

        markers.add(
          Marker(
            point: LatLng(lat, lon),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 20,
            ),
          ),
        );

        totalRisk += score;
        validRiskZones++;
        if (topRisk == null || score > topRisk) {
          topRisk = score;
        }
      }

      double? safetyScore;
      if (validRiskZones == 0) {
        safetyScore = 100.0;
      } else {
        final avgRisk = totalRisk / validRiskZones;
        safetyScore = 100.0 - (avgRisk * 100.0);
        safetyScore = safeDouble(safetyScore);
        if (safetyScore < 0) safetyScore = 0;
        if (safetyScore > 100) safetyScore = 100;
      }

      double? sDist = safeDouble(data["shortest_distance"]);
      double? oCost = safeDouble(data["optimal_cost"]);

      debugPrint("Distance: $sDist");
      debugPrint("Cost: $oCost");

      setState(() {
        _shortestPath = shortestPath;
        _optimalPath = optimalPath;
        _riskMarkers = markers;
        _shortestDistance = sDist;
        _optimalCost = oCost;
        _topRiskScore = topRisk;
        _safetyScore = safetyScore;

        if (_shortestPath.isEmpty && _optimalPath.isEmpty) {
          _routeError = "No route available.";
        }
      });

      // Determine points to include in bounds
      final pointsForBounds = <LatLng>[];
      if (_optimalPath.isNotEmpty) pointsForBounds.addAll(_optimalPath);
      if (_shortestPath.isNotEmpty) pointsForBounds.addAll(_shortestPath);
      if (_source != null) pointsForBounds.add(_source!);
      if (_destination != null) pointsForBounds.add(_destination!);

      if (pointsForBounds.isNotEmpty) {
        try {
          // Filter out any lingering invalid points just in case
          final validPoints = pointsForBounds
              .where((p) => _isValidLatLng(p.latitude, p.longitude))
              .toList();

          if (validPoints.isEmpty) return;

          final bounds = LatLngBounds.fromPoints(validPoints);

          // Check for zero-size bounds (single point or all points same)
          final isZeroSize =
              (bounds.north == bounds.south) && (bounds.east == bounds.west);

          if (isZeroSize) {
            _mapController.move(bounds.center, 15.0);
          } else {
            _mapController.fitCamera(
              CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(40),
              ),
            );
          }
        } catch (e) {
          debugPrint("Camera fit error: $e");
        }
      }
    } catch (e) {
      debugPrint("safest-route error: $e");
      setState(() {
        _routeError = "Failed to reach backend";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }
}
