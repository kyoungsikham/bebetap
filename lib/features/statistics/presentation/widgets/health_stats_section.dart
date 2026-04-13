import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/date_range_selection.dart';
import '../../domain/models/temperature_stats.dart';
import 'stat_card.dart';
import 'temperature_line_chart.dart';

class HealthStatsSection extends StatelessWidget {
  const HealthStatsSection({
    super.key,
    required this.tempStats,
    required this.range,
  });

  final TemperatureStats tempStats;
  final DateRangeSelection range;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (tempStats.measurementCount == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.healthSection,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Latest temperature
        if (tempStats.latestCelsius != null)
          StatCard(
            icon: Icons.thermostat,
            label: l10n.temperature,
            value: '${tempStats.latestCelsius!.toStringAsFixed(1)}°C',
            subtitle: tempStats.avgCelsius != null
                ? '${l10n.avgLabel}: ${tempStats.avgCelsius!.toStringAsFixed(1)}°C'
                : null,
            color: tempStats.hasFever ? AppColors.error : AppColors.primary,
          ),
        if (tempStats.latestCelsius != null) const SizedBox(height: AppSpacing.sm),

        // Temperature trend chart
        if (tempStats.dailyEntries.length >= 2)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.temperatureTrend,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TemperatureLineChart(entries: tempStats.dailyEntries),
              ],
            ),
          ),
      ],
    );
  }
}
