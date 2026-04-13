import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/feeding_stats.dart';

class FeedingTrendChart extends StatelessWidget {
  const FeedingTrendChart({super.key, required this.entries});

  final List<DailyFeedingEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // 91+ days → weekly average bar chart
    if (entries.length > 90) {
      return _WeeklyBarChart(entries: entries);
    }

    // ≤90 days → line chart
    return _DailyLineChart(entries: entries);
  }
}

class _DailyLineChart extends StatelessWidget {
  const _DailyLineChart({required this.entries});
  final List<DailyFeedingEntry> entries;

  @override
  Widget build(BuildContext context) {
    final maxMl = entries
        .map((e) => e.totalMl.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxMl > 0 ? maxMl * 1.2 : 100.0;

    final step = entries.length > 60
        ? 7
        : entries.length > 14
            ? 3
            : 1;

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: entries.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.totalMl.toDouble());
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 2,
              dotData: FlDotData(
                show: entries.length <= 14,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 0,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ],
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
                  if (i % step != 0 && i != entries.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${entries[i].date.day}',
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value == 0 || value == maxY) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    '${value.toInt()}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      fontSize: 9,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  const _WeeklyBarChart({required this.entries});
  final List<DailyFeedingEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Group entries into weeks and compute average
    final weeks = <({DateTime startDate, double avgMl})>[];
    for (var i = 0; i < entries.length; i += 7) {
      final chunk = entries.sublist(i, (i + 7).clamp(0, entries.length));
      final avg = chunk.fold<int>(0, (s, e) => s + e.totalMl) / chunk.length;
      weeks.add((startDate: chunk.first.date, avgMl: avg));
    }

    final maxMl = weeks.map((w) => w.avgMl).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxMl > 0 ? maxMl * 1.2 : 100.0;
    final barWidth = weeks.length <= 12 ? 16.0 : 10.0;

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: weeks.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.avgMl,
                  color: AppColors.primary,
                  width: barWidth,
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
                  if (i < 0 || i >= weeks.length) {
                    return const SizedBox.shrink();
                  }
                  final d = weeks[i].startDate;
                  final label = '${d.month}/${d.day}';
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        fontSize: 9,
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
