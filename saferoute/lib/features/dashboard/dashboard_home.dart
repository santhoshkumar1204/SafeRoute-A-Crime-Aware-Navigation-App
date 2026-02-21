import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/chart_placeholder.dart';
import '../../core/widgets/map_widget.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accessing state from your providers
    final authState = ref.watch(authProvider);
    final riskState = ref.watch(riskProvider); // Updated to match your state provider

    final user = authState.user;
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(user),
          const SizedBox(height: 16),
          _buildStatsGrid(riskState),
          const SizedBox(height: 16),

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

          _buildBusIntelligence(isDesktop),
          const SizedBox(height: 16),

          if (MockData.events.isNotEmpty) ...[
            _buildEventAlerts(),
            const SizedBox(height: 16),
          ],

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

          _buildGreenMobility(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(dynamic user) {
    final name = user?.name ?? 'User';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Welcome back, $name 👋',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic riskState) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Area Overview',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        MapWidget(
          showHeatmap: true,
          showRoute: true,
          showPoliceStations: false,
          height: 350,
          isInteractive: true, // Enables the source/destination picking
        ),
      ],
    );
  }

  Widget _buildBusIntelligence(bool isDesktop) {
    final nextBus = MockData.nextBus;
    final crowd = MockData.crowdData.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MTC Intelligence',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.directions_bus, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${nextBus.route} • ETA: ${nextBus.eta}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Crowd Level: ${crowd.percent}% full',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventAlerts() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🎪 Active Events', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...MockData.events.map((e) => Text('• ${e.name} at ${e.area}')),
        ],
      ),
    );
  }

  Widget _buildCommunityActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Community Activity', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text('• Overcrowding reported on 21G', style: TextStyle(fontSize: 12)),
          SizedBox(height: 8),
          Text('• Street light out near Guindy', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildGreenMobility() {
    const green = MockData.greenData;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.safe.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat('CO₂ Saved', '${green.co2Saved}kg'),
          _buildMiniStat('Trees Eq.', '${green.treesEquivalent}'),
          _buildMiniStat('Trips', '${green.publicTransportTrips}'),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.safe)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}