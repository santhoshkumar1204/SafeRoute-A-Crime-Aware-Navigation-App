import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/safe_route_map.dart';

class HeatmapPage extends StatefulWidget {
  const HeatmapPage({super.key});

  @override
  State<HeatmapPage> createState() => _HeatmapPageState();
}

class _HeatmapPageState extends State<HeatmapPage> {
  // Filters State
  bool _showHeatmap = true;
  bool _showPolice = true;
  bool _showAI = true;
  String _timeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. FULL SCREEN MAP BACKGROUND
          SafeRouteMap(
  showHeatmap: _showHeatmap,
  showRoute: false,
  showPoliceStations: _showPolice,
),

          // 2. TOP HEADER CARD (Title and Stats)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: _buildHeaderCard(),
          ),

          // 3. RIGHT SIDE LAYER TOGGLES
          Positioned(
            right: 15,
            top: MediaQuery.of(context).padding.top + 100,
            child: _buildLayerControls(),
          ),

          // 4. BOTTOM TIME FILTER
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _buildTimeFilterDock(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.security, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Safety Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Live Chennai Crime Data', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {}, // Future PDF Download logic
            icon: const Icon(Icons.download_for_offline, color: AppColors.primary),
          )
        ],
      ),
    );
  }

  Widget _buildLayerControls() {
    return Column(
      children: [
        _layerButton(
          icon: Icons.layers,
          label: 'Heatmap',
          active: _showHeatmap,
          onTap: () => setState(() => _showHeatmap = !_showHeatmap),
        ),
        const SizedBox(height: 10),
        _layerButton(
          icon: Icons.local_police,
          label: 'Police',
          active: _showPolice,
          onTap: () => setState(() => _showPolice = !_showPolice),
        ),
        const SizedBox(height: 10),
        _layerButton(
          icon: Icons.psychology,
          label: 'AI Pred.',
          active: _showAI,
          onTap: () => setState(() => _showAI = !_showAI),
        ),
      ],
    );
  }

  Widget _layerButton({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 65,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? Colors.white : Colors.black87, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: active ? Colors.white : Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeFilterDock() {
    final times = [
      {'key': 'all', 'label': 'All Day', 'icon': Icons.wb_sunny_outlined},
      {'key': 'morning', 'label': 'Morning', 'icon': Icons.wb_twilight},
      {'key': 'evening', 'label': 'Evening', 'icon': Icons.nightlight_round},
      {'key': 'night', 'label': 'Late Night', 'icon': Icons.bedtime},
    ];

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: times.map((t) {
            bool isSelected = _timeFilter == t['key'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                showCheckmark: false,
                label: Text(t['label'] as String),
                avatar: Icon(t['icon'] as IconData, size: 16, color: isSelected ? Colors.white : Colors.black54),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.transparent,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                onSelected: (s) => setState(() => _timeFilter = t['key'] as String),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}