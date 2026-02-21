import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';

const _categories = [
  'All',
  'Overcrowding',
  'Harassment',
  'Delay',
  'Infrastructure',
  'Suspicious Activity',
  'Theft',
];

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All'
        ? MockData.communityReports
        : MockData.communityReports
            .where((r) => r.category == _filter)
            .toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter card
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
                Row(
                  children: const [
                    Icon(Icons.filter_list,
                        size: 16, color: AppColors.mutedForeground),
                    SizedBox(width: 8),
                    Text('Filter by Category',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((c) {
                    final isActive = _filter == c;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.white
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reports
          Row(
            children: [
              const Icon(Icons.people, size: 16),
              const SizedBox(width: 8),
              Text('Community Reports (${filtered.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),

          ...filtered.map((r) {
            Color iconBg, iconColor;
            if (r.severity >= 4) {
              iconBg = AppColors.danger.withOpacity(0.1);
              iconColor = AppColors.danger;
            } else if (r.severity >= 3) {
              iconBg = AppColors.warning.withOpacity(0.1);
              iconColor = AppColors.warning;
            } else {
              iconBg = AppColors.primary.withOpacity(0.1);
              iconColor = AppColors.primary;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.warning_amber,
                        size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: iconBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                r.category,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: iconColor),
                              ),
                            ),
                            Text(r.time,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedForeground)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.visibility_off,
                                    size: 12,
                                    color: AppColors.mutedForeground),
                                SizedBox(width: 2),
                                Text('Anon',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.mutedForeground)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.desc,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground)),
                        const SizedBox(height: 6),
                        Row(
                          children: List.generate(5, (i) {
                            return Container(
                              width: 16,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: i < r.severity
                                    ? AppColors.danger
                                    : AppColors.muted,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
