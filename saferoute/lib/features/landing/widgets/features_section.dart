import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';

class _Feature {
  final IconData icon;
  final String title;
  final String short;
  final String detail;
  final String route;
  const _Feature(this.icon, this.title, this.short, this.detail, this.route);
}

const _features = [
  _Feature(Icons.psychology, 'AI Risk Prediction Engine',
      'ML models predict crime probability for any area',
      'Leverages historical crime data, weather, time-of-day, and socioeconomic factors through ensemble ML models to generate granular risk predictions.',
      '/dashboard/analytics'),
  _Feature(Icons.route, 'Dynamic Route Scoring',
      'Real-time risk-weighted pathfinding',
      'Dijkstra-based graph optimization where edge weights dynamically update based on predicted crime risk, time, and user preferences.',
      '/dashboard/navigation'),
  _Feature(Icons.notifications_active, 'Real-Time Crime Alerts',
      'Instant notifications for nearby incidents',
      'Push notifications triggered by live crime feeds and community reports within configurable proximity radius.',
      '/dashboard'),
  _Feature(Icons.gps_fixed, 'Live GPS Monitoring',
      'Continuous safety tracking during navigation',
      'Background GPS tracking with automatic rerouting if the user deviates or new risks are detected along the current path.',
      '/dashboard/navigation'),
  _Feature(Icons.map, 'Crime Heatmap Visualization',
      'Visual crime density overlays',
      'Multi-layer heatmaps showing historical crime density, predicted risk zones, and temporal patterns with filtering controls.',
      '/dashboard/heatmap'),
  _Feature(Icons.people, 'Community Crime Reporting',
      'Crowd-sourced safety intelligence',
      'Users can report incidents, suspicious activity, and safety concerns that feed into the AI model for improved predictions.',
      '/dashboard/report'),
  _Feature(Icons.bar_chart, 'Route Risk Dashboard',
      'Detailed analytics for every route',
      'Comprehensive breakdown showing risk scores per segment, alternative comparisons, and historical safety trends.',
      '/dashboard/analytics'),
  _Feature(Icons.refresh, 'Smart Rerouting',
      'Automatic safer path suggestions',
      'When new threats emerge mid-journey, the system instantly calculates and suggests safer alternative routes.',
      '/dashboard/navigation'),
  _Feature(Icons.verified_user, 'Women Safety Mode',
      'Enhanced safety features for women',
      'Prioritizes well-lit paths, populated areas, and CCTV-covered routes. Includes quick-share location and emergency contacts.',
      '/dashboard/settings'),
  _Feature(Icons.dark_mode, 'Night Travel Mode',
      'Optimized for after-dark navigation',
      'Adjusts risk models for nighttime crime patterns, prioritizes well-lit and patrolled routes.',
      '/dashboard/navigation'),
  _Feature(Icons.phone_in_talk, 'Emergency SOS Integration',
      'One-tap emergency assistance',
      'Instantly alerts emergency contacts, shares live location, and connects to nearest emergency services.',
      '/dashboard/emergency'),
  _Feature(Icons.history, 'Safety Score History',
      'Track your safety over time',
      'Personal analytics dashboard showing trip history, cumulative risk exposure, and safety improvement trends.',
      '/dashboard/analytics'),
];

class FeaturesSection extends ConsumerStatefulWidget {
  const FeaturesSection({super.key});

  @override
  ConsumerState<FeaturesSection> createState() => _FeaturesSectionState();
}

class _FeaturesSectionState extends ConsumerState<FeaturesSection> {
  int? _selectedIndex;

  void _handleGoToFeature(String route) {
    Navigator.pop(context);
    setState(() => _selectedIndex = null);
    final isAuth = ref.read(authProvider).isAuthenticated;
    if (isAuth) {
      context.go(route);
    } else {
      context.go('/login');
    }
  }

  void _showDetail(int index) {
    setState(() => _selectedIndex = index);
    final isAuth = ref.read(authProvider).isAuthenticated;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_features[index].icon,
                      color: Colors.white, size: 24),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _features[index].title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _features[index].detail,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: () => _handleGoToFeature(_features[index].route),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isAuth ? 'Open Feature →' : 'Login to Access →',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _selectedIndex = null));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    int crossAxisCount = 2;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 600) {
      crossAxisCount = 3;
    }

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          const Text(
            'FEATURES',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.foreground,
              ),
              children: [
                const TextSpan(text: 'Comprehensive '),
                TextSpan(
                  text: 'Safety Platform',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = AppColors.primaryGradient
                          .createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              final f = _features[index];
              return GestureDetector(
                onTap: () => _showDetail(index),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(f.icon, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        f.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          f.short,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mutedForeground,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
