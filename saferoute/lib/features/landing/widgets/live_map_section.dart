//live_map_section.dart - This widget displays an interactive map using Flutter Map, showing bus stops from a CSV file and allowing users to click on the map to set source/destination points. It fetches routing data from OSRM to display routes and turn-by-turn instructions. The map also includes markers for bus stops, which show details in a bottom sheet when tapped. The widget is designed to be reusable and integrates seamlessly with the landing page of the SafeRoute app.
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

// Helper class to store bus stop data
class BusStop {
  final String name;
  final double lat;
  final double lon;
  final List<String> routes;

  BusStop({
    required this.name,
    required this.lat,
    required this.lon,
    required this.routes,
  });
}

class MapComponent extends StatefulWidget {
  final LatLng? sourceCoords;
  final LatLng? destCoords;
  final Function(LatLng)? onMapClick;
  final double height;
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;

  const MapComponent({
    super.key,
    this.sourceCoords,
    this.destCoords,
    this.onMapClick,
    this.height = 320.0,
    this.showHeatmap = false,
    this.showRoute = false,
    this.showPoliceStations = false,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  final MapController _mapController = MapController();
  final LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);
  double? _distanceInMeters;
  double? _durationInSeconds;
  List<dynamic> _turnByTurnSteps = [];
  
  List<BusStop> _busStops = [];
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadBusStops();
  }

  @override
  void didUpdateWidget(covariant MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If source or destination changes, recalculate the route
    if (widget.sourceCoords != oldWidget.sourceCoords || 
        widget.destCoords != oldWidget.destCoords) {
      if (widget.sourceCoords != null && widget.destCoords != null) {
        _fetchRoute(widget.sourceCoords!, widget.destCoords!);
      } else {
        setState(() => _routePoints = []);
      }
    }
  }

  // Load and parse CSV exactly like PapaParse in React
  Future<void> _loadBusStops() async {
    try {
      final String csvString = await rootBundle.loadString('assets/structured_bus_segments.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n').convert(csvString);
      
      if (csvTable.isEmpty) return;

      // Extract headers to find indices
      final headers = csvTable.first.map((e) => e.toString().trim()).toList();
      final stopIdx = headers.indexOf('Start_Stop');
      final latIdx = headers.indexOf('Start_Lat');
      final lonIdx = headers.indexOf('Start_Lon');
      final routeIdx = headers.indexOf('Route_No');

      if (stopIdx == -1 || latIdx == -1 || lonIdx == -1) return;

      Map<String, BusStop> uniqueStops = {};

      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length <= lonIdx) continue; // Skip malformed rows

        final stopName = row[stopIdx].toString();
        final lat = double.tryParse(row[latIdx].toString());
        final lon = double.tryParse(row[lonIdx].toString());
        final route = routeIdx != -1 ? row[routeIdx].toString() : '';

        if (lat != null && lon != null) {
          if (!uniqueStops.containsKey(stopName)) {
            uniqueStops[stopName] = BusStop(
              name: stopName,
              lat: lat,
              lon: lon,
              routes: [route],
            );
          } else {
            if (!uniqueStops[stopName]!.routes.contains(route)) {
              uniqueStops[stopName]!.routes.add(route);
            }
          }
        }
      }

      setState(() {
        _busStops = uniqueStops.values.toList();
      });
    } catch (e) {
      debugPrint("Error loading CSV: $e");
    }
  }

  // Fetch routing data from OSRM (Leaflet Routing Machine's default backend)
  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    setState(() => _isLoadingRoute = true);
    
    // ADDED: steps=true and overview=full
    final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true&overview=full';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final List coordinates = route['geometry']['coordinates'];
        
        setState(() {
          _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
          
          // EXTRACT REAL DATA
          _distanceInMeters = route['distance'].toDouble();
          _durationInSeconds = route['duration'].toDouble();
          
          // EXTRACT TURN-BY-TURN STEPS
          _turnByTurnSteps = route['legs'][0]['steps']; 
          
          _isLoadingRoute = false;
        });

        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
        );
      }
    } catch (e) {
      debugPrint("Error fetching route: $e");
      setState(() => _isLoadingRoute = false);
    }
  }

  void _showStopDetails(BuildContext context, BusStop stop) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stop.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Routes: ${stop.routes.where((r) => r.isNotEmpty).join(", ")}'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _chennaiCenter,
              initialZoom: 12,
              onTap: (tapPosition, point) {
                if (widget.onMapClick != null) widget.onMapClick!(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.your_app', 
              ),
              
              // 1. Draw Routing Line
              if (widget.showRoute && _routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: Colors.blue.shade700.withOpacity(0.8),
                    ),
                  ],
                ),

              // 2. Draw Bus Stops (Circle Markers)
              MarkerLayer(
                markers: _busStops.map((stop) {
                  return Marker(
                    point: LatLng(stop.lat, stop.lon),
                    width: 10,
                    height: 10,
                    child: GestureDetector(
                      onTap: () => _showStopDetails(context, stop),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green.shade700.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // 3. Draw Source / Dest Markers
              MarkerLayer(
                markers: [
                  if (widget.sourceCoords != null)
                    Marker(
                      point: widget.sourceCoords!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                    ),
                  if (widget.destCoords != null)
                    Marker(
                      point: widget.destCoords!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                    ),
                ],
              ),
            ],
          ),

          // Place this inside your Stack children, below FlutterMap
if (_turnByTurnSteps.isNotEmpty)
  Positioned(
    top: 10,
    right: 10,
    child: Container(
      width: 240,
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _turnByTurnSteps.length,
        itemBuilder: (context, index) {
          final step = _turnByTurnSteps[index];
          final maneuver = step['maneuver'];
          
          // Safely parse OSRM maneuver text
          String type = maneuver['type'] ?? '';
          String modifier = maneuver['modifier'] != null ? " ${maneuver['modifier']}" : "";
          String name = step['name'] == "" ? "destination" : step['name'];
          String distance = "${(step['distance'] as num).toStringAsFixed(0)}m";
          
          // Clean up the text (e.g., "turn left onto Madley Road")
          String instruction = "${type[0].toUpperCase()}${type.substring(1)}$modifier onto $name";
          if (type == 'depart' || type == 'arrive') {
             instruction = type == 'depart' ? "Head ${modifier.trim()} on $name" : "Arrive at $name";
          }

          return ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: const Icon(Icons.turn_right, size: 16, color: Colors.blueGrey),
            title: Text(instruction, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            trailing: Text(distance, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          );
        },
      ),
    ),
  ),

          if (_isLoadingRoute)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}