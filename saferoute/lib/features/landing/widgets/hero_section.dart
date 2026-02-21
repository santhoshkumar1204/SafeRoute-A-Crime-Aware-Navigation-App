import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 600;

    return Container(
      constraints: BoxConstraints(minHeight: isDesktop ? 600 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 48 : 80,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _buildTextContent(context, isMobile)),
                const SizedBox(width: 48),
                Expanded(child: _buildHeroImage()),
              ],
            )
          : Column(
              children: [
                _buildTextContent(context, isMobile),
                const SizedBox(height: 40),
                _buildHeroImage(),
              ],
            ),
    );
  }

  Widget _buildTextContent(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment:
          isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Logo
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image.asset(
              AppImages.logo,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shield, size: 16, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'AI-Powered Safety Navigation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Headline
        Text(
          'Navigate Smarter.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
            height: 1.2,
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Travel Safer.',
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: TextStyle(
              fontSize: isMobile ? 32 : 48,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),

        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Text(
            'AI-powered crime-aware navigation that predicts route risk in real time and guides users through safer paths.',
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // CTA Buttons
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/signup'),
              icon: const Text('Get Started'),
              label: const Icon(Icons.arrow_forward, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Explore Demo'),
            ),
          ],
        ),
        const SizedBox(height: 48),

        // Stats
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _StatItem(value: '50K+', label: 'Safe Routes'),
            Container(
                width: 1, height: 40, color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 24)),
            const _StatItem(value: '98%', label: 'Accuracy'),
            Container(
                width: 1, height: 40, color: AppColors.border,
                margin: const EdgeInsets.symmetric(horizontal: 24)),
            const _StatItem(value: '24/7', label: 'Monitoring'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Image.asset(
        AppImages.heroIllustration,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.foreground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.mutedForeground,
          ),
        ),
      ],
    );
  }
}
