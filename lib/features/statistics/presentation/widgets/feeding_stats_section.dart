import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../domain/models/date_range_selection.dart';
import '../../domain/models/feeding_stats.dart';
import 'breast_balance_chart.dart';
import 'feeding_trend_chart.dart';
import 'stat_card.dart';

class FeedingStatsSection extends StatelessWidget {
  const FeedingStatsSection({
    super.key,
    required this.stats,
    required this.range,
    required this.volumeUnit,
  });

  final FeedingStats stats;
  final DateRangeSelection range;
  final VolumeUnit volumeUnit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (stats.totalFormulaMl == 0 &&
        stats.totalBreastSec == 0 &&
        stats.totalPumpedMl == 0 &&
        stats.totalBabyFoodMl == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.feedingSection,
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatCard(
            icon: Icons.local_drink,
            label: l10n.feedingSection,
            value: l10n.noFeedingRecord,
            color: AppColors.primary,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.feedingSection,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Formula card
        if (stats.totalFormulaMl > 0)
          StatCard(
            icon: Icons.local_drink,
            label: l10n.formula,
            value: volumeUnit.formatAmount(stats.totalFormulaMl),
            subtitle: l10n.timesCount(stats.totalFormulaCount),
            deltaPercent: stats.formulaDeltaPercent,
            color: AppColors.primary,
          ),
        if (stats.totalFormulaMl > 0) const SizedBox(height: AppSpacing.sm),

        // Breast card
        if (stats.totalBreastSec > 0)
          StatCard(
            icon: Icons.favorite_outline,
            label: l10n.breast,
            value: stats.totalBreastDuration.formatHhMm(),
            subtitle: l10n.timesCount(stats.totalBreastCount),
            deltaPercent: stats.breastDeltaPercent,
            color: const Color(0xFFD81B60),
          ),
        if (stats.totalBreastSec > 0) const SizedBox(height: AppSpacing.sm),

        // Average feeding interval
        if (stats.avgIntervalHours != null)
          StatCard(
            icon: Icons.schedule,
            label: l10n.avgFeedingInterval,
            value: _formatInterval(stats.avgIntervalHours!),
            color: AppColors.primary,
          ),
        if (stats.avgIntervalHours != null) const SizedBox(height: AppSpacing.sm),

        // Daily intake trend chart
        if (stats.dailyEntries.isNotEmpty && range.days > 1)
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
                  l10n.dailyIntakeTrend,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                FeedingTrendChart(entries: stats.dailyEntries),
              ],
            ),
          ),
        if (stats.dailyEntries.isNotEmpty && range.days > 1)
          const SizedBox(height: AppSpacing.sm),

        // Left/Right balance
        if (stats.leftRightRatio != null)
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
                  l10n.leftRightBalance,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                BreastBalanceChart(leftRatio: stats.leftRightRatio!),
              ],
            ),
          ),
      ],
    );
  }

  String _formatInterval(double hours) {
    final h = hours.floor();
    final m = ((hours - h) * 60).round();
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
