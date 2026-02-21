import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/chart_placeholder.dart';
import '../../data/mock_data.dart';
import '../../providers/firebase_providers.dart';

class AnalyticsPage extends ConsumerWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats
          _buildStatsGrid(isDesktop, ref),
          const SizedBox(height: 16),

          // Crime Analytics header
          const Row(
            children: [
              Text('🔍 ', style: TextStyle(fontSize: 14)),
              Text('Crime Analytics',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),

          isDesktop
              ? const Row(
                  children: [
                    Expanded(
                        child: ChartPlaceholder(
                            title: 'Risk Trends (30 Days)', height: 250)),
                    SizedBox(width: 16),
                    Expanded(
                        child: ChartPlaceholder(
                            title: 'Time-Based Crime Patterns',
                            height: 250)),
                  ],
                )
              : const Column(
                  children: [
                    ChartPlaceholder(
                        title: 'Risk Trends (30 Days)', height: 250),
                    SizedBox(height: 16),
                    ChartPlaceholder(
                        title: 'Time-Based Crime Patterns', height: 250),
                  ],
                ),
          const SizedBox(height: 16),

          // Hotspot Clusters
          _buildHotspotClusters(isDesktop),
          const SizedBox(height: 16),

          // Transport Analytics header
          const Row(
            children: [
              Icon(Icons.directions_bus, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Transport Analytics',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),

          isDesktop
              ? const Row(
                  children: [
                    Expanded(
                        child: ChartPlaceholder(
                            title: 'Bus Punctuality Trends',
                            height: 220)),
                    SizedBox(width: 16),
                    Expanded(
                        child: ChartPlaceholder(
                            title: 'Peak Hour Congestion', height: 220)),
                  ],
                )
              : const Column(
                  children: [
                    ChartPlaceholder(
                        title: 'Bus Punctuality Trends', height: 220),
                    SizedBox(height: 16),
                    ChartPlaceholder(
                        title: 'Peak Hour Congestion', height: 220),
                  ],
                ),
          const SizedBox(height: 16),

          // Crowd + Delay
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildCrowdHeatmap()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildDelayRanking()),
                  ],
                )
              : Column(
                  children: [
                    _buildCrowdHeatmap(),
                    const SizedBox(height: 16),
                    _buildDelayRanking(),
                  ],
                ),
          const SizedBox(height: 16),

          // Risk History table
          _buildRiskHistory(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDesktop, WidgetRef ref) {
    final tripsAsync = ref.watch(tripsStreamProvider);

    String avgSafety = '—';
    String totalTrips = '—';

    tripsAsync.whenData((trips) {
      if (trips.isNotEmpty) {
        final avg = trips.fold<int>(0, (s, t) => s + t.riskScore) ~/ trips.length;
        avgSafety = '$avg%';
      }
      totalTrips = '${trips.length}';
    });

    final cards = [
      StatCard(
          icon: Icons.shield,
          label: 'Avg Trip Safety',
          value: avgSafety,
          colorType: 'safe'),
      const StatCard(
          icon: Icons.trending_up,
          label: 'Monthly Risk Exposure',
          value: 'Low',
          colorType: 'primary'),
      StatCard(
          icon: Icons.location_on,
          label: 'Total Trips',
          value: totalTrips,
          colorType: 'warning'),
      const StatCard(
          icon: Icons.bar_chart,
          label: 'Safety Improvement',
          value: '+12%',
          colorType: 'safe'),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isDesktop ? 2.4 : 2.0,
      children: cards,
    );
  }

  Widget _buildHotspotClusters(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hotspot Clusters',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 4 : 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: MockData.crimeData.map((c) {
              Color badgeColor;
              Color bgColor;
              if (c.riskLevel == 'high') {
                badgeColor = AppColors.danger;
                bgColor = AppColors.danger.withOpacity(0.1);
              } else if (c.riskLevel == 'moderate') {
                badgeColor = AppColors.warning;
                bgColor = AppColors.warning.withOpacity(0.1);
              } else {
                badgeColor = AppColors.safe;
                bgColor = AppColors.safe.withOpacity(0.1);
              }
              final arrow =
                  c.trend == 'up' ? '↑' : c.trend == 'down' ? '↓' : '→';

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.area,
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Text('${c.incidents} incidents',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$arrow ${c.riskLevel}',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: badgeColor),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdHeatmap() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.people, size: 16),
              SizedBox(width: 8),
              Text('Crowd Heatmap by Stop',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          ...MockData.crowdData.map((c) {
            Color barColor;
            if (c.level == 'high') {
              barColor = AppColors.danger;
            } else if (c.level == 'moderate') {
              barColor = AppColors.warning;
            } else {
              barColor = AppColors.safe;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(c.stop,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.muted.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: c.percent / 100,
                        child: Container(
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('${c.percent}%',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDelayRanking() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, size: 16),
              SizedBox(width: 8),
              Text('Route Delay Ranking',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          ...MockData.delayData.map((d) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(d.route,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500)),
                        Text(
                          '${d.probability}% delay',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: d.probability >= 60
                                ? AppColors.danger
                                : d.probability >= 30
                                    ? AppColors.warning
                                    : AppColors.safe,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(d.reason,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.mutedForeground)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRiskHistory() {
    final history = [
      {
        'date': 'Feb 20',
        'route': 'Tambaram → Broadway (21G)',
        'score': '23%',
        'level': 'Low'
      },
      {
        'date': 'Feb 19',
        'route': 'T. Nagar → Guindy (27C)',
        'score': '41%',
        'level': 'Moderate'
      },
      {
        'date': 'Feb 18',
        'route': 'Home → Anna Nagar',
        'score': '18%',
        'level': 'Low'
      },
      {
        'date': 'Feb 17',
        'route': 'Egmore → Downtown',
        'score': '67%',
        'level': 'High'
      },
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Risk History',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.mutedForeground,
              ),
              dataTextStyle: const TextStyle(fontSize: 12),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Route')),
                DataColumn(label: Text('Risk Score')),
                DataColumn(label: Text('Level')),
              ],
              rows: history.map((r) {
                Color badgeColor;
                Color bgColor;
                if (r['level'] == 'High') {
                  badgeColor = AppColors.danger;
                  bgColor = AppColors.danger.withOpacity(0.1);
                } else if (r['level'] == 'Moderate') {
                  badgeColor = AppColors.warning;
                  bgColor = AppColors.warning.withOpacity(0.1);
                } else {
                  badgeColor = AppColors.safe;
                  bgColor = AppColors.safe.withOpacity(0.1);
                }

                return DataRow(cells: [
                  DataCell(Text(r['date']!)),
                  DataCell(Text(r['route']!,
                      style:
                          const TextStyle(color: AppColors.mutedForeground))),
                  DataCell(Text(r['score']!,
                      style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(r['level']!,
                        style: TextStyle(
                            fontSize: 11,
                            color: badgeColor,
                            fontWeight: FontWeight.w500)),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
