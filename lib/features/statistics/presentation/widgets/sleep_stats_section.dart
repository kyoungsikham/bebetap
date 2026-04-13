import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/date_range_selection.dart';
import '../../domain/models/sleep_stats.dart';
import 'sleep_bar_chart.dart';
import 'sleep_consistency_chart.dart';
import 'sleep_nap_pie_chart.dart';
import 'sleep_vs_recommended.dart';
import 'stat_card.dart';

class SleepStatsSection extends StatelessWidget {
  const SleepStatsSection({
    super.key,
    required this.stats,
    required this.range,
  });

  final SleepStats stats;
  final DateRangeSelection range;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sleepSection,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Total sleep card
        StatCard(
          icon: Icons.bedtime,
          label: l10n.totalSleep,
          value: stats.totalDuration.formatHhMm(),
          deltaPercent: stats.deltaPercent,
          color: const Color(0xFF7B68EE),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Sleep vs recommended (if data available)
        if (stats.ageRecommendedMin != null && stats.ageRecommendedMax != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: SleepVsRecommended(
              actualHours: stats.avgDailyHours,
              recommendedMin: stats.ageRecommendedMin!,
              recommendedMax: stats.ageRecommendedMax!,
            ),
          ),
        if (stats.ageRecommendedMin != null) const SizedBox(height: AppSpacing.sm),

        // Nap vs Night pie chart
        if (stats.napTotal.inMinutes > 0 || stats.nightTotal.inMinutes > 0)
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
                  l10n.napVsNight,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                SleepNapPieChart(
                  napMinutes: stats.napTotal.inMinutes,
                  nightMinutes: stats.nightTotal.inMinutes,
                ),
              ],
            ),
          ),
        if (stats.napTotal.inMinutes > 0 || stats.nightTotal.inMinutes > 0)
          const SizedBox(height: AppSpacing.sm),

        // Daily sleep bar chart
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
                  l10n.dailySleepTrend,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SleepBarChart(entries: stats.dailyEntries),
              ],
            ),
          ),
        if (stats.dailyEntries.isNotEmpty && range.days > 1)
          const SizedBox(height: AppSpacing.sm),

        // Longest consecutive sleep
        if (stats.longestConsecutive.inMinutes > 0)
          StatCard(
            icon: Icons.hotel,
            label: l10n.longestSleep,
            value: stats.longestConsecutive.formatHhMm(),
            color: const Color(0xFF7B68EE),
          ),
        if (stats.longestConsecutive.inMinutes > 0)
          const SizedBox(height: AppSpacing.sm),

        // Bedtime consistency
        if (stats.bedtimes.length >= 2)
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
                Row(
                  children: [
                    Text(
                      l10n.bedtimeConsistency,
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                    const Spacer(),
                    if (stats.bedtimeConsistency != null)
                      _ConsistencyBadge(score: stats.bedtimeConsistency!),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SleepConsistencyChart(
                  bedtimes: stats.bedtimes,
                  waketimes: stats.waketimes,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConsistencyBadge extends StatelessWidget {
  const _ConsistencyBadge({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 0.7
        ? const Color(0xFF6BCB77)
        : score >= 0.4
            ? const Color(0xFFFFD166)
            : const Color(0xFFEF767A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${(score * 100).round()}%',
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
