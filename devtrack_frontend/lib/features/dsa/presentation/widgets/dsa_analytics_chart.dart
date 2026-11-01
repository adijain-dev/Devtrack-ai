import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/dsa_topic.dart';
import '../providers/dsa_state.dart';

class DsaAnalyticsChart extends StatefulWidget {
  final DsaState state;

  const DsaAnalyticsChart({super.key, required this.state});

  @override
  State<DsaAnalyticsChart> createState() => _DsaAnalyticsChartState();
}

class _DsaAnalyticsChartState extends State<DsaAnalyticsChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.state.topics.isEmpty) {
      return const SizedBox.shrink();
    }

    final easySolved = widget.state.topics
        .where((t) => t.difficulty == DsaDifficulty.easy && t.isSolved)
        .length;
    final mediumSolved = widget.state.topics
        .where((t) => t.difficulty == DsaDifficulty.medium && t.isSolved)
        .length;
    final hardSolved = widget.state.topics
        .where((t) => t.difficulty == DsaDifficulty.hard && t.isSolved)
        .length;

    final totalSolved = widget.state.solvedCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Difficulty Analytics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Total Solved: $totalSolved',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: totalSolved == 0
                      ? Center(
                          child: Text(
                            'Solve topics to view chart',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        )
                      : PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse
                                      .touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 4,
                            centerSpaceRadius: 35,
                            sections: _generatePieSections(
                              easy: easySolved,
                              medium: mediumSolved,
                              hard: hardSolved,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Indicator(
                      color: Colors.green,
                      text: 'Easy ($easySolved)',
                      isSquare: true,
                    ),
                    const SizedBox(height: 8),
                    _Indicator(
                      color: Colors.orange,
                      text: 'Medium ($mediumSolved)',
                      isSquare: true,
                    ),
                    const SizedBox(height: 8),
                    _Indicator(
                      color: Colors.red,
                      text: 'Hard ($hardSolved)',
                      isSquare: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections({
    required int easy,
    required int medium,
    required int hard,
  }) {
    final List<PieChartSectionData> sections = [];
    int index = 0;

    if (easy > 0) {
      final isTouched = index == _touchedIndex;
      sections.add(PieChartSectionData(
        color: Colors.green,
        value: easy.toDouble(),
        title: '$easy',
        radius: isTouched ? 45.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      index++;
    }

    if (medium > 0) {
      final isTouched = index == _touchedIndex;
      sections.add(PieChartSectionData(
        color: Colors.orange,
        value: medium.toDouble(),
        title: '$medium',
        radius: isTouched ? 45.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
      index++;
    }

    if (hard > 0) {
      final isTouched = index == _touchedIndex;
      sections.add(PieChartSectionData(
        color: Colors.red,
        value: hard.toDouble(),
        title: '$hard',
        radius: isTouched ? 45.0 : 38.0,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }

    return sections;
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const _Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
            borderRadius: isSquare ? BorderRadius.circular(3) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
