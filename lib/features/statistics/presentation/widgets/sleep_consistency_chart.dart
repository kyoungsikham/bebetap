import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';

class SleepConsistencyChart extends StatelessWidget {
  const SleepConsistencyChart({
    super.key,
    required this.bedtimes,
    required this.waketimes,
  });

  final List<TimeOfDay> bedtimes;
  final List<TimeOfDay> waketimes;

  @override
  Widget build(BuildContext context) {
    if (bedtimes.isEmpty && waketimes.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 140,
      child: ScatterChart(
        ScatterChartData(
          minX: 0,
          maxX: (bedtimes.length + waketimes.length - 1).toDouble().clamp(1, 30),
          minY: 0, // midnight
          maxY: 24, // midnight next day
          scatterSpots: [
            ..._buildSpots(bedtimes, const Color(0xFF5C6BC0), 0),
            ..._buildSpots(waketimes, const Color(0xFFFFD166), bedtimes.length.toDouble()),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                interval: 6,
                getTitlesWidget: (value, meta) {
                  final hour = value.toInt();
                  if (hour % 6 != 0) return const SizedBox.shrink();
                  return Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                      fontSize: 9,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
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
            horizontalInterval: 6,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 0.5,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          scatterTouchData: ScatterTouchData(enabled: false),
        ),
      ),
    );
  }

  List<ScatterSpot> _buildSpots(
      List<TimeOfDay> times, Color color, double xOffset) {
    return times.asMap().entries.map((entry) {
      final t = entry.value;
      // Convert to 24h decimal: adjust times after midnight
      double y = t.hour + t.minute / 60.0;
      return ScatterSpot(
        entry.key.toDouble() + xOffset,
        y,
        dotPainter: FlDotCirclePainter(
          radius: 4,
          color: color,
          strokeWidth: 0,
        ),
      );
    }).toList();
  }
}
