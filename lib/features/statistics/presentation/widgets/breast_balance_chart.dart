import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';

class BreastBalanceChart extends StatelessWidget {
  const BreastBalanceChart({
    super.key,
    required this.leftRatio,
  });

  /// 0.0 = all right, 1.0 = all left
  final double leftRatio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final leftPercent = (leftRatio * 100).round();
    final rightPercent = 100 - leftPercent;

    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 24,
                sections: [
                  PieChartSectionData(
                    value: leftRatio,
                    color: AppColors.primary,
                    radius: 20,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 1 - leftRatio,
                    color: const Color(0xFFD81B60),
                    radius: 20,
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
                color: AppColors.primary,
                label: l10n.leftBreast,
                value: '$leftPercent%',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: const Color(0xFFD81B60),
                label: l10n.rightBreast,
                value: '$rightPercent%',
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
