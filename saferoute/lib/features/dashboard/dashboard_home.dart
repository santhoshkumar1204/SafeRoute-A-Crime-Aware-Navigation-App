import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/chart_placeholder.dart';
import '../../core/widgets/map_widget.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/firebase_providers.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final riskState = ref.watch(riskProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${user?.name ?? 'User'}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your safety & transport overview for today.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          _buildStatsGrid(riskState),
          const SizedBox(height: 16),

          // Map + chart row
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildAreaOverview()),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: ChartPlaceholder(title: 'Risk Trend (7 Days)'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    _buildAreaOverview(),
                    const SizedBox(height: 16),
                    const ChartPlaceholder(title: 'Risk Trend (7 Days)'),
                  ],
                ),
          const SizedBox(height: 16),

          // MTC Bus Intelligence
          _buildBusIntelligence(isDesktop),
          const SizedBox(height: 16),

          // Event alerts
          if (MockData.events.isNotEmpty) ...[
            _buildEventAlerts(),
            const SizedBox(height: 16),
          ],

          // Crime Density + Community
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: ChartPlaceholder(
                        title: 'Crime Density by Area',
                        height: 250,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildCommunityActivity()),
                  ],
                )
              : Column(
                  children: [
                    const ChartPlaceholder(
                      title: 'Crime Density by Area',
                      height: 250,
                    ),
                    const SizedBox(height: 16),
                    _buildCommunityActivity(),
                  ],
                ),
          const SizedBox(height: 16),

          // Green Mobility
          _buildGreenMobility(ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(RiskState riskState) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 600;
      final cards = [
        StatCard(
          icon: Icons.shield,
          label: "Today's Safety Score",
          value: '${riskState.todaySafetyScore}%',
          colorType: 'safe',
        ),
        StatCard(
          icon: Icons.warning_amber,
          label: 'Nearby High Risk Areas',
          value: '${riskState.nearbyHighRiskAreas}',
          colorType: 'danger',
        ),
        StatCard(
          icon: Icons.notifications,
          label: 'Recent Alerts',
          value: '${riskState.recentAlerts}',
          colorType: 'warning',
        ),
        StatCard(
          icon: Icons.route,
          label: 'Trips This Week',
          value: '${riskState.tripsThisWeek}',
          colorType: 'primary',
        ),
      ];

      if (isWide) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: constraints.maxWidth >= 1024 ? 4 : 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.4,
          children: cards,
        );
      }
      return Column(
        children: cards
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: c,
                ))
            .toList(),
      );
    });
  }

  Widget _buildAreaOverview() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Area Overview',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: MapWidget(
            showHeatmap: true,
            showRoute: true,
            showPoliceStations: false,
          ),
        ),
      ],
    );
  }

  Widget _buildBusIntelligence(bool isDesktop) {
    final nextBus = {
      'route': MockData.nextBus.route,
      'type': MockData.nextBus.type,
      'eta': MockData.nextBus.eta,
      'from': MockData.nextBus.from,
      'to': MockData.nextBus.to,
    };
    final crowd = MockData.crowdData.first;
    final delay = MockData.delayData.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.directions_bus, size: 16, color: AppColors.primary),
            SizedBox(width: 8),
            Text(
              'TN MTC Bus Intelligence',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        isDesktop
            ? Row(
                children: [
                  Expanded(child: _nextBusCard(nextBus)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.people,
                      label: 'Crowd at Nearest Stop',
                      value: '${crowd.percent}%',
                      colorType:
                          crowd.level == 'high' ? 'danger' : 'warning',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.trending_up,
                      label: 'Delay Risk (Route 21G)',
                      value: '${delay.probability}%',
                      colorType: 'warning',
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _nextBusCard(nextBus),
                  const SizedBox(height: 8),
                  StatCard(
                    icon: Icons.people,
                    label: 'Crowd at Nearest Stop',
                    value: '${crowd.percent}%',
                    colorType:
                        crowd.level == 'high' ? 'danger' : 'warning',
                  ),
                  const SizedBox(height: 8),
                  StatCard(
                    icon: Icons.trending_up,
                    label: 'Delay Risk (Route 21G)',
                    value: '${delay.probability}%',
                    colorType: 'warning',
                  ),
                ],
              ),
      ],
    );
  }

  Widget _nextBusCard(Map<String, dynamic> bus) {
    return Container(
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
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.directions_bus,
                  color: AppColors.primary, size: 28),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Next Bus',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                bus['route'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${bus['type']} · ETA: ${bus['eta']}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.mutedForeground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${bus['from']} → ${bus['to']}',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventAlerts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎪 Active Events',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...MockData.events.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            e.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${e.area} · ${e.date}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: e.impact == 'high'
                            ? AppColors.danger.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${e.congestion}% congestion',
                        style: TextStyle(
                          fontSize: 11,
                          color: e.impact == 'high'
                              ? AppColors.danger
                              : AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCommunityActivity() {
    const activities = [
      'Overcrowding reported on Bus 21G',
      'Suspicious activity near T. Nagar',
      'Street light outage at Guindy stop',
      'Bus delay at Tambaram resolved',
    ];

    return Container(
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
            'Community Activity',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ...activities.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        a,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGreenMobility(WidgetRef ref) {
    final sustainAsync = ref.watch(sustainabilityStreamProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.safe.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.safe.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, size: 16, color: AppColors.safe),
              SizedBox(width: 8),
              Text(
                'Green Mobility Impact',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 400;
            final green = sustainAsync.when(
              data: (s) => s,
              loading: () => null,
              error: (_, __) => null,
            );
            final co2 = green?.totalCO2Saved.toInt() ?? MockData.greenData.co2Saved;
            final fuel = green?.fuelSavedLiters ?? MockData.greenData.fuelSaved;
            final trips = green?.busTripsCount ?? MockData.greenData.publicTransportTrips;
            final trees = green?.treesEquivalent ?? MockData.greenData.treesEquivalent;
            final items = [
              _MiniStat('CO₂ Saved', '$co2 kg'),
              _MiniStat('Fuel Saved', '$fuel L'),
              _MiniStat('Public Transport Trips', '$trips'),
              _MiniStat('Trees Equivalent', '$trees'),
            ];

            if (isWide) {
              return Row(
                children: items
                    .map((i) => Expanded(child: _buildMiniStat(i)))
                    .toList(),
              );
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              children:
                  items.map((i) => _buildMiniStat(i)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniStat(_MiniStat stat) {
    return Column(
      children: [
        Text(
          stat.value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.safe,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mutedForeground,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _MiniStat {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);
}
