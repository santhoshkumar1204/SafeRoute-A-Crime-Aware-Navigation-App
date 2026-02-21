import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/firebase_providers.dart';

class NotificationPanel extends ConsumerStatefulWidget {
  const NotificationPanel({super.key});

  @override
  ConsumerState<NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends ConsumerState<NotificationPanel> {
  bool _open = false;
  final Set<String> _locallyRead = {};
  bool _cleared = false;

  int _unreadCount(List<Map<String, dynamic>> alerts) =>
      alerts.where((a) => !(a['read'] as bool)).length;

  void _markRead(String id) {
    setState(() => _locallyRead.add(id));
  }

  void _markAllRead(List<Map<String, dynamic>> alerts) {
    setState(() {
      for (final a in alerts) {
        _locallyRead.add(a['id'] as String);
      }
    });
  }

  void _clearAll() {
    setState(() => _cleared = true);
  }

  void _togglePanel() {
    setState(() => _open = !_open);
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsStreamProvider);

    final alerts = alertsAsync.when<List<Map<String, dynamic>>>(
      loading: () => [],
      error: (_, __) => [],
      data: (list) => list
          .map((a) => <String, dynamic>{
                'id': a.id,
                'message': a.message,
                'type': a.severity == 'danger'
                    ? 'danger'
                    : a.severity == 'warning'
                        ? 'warning'
                        : 'info',
                'time': _formatTime(a.timestamp),
                'read': a.read || _locallyRead.contains(a.id),
              })
          .toList(),
    );

    final displayAlerts = _cleared ? <Map<String, dynamic>>[] : alerts;
    final unread = _unreadCount(displayAlerts);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bell button
        IconButton(
          onPressed: _togglePanel,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined, size: 22),
              if (unread > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Dropdown panel
        if (_open) ...[
          Positioned(
            right: 0,
            top: 48,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 340,
                constraints: const BoxConstraints(maxHeight: 420),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const Text(
                            'Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => _markAllRead(displayAlerts),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    size: 12, color: AppColors.primary),
                                SizedBox(width: 2),
                                Text(
                                  'Mark all read',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _clearAll,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 12,
                                    color: AppColors.mutedForeground),
                                SizedBox(width: 2),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Alerts list
                    Flexible(
                      child: displayAlerts.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No notifications',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.mutedForeground,
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: displayAlerts.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final alert = displayAlerts[index];
                                final isRead = alert['read'] as bool;
                                final type = alert['type'] as String;
                                Color dotColor;
                                switch (type) {
                                  case 'danger':
                                    dotColor = AppColors.danger;
                                    break;
                                  case 'warning':
                                    dotColor = AppColors.warning;
                                    break;
                                  default:
                                    dotColor = AppColors.primary;
                                }

                                return InkWell(
                                  onTap: () =>
                                      _markRead(alert['id'] as String),
                                  child: Container(
                                    color: isRead
                                        ? Colors.transparent
                                        : AppColors.primary
                                            .withOpacity(0.05),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin:
                                              const EdgeInsets.only(top: 5),
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                alert['message'] as String,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isRead
                                                      ? FontWeight.w400
                                                      : FontWeight.w500,
                                                  color: isRead
                                                      ? AppColors
                                                          .mutedForeground
                                                      : AppColors
                                                          .foreground,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                alert['time'] as String,
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors
                                                      .mutedForeground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
