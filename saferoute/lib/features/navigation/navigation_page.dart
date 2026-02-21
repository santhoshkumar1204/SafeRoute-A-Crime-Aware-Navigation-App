

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:csv/csv.dart';
// import 'package:latlong2/latlong.dart';
// import '../../core/widgets/safe_route_map.dart';

// class BusStop {
//   final String name;
//   final LatLng coords;
//   BusStop({required this.name, required this.coords});
// }

// class NavigationScreen extends StatefulWidget {
//   const NavigationScreen({super.key});

//   @override
//   State<NavigationScreen> createState() => _NavigationScreenState();
// }

// class _NavigationScreenState extends State<NavigationScreen> {
//   bool _showHeatmap = true;
//   bool _showRoute = true;
//   bool _showPolice = true;
//   String _selectedRouteMode = 'Safest'; // Fastest, Balanced, Safest

//   List<BusStop> _busStops = [];
//   BusStop? _sourceStop;
//   BusStop? _destStop;
  
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCSVData();
//   }

//   Future<void> _loadCSVData() async {
//     try {
//       final String csvString = await rootBundle.loadString('assets/structured_bus_segments.csv');
//       List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n').convert(csvString);
      
//       if (csvTable.isEmpty) return;

//       final headers = csvTable.first.map((e) => e.toString().trim()).toList();
//       final stopIdx = headers.indexOf('start_stop_name');
//       final latIdx = headers.indexOf('start_lat');
//       final lonIdx = headers.indexOf('start_lon');

//       if (stopIdx == -1 || latIdx == -1 || lonIdx == -1) return;

//       Map<String, BusStop> uniqueStops = {};
//       for (int i = 1; i < csvTable.length; i++) {
//         final row = csvTable[i];
//         if (row.length <= lonIdx) continue;
        
//         final stopName = row[stopIdx].toString().trim();
//         final lat = double.tryParse(row[latIdx].toString());
//         final lon = double.tryParse(row[lonIdx].toString());

