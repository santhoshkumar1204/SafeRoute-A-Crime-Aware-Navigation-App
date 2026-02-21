import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;

  const ChartPlaceholder({
    super.key,
    required this.title,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    final bars = [40, 65, 45, 80, 55, 70, 90, 60, 75, 50, 85, 42];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: height,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.muted.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars.map((h) {
                  return Container(
                    width: 12,
                    height: max(8, height * h / 100),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
