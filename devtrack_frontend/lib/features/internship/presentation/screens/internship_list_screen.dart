import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/internship.dart';
import '../notifiers/internship_notifier.dart';

class InternshipListScreen extends ConsumerStatefulWidget {
  const InternshipListScreen({super.key});

  @override
  ConsumerState<InternshipListScreen> createState() => _InternshipListScreenState();
}

class _InternshipListScreenState extends ConsumerState<InternshipListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(internshipNotifierProvider.notifier).fetchAll(silent: true));
  }

  Color _statusColor(InternshipStatus status) {
    switch (status) {
      case InternshipStatus.applied:
        return AppColors.statusBlue;
      case InternshipStatus.interview:
        return AppColors.statusAmber;
      case InternshipStatus.offer:
        return AppColors.statusGreen;
      case InternshipStatus.rejected:
        return AppColors.statusRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(internshipNotifierProvider);
    final notifier = ref.read(internshipNotifierProvider.notifier);

    // Show error snackbar
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
      });
    }

    final upcomingInterviews = state.internships
        .where((i) => i.interviewDate != null && i.interviewDate!.isNotEmpty)
        .toList()
      ..sort((a, b) => a.interviewDate!.compareTo(b.interviewDate!));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        title: const Text('My Internships'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              onChanged: notifier.search,
              decoration: InputDecoration(
                hintText: 'Search by company, role or location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Upcoming Interviews Calendar / Reminder Alert Banner
          if (upcomingInterviews.isNotEmpty)
            _UpcomingInterviewsBanner(
              interviews: upcomingInterviews,
              onTap: (internship) =>
                  context.push('/internships/edit', extra: internship),
            ),

          // Stats row
          if (!state.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _StatsRow(internships: state.internships),
            ),

          // List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_outline,
                                size: 72, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'No results found'
                                  : 'No internships yet.\nTap + to add one!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: state.filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final internship = state.filtered[index];
                          return _InternshipCard(
                            internship: internship,
                            statusColor: _statusColor(internship.status),
                            onTap: () async {
                              await context.push('/internships/edit', extra: internship);
                              ref.read(internshipNotifierProvider.notifier).fetchAll();
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Internship'),
                                  content: Text(
                                      'Remove ${internship.companyName} - ${internship.role}?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await notifier.delete(internship.id);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/internships/add');
          ref.read(internshipNotifierProvider.notifier).fetchAll();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}

// ── Upcoming Interviews Calendar Banner ────────────────────────────────────

class _UpcomingInterviewsBanner extends StatelessWidget {
  final List<Internship> interviews;
  final Function(Internship) onTap;

  const _UpcomingInterviewsBanner({
    required this.interviews,
    required this.onTap,
  });

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.month}/${dt.day} at $hour:$min $period';
    } catch (_) {
      return iso.replaceFirst('T', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = interviews.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.event_available, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Next Interview: ${next.companyName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.deepOrange,
                      ),
                    ),
                    if (next.reminderEnabled) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.alarm_on, size: 14, color: Colors.deepOrange),
                    ],
                  ],
                ),
                Text(
                  '${next.role} • ${_formatDate(next.interviewDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onTap(next),
            child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<Internship> internships;
  const _StatsRow({required this.internships});

  int _count(InternshipStatus s) =>
      internships.where((i) => i.status == s).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip(label: 'Applied', count: _count(InternshipStatus.applied), color: AppColors.statusBlue),
          _StatChip(label: 'Interview', count: _count(InternshipStatus.interview), color: AppColors.statusAmber),
          _StatChip(label: 'Offer', count: _count(InternshipStatus.offer), color: AppColors.statusGreen),
          _StatChip(label: 'Rejected', count: _count(InternshipStatus.rejected), color: AppColors.statusRed),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTheme.mono(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTheme.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ── Card ───────────────────────────────────────────────────────────────────

class _InternshipCard extends StatelessWidget {
  final Internship internship;
  final Color statusColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _InternshipCard({
    required this.internship,
    required this.statusColor,
    required this.onTap,
    required this.onDelete,
  });

  String _formatInterview(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.month}/${dt.day} $hour:$min $period';
    } catch (_) {
      return iso.replaceFirst('T', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorder, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Company initial avatar
                  CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.15),
                    child: Text(
                      internship.companyName.isNotEmpty
                          ? internship.companyName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(internship.companyName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Text(internship.role,
                            style: TextStyle(color: Colors.grey.shade600)),
                        if (internship.location != null)
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 2),
                              Text(internship.location!,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Status badge + delete
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          internship.status.label,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(Icons.delete_outline,
                            size: 20, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ],
              ),

              // ── Interview & Document Attachment Badges ───────────────────
              if (internship.interviewDate != null ||
                  internship.resumeFileName != null ||
                  internship.resumeUrl != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (internship.interviewDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              internship.reminderEnabled ? Icons.alarm_on : Icons.event,
                              size: 13,
                              color: Colors.deepOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Interview: ${_formatInterview(internship.interviewDate!)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (internship.resumeFileName != null || internship.resumeUrl != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file, size: 13, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(
                              internship.resumeFileName ?? 'Resume Attached',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
