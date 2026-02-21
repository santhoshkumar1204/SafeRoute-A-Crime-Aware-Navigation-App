

// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;

// class SafeRouteMap extends StatefulWidget {
//   final LatLng? sourceCoords;
//   final LatLng? destCoords;
//   final bool showHeatmap;
//   final bool showRoute;
//   final bool showPoliceStations;
//   final Color routeColor;

//   const SafeRouteMap({
//     super.key,
//     this.sourceCoords,
//     this.destCoords,
//     this.showHeatmap = true,
//     this.showRoute = true,
//     this.showPoliceStations = false,
//     this.routeColor = Colors.blueAccent,
//   });

//   @override
//   State<SafeRouteMap> createState() => _SafeRouteMapState();
// }

// class _SafeRouteMapState extends State<SafeRouteMap> {
//   final MapController _mapController = MapController();
//   final LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);

//   List<LatLng> _routePoints = [];
//   List<CircleMarker> _heatmaps = [];
//   List<Marker> _policeStations = [];
  
//   double? _distanceInMeters;
//   double? _durationInSeconds;
//   List<dynamic> _turnByTurnSteps = [];
//   bool _isLoadingRoute = false;

//   @override
//   void initState() {
//     super.initState();
//     _generateMockSafetyData();
//   }

//   // Trigger routing when sidebar coordinates change
//   @override
//   void didUpdateWidget(covariant SafeRouteMap oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.sourceCoords != oldWidget.sourceCoords || widget.destCoords != oldWidget.destCoords) {
//       if (widget.sourceCoords != null && widget.destCoords != null) {
//         _fetchRoadRoute(widget.sourceCoords!, widget.destCoords!);
//       }
//     }
//   }

//   Future<void> _fetchRoadRoute(LatLng start, LatLng end) async {
//     setState(() => _isLoadingRoute = true);
    
//     final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true&overview=full';
    
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final route = data['routes'][0];
//         final List coordinates = route['geometry']['coordinates'];
        
//         setState(() {
//           _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
//           _distanceInMeters = route['distance'].toDouble();
//           _durationInSeconds = route['duration'].toDouble();
//           _turnByTurnSteps = route['legs'][0]['steps']; 
//           _isLoadingRoute = false;
//         });

//         // Zoom to fit route
//         final bounds = LatLngBounds.fromPoints(_routePoints);
//         _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
//       }
//     } catch (e) {
//       setState(() => _isLoadingRoute = false);
//     }
//   }

//   void _generateMockSafetyData() {
//     final random = Random(42);
//     List<CircleMarker> hm = [];
//     List<Marker> police = [];

//     for (int i = 0; i < 20; i++) {
//       final point = LatLng(12.9 + random.nextDouble() * 0.2, 80.15 + random.nextDouble() * 0.2);
//       double val = random.nextDouble();
//       Color zoneColor = val > 0.8 ? Colors.red.withOpacity(0.3) : 
//                         val > 0.5 ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.2);

//       hm.add(CircleMarker(point: point, color: zoneColor, radius: 600, useRadiusInMeter: true));
//       if (val > 0.85) {
//         police.add(Marker(point: point, child: const Icon(Icons.local_police, color: Colors.blue, size: 24)));
//       }
//     }
//     setState(() { _heatmaps = hm; _policeStations = police; });
//   }

//   String _formatETA() => _durationInSeconds == null ? "--" : "${(_durationInSeconds! / 60).round()} min";
//   String _formatDist() => _distanceInMeters == null ? "" : "(${(_distanceInMeters! / 1000).toStringAsFixed(1)} km)";

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         FlutterMap(
//           mapController: _mapController,
//           options: MapOptions(initialCenter: _chennaiCenter, initialZoom: 12.0),
//           children: [
//             TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
//             if (widget.showHeatmap) CircleLayer(circles: _heatmaps),
//             if (widget.showPoliceStations) MarkerLayer(markers: _policeStations),
//             if (widget.showRoute && _routePoints.isNotEmpty)
//               PolylineLayer(polylines: [Polyline(points: _routePoints, color: widget.routeColor, strokeWidth: 6)]),
//             MarkerLayer(
//               markers: [
//                 if (widget.sourceCoords != null) Marker(point: widget.sourceCoords!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)),
//                 if (widget.destCoords != null) Marker(point: widget.destCoords!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 36)),
//               ],
//             ),
//           ],
//         ),

//         // TURN BY TURN
//         if (_turnByTurnSteps.isNotEmpty)
//           Positioned(
//             top: 20, right: 20,
//             child: Container(
//               width: 260, constraints: const BoxConstraints(maxHeight: 350),
//               decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)]),
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(8), shrinkWrap: true, itemCount: _turnByTurnSteps.length,
//                 itemBuilder: (context, i) {
//                   final step = _turnByTurnSteps[i];
//                   String inst = "${step['maneuver']['type']} ${step['name'] == '' ? '' : 'onto ${step['name']}'}";
//                   return ListTile(
//                     dense: true, visualDensity: VisualDensity.compact,
//                     leading: const Icon(Icons.turn_right, color: Colors.blueGrey),
//                     title: Text(inst, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//                     trailing: Text("${(step['distance'] as num).toStringAsFixed(0)}m", style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                   );
//                 },
//               ),
//             ),
//           ),

//         // BOTTOM CARD
//         if (widget.sourceCoords != null && widget.destCoords != null)
//           Positioned(
//             bottom: 20, left: 20, right: 20,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))]),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Estimated Arrival", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Text(_formatETA(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
//                           const SizedBox(width: 8),
//                           Text(_formatDist(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
//                         ],
//                       ),
//                     ],
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.navigation, color: Colors.white),
//                     label: const Text("Start Secure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                     style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
//                   )
//                 ],
//               ),
//             ),
//           ),
          
