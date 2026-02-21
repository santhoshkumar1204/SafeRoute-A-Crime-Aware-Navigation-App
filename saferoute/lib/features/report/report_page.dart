import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/firebase_providers.dart';

const _categories = [
  'Theft', 'Assault', 'Vandalism', 'Harassment',
  'Suspicious Activity', 'Drug Activity', 'Overcrowding',
  'Bus Delay', 'Infrastructure Complaint', 'Other',
];

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String _category = '';
  int _severity = 3;
  String _desc = '';
  bool _anonymous = false;
  bool _submitting = false;
  bool _submitted = false;

  Future<void> _handleSubmit() async {
    if (_category.isEmpty || _desc.isEmpty) return;
    setState(() => _submitting = true);
    try {
      await ref.read(reportSubmissionProvider.notifier).submit(
            category: _category,
            description: _desc,
            severity: _severity,
            location: 'Auto-detected: Central Park, NY',
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = true;
        _category = '';
        _desc = '';
        _severity = 3;
      });
      Future.delayed(const Duration(seconds: 3),
          () => mounted ? setState(() => _submitted = false) : null);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildForm()),
          const SizedBox(width: 24),
          Expanded(child: _buildRecentReports()),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildForm(),
          const SizedBox(height: 24),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
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
          const Text('Report an Incident',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 20),

          // Location
          const Text('Location',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: 'Auto-detected: Central Park, NY',
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on,
                  size: 18, color: AppColors.mutedForeground),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Category
          const Text('Category',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _category.isEmpty ? null : _category,
                hint: const Text('Select category',
                    style: TextStyle(fontSize: 13)),
                isExpanded: true,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? ''),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Severity
          const Text('Severity (1-5)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            children: List.generate(5, (i) {
              final level = i + 1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _severity = level),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _severity >= level
                          ? AppColors.danger
                          : AppColors.muted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$level',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _severity >= level
                            ? Colors.white
                            : AppColors.mutedForeground,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),

          // Description
          const Text('Description',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextFormField(
            maxLines: 3,
            onChanged: (v) => _desc = v,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describe the incident...',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 16),

          // Photo
          const Text('Photo (optional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                    width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.camera_alt,
                      size: 32, color: AppColors.mutedForeground),
                  SizedBox(height: 8),
                  Text('Click to upload or drag & drop',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Anonymous toggle
          GestureDetector(
            onTap: () => setState(() => _anonymous = !_anonymous),
            child: Row(
              children: [
                _toggleSwitch(_anonymous),
                const SizedBox(width: 8),
                const Text('Report anonymously',
                    style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Success message
          if (_submitted)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.safe.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '✓ Report submitted successfully!',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.safe,
                ),
              ),
            ),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _handleSubmit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send, size: 18),
              label: Text(_submitting ? '' : 'Submit Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleSwitch(bool active) {
    return Container(
      width: 36,
      height: 20,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.muted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: active ? Alignment.centerRight : Alignment.centerLeft,
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
    );
  }

  Widget _buildRecentReports() {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (reports) {
        final recent = reports.take(10).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Community Reports (${recent.length})',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No reports yet.',
                      style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                ),
              ),
            ...recent.map((r) {
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
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.warning_amber,
                        size: 20, color: AppColors.danger),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                r.category,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.danger),
                              ),
                            ),
                            Text(timeAgo,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.mutedForeground)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          r.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
            }),
          ],
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return DateFormat('MMM d').format(dt);
  }
}
