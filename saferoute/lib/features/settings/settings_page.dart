import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _alertNotifs = true;
  bool _reportNotifs = true;
  bool _updateNotifs = false;
  bool _shareLocation = true;
  bool _anonymousDefault = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // Profile
            _card(
              icon: Icons.person,
              title: 'Profile',
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _input(
                            label: 'Name', value: user?.name ?? ''),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _input(
                            label: 'Email', value: user?.email ?? ''),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notifications
            _card(
              icon: Icons.notifications,
              title: 'Notifications',
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _toggle('Crime Alerts', _alertNotifs,
                      (v) => setState(() => _alertNotifs = v)),
                  const SizedBox(height: 12),
                  _toggle('Community Reports', _reportNotifs,
                      (v) => setState(() => _reportNotifs = v)),
                  const SizedBox(height: 12),
                  _toggle('Product Updates', _updateNotifs,
                      (v) => setState(() => _updateNotifs = v)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Location
            _card(
              icon: Icons.location_on,
              title: 'Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Location access is required for navigation and safety features.',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Grant Location Permission',
                        style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy
            _card(
              icon: Icons.lock,
              title: 'Privacy',
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _toggle(
                      'Share location with emergency contacts',
                      _shareLocation,
                      (v) => setState(() => _shareLocation = v)),
                  const SizedBox(height: 12),
                  _toggle(
                      'Anonymous reporting by default',
                      _anonymousDefault,
                      (v) => setState(() => _anonymousDefault = v)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Appearance
            _card(
              icon: Icons.dark_mode,
              title: 'Appearance',
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _toggle(
                      'Dark Mode',
                      ref.watch(themeModeProvider) == ThemeMode.dark,
                      (v) => ref.read(themeModeProvider.notifier).setThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Language
            _card(
              icon: Icons.language,
              title: 'Language',
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'English',
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.foreground),
                        items: const [
                          DropdownMenuItem(
                              value: 'English',
                              child: Text('English')),
                          DropdownMenuItem(
                              value: 'Spanish',
                              child: Text('Spanish')),
                          DropdownMenuItem(
                              value: 'French',
                              child: Text('French')),
                          DropdownMenuItem(
                              value: 'Hindi', child: Text('Hindi')),
                        ],
                        onChanged: (_) {},
                      ),
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

  Widget _card({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 16),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _input({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: value,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _toggle(
      String label, bool active, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!active),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Container(
            width: 36,
            height: 20,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  active ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
