import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/map_widget.dart';
import '../../providers/app_state_provider.dart';

class _TransportMode {
  final String key;
  final String label;
  final IconData icon;
  const _TransportMode(this.key, this.label, this.icon);
}

const _transportModes = [
  _TransportMode('bus', 'Bus', Icons.directions_bus),
  _TransportMode('car', 'Car', Icons.directions_car),
  _TransportMode('bike', 'Two-wheeler', Icons.two_wheeler),
  _TransportMode('walk', 'Walking', Icons.directions_walk),
];

class _RouteMode {
  final String key;
  final String label;
  final IconData icon;
  final String desc;
  const _RouteMode(this.key, this.label, this.icon, this.desc);
}

const _routeModes = [
  _RouteMode('safest', 'Safest', Icons.shield, 'Avoids all high-risk zones'),
  _RouteMode(
      'balanced', 'Balanced', Icons.navigation, 'Balance of safety & speed'),
  _RouteMode('fastest', 'Fastest', Icons.access_time, 'Shortest travel time'),
];

class NavigationPage extends ConsumerStatefulWidget {
  const NavigationPage({super.key});

  @override
  ConsumerState<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends ConsumerState<NavigationPage> {
  late String _source;
  late String _destination;
  String _transport = 'bus';
  String _busType = 'all';
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    final rs = ref.read(routeProvider);
    _source = rs.source;
    _destination = rs.destination;
  }

  void _handleStart() {
    ref.read(routeProvider.notifier).setSource(_source);
    ref.read(routeProvider.notifier).setDestination(_destination);
    setState(() => _navigating = true);
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(routeProvider);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 350, child: _buildControls(routeState)),
          const SizedBox(width: 16),
          Expanded(child: _buildMapSection()),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildControls(routeState),
          const SizedBox(height: 16),
          SizedBox(height: 500, child: _buildMapSection()),
        ],
      ),
    );
  }

  Widget _buildControls(RouteState routeState) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
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
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'AI-powered navigation with crime & transport intelligence',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android,
                      color: AppColors.primary, size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Route planner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
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
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Transport mode
                Row(
                  children: _transportModes.map((m) {
                    final isSelected = _transport == m.key;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _transport = m.key),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.muted.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: m.key == 'bus' && !isSelected
                                ? Border.all(
                                    color:
                                        AppColors.primary.withOpacity(0.2))
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(m.icon,
                                  size: 18,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.foreground),
                              const SizedBox(height: 4),
                              Text(
                                m.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.foreground,
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
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedForeground)),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _busType,
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.foreground),
                        items: const [
                          DropdownMenuItem(
                              value: 'all', child: Text('All Types')),
                          DropdownMenuItem(
                              value: 'ordinary',
                              child: Text('Ordinary')),
                          DropdownMenuItem(
                              value: 'express', child: Text('Express')),
                          DropdownMenuItem(
                              value: 'ac', child: Text('Deluxe/AC')),
                          DropdownMenuItem(
                              value: 'mini', child: Text('Mini Bus')),
                          DropdownMenuItem(
                              value: 'special',
                              child: Text('Special/Event')),
                        ],
                        onChanged: (v) =>
                            setState(() => _busType = v ?? 'all'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Source / Destination
                _locationField(
                  icon: Icons.location_on,
                  iconColor: AppColors.safe,
                  hint: 'Source location',
                  value: _source,
                  onChanged: (v) => _source = v,
                ),
                const SizedBox(height: 10),
                _locationField(
                  icon: Icons.location_on,
                  iconColor: AppColors.danger,
                  hint: 'Destination',
                  value: _destination,
                  onChanged: (v) => _destination = v,
                ),
                const SizedBox(height: 16),

                // Route mode
                const Text('Route Mode',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedForeground)),
                const SizedBox(height: 8),
                ..._routeModes.map((m) {
                  final isSelected = routeState.mode == m.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(routeProvider.notifier)
                          .setMode(m.key),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.muted.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(m.icon,
                                size: 18,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.foreground),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.foreground,
                                  ),
                                ),
                                Text(
                                  m.desc,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white70
                                        : AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleStart,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Start Safe Navigation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Route Risk Score
          // Disabled until wired to backend

          // Stop Intelligence (bus only)
          // Disabled to avoid showing mock data
        ],
      ),
    );
  }

  Widget _locationField({
    required IconData icon,
    required Color iconColor,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: iconColor),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Widget _buildRouteRiskScore() {
    return const SizedBox.shrink();
  }

  Widget _buildStopIntelligence() {
    return const SizedBox.shrink();
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        const Expanded(
          child: MapWidget(
            showHeatmap: true,
            showRoute: true,
            showPoliceStations: true,
          ),
        ),
      ],
    );
  }
}
