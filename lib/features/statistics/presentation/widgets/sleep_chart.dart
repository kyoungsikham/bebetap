import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../domain/models/sleep_stats.dart';

class SleepBarChart extends StatelessWidget {
  const SleepBarChart({super.key, required this.entries});

  final List<DailySleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final maxHours = entries
        .map((e) => e.duration.inMinutes / 60.0)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (maxHours + 1).clamp(4.0, 24.0);

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: entries.asMap().entries.map((entry) {
            final i = entry.key;
            final data = entry.value;
            final hours = data.duration.inMinutes / 60.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: hours,
                  color: const Color(0xFF7B68EE),
                  width: 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxY,
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  final weekday = weekdays[entries[i].date.weekday - 1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      weekday,
                      style: AppTypography.labelSmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
