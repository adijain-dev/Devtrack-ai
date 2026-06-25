import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/dsa_topic.dart';
import '../notifiers/dsa_notifier.dart';
import '../providers/dsa_state.dart';

class DsaScreen extends ConsumerWidget {
  const DsaScreen({super.key});

  Color _diffColor(DsaDifficulty d) {
    switch (d) {
      case DsaDifficulty.easy:   return Colors.green;
      case DsaDifficulty.medium: return Colors.orange;
      case DsaDifficulty.hard:   return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: const Text('DSA Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: notifier.fetchAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Stats banner ────────────────────────────────────────────
          _StatsBanner(state: state),

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
                            Icon(Icons.code_off,
                                size: 72, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No topics found.\nTap + to add one!',
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
                            onTap: () => context.push(
                              '/dsa/edit',
                              extra: topic,
                            ),
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
        onPressed: () => context.push('/dsa/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Topic'),
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
                  const Text('Progress',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12)),
                  Text('${state.solvedCount} / ${state.totalCount} solved',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
              // Streak badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 4),
                    Text('${state.streak} day streak',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).toStringAsFixed(0)}% complete',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
              Text('${state.pendingCount} remaining',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12)),
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
          // Category filter chips
          _chip(
            label: 'All',
            selected: state.selectedCategory == null,
            onTap: () => notifier.filterByCategory(null),
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
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TopicCard({
    required this.topic,
    required this.diffColor,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: topic.isSolved ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Solved toggle checkbox
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: topic.isSolved
                        ? Colors.green
                        : Colors.transparent,
                    border: Border.all(
                      color: topic.isSolved
                          ? Colors.green
                          : Colors.grey.shade400,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: topic.isSolved
                            ? TextDecoration.lineThrough
                            : null,
                        color: topic.isSolved
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _badge(topic.category.label,
                            Colors.deepPurple),
                        const SizedBox(width: 6),
                        _badge(topic.difficulty.label, diffColor),
                        if (topic.practiceCount > 0) ...[
                          const SizedBox(width: 6),
                          _badge(
                            '×${topic.practiceCount}',
                            Colors.blue,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Delete
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 20, color: Colors.grey.shade400),
                onPressed: onDelete,
              ),
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
