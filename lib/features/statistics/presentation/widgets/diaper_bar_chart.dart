import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/diaper_stats.dart';

class DiaperBarChart extends StatelessWidget {
  const DiaperBarChart({super.key, required this.entries});

  final List<DailyDiaperEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final maxCount = entries
        .map((e) => e.total.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = (maxCount + 2).clamp(4.0, 30.0);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barGroups: entries.asMap().entries.map((entry) {
                final i = entry.key;
                final d = entry.value;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: d.total.toDouble(),
                      width: entries.length <= 7 ? 20 : 10,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                      rodStackItems: _buildStack(d),
                      color: Colors.transparent,
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
                      final step = entries.length > 14 ? 3 : 1;
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
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppColors.primary, label: l10n.wetDiaper),
            const SizedBox(width: 12),
            _Legend(color: const Color(0xFF00BFA5), label: l10n.soiledDiaper),
            const SizedBox(width: 12),
            _Legend(color: AppColors.warning, label: l10n.bothDiaper),
          ],
        ),
      ],
    );
  }

  List<BarChartRodStackItem> _buildStack(DailyDiaperEntry d) {
    final items = <BarChartRodStackItem>[];
    double from = 0;

    if (d.wet > 0) {
      items.add(BarChartRodStackItem(from, from + d.wet, AppColors.primary));
      from += d.wet;
    }
    if (d.soiled > 0) {
      items.add(BarChartRodStackItem(
          from, from + d.soiled, const Color(0xFF00BFA5)));
      from += d.soiled;
    }
    if (d.both > 0) {
      items.add(BarChartRodStackItem(from, from + d.both, AppColors.warning));
      from += d.both;
    }
    if (d.dry > 0) {
      items.add(BarChartRodStackItem(
          from, from + d.dry, const Color(0xFFBDBDBD)));
    }
    return items;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
