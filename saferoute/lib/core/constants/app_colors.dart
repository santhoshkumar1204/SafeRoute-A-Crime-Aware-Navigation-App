import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryForeground = Colors.white;

  // Safety colors
  static const Color safe = Color(0xFF16A34A);
  static const Color safeBg = Color(0xFFDCFCE7);
  static const Color moderate = Color(0xFFF59E0B);
  static const Color moderateBg = Color(0xFFFEF3C7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerForeground = Colors.white;

  // Neutral
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Colors.white;
  static const Color foreground = Color(0xFF0F172A);
  static const Color mutedForeground = Color(0xFF64748B);
  static const Color muted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color input = Color(0xFFE2E8F0);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color riskColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'danger':
        return danger;
      case 'moderate':
      case 'warning':
        return warning;
      case 'low':
      case 'safe':
        return safe;
      default:
        return primary;
    }
  }

  static Color riskBgColor(String level) {
    switch (level.toLowerCase()) {
      case 'high':
      case 'danger':
        return dangerBg;
      case 'moderate':
      case 'warning':
        return warningBg;
      case 'low':
      case 'safe':
        return safeBg;
      default:
        return primaryLight;
    }
  }
}
