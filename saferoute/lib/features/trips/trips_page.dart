import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../../providers/firebase_providers.dart';

class TripsPage extends ConsumerWidget {
  const TripsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    final tripsAsync = ref.watch(tripsStreamProvider);

    return tripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading trips: $e')),
      data: (trips) {
        final avgSafety = trips.isEmpty
            ? 0
            : (trips.fold<int>(0, (sum, t) => sum + t.riskScore) / trips.length)
                .round();

        return SingleChildScrollView(
          child: Column(
            children: [
              // Trip stats
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: isDesktop ? 3 : 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isDesktop ? 2.8 : 3.5,
                children: [
                  StatCard(
                    icon: Icons.directions_bus,
                    label: 'Total Trips',
                    value: '${trips.length}',
                    colorType: 'primary',
                  ),
                  StatCard(
                    icon: Icons.shield,
                    label: 'Avg Safety',
                    value: '$avgSafety%',
                    colorType: 'safe',
                  ),
                  const StatCard(
                    icon: Icons.access_time,
                    label: 'Avg Distance',
                    value: '4.2 km',
                    colorType: 'warning',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent trips
              Container(
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
                    const Text('Recent Trips',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 16),
                    if (trips.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No trips yet. Start navigating to see your trip history!',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      ),
                    ...trips.map((trip) {
                      final safety = trip.riskScore;
                      Color badgeColor, bgColor;
                      if (safety >= 80) {
                        badgeColor = AppColors.safe;
                        bgColor = AppColors.safe.withOpacity(0.1);
                      } else if (safety >= 60) {
                        badgeColor = AppColors.warning;
                        bgColor = AppColors.warning.withOpacity(0.1);
                      } else {
                        badgeColor = AppColors.danger;
                        bgColor = AppColors.danger.withOpacity(0.1);
                      }

                      final dateStr = DateFormat('MMM d').format(trip.timestamp);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.muted.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on,
                                  size: 20, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${trip.source} → ${trip.destination}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500)),
                                  Text('$dateStr · ${trip.transportType}',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$safety% Safe',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: badgeColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
