import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/temperature_stats.dart';

class TemperatureLineChart extends StatelessWidget {
  const TemperatureLineChart({super.key, required this.entries});

  final List<DailyTemperatureEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final maxC = entries
        .map((e) => e.maxCelsius)
        .fold(0.0, (a, b) => a > b ? a : b);
    final minC = entries
        .map((e) => e.avgCelsius)
        .fold(100.0, (a, b) => a < b ? a : b);
    final maxY = (maxC + 0.5).clamp(37.0, 42.0);
    final minY = (minC - 0.5).clamp(35.0, 37.0);

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: entries.asMap().entries.map((e) {
                return FlSpot(
                    e.key.toDouble(), e.value.avgCelsius);
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.error,
              barWidth: 2,
              dotData: FlDotData(
                show: entries.length <= 14,
                getDotPainter: (spot, percent, bar, index) {
                  final isFever = spot.y >= 37.5;
                  return FlDotCirclePainter(
                    radius: 3,
                    color: isFever ? AppColors.error : AppColors.primary,
                    strokeWidth: 0,
                  );
                },
              ),
            ),
          ],
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: 37.5,
                color: AppColors.error.withValues(alpha: 0.4),
                strokeWidth: 1,
                dashArray: [5, 3],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.error,
                    fontSize: 9,
                  ),
                  labelResolver: (_) => '37.5°C',
                ),
              ),
            ],
          ),
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
                  return Text(
                    value.toStringAsFixed(1),
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
