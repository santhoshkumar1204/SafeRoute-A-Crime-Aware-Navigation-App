import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 600;

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        children: [
          isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildColumns(context),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildColumns(context)
                      .map((w) => Expanded(child: w))
                      .toList(),
                ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          const Text(
            '© 2026 SafeRoute. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildColumns(BuildContext context) {
    return [
      // Brand
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.all(1),
                  child: ClipOval(
                    child: Image.asset(
                      AppImages.logo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'SafeRoute',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'AI-powered crime-aware navigation for safer urban mobility. Aligned with UN SDG 11 & SDG 16.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),

      // Product
      const _FooterColumn(title: 'Product', items: [
        'Features',
        'Live Map',
        'How It Works',
        'Dashboard',
      ]),

      // Company
      const _FooterColumn(title: 'Company', items: [
        'About',
        'Contact',
        'Help',
      ]),

      // Legal
      const _FooterColumn(title: 'Legal', items: [
        '📄 Privacy Policy',
        '🛡 Terms of Service',
        '❓ FAQ',
        '✉ support@saferoute.ai',
      ]),
    ];
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const _FooterColumn({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
