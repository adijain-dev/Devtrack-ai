import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/dsa_topic.dart';
import '../notifiers/dsa_notifier.dart';
import '../providers/dsa_state.dart';
import '../widgets/dsa_analytics_chart.dart';

class DsaScreen extends ConsumerStatefulWidget {
  const DsaScreen({super.key});

  @override
  ConsumerState<DsaScreen> createState() => _DsaScreenState();
}

class _DsaScreenState extends ConsumerState<DsaScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(dsaNotifierProvider.notifier).fetchAll(silent: true));
  }

  Color _diffColor(DsaDifficulty d) {
    switch (d) {
      case DsaDifficulty.easy:   return AppColors.statusGreen;
      case DsaDifficulty.medium: return AppColors.statusAmber;
      case DsaDifficulty.hard:   return AppColors.statusRed;
    }
  }

  void _showSyncSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _SyncProfileBottomSheet(parentRef: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(dsaNotifierProvider);
    final notifier = ref.read(dsaNotifierProvider.notifier);

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        title: const Text('DSA Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Sync LeetCode / Codeforces',
            onPressed: () => _showSyncSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats banner ────────────────────────────────────────────
          _StatsBanner(state: state),

          // ── Spaced Repetition Due Alert Banner ───────────────────────
          if (state.dueRevisionsCount > 0)
            _SpacedRepetitionAlertBanner(
              dueCount: state.dueRevisionsCount,
              isFiltered: state.showOnlyDueRevisions,
              onToggleFilter: notifier.toggleDueRevisionsFilter,
            ),

          // ── Analytics Chart ─────────────────────────────────────────
          DsaAnalyticsChart(state: state),

          // ── Filters ─────────────────────────────────────────────────
          _FilterBar(state: state, notifier: notifier),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.showOnlyDueRevisions
                                  ? Icons.task_alt
                                  : Icons.code_off,
                              size: 72,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.showOnlyDueRevisions
                                  ? 'No problems due for revision right now! 🎉'
                                  : 'No topics found.\nTap + or Sync to import problems!',
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
                          final topic = state.filtered[index];
                          return _TopicCard(
                            topic: topic,
                            diffColor: _diffColor(topic.difficulty),
                            onToggle: () => notifier.toggleSolved(topic),
                            onReview: () async {
                              final success = await notifier.reviewTopic(topic);
                              if (context.mounted && success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Marked "${topic.topicName}" as reviewed! Next revision scheduled in ${topic.revisionIntervalDays * 2} days.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            onTap: () async {
                              await context.push(
                                '/dsa/edit',
                                extra: topic,
                              );
                              ref.read(dsaNotifierProvider.notifier).fetchAll();
                            },
                            onDelete: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete Topic'),
                                  content: Text('Remove "${topic.topicName}"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await notifier.delete(topic.id);
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
          await context.push('/dsa/add');
          ref.read(dsaNotifierProvider.notifier).fetchAll();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Topic'),
      ),
    );
  }
}

// ── Spaced Repetition Due Alert Banner ───────────────────────────────────────

class _SpacedRepetitionAlertBanner extends StatelessWidget {
  final int dueCount;
  final bool isFiltered;
  final VoidCallback onToggleFilter;

  const _SpacedRepetitionAlertBanner({
    required this.dueCount,
    required this.isFiltered,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade800, Colors.deepOrange.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dueCount Problem${dueCount > 1 ? 's' : ''} Due for Revision',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Text(
                  'Spaced repetition reminder: solved 7 or 14+ days ago.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onToggleFilter,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepOrange.shade800,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              isFiltered ? 'Show All' : 'Review',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Banner ─────────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  final DsaState state;
  const _StatsBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final progress = state.totalCount == 0
        ? 0.0
        : state.solvedCount / state.totalCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESS OVERVIEW',
                    style: AppTheme.mono(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${state.solvedCount}',
                        style: AppTheme.mono(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' / ${state.totalCount} solved',
                        style: AppTheme.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Streak badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.statusAmberBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.statusAmber.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${state.streak}d streak',
                      style: AppTheme.mono(
                        color: AppColors.statusAmber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.statusGreen),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% complete',
                style: AppTheme.mono(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                '${state.pendingCount} remaining',
                style: AppTheme.inter(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter Bar ───────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final DsaState state;
  final DsaNotifier notifier;
  const _FilterBar({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Due Revision quick toggle
          if (state.dueRevisionsCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _chip(
                label: '🔁 Due Revision (${state.dueRevisionsCount})',
                selected: state.showOnlyDueRevisions,
                selectedColor: Colors.deepOrange,
                onTap: notifier.toggleDueRevisionsFilter,
              ),
            ),
          // Category filter chips
          _chip(
            label: 'All',
            selected: state.selectedCategory == null && !state.showOnlyDueRevisions,
            onTap: () {
              if (state.showOnlyDueRevisions) notifier.toggleDueRevisionsFilter();
              notifier.filterByCategory(null);
            },
          ),
          ...DsaCategory.values.map((c) => _chip(
                label: c.label,
                selected: state.selectedCategory == c,
                onTap: () => notifier.filterByCategory(
                    state.selectedCategory == c ? null : c),
              )),
          const SizedBox(width: 12),
          // Difficulty filter chips
          ...DsaDifficulty.values.map((d) {
            final colors = {
              DsaDifficulty.easy: Colors.green,
              DsaDifficulty.medium: Colors.orange,
              DsaDifficulty.hard: Colors.red,
            };
            return _chip(
              label: d.label,
              selected: state.selectedDifficulty == d,
              selectedColor: colors[d]!,
              onTap: () => notifier.filterByDifficulty(
                  state.selectedDifficulty == d ? null : d),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    Color selectedColor = Colors.deepPurple,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? selectedColor.withValues(alpha: 0.15)
                : Colors.grey.shade100,
            border: Border.all(
              color: selected ? selectedColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? selectedColor : Colors.grey.shade600,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Topic Card ───────────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  final DsaTopic topic;
  final Color diffColor;
  final VoidCallback onToggle;
  final VoidCallback onReview;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TopicCard({
    required this.topic,
    required this.diffColor,
    required this.onToggle,
    required this.onReview,
    required this.onTap,
    required this.onDelete,
  });

  Color _platformColor(String? platform) {
    switch (platform?.toUpperCase()) {
      case 'LEETCODE':   return Colors.amber.shade800;
      case 'CODEFORCES': return Colors.blue.shade700;
      default:           return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDue = topic.needsRevision;

    return Card(
      elevation: 0,
      color: isDue ? AppColors.statusAmberBg : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDue ? AppColors.statusAmber.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: 1,
        ),
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
                  // Solved toggle checkbox
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: topic.isSolved
                            ? AppColors.statusGreen
                            : Colors.transparent,
                        border: Border.all(
                          color: topic.isSolved
                              ? AppColors.statusGreen
                              : AppColors.textMuted,
                          width: 2,
                        ),
                      ),
                      child: topic.isSolved
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Topic details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.topicName,
                          style: AppTheme.mono(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: topic.isSolved
                                ? TextDecoration.lineThrough
                                : null,
                            color: topic.isSolved
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (topic.platform != null &&
                                topic.platform != 'MANUAL')
                              _badge(topic.platform!,
                                  _platformColor(topic.platform)),
                            _badge(topic.category.label,
                                AppColors.accentLight),
                            _badge(topic.difficulty.label, diffColor),
                            if (topic.practiceCount > 0)
                              _badge(
                                '×${topic.practiceCount}',
                                AppColors.statusBlue,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Delete
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.textMuted),
                    onPressed: onDelete,
                  ),
                ],
              ),

              // Revision & Spaced Repetition status row
              if (topic.isSolved) ...[
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (isDue) ...[
                      const Icon(Icons.replay_circle_filled,
                          size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 4),
                      Text(
                        'Revision Due (${topic.revisionIntervalDays}d interval)',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: onReview,
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Mark Reviewed',
                            style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        topic.nextRevisionDate != null
                            ? 'Next review: ${topic.nextRevisionDate} (${topic.revisionIntervalDays}d)'
                            : 'Solved on ${topic.solvedDate ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (topic.problemUrl != null &&
                          topic.problemUrl!.isNotEmpty) ...[
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: topic.problemUrl!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Problem URL copied to clipboard!'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(Icons.link,
                                  size: 14, color: Colors.blue.shade700),
                              const SizedBox(width: 2),
                              Text(
                                'Copy Link',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Sync Profile Bottom Sheet ────────────────────────────────────────────────

class _SyncProfileBottomSheet extends StatefulWidget {
  final WidgetRef parentRef;
  const _SyncProfileBottomSheet({required this.parentRef});

  @override
  State<_SyncProfileBottomSheet> createState() =>
      _SyncProfileBottomSheetState();
}

class _SyncProfileBottomSheetState extends State<_SyncProfileBottomSheet> {
  String _platform = 'LEETCODE';
  final _usernameController = TextEditingController();
  bool _importProblems = true;
  bool _isLoading = false;
  Map<String, dynamic>? _resultStats;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSync() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _errorMessage = 'Please enter a username or handle');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _resultStats = null;
    });

    final notifier = widget.parentRef.read(dsaNotifierProvider.notifier);
    final stats = await notifier.syncProfile(
      platform: _platform,
      username: username,
      importProblems: _importProblems,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (stats != null) {
          _resultStats = stats;
        } else {
          _errorMessage =
              widget.parentRef.read(dsaNotifierProvider).error ?? 'Sync failed.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.sync, color: Colors.deepPurple, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Sync Coding Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Import your solved questions and automate spaced repetition revision.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Platform selector
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('LeetCode')),
                    selected: _platform == 'LEETCODE',
                    selectedColor: Colors.amber.shade800.withValues(alpha: 0.2),
                    onSelected: (val) {
                      if (val) setState(() => _platform = 'LEETCODE');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Codeforces')),
                    selected: _platform == 'CODEFORCES',
                    selectedColor: Colors.blue.shade700.withValues(alpha: 0.2),
                    onSelected: (val) {
                      if (val) setState(() => _platform = 'CODEFORCES');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Username input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: _platform == 'LEETCODE'
                    ? 'LeetCode Username'
                    : 'Codeforces Handle',
                hintText: _platform == 'LEETCODE'
                    ? 'e.g. neal_wu'
                    : 'e.g. tourist',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Import problems checkbox
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Auto-import solved questions',
                  style: TextStyle(fontSize: 14)),
              subtitle: const Text(
                  'Sets up 7-day spaced repetition revision for every imported problem',
                  style: TextStyle(fontSize: 11)),
              value: _importProblems,
              onChanged: (val) => setState(() => _importProblems = val),
            ),
            const SizedBox(height: 12),

            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                ),
              ),

            // Result summary
            if (_resultStats != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  border: Border.all(color: Colors.green.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_resultStats!['platform']} Synced!',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Solved: ${_resultStats!['totalSolved']} problems '
                      '(${_resultStats!['easySolved']} Easy, ${_resultStats!['mediumSolved']} Medium, ${_resultStats!['hardSolved']} Hard)',
                      style: const TextStyle(fontSize: 12),
                    ),
                    if (_resultStats!['rating'] != null)
                      Text(
                        '• Rating: ${_resultStats!['rating']} (${_resultStats!['rank'] ?? 'Rank'})',
                        style: const TextStyle(fontSize: 12),
                      ),
                    if (_resultStats!['ranking'] != null)
                      Text(
                        '• Ranking: ${_resultStats!['ranking']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    Text(
                      '• Imported to Tracker: ${_resultStats!['importedCount']} questions',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],

            ElevatedButton(
              onPressed: _isLoading ? null : _handleSync,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sync Now', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
