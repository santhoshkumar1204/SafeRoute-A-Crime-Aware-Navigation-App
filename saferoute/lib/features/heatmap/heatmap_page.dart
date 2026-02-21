// import 'package:flutter/material.dart';
// import '../../core/constants/app_colors.dart';
// import '../../core/widgets/map_widget.dart';

// class HeatmapPage extends StatefulWidget {
//   const HeatmapPage({super.key});

//   @override
//   State<HeatmapPage> createState() => _HeatmapPageState();
// }

// class _HeatmapPageState extends State<HeatmapPage> {
//   bool _showHeatmap = true;
//   bool _showAI = true;
//   String _timeFilter = 'all';
//   String _severity = 'all';

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    
//     // We pass the filter states to MapWidget
//     final map = MapWidget(
//       showHeatmap: _showHeatmap,
//       showRoute: false,
//       showPoliceStations: true,
//       height: isDesktop ? double.infinity : 450,
//     );

//     if (isDesktop) {
//       return Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(child: map),
//           const SizedBox(width: 16),
//           SizedBox(width: 280, child: SingleChildScrollView(child: _buildFilters())),
//         ],
//       );
//     }

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           map,
//           const SizedBox(height: 16),
//           _buildFilters(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilters() {
//     return Column(
//       children: [
//         // Toggle filters
//         _card(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Filters',
//                   style:
//                       TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//               const SizedBox(height: 16),
//               _toggle(
//                 label: 'Crime Heatmap',
//                 icon: Icons.layers,
//                 active: _showHeatmap,
//                 onToggle: () =>
//                     setState(() => _showHeatmap = !_showHeatmap),
//               ),
//               const SizedBox(height: 12),
//               _toggle(
//                 label: 'AI Prediction',
//                 icon: Icons.wb_sunny,
//                 active: _showAI,
//                 onToggle: () => setState(() => _showAI = !_showAI),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),

//         // Time filter
//         _card(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Row(
//                 children: [
//                   Icon(Icons.access_time, size: 16),
//                   SizedBox(width: 8),
//                   Text('Time Filter',
//                       style: TextStyle(
//                           fontWeight: FontWeight.w600, fontSize: 14)),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               ...['all', 'morning', 'afternoon', 'evening', 'night']
//                   .map((t) => _filterButton(
//                         label:
//                             t == 'all' ? 'All Day' : t[0].toUpperCase() + t.substring(1),
//                         isActive: _timeFilter == t,
//                         onTap: () => setState(() => _timeFilter = t),
//                       )),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),

//         // Severity
//         _card(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Severity',
//                   style:
//                       TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
//               const SizedBox(height: 12),
//               ...['all', 'low', 'moderate', 'high'].map((s) =>
//                   _filterButton(
//                     label: s == 'all'
//                         ? 'All Levels'
//                         : s[0].toUpperCase() + s.substring(1),
//                     isActive: _severity == s,
//                     onTap: () => setState(() => _severity = s),
//                   )),
//             ],
//           ),
//         ),
//         const SizedBox(height: 12),

//         // Download
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: () {},
//             icon: const Icon(Icons.download, size: 18),
//             label: const Text('Download PDF Report'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _card({required Widget child}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }

//   Widget _toggle({
//     required String label,
//     required IconData icon,
//     required bool active,
//     required VoidCallback onToggle,
//   }) {
//     return GestureDetector(
//       onTap: onToggle,
//       child: Row(
//         children: [
//           Icon(icon, size: 16, color: AppColors.foreground),
//           const SizedBox(width: 8),
//           Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
//           Container(
//             width: 36,
//             height: 20,
//             decoration: BoxDecoration(
//               color: active ? AppColors.primary : AppColors.muted,
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: AnimatedAlign(
//               duration: const Duration(milliseconds: 200),
//               alignment:
//                   active ? Alignment.centerRight : Alignment.centerLeft,
//               child: Container(
//                 width: 16,
//                 height: 16,
//                 margin: const EdgeInsets.symmetric(horizontal: 2),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _filterButton({
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: SizedBox(
//         width: double.infinity,
//         child: TextButton(
//           onPressed: onTap,
//           style: TextButton.styleFrom(
//             backgroundColor:
//                 isActive ? AppColors.primary : Colors.transparent,
//             foregroundColor:
//                 isActive ? Colors.white : AppColors.foreground,
//             padding:
//                 const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8)),
//             alignment: Alignment.centerLeft,
//           ),
//           child: Text(label, style: const TextStyle(fontSize: 13)),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/map_widget.dart';

class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  bool _showHeatmap = true;
  bool _showPolice = true;
  String _timeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    final mapDisplay = MapWidget(
      showHeatmap: _showHeatmap,
      showPoliceStations: _showPolice,
      showRoute: false,
      height: isDesktop ? double.infinity : 400,
      isInteractive: false, // Heatmap is usually for viewing, not routing
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: mapDisplay),
          const SizedBox(width: 16),
          SizedBox(width: 300, child: _buildSidebar()),
        ],
      );
    }

    return Column(
      children: [
        mapDisplay,
        Expanded(child: SingleChildScrollView(child: _buildSidebar())),
      ],
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Map Layers', style: TextStyle(fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Crime Heatmap', style: TextStyle(fontSize: 14)),
            value: _showHeatmap,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _showHeatmap = v),
          ),
          SwitchListTile(
            title: const Text('Police Stations', style: TextStyle(fontSize: 14)),
            value: _showPolice,
            activeColor: Colors.blue,
            onChanged: (v) => setState(() => _showPolice = v),
          ),
          const Divider(),
          const Text('Time of Day', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['all', 'morning', 'evening', 'night'].map((t) {
              return ChoiceChip(
                label: Text(t),
                selected: _timeFilter == t,
                onSelected: (s) => setState(() => _timeFilter = t),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}