import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/data/who_growth_standards.dart';

/// Renders WHO percentile curves (P3/P15/P50/P85/P97) for 0–24 months
/// and overlays the child's current measurement as a highlighted dot.
class GrowthPercentileChart extends StatelessWidget {
  const GrowthPercentileChart({
    super.key,
    required this.standards,
    required this.unitLabel,
    this.currentValue,
    this.currentAgeMonths,
  });

  final List<WhoGrowthPoint> standards;
  final String unitLabel; // 'cm' or 'kg'
  final double? currentValue;
  final int? currentAgeMonths;

  static const _percentileColors = [
    Color(0xFFBDBDBD), // P3
    Color(0xFF90A4AE), // P15
    Color(0xFF26A69A), // P50 — highlighted
    Color(0xFF90A4AE), // P85
    Color(0xFFBDBDBD), // P97
  ];

  static const _percentileWidths = [1.0, 1.0, 2.0, 1.0, 1.0];
  static const _percentileLabels = ['P3', 'P15', 'P50', 'P85', 'P97'];

  List<FlSpot> _spots(double Function(WhoGrowthPoint) selector) =>
      standards.map((p) => FlSpot(p.ageMonths.toDouble(), selector(p))).toList();

  @override
  Widget build(BuildContext context) {
    final allValues = standards.expand((p) => [p.p3, p.p97]).toList();
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 2;

    // Extra dot for the child's current position
    final List<LineChartBarData> extraDotBar = [];
    if (currentValue != null && currentAgeMonths != null) {
      extraDotBar.add(
        LineChartBarData(
          spots: [FlSpot(currentAgeMonths!.toDouble(), currentValue!)],
          color: Colors.transparent,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
              radius: 6,
              color: AppColors.primary,
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ),
      );
    }

    final curveBars = [
      _curveBar(_spots((p) => p.p3), 0),
      _curveBar(_spots((p) => p.p15), 1),
      _curveBar(_spots((p) => p.p50), 2),
      _curveBar(_spots((p) => p.p85), 3),
      _curveBar(_spots((p) => p.p97), 4),
      ...extraDotBar,
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 24,
          minY: minY,
          maxY: maxY,
          lineBarsData: curveBars,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 6,
                getTitlesWidget: (value, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${value.toInt()}m',
                    style: AppTypography.labelSmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toStringAsFixed(unitLabel == 'kg' ? 1 : 0),
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
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Theme.of(context).dividerColor,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: currentValue != null,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (spots) => spots.map((s) {
                // Only show tooltip for the child dot (last bar)
                if (s.barIndex < 5) {
                  return LineTooltipItem(
                    _percentileLabels[s.barIndex],
                    AppTypography.labelSmall.copyWith(
                      color: _percentileColors[s.barIndex],
                      fontSize: 9,
                    ),
                  );
                }
                return LineTooltipItem(
                  '${s.y.toStringAsFixed(unitLabel == 'kg' ? 1 : 0)} $unitLabel',
                  AppTypography.labelLarge.copyWith(color: AppColors.primary),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _curveBar(List<FlSpot> spots, int index) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3,
      color: _percentileColors[index],
      barWidth: _percentileWidths[index],
      dotData: const FlDotData(show: false),
      dashArray: index == 2 ? null : [4, 3],
    );
  }
}
