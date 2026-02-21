import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/safe_route_map.dart';
import '../../providers/app_state_provider.dart';
// Note: Ensure firebase_providers.dart and routeProvider exist and match this usage.
import '../../providers/firebase_providers.dart';

class _SimpleStop {
  final String name;
  final LatLng coords;

  _SimpleStop({required this.name, required this.coords});
}

// Helper class for UI mode selections
class _UiMode {
  final String key;
  final IconData icon;
  final String label;
  final String desc;
  _UiMode(this.key, this.icon, this.label, [this.desc = '']);
}

class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  bool _showHeatmap = true;
  bool _showRoute = true;
  bool _showPolice = true;

  // State variables for routing
  List<_SimpleStop> _busStops = [];
  _SimpleStop? _sourceStop;
  _SimpleStop? _destStop;
  bool _isLoading = true;

  // ML/Transport State
  String _transport = 'bus';
  String _busType = 'all';

  // Definitions for UI
  final List<_UiMode> _transportModes = [
    _UiMode('bus', Icons.directions_bus, 'Bus'),
    _UiMode('walk', Icons.directions_walk, 'Walk'),
    _UiMode('auto', Icons.local_taxi, 'Auto'),
  ];

  final List<_UiMode> _routeModes = [
    _UiMode('fastest', Icons.flash_on, 'Fastest', 'Quickest estimated arrival'),
    _UiMode('balanced', Icons.balance, 'Balanced', 'Good mix of speed & safety'),
    _UiMode('safest', Icons.shield, 'Safest', 'Prioritizes well-lit, low-risk paths'),
  ];

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
      setState(() { 
        _busStops = uniqueStops.values.toList(); 
        _isLoading = false; 
      });
    } catch (e) {
      debugPrint("CSV Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assuming routeProvider exposes a state object with a 'mode' string property.
    final routeState = ref.watch(routeProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 380, child: _buildControls(routeState)),
                      Expanded(child: _buildMapSection()),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildControls(routeState),
                      ),
                      Expanded(
                        flex: 6,
                        child: _buildMapSection(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildControls(dynamic routeState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ML Hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white, // Fallback if AppColors.card is null
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Route Scanner',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AI-powered navigation with crime & transport intelligence',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology, color: Colors.blue, size: 28),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Route planner Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plan Your Route',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),

                // Transport mode
                Row(
                  children: _transportModes.map((m) {
                    final isSelected = _transport == m.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _transport = m.key),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                m.icon,
                                size: 18,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Bus type filter
                if (_transport == 'bus') ...[
                  const Text('Bus Type',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _busType,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Types')),
                          DropdownMenuItem(value: 'ordinary', child: Text('Ordinary')),
                          DropdownMenuItem(value: 'express', child: Text('Express')),
                          DropdownMenuItem(value: 'ac', child: Text('Deluxe/AC')),
                          DropdownMenuItem(value: 'mini', child: Text('Mini Bus')),
                          DropdownMenuItem(value: 'special', child: Text('Special/Event')),
                        ],
                        onChanged: (v) => setState(() => _busType = v ?? 'all'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Source / Destination Autocomplete Fields
                _buildSearchField("Start Location", Icons.my_location, true),
                const SizedBox(height: 12),
                _buildSearchField("Destination", Icons.location_on, false),
                const SizedBox(height: 20),

                // Route mode using Riverpod
                const Text('Route Mode',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ..._routeModes.map((m) {
                  // Assuming routeState has a mode property. Fallback to 'safest'.
                  final currentMode = routeState.mode ?? 'safest'; 
                  final isSelected = currentMode == m.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () {
                        // Notify your Riverpod state
                        ref.read(routeProvider.notifier).setMode(m.key);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E293B) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                          )
                        ),
                        child: Row(
                          children: [
                            Icon(m.icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.label,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : const Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    m.desc,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? Colors.grey.shade300 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Safety UI blocks if stops are selected
          if (_sourceStop != null && _destStop != null) ...[
            _buildRiskScoreCard(),
            const SizedBox(height: 12),
            _buildRiskAlertBanner(),
            const SizedBox(height: 16),
          ],

          // Map Overlays
          const Text("Safety Overlays", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          SwitchListTile(
            dense: true, contentPadding: EdgeInsets.zero,
            title: const Text("Crime Risk Heatmaps", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
            value: _showHeatmap, onChanged: (val) => setState(() => _showHeatmap = val),
            activeColor: Colors.blueAccent,
          ),
          SwitchListTile(
            dense: true, contentPadding: EdgeInsets.zero,
            title: const Text("Safe Zones & Police Stations", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
            value: _showPolice, onChanged: (val) => setState(() => _showPolice = val),
            activeColor: Colors.blueAccent,
          ),
          SwitchListTile(
            dense: true, contentPadding: EdgeInsets.zero,
            title: const Text("Show Navigation Line", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
            value: _showRoute, onChanged: (val) => setState(() => _showRoute = val),
            activeColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    // Determine route color based on Riverpod state if available
    final routeMode = ref.watch(routeProvider).mode ?? 'safest';
    final activeRouteColor = routeMode == 'safest' ? Colors.green : Colors.blueAccent;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: SafeRouteMap(
        sourceCoords: _sourceStop?.coords,
        destCoords: _destStop?.coords,
        showHeatmap: _showHeatmap,
        showPoliceStations: _showPolice,
        showRoute: _showRoute,
        routeColor: activeRouteColor,
      ),
    );
  }

  // Adapted Autocomplete widget from your HEAD branch to fit the layout perfectly
  Widget _buildSearchField(String label, IconData icon, bool isSource) {
    return Autocomplete<_SimpleStop>(
      optionsBuilder: (textValue) {
        if (textValue.text.isEmpty) return const Iterable<_SimpleStop>.empty();
        return _busStops.where((s) => s.name.toLowerCase().contains(textValue.text.toLowerCase()));
      },
      displayStringForOption: (s) => s.name,
      onSelected: (selection) => setState(() => isSource ? _sourceStop = selection : _destStop = selection),
      fieldViewBuilder: (context, controller, node, onSubmitted) {
        return TextField(
          controller: controller, 
          focusNode: node,
          decoration: InputDecoration(
            labelText: label, 
            labelStyle: const TextStyle(fontSize: 13),
            prefixIcon: Icon(icon, color: isSource ? Colors.blue : Colors.red, size: 20),
            filled: true, 
            fillColor: const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        );
      },
    );
  }

  Widget _buildRiskScoreCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.green.shade50, Colors.white]), 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.green.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text("Route Safety Score", style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("92 / 100", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.green)),
            ]
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.verified_user, color: Colors.green, size: 28),
          )
        ],
      ),
    );
  }

  Widget _buildRiskAlertBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.orange.shade200)
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Low lighting reported 2km near destination. AI rerouting active.", 
              style: TextStyle(fontSize: 12, color: Colors.deepOrange, fontWeight: FontWeight.w600)
            )
          ),
        ]
      ),
    );
  }
}