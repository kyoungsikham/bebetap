import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';

class SleepNapPieChart extends StatelessWidget {
  const SleepNapPieChart({
    super.key,
    required this.napMinutes,
    required this.nightMinutes,
  });

  final int napMinutes;
  final int nightMinutes;

  @override
  Widget build(BuildContext context) {
    final total = napMinutes + nightMinutes;
    if (total == 0) return const SizedBox.shrink();

    final napPercent = (napMinutes / total * 100).round();
    final nightPercent = 100 - napPercent;
    final l10n = context.l10n;

    return SizedBox(
      height: 140,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    value: napMinutes.toDouble(),
                    color: const Color(0xFFFFD166),
                    radius: 24,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: nightMinutes.toDouble(),
                    color: const Color(0xFF7B68EE),
                    radius: 24,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                color: const Color(0xFFFFD166),
                label: l10n.napSleep,
                value: '$napPercent%',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: const Color(0xFF7B68EE),
                label: l10n.nightSleep,
                value: '$nightPercent%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(width: 6),
        Text(
          '$label $value',
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
