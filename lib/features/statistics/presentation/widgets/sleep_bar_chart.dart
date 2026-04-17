import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/sleep_stats.dart';

class SleepBarChart extends StatelessWidget {
  const SleepBarChart({super.key, required this.entries});

  final List<DailySleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // 91+ days → weekly average bar chart
    if (entries.length > 90) {
      return _WeeklySleepBarChart(entries: entries);
    }

    return _DailySleepBarChart(entries: entries);
  }
}

class _DailySleepBarChart extends StatelessWidget {
  const _DailySleepBarChart({required this.entries});
  final List<DailySleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final weekdays = [
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat,
      l10n.weekdaySun,
    ];

    final maxHours = entries
        .map((e) => e.duration.inMinutes / 60.0)
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (maxHours + 1).clamp(4.0, 24.0);

    final useWeekdays = entries.length <= 7;
    final barWidth = entries.length <= 7
        ? 20.0
        : entries.length <= 30
            ? 10.0
            : 6.0;

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
                  color: const Color(0xFF5C6BC0),
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
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  String label;
                  if (useWeekdays) {
                    label = weekdays[entries[i].date.weekday - 1];
                  } else {
                    final d = entries[i].date;
                    label = '${d.day}';
                    final step = entries.length > 60
                        ? 7
                        : entries.length > 14
                            ? 3
                            : 1;
                    if (i % step != 0 && i != entries.length - 1) {
                      return const SizedBox.shrink();
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      label,
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

class _WeeklySleepBarChart extends StatelessWidget {
  const _WeeklySleepBarChart({required this.entries});
  final List<DailySleepEntry> entries;

  @override
  Widget build(BuildContext context) {
    // Group into weeks and compute average hours
    final weeks = <({DateTime startDate, double avgHours})>[];
    for (var i = 0; i < entries.length; i += 7) {
      final chunk = entries.sublist(i, (i + 7).clamp(0, entries.length));
      final avgMin =
          chunk.fold<int>(0, (s, e) => s + e.duration.inMinutes) / chunk.length;
      weeks.add((startDate: chunk.first.date, avgHours: avgMin / 60.0));
    }

    final maxHours =
        weeks.map((w) => w.avgHours).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (maxHours + 1).clamp(4.0, 24.0);
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
                  toY: entry.value.avgHours,
                  color: const Color(0xFF5C6BC0),
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
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${d.month}/${d.day}',
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
