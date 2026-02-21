import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_images.dart';
import '../../core/widgets/notification_panel.dart';
import '../../providers/auth_provider.dart';

class _SidebarItem {
  final IconData icon;
  final String label;
  final String path;
  const _SidebarItem(this.icon, this.label, this.path);
}

const _sidebarItems = [
  _SidebarItem(Icons.dashboard, 'Dashboard', '/dashboard'),
  _SidebarItem(Icons.navigation, 'Start Navigation', '/navigation'),
  _SidebarItem(Icons.map, 'Risk Heatmap', '/heatmap'),
  _SidebarItem(Icons.directions_bus, 'MTC Bus Services', '/transport-types'),
  _SidebarItem(Icons.route, 'My Trips', '/trips'),
  _SidebarItem(Icons.bar_chart, 'Safety Analytics', '/analytics'),
  _SidebarItem(Icons.warning_amber, 'Report Incident', '/report'),
  _SidebarItem(Icons.people, 'Community Alerts', '/community'),
  _SidebarItem(Icons.phone, 'Emergency Center', '/emergency'),
  _SidebarItem(Icons.settings, 'Settings', '/settings'),
  _SidebarItem(Icons.help_outline, 'Help & Support', '/help'),
];

const _bottomNavItems = [0, 1, 2, 4, 7]; // Dashboard, Navigation, Heatmap, Trips, Community

class DashboardShell extends ConsumerStatefulWidget {
  final Widget child;
  const DashboardShell({super.key, required this.child});

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  bool _sidebarOpen = false;
  bool _userMenuOpen = false;

  String get _currentPath {
    final uri = GoRouterState.of(context).uri.toString();
    return uri;
  }

  String get _pageTitle {
    final path = _currentPath;
    return _sidebarItems
            .where((i) => i.path == path)
            .map((i) => i.label)
            .firstOrNull ??
        'Dashboard';
  }

  void _handleLogout() {
    ref.read(authProvider.notifier).logout();
    context.go('/');
  }

  void _navigateTo(String path) {
    setState(() => _sidebarOpen = false);
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Row(
        children: [
          // --- Sidebar ---
          if (isDesktop)
            _buildSidebar(isDesktop: true)
          else if (_sidebarOpen) ...[
            // Mobile overlay
            GestureDetector(
              onTap: () => setState(() => _sidebarOpen = false),
              child: Container(
                color: Colors.black26,
                width: MediaQuery.sizeOf(context).width,
                height: MediaQuery.sizeOf(context).height,
              ),
            ),
          ],

          // --- Main content ---
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.9),
                    border: const Border(
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (!isDesktop)
                        IconButton(
                          onPressed: () =>
                              setState(() => _sidebarOpen = true),
                          icon: const Icon(Icons.menu, size: 22),
                        ),
                      Text(
                        _pageTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const NotificationPanel(),
                      const SizedBox(width: 8),

                      // User menu
                      GestureDetector(
                        onTap: () =>
                            setState(() => _userMenuOpen = !_userMenuOpen),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                user?.initials ?? 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 8),
                              Text(
                                user?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(width: 4),
                            const Icon(Icons.expand_more,
                                size: 16,
                                color: AppColors.mutedForeground),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Page content
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 16,
                          bottom: isDesktop ? 16 : 72,
                        ),
                        child: widget.child,
                      ),

                      // User dropdown menu
                      if (_userMenuOpen) ...[
                        GestureDetector(
                          onTap: () =>
                              setState(() => _userMenuOpen = false),
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 16,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 192,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    child: Text(
                                      user?.email ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.settings,
                                        size: 16),
                                    title: const Text('Settings',
                                        style: TextStyle(fontSize: 13)),
                                    onTap: () {
                                      setState(
                                          () => _userMenuOpen = false);
                                      context.go('/settings');
                                    },
                                  ),
                                  ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.logout,
                                        size: 16,
                                        color: AppColors.danger),
                                    title: const Text('Logout',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.danger)),
                                    onTap: _handleLogout,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Mobile sidebar - shown as drawer-like overlay
      drawer: isDesktop ? null : _buildDrawer(),

      // Mobile bottom nav
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: AppColors.card,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _bottomNavItems.map((idx) {
                  final item = _sidebarItems[idx];
                  final isActive = _currentPath == item.path;
                  return GestureDetector(
                    onTap: () => _navigateTo(item.path),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: 22,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? AppColors.primary
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: _buildSidebar(isDesktop: false),
    );
  }

  Widget _buildSidebar({required bool isDesktop}) {
    return Container(
      width: 256,
      color: AppColors.card,
      child: Column(
        children: [
          // Logo header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
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
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: const Text(
                    'SafeRoute',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (!isDesktop) ...[
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() => _sidebarOpen = false);
                      Navigator.of(context).maybePop();
                    },
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ],
            ),
          ),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _sidebarItems.map((item) {
                final isActive = _currentPath == item.path;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isActive ? AppColors.primary : null,
                    leading: Icon(
                      item.icon,
                      size: 18,
                      color: isActive
                          ? Colors.white
                          : AppColors.mutedForeground,
                    ),
                    title: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.w400,
                        color: isActive
                            ? Colors.white
                            : AppColors.mutedForeground,
                      ),
                    ),
                    onTap: () => _navigateTo(item.path),
                  ),
                );
              }).toList(),
            ),
          ),

          // Logout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: ListTile(
              dense: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.logout,
                  size: 18, color: AppColors.mutedForeground),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.mutedForeground,
                ),
              ),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }
}
