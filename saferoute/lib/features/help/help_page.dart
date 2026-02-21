import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

const _faqs = [
  {
    'q': 'How does SafeRoute calculate risk scores?',
    'a': 'SafeRoute uses ensemble ML models analyzing historical crime data, time-of-day patterns, weather, socioeconomic factors, and community reports to generate risk probabilities for each route segment.'
  },
  {
    'q': 'How accurate is the AI prediction?',
    'a': 'Our models achieve 94-98% accuracy depending on the region, trained on millions of data points and continuously improved with user feedback.'
  },
  {
    'q': 'Is my data private?',
    'a': 'Yes. All personal data is encrypted. You can report incidents anonymously, and location data is only shared with your explicit consent.'
  },
  {
    'q': 'What is the Safety Score?',
    'a': 'The Safety Score is a 0-100 metric calculated daily based on your routes, nearby incident density, and time-based risk patterns.'
  },
  {
    'q': 'How does the ML prediction model work?',
    'a': 'We use a combination of Random Forests, Gradient Boosting, and LSTM networks trained on spatio-temporal crime data. The model considers 40+ features including location, time, weather, and historical patterns.'
  },
  {
    'q': 'Can I use SafeRoute offline?',
    'a': 'Limited offline mode is available with cached risk data for your frequent routes. Full features require an internet connection.'
  },
];

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ
            const Text('Frequently Asked Questions',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 16),

            ..._faqs.asMap().entries.map((entry) {
              final i = entry.key;
              final faq = entry.value;
              final isExpanded = _expanded == i;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(
                          () => _expanded = isExpanded ? null : i),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(faq['q']!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: const Icon(Icons.expand_more,
                                  size: 20,
                                  color: AppColors.mutedForeground),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(faq['a']!,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.mutedForeground)),
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

            // Contact form
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
                    children: const [
                      Icon(Icons.email, size: 16),
                      SizedBox(width: 8),
                      Text('Contact Us',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _formField(hint: 'Your email'),
                  const SizedBox(height: 12),
                  _formField(hint: 'Subject'),
                  const SizedBox(height: 12),
                  _formField(hint: 'Your message...', maxLines: 4),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('Send Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _formField({required String hint, int maxLines = 1}) {
    return TextFormField(
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
