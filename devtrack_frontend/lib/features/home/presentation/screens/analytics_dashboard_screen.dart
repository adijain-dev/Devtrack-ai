import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../internship/presentation/notifiers/internship_notifier.dart';
import '../../../internship/domain/entities/internship.dart';
import '../../../dsa/presentation/notifiers/dsa_notifier.dart';
import '../../../dsa/presentation/providers/dsa_state.dart';
import '../../../dsa/domain/entities/dsa_topic.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final internshipState = ref.watch(internshipNotifierProvider);
    final dsaState = ref.watch(dsaNotifierProvider);

    final isLoading = internshipState.isLoading || dsaState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Overview Summary Header ─────────────────────────
                  _buildSummaryHeader(context, internshipState, dsaState),
                  const SizedBox(height: 18),

                  // ── Internship Distribution Ring Chart ──────────────
                  _buildInternshipsChartCard(context, internshipState.internships),
                  const SizedBox(height: 18),

                  // ── DSA Categories Progress Bar Chart ──────────────
                  _buildDsaChartCard(context, dsaState.topics),
                ],
              ),
            ),
    );
  }

  // ── Summary Cards Row ───────────────────────────────────────────────

  Widget _buildSummaryHeader(
    BuildContext context,
    InternshipState internshipState,
    DsaState dsaState,
  ) {
    final totalApps = internshipState.internships.length;
    final offers = internshipState.internships.where((i) => i.status == InternshipStatus.offer).length;
    final solved = dsaState.solvedCount;
    final streak = dsaState.streak;

    return Row(
      children: [
        Expanded(
          child: _CardSummaryItem(
            title: 'Applications',
            value: '$totalApps',
            subtitle: '$offers Offers',
            icon: Icons.work_outline,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CardSummaryItem(
            title: 'DSA Solved',
            value: '$solved',
            subtitle: '$streak Day Streak 🔥',
            icon: Icons.code,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  // ── Internship Status Pie Chart Card ────────────────────────────────

  Widget _buildInternshipsChartCard(BuildContext context, List<Internship> internships) {
    if (internships.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Add internship applications to view status analytics!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final applied = internships.where((i) => i.status == InternshipStatus.applied).length;
    final interview = internships.where((i) => i.status == InternshipStatus.interview).length;
    final offer = internships.where((i) => i.status == InternshipStatus.offer).length;
    final rejected = internships.where((i) => i.status == InternshipStatus.rejected).length;

    final total = internships.length;

    final sectionData = [
      _PieData(value: applied.toDouble(), color: Colors.blue, title: 'Applied'),
      _PieData(value: interview.toDouble(), color: Colors.orange, title: 'Interview'),
      _PieData(value: offer.toDouble(), color: Colors.green, title: 'Offer'),
      _PieData(value: rejected.toDouble(), color: Colors.red, title: 'Rejected'),
    ].where((d) => d.value > 0).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Statuses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: sectionData.map((d) {
                          final pct = (d.value / total * 100).toStringAsFixed(0);
                          return PieChartSectionData(
                            color: d.color,
                            value: d.value,
                            title: '$pct%',
                            radius: 35,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Applied', Colors.blue, applied),
                      _buildLegendItem('Interview', Colors.orange, interview),
                      _buildLegendItem('Offer', Colors.green, offer),
                      _buildLegendItem('Rejected', Colors.red, rejected),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ── DSA Solved Categories Bar Chart Card ────────────────────────────

  Widget _buildDsaChartCard(BuildContext context, List<DsaTopic> topics) {
    final solvedTopics = topics.where((t) => t.isSolved).toList();

    if (solvedTopics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'Solve DSA questions to see category-wise performance!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    // Get solved count by category
    final categoryProgress = <DsaCategory, int>{};
    for (final cat in DsaCategory.values) {
      categoryProgress[cat] = solvedTopics.where((t) => t.category == cat).length;
    }

    final maxVal = categoryProgress.values.fold<int>(0, (max, val) => val > max ? val : max).toDouble();
    final yMax = maxVal == 0 ? 5.0 : maxVal + 1.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Solved by Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: yMax,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= DsaCategory.values.length) {
                            return const SizedBox.shrink();
                          }
                          final cat = DsaCategory.values[index];
                          // Short label for x axis
                          String label = cat.name.substring(0, 3).toUpperCase();
                          if (cat == DsaCategory.linkedList) label = 'LKL';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          if (value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                        reservedSize: 20,
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: DsaCategory.values.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final cat = entry.value;
                    final count = categoryProgress[cat] ?? 0;

                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: Colors.deepPurple.shade400,
                          width: 14,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper models/widgets

class _PieData {
  final double value;
  final Color color;
  final String title;

  _PieData({required this.value, required this.color, required this.title});
}

class _CardSummaryItem extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CardSummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
