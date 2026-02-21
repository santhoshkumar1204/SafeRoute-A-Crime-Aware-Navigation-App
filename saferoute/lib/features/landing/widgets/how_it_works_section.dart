import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class _Step {
  final String number;
  final String title;
  final String description;
  const _Step(this.number, this.title, this.description);
}

// Match React's step titles and descriptions exactly
const _steps = [
  _Step('01', 'Enter Source & Destination',
      'User inputs origin and destination for the trip.'),
  _Step('02', 'Routes Retrieved',
      'Multiple candidate routes are fetched from Maps API.'),
  _Step('03', 'Crime Data & ML Analysis',
      'Historical crime data is analyzed with ML models per route segment.'),
  _Step('04', 'Risk Scoring & Optimization',
      'Dynamic graph optimization assigns risk-weighted scores.'),
  _Step('05', 'Safest Route Selected',
      'The optimal balance of safety, distance and time is recommended.'),
  _Step('06', 'Real-Time Monitoring',
      'Continuous GPS tracking with live risk alerts during navigation.'),
  _Step('07', 'Feedback & Learning',
      'User feedback and trip data improve future predictions.'),
];

class HowItWorksSection extends StatefulWidget {
  const HowItWorksSection({super.key});

  @override
  State<HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<HowItWorksSection> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          // Title
          const Text(
            'PROCESS',
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
                const TextSpan(text: 'How '),
                TextSpan(
                  text: 'SafeRoute Works',
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

          // 2-column layout: image left, steps right
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildImage()),
                        const SizedBox(width: 64),
                        Expanded(child: _buildSteps()),
                      ],
                    )
                  : Column(
                      children: [
                        _buildImage(),
                        const SizedBox(height: 32),
                        _buildSteps(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Image.asset(
        AppImages.howItWorks,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSteps() {
    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isExpanded = _expandedIndex == index;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GestureDetector(
            onTap: () => setState(
                () => _expandedIndex = isExpanded ? -1 : index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          step.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(Icons.expand_more,
                            color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 12, left: 52),
                      child: Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.mutedForeground,
                          height: 1.5,
                        ),
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
