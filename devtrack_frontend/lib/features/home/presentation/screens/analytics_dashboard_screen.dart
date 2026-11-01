import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Home',
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Analytics & Metrics',
          style: AppTheme.inter(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentLight),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Overview Summary Header ─────────────────────────
                  _buildSummaryHeader(context, internshipState, dsaState),
                  const SizedBox(height: 16),

                  // ── Internship Distribution Ring Chart ──────────────
                  _buildInternshipsChartCard(context, internshipState.internships),
                  const SizedBox(height: 16),

                  // ── DSA Categories Progress Bar Chart ──────────────
                  _buildDsaChartCard(context, dsaState.topics),
                  const SizedBox(height: 24),
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
    final offers = internshipState.internships
        .where((i) => i.status == InternshipStatus.offer)
        .length;
    final solved = dsaState.solvedCount;
    final streak = dsaState.streak;

    return Row(
      children: [
        Expanded(
          child: _CardSummaryItem(
            title: 'APPLICATIONS',
            value: '$totalApps',
            subtitle: '$offers Offers secured',
            icon: Icons.work_outline_rounded,
            color: AppColors.statusBlue,
            bgColor: AppColors.statusBlueBg,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CardSummaryItem(
            title: 'DSA SOLVED',
            value: '$solved',
            subtitle: '$streak Day Streak 🔥',
            icon: Icons.code_rounded,
            color: AppColors.statusGreen,
            bgColor: AppColors.statusGreenBg,
          ),
        ),
      ],
    );
  }

  // ── Internship Status Pie Chart Card ────────────────────────────────

  Widget _buildInternshipsChartCard(BuildContext context, List<Internship> internships) {
    if (internships.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Center(
          child: Text(
            'Track internship applications to view pipeline analytics!',
            textAlign: TextAlign.center,
            style: AppTheme.inter(color: AppColors.textMuted),
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
      _PieData(value: applied.toDouble(), color: AppColors.statusBlue, title: 'Applied'),
      _PieData(value: interview.toDouble(), color: AppColors.statusAmber, title: 'Interview'),
      _PieData(value: offer.toDouble(), color: AppColors.statusGreen, title: 'Offer'),
      _PieData(value: rejected.toDouble(), color: AppColors.statusRed, title: 'Rejected'),
    ].where((d) => d.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APPLICATION STATUS BREAKDOWN',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '$total total',
                style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                          radius: 36,
                          titleStyle: AppTheme.mono(
                            fontSize: 11,
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
                    _buildLegendItem('Offer', AppColors.statusGreen, offer),
                    _buildLegendItem('Interview', AppColors.statusAmber, interview),
                    _buildLegendItem('Applied', AppColors.statusBlue, applied),
                    _buildLegendItem('Rejected', AppColors.statusRed, rejected),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTheme.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Text(
            '$count',
            style: AppTheme.mono(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── DSA Solved Categories Bar Chart Card ────────────────────────────

  Widget _buildDsaChartCard(BuildContext context, List<DsaTopic> topics) {
    final solvedTopics = topics.where((t) => t.isSolved).toList();

    if (solvedTopics.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Center(
          child: Text(
            'Solve DSA questions to see category-wise performance analytics!',
            textAlign: TextAlign.center,
            style: AppTheme.inter(color: AppColors.textMuted),
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

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SOLVED PROBLEMS BY TOPIC CATEGORY',
            style: AppTheme.mono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: yMax,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: AppColors.surfaceElevated,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final cat = DsaCategory.values[group.x.toInt()];
                      return BarTooltipItem(
                        '${cat.label}\n',
                        AppTheme.inter(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} solved',
                            style: AppTheme.mono(color: AppColors.accentLight),
                          ),
                        ],
                      );
                    },
                  ),
                ),
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
                        final label = cat.shortLabel;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: AppTheme.mono(
                              fontSize: 10,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
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
                          style: AppTheme.mono(fontSize: 10, color: AppColors.textMuted),
                        );
                      },
                      reservedSize: 22,
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppColors.cardBorder,
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
                        color: AppColors.accent,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5),
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
    );
  }
}

// ── Models & Widgets ────────────────────────────────────────────────────────

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
  final Color bgColor;

  const _CardSummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTheme.mono(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.mono(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTheme.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
