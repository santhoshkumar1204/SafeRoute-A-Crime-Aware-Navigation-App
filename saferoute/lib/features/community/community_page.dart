import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // REQUIRED IMPORT
import '../../core/constants/app_colors.dart';
import '../../providers/firebase_providers.dart';

const _categories = [
  'All',
  'Overcrowding',
  'Harassment',
  'Delay',
  'Infrastructure',
  'Suspicious Activity',
  'Theft',
];

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  String _filter = 'All';

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('MMM d').format(dt);
  }

  int _autoSeverity(String text) {
    final t = text.toLowerCase();
    if (t.contains("harassment") || t.contains("theft") || t.contains("attack") || t.contains("suspicious")) {
      return 4; 
    }
    if (t.contains("delay") || t.contains("stuck")) {
      return 3;
    }
    return 2;
  }

  void _openReportDialog() {
    String selectedCategory = "Overcrowding";
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder is necessary so the dropdown UI updates when clicked
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Report an Issue",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: _categories
                          .where((c) => c != "All")
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedCategory = v);
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Issue Type",
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Describe what's happening...",
                        filled: true,
                        fillColor: AppColors.muted,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                          child: const Text("Cancel", style: TextStyle(color: AppColors.mutedForeground)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            final text = controller.text.trim();
                            if (text.isEmpty) return;

                            final severity = _autoSeverity(text);
                            
                            // SUBMISSION LOGIC
                            await FirebaseFirestore.instance.collection('reports').add({
                              'category': selectedCategory,
                              'description': text,
                              'severity': severity,
                              'timestamp': FieldValue.serverTimestamp(),
                              'userId': 'anonymous', 
                            });

                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pop();
                            }
                          },
                          child: const Text("Submit Report"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (allReports) {
        final filtered = _filter == 'All'
            ? allReports
            : allReports.where((r) => r.category == _filter).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _openReportDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter card
              Container(
                padding: const EdgeInsets.all(20),
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
                    const Row(
                      children: [
                        Icon(Icons.filter_list, size: 16, color: AppColors.mutedForeground),
                        SizedBox(width: 8),
                        Text('Filter by Category', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((c) {
                        final isActive = _filter == c;
                        return GestureDetector(
                          onTap: () => setState(() => _filter = c),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : AppColors.muted,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isActive ? Colors.white : AppColors.mutedForeground,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 8),
                  Text('Community Reports (${filtered.length})',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),

              ...filtered.map((r) {
                Color iconBg, iconColor;
                if (r.severity >= 4) {
                  iconBg = AppColors.danger.withOpacity(0.1);
                  iconColor = AppColors.danger;
                } else if (r.severity >= 3) {
                  iconBg = AppColors.warning.withOpacity(0.1);
                  iconColor = AppColors.warning;
                } else {
                  iconBg = AppColors.primary.withOpacity(0.1);
                  iconColor = AppColors.primary;
                }

                final timeAgo = _formatTimeAgo(r.timestamp);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.warning_amber, size: 20, color: iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: iconBg,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    r.category,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: iconColor),
                                  ),
                                ),
                                Text(timeAgo, style: const TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility_off, size: 12, color: AppColors.mutedForeground),
                                    SizedBox(width: 2),
                                    Text('Anon', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(r.description, style: const TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                            const SizedBox(height: 6),
                            Row(
                              children: List.generate(5, (i) {
                                return Container(
                                  width: 16,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: i < r.severity ? AppColors.danger : AppColors.muted,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}