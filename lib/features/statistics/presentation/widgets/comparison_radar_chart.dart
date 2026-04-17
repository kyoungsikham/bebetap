import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/comparison_data.dart';

class ComparisonRadarChart extends StatelessWidget {
  const ComparisonRadarChart({super.key, required this.result});

  final ComparisonResult result;

  static const _colors = [
    AppColors.primary,
    Color(0xFFD81B60),
    Color(0xFF00BFA5),
    Color(0xFFFFD166),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (result.babies.isEmpty) return const SizedBox.shrink();

    // Normalize values across babies for radar chart
    double maxSleep = 1;
    double maxFeeding = 1;
    double maxDiaper = 1;
    for (final b in result.babies) {
      if (b.totalSleepMinutes > maxSleep) {
        maxSleep = b.totalSleepMinutes.toDouble();
      }
      if (b.totalFeedingMl > maxFeeding) {
        maxFeeding = b.totalFeedingMl.toDouble();
      }
      if (b.totalDiaperCount > maxDiaper) {
        maxDiaper = b.totalDiaperCount.toDouble();
      }
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: AppTypography.labelSmall.copyWith(
                color: Colors.transparent,
              ),
              tickBorderData: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              gridBorderData: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              radarBorderData: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              titleTextStyle: AppTypography.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              getTitle: (index, angle) {
                switch (index) {
                  case 0:
                    return RadarChartTitle(text: l10n.sleepSection);
                  case 1:
                    return RadarChartTitle(text: l10n.feedingSection);
                  case 2:
                    return RadarChartTitle(text: l10n.diaperSection);
                  default:
                    return const RadarChartTitle(text: '');
                }
              },
              dataSets: result.babies.asMap().entries.map((entry) {
                final i = entry.key;
                final b = entry.value;
                final color = _colors[i % _colors.length];
                return RadarDataSet(
                  fillColor: color.withValues(alpha: 0.1),
                  borderColor: color,
                  borderWidth: 2,
                  entryRadius: 3,
                  dataEntries: [
                    RadarEntry(value: b.totalSleepMinutes / maxSleep),
                    RadarEntry(value: b.totalFeedingMl / maxFeeding),
                    RadarEntry(value: b.totalDiaperCount / maxDiaper),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: result.babies.asMap().entries.map((entry) {
            final i = entry.key;
            final b = entry.value;
            final color = _colors[i % _colors.length];
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  b.babyName,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
