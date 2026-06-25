import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/internship.dart';
import '../notifiers/internship_notifier.dart';

class InternshipListScreen extends ConsumerWidget {
  const InternshipListScreen({super.key});

  Color _statusColor(InternshipStatus status) {
    switch (status) {
      case InternshipStatus.applied:
        return Colors.blue;
      case InternshipStatus.interview:
        return Colors.orange;
      case InternshipStatus.offer:
        return Colors.green;
      case InternshipStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Internships'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: notifier.fetchAll,
          ),
        ],
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
                            onTap: () =>
                                context.push('/internships/edit', extra: internship),
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
        onPressed: () => context.push('/internships/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatChip(label: 'Applied', count: _count(InternshipStatus.applied), color: Colors.blue),
        _StatChip(label: 'Interview', count: _count(InternshipStatus.interview), color: Colors.orange),
        _StatChip(label: 'Offer', count: _count(InternshipStatus.offer), color: Colors.green),
        _StatChip(label: 'Rejected', count: _count(InternshipStatus.rejected), color: Colors.red),
      ],
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
        Text('$count',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
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
        ),
      ),
    );
  }
}
