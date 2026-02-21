import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class ProblemSolutionSection extends StatelessWidget {
  const ProblemSolutionSection({super.key});

  static const _points = [
    _Point(Icons.psychology, 'Spatio-Temporal Crime Analysis',
        'Analyze crime patterns across space and time'),
    _Point(Icons.shield, 'ML-Based Risk Prediction',
        'Machine learning models predict area risk levels'),
    _Point(Icons.route, 'Dynamic Route Weighting',
        'Graph algorithms find optimally safe routes'),
    _Point(Icons.warning_amber, 'Real-Time Alerts',
        'Live monitoring with instant notifications'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: _buildImage()),
                    const SizedBox(width: 64),
                    Expanded(child: _buildContent()),
                  ],
                )
              : Column(
                  children: [
                    _buildImage(),
                    const SizedBox(height: 40),
                    _buildContent(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Image.asset(
        AppImages.problemSolution,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'WHY SAFEROUTE?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
            children: [
              const TextSpan(text: 'Shortest Route ≠ '),
              TextSpan(
                text: 'Safest Route',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = AppColors.primaryGradient
                        .createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Traditional navigation ignores crime data entirely. SafeRoute integrates AI-driven crime intelligence to protect every journey.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.mutedForeground,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        ..._points.map((p) => _PointCard(
              icon: p.icon,
              title: p.title,
              desc: p.desc,
            )),
      ],
    );
  }
}

class _Point {
  final IconData icon;
  final String title;
  final String desc;
  const _Point(this.icon, this.title, this.desc);
}

class _PointCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _PointCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
