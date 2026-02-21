import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/mock_data.dart';

class TransportTypesPage extends StatefulWidget {
  const TransportTypesPage({super.key});

  @override
  State<TransportTypesPage> createState() => _TransportTypesPageState();
}

class _TransportTypesPageState extends State<TransportTypesPage> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    final busTypes = MockData.busTypes;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(24),
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
                  children: [
                    Icon(Icons.directions_bus,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('MTC Bus Types & Services',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                // Placeholder for bus types image
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.muted.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bus,
                          size: 48,
                          color: AppColors.primary.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      Text('MTC Bus Types Overview',
                          style: TextStyle(
                              color: AppColors.mutedForeground,
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Accordion list
          ...busTypes.asMap().entries.map((entry) {
            final i = entry.key;
            final bus = entry.value;
            final isExpanded = _expanded == i;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
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
                children: [
                  // Header button
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(
                        () => _expanded = isExpanded ? null : i),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.directions_bus,
                                size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(bus.type,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                Text(bus.fare,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration:
                                const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more,
                                color: AppColors.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable content
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(bus.desc,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.muted.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text('Popular Routes',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                Text(bus.routes,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
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