//         if (_isLoadingRoute) const Center(child: Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class SafeRouteMap extends StatefulWidget {
  final LatLng? sourceCoords;
  final LatLng? destCoords;
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;
  final Color routeColor;

  const SafeRouteMap({
    super.key,
    this.sourceCoords,
    this.destCoords,
    this.showHeatmap = true,
    this.showRoute = true,
    this.showPoliceStations = false,
    this.routeColor = Colors.blueAccent,
  });

  @override
  State<SafeRouteMap> createState() => _SafeRouteMapState();
}

class _SafeRouteMapState extends State<SafeRouteMap> {
  final MapController _mapController = MapController();
  final LatLng _chennaiCenter = const LatLng(13.0827, 80.2707);

  List<LatLng> _routePoints = [];
  List<CircleMarker> _heatmaps = [];
  List<Marker> _policeStations = [];
  
  double? _distanceInMeters;
  double? _durationInSeconds;
  List<dynamic> _turnByTurnSteps = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _generateMockSafetyData();
  }

  @override
  void didUpdateWidget(covariant SafeRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sourceCoords != oldWidget.sourceCoords || widget.destCoords != oldWidget.destCoords) {
      if (widget.sourceCoords != null && widget.destCoords != null) {
        _fetchRoadRoute(widget.sourceCoords!, widget.destCoords!);
      }
    }
  }

  Future<void> _fetchRoadRoute(LatLng start, LatLng end) async {
    setState(() => _isLoadingRoute = true);
    final url = 'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson&steps=true&overview=full';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final List coordinates = route['geometry']['coordinates'];
        
        setState(() {
          _routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
          _distanceInMeters = route['distance'].toDouble();
          _durationInSeconds = route['duration'].toDouble();
          _turnByTurnSteps = route['legs'][0]['steps']; 
          _isLoadingRoute = false;
        });

        final bounds = LatLngBounds.fromPoints(_routePoints);
        _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
      }
    } catch (e) {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _generateMockSafetyData() {
    final random = Random(42);
    List<CircleMarker> hm = [];
    List<Marker> police = [];

    for (int i = 0; i < 20; i++) {
      final point = LatLng(12.9 + random.nextDouble() * 0.2, 80.15 + random.nextDouble() * 0.2);
      double val = random.nextDouble();
      Color zoneColor = val > 0.8 ? Colors.red.withOpacity(0.3) : 
                        val > 0.5 ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.2);

      hm.add(CircleMarker(point: point, color: zoneColor, radius: 600, useRadiusInMeter: true));
      if (val > 0.85) {
        police.add(Marker(point: point, child: const Icon(Icons.local_police, color: Colors.blue, size: 24)));
      }
    }
    setState(() { _heatmaps = hm; _policeStations = police; });
  }

  String _formatETA() => _durationInSeconds == null ? "--" : "${(_durationInSeconds! / 60).round()} min";
  String _formatDist() => _distanceInMeters == null ? "" : "(${(_distanceInMeters! / 1000).toStringAsFixed(1)} km)";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(initialCenter: _chennaiCenter, initialZoom: 12.0),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
            if (widget.showHeatmap) CircleLayer(circles: _heatmaps),
            if (widget.showPoliceStations) MarkerLayer(markers: _policeStations),
            if (widget.showRoute && _routePoints.isNotEmpty)
              PolylineLayer(polylines: [Polyline(points: _routePoints, color: widget.routeColor, strokeWidth: 6)]),
            MarkerLayer(
              markers: [
                if (widget.sourceCoords != null) Marker(point: widget.sourceCoords!, width: 40, height: 40, child: const Icon(Icons.my_location, color: Colors.blue, size: 30)),
                if (widget.destCoords != null) Marker(point: widget.destCoords!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.red, size: 36)),
              ],
            ),
          ],
        ),

        // TURN BY TURN - Added constraints for mobile
        if (_turnByTurnSteps.isNotEmpty)
          Positioned(
            top: 10, right: 10,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6, 
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)]),
              child: ListView.builder(
                padding: const EdgeInsets.all(8), shrinkWrap: true, itemCount: _turnByTurnSteps.length,
                itemBuilder: (context, i) {
                  final step = _turnByTurnSteps[i];
                  String inst = "${step['maneuver']['type']} ${step['name'] == '' ? '' : 'onto ${step['name']}'}";
                  return ListTile(
                    dense: true, visualDensity: VisualDensity.compact,
                    leading: const Icon(Icons.turn_right, color: Colors.blueGrey, size: 16),
                    title: Text(inst, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    trailing: Text("${(step['distance'] as num).toStringAsFixed(0)}m", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                },
              ),
            ),
          ),

        // BOTTOM CARD - Wrapped with Expanded to prevent horizontal overflow
        if (widget.sourceCoords != null && widget.destCoords != null)
          Positioned(
            bottom: 10, left: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded( // Prevent text from pushing the button out
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("ETA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatETA(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                            const SizedBox(width: 4),
                            Flexible(child: Text(_formatDist(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.navigation, color: Colors.white, size: 18),
                    label: const Text("Start", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  )
                ],
              ),
            ),
          ),
          
        if (_isLoadingRoute) const Center(child: Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))),
      ],
    );
  }
}