//         if (lat != null && lon != null && stopName.isNotEmpty && !uniqueStops.containsKey(stopName)) {
//           uniqueStops[stopName] = BusStop(name: stopName, coords: LatLng(lat, lon));
//         }
//       }
//       setState(() {
//         _busStops = uniqueStops.values.toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       debugPrint("CSV Error: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8FAFC),
//       body: SafeArea(
//         child: Row(
//           children: [
//             // LEFT SIDEBAR
//             Container(
//               width: 380,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
//               ),
//               child: _isLoading 
//                 ? const Center(child: CircularProgressIndicator())
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text("Plan Your Route", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
//                       const SizedBox(height: 24),
                      
//                       // AUTOCOMPLETE SEARCH FIELDS
//                       _buildSearchField("Start Location", Icons.my_location, true),
//                       const SizedBox(height: 12),
//                       _buildSearchField("Destination", Icons.location_on, false),
                      
//                       const SizedBox(height: 24),
                      
//                       // ROUTE MODES
//                       const Text("Route Mode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           _buildRouteModeBtn("Fastest", Icons.flash_on),
//                           const SizedBox(width: 8),
//                           _buildRouteModeBtn("Balanced", Icons.balance),
//                           const SizedBox(width: 8),
//                           _buildRouteModeBtn("Safest", Icons.shield),
//                         ],
//                       ),
                      
//                       const SizedBox(height: 24),
//                       const Divider(),
//                       const SizedBox(height: 12),

//                       // RISK SCORE & ALERTS
//                       if (_sourceStop != null && _destStop != null) ...[
//                         _buildRiskScoreCard(),
//                         const SizedBox(height: 16),
//                         _buildRiskAlertBanner(),
//                         const SizedBox(height: 24),
//                       ],

//                       // TOGGLES
//                       const Text("Safety Overlays", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
//                       SwitchListTile(
//                         contentPadding: EdgeInsets.zero,
//                         title: const Text("Crime Risk Heatmaps", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//                         activeColor: Colors.blueAccent,
//                         value: _showHeatmap,
//                         onChanged: (val) => setState(() => _showHeatmap = val),
//                       ),
//                       SwitchListTile(
//                         contentPadding: EdgeInsets.zero,
//                         title: const Text("Police Stations & Safe Zones", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//                         activeColor: Colors.blueAccent,
//                         value: _showPolice,
//                         onChanged: (val) => setState(() => _showPolice = val),
//                       ),
//                       SwitchListTile(
//                         contentPadding: EdgeInsets.zero,
//                         title: const Text("Show Navigation Polyline", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//                         activeColor: Colors.blueAccent,
//                         value: _showRoute,
//                         onChanged: (val) => setState(() => _showRoute = val),
//                       ),
//                     ],
//                   ),
//             ),

//             // RIGHT MAP AREA
//             Expanded(
//               child: ClipRRect(
//                 borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30)),
//                 child: SafeRouteMap(
//                   sourceCoords: _sourceStop?.coords,
//                   destCoords: _destStop?.coords,
//                   showHeatmap: _showHeatmap,
//                   showPoliceStations: _showPolice,
//                   showRoute: _showRoute,
//                   routeColor: _selectedRouteMode == 'Safest' ? Colors.green : Colors.blueAccent,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // UI HELPERS
//   Widget _buildSearchField(String label, IconData icon, bool isSource) {
//     return Autocomplete<BusStop>(
//       optionsBuilder: (TextEditingValue textEditingValue) {
//         if (textEditingValue.text.isEmpty) return const Iterable<BusStop>.empty();
//         return _busStops.where((stop) => stop.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
//       },
//       displayStringForOption: (BusStop option) => option.name,
//       onSelected: (BusStop selection) {
//         setState(() {
//           if (isSource) _sourceStop = selection;
//           else _destStop = selection;
//         });
//       },
//       fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
//         return TextField(
//           controller: textEditingController,
//           focusNode: focusNode,
//           decoration: InputDecoration(
//             labelText: label,
//             prefixIcon: Icon(icon, color: isSource ? Colors.blue : Colors.red),
//             filled: true,
//             fillColor: const Color(0xFFF1F5F9),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRouteModeBtn(String title, IconData icon) {
//     bool isSelected = _selectedRouteMode == title;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => setState(() => _selectedRouteMode = title),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             color: isSelected ? const Color(0xFF1E293B) : Colors.white,
//             border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade300),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Column(
//             children: [
//               Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade600),
//               const SizedBox(height: 4),
//               Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade600)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRiskScoreCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.green.shade200),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Route Risk Score", style: TextStyle(fontSize: 13, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
//               SizedBox(height: 4),
//               Text("92 / 100", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green)),
//             ],
//           ),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
//             child: const Icon(Icons.verified_user, color: Colors.green, size: 28),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildRiskAlertBanner() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.orange.shade200),
//       ),
//       child: const Row(
//         children: [
//           Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
//           SizedBox(width: 12),
//           Expanded(child: Text("Risk Zone Ahead: Low lighting reported 2km near destination. Rerouting active.", style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w600))),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:latlong2/latlong.dart';
import '../../core/widgets/safe_route_map.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}
class _SimpleStop {
  final String name;
  final LatLng coords;

  _SimpleStop({required this.name, required this.coords});
}
class _NavigationScreenState extends State<NavigationScreen> {
  bool _showHeatmap = true;
  bool _showRoute = true;
  bool _showPolice = true;
  String _selectedRouteMode = 'Safest';

  List<_SimpleStop> _busStops = [];
_SimpleStop? _sourceStop;
_SimpleStop? _destStop;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCSVData();
  }

  Future<void> _loadCSVData() async {
    try {
      final String csvString = await rootBundle.loadString('assets/structured_bus_segments.csv');
      List<List<dynamic>> csvTable = const CsvToListConverter(eol: '\n').convert(csvString);
      if (csvTable.isEmpty) return;
      final headers = csvTable.first.map((e) => e.toString().trim()).toList();
      final stopIdx = headers.indexOf('start_stop_name');
      final latIdx = headers.indexOf('start_lat');
      final lonIdx = headers.indexOf('start_lon');

      Map<String, _SimpleStop> uniqueStops = {};
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        final stopName = row[stopIdx].toString().trim();
        final lat = double.tryParse(row[latIdx].toString());
        final lon = double.tryParse(row[lonIdx].toString());
        if (lat != null && lon != null && stopName.isNotEmpty && !uniqueStops.containsKey(stopName)) {
          uniqueStops[stopName] = _SimpleStop(
  name: stopName,
  coords: LatLng(lat, lon),
);
        }
      }
      setState(() { _busStops = uniqueStops.values.toList(); _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column( // CHANGED Row to Column for Note 20
          children: [
            // TOP SECTION (Formerly Sidebar) - Now Scrollable to prevent overflow
            Flexible(
              flex: 1, // Takes up appropriate space based on content
              child: SingleChildScrollView( // FIX: Prevents bottom overflow
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Plan Your Route", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    const SizedBox(height: 16),
                    _buildSearchField("Start Location", Icons.my_location, true),
                    const SizedBox(height: 10),
                    _buildSearchField("Destination", Icons.location_on, false),
                    const SizedBox(height: 16),
                    const Text("Route Mode", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRouteModeBtn("Fastest", Icons.flash_on),
                        const SizedBox(width: 8),
                        _buildRouteModeBtn("Balanced", Icons.balance),
                        const SizedBox(width: 8),
                        _buildRouteModeBtn("Safest", Icons.shield),
                      ],
                    ),
                    if (_sourceStop != null && _destStop != null) ...[
                      const SizedBox(height: 16),
                      _buildRiskScoreCard(),
                      const SizedBox(height: 10),
                      _buildRiskAlertBanner(),
                    ],
                    const SizedBox(height: 16),
                    const Text("Safety Overlays", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    SwitchListTile(
                      dense: true, contentPadding: EdgeInsets.zero,
                      title: const Text("Crime Risk Heatmaps", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      value: _showHeatmap, onChanged: (val) => setState(() => _showHeatmap = val),
                    ),
                    SwitchListTile(
                      dense: true, contentPadding: EdgeInsets.zero,
                      title: const Text("Safe Zones", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      value: _showPolice, onChanged: (val) => setState(() => _showPolice = val),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM MAP AREA
            Expanded(
              flex: 1, // Map takes up the remaining half of the screen
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                child: SafeRouteMap(
                  sourceCoords: _sourceStop?.coords,
                  destCoords: _destStop?.coords,
                  showHeatmap: _showHeatmap,
                  showPoliceStations: _showPolice,
                  showRoute: _showRoute,
                  routeColor: _selectedRouteMode == 'Safest' ? Colors.green : Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(String label, IconData icon, bool isSource) {
    return Autocomplete<_SimpleStop>(
      optionsBuilder: (textValue) => textValue.text.isEmpty ? const [] : _busStops.where((s) => s.name.toLowerCase().contains(textValue.text.toLowerCase())),
      displayStringForOption: (s) => s.name,
      onSelected: (selection) => setState(() => isSource ? _sourceStop = selection : _destStop = selection),
      fieldViewBuilder: (context, controller, node, onSubmitted) {
        return TextField(
          controller: controller, focusNode: node,
          decoration: InputDecoration(
            labelText: label, prefixIcon: Icon(icon, color: isSource ? Colors.blue : Colors.red, size: 20),
            filled: true, fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        );
      },
    );
  }

  Widget _buildRouteModeBtn(String title, IconData icon) {
    bool isSelected = _selectedRouteMode == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRouteMode = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.white,
            border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
              Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskScoreCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.shade200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Safety Score", style: TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
            Text("92 / 100", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.green)),
          ]),
          Icon(Icons.verified_user, color: Colors.green, size: 24)
        ],
      ),
    );
  }

  Widget _buildRiskAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
      child: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18),
        SizedBox(width: 8),
        Expanded(child: Text("Low lighting reported 2km ahead.", style: TextStyle(fontSize: 11, color: Colors.deepOrange, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}