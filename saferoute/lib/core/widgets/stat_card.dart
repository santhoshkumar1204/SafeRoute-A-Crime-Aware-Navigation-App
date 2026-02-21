import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'custom_card.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String colorType;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.colorType = 'primary',
  });

  Color get _iconColor {
    switch (colorType) {
      case 'safe':
        return AppColors.safe;
      case 'danger':
        return AppColors.danger;
      case 'warning':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color get _bgColor {
    switch (colorType) {
      case 'safe':
        return AppColors.safeBg;
      case 'danger':
        return AppColors.dangerBg;
      case 'warning':
        return AppColors.warningBg;
      default:
        return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: _iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
