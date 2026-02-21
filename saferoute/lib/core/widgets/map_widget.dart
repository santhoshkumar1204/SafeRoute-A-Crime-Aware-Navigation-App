import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

class MapWidget extends StatefulWidget {
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
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  
  LatLng? _source;
  LatLng? _destination;
  String _sourceName = "Select Start Point";
  String _destName = "Select Destination";
  
  List<LatLng> _routePath = [];
  List<CircleMarker> _heatmaps = [];
  List<Marker> _policeStations = [];
  
  final LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);

  @override
  void initState() {
    super.initState();
    _loadMTCData();
  }

  Future<String> _getAddress(LatLng point) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}');
      final response = await http.get(url, headers: {'User-Agent': 'SafeRouteHackathon'});
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
        _routePath = [];
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
        _routePath = [_source!, _destination!]; // Simplified route
      });
    }
  }

  Future<void> _loadMTCData() async {
    try {
      final String csvData = await rootBundle.loadString('assets/structured_bus_segments.csv');
      final List<String> lines = csvData.split('\n');
      final random = Random(42);
      
      List<CircleMarker> generatedHeatmaps = [];
      List<Marker> generatedPolice = [];

      // Generate localized heatmaps for demo
      for (int i = 0; i < 15; i++) {
        final point = LatLng(12.9 + random.nextDouble() * 0.2, 80.2 + random.nextDouble() * 0.1);
        Color zoneColor = AppColors.safe.withOpacity(0.3);
        double val = random.nextDouble();
        if (val > 0.8) zoneColor = AppColors.danger.withOpacity(0.4);
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
    return Container(
      height: widget.height ?? 300,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                if (widget.showHeatmap) CircleLayer(circles: _heatmaps),
                if (widget.showPoliceStations) MarkerLayer(markers: _policeStations),
                if (widget.showRoute && _routePath.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(points: _routePath, color: AppColors.primary, strokeWidth: 5),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (_source != null)
                      Marker(point: _source!, child: const Icon(Icons.radio_button_checked, color: Colors.blue, size: 20)),
                    if (_destination != null)
                      Marker(point: _destination!, child: const Icon(Icons.location_on, color: Colors.red, size: 30)),
                  ],
                ),
              ],
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("24 min", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: const Text("98% Safe", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text(_sourceName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(child: Text(_destName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Start Safe Navigation", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}