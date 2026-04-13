import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/date_range_selection.dart';
import '../../domain/models/diaper_stats.dart';
import 'diaper_bar_chart.dart';
import 'stat_card.dart';

class DiaperStatsSection extends StatelessWidget {
  const DiaperStatsSection({
    super.key,
    required this.stats,
    required this.range,
  });

  final DiaperStats stats;
  final DateRangeSelection range;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.diaperSection,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Total count card
        StatCard(
          icon: Icons.baby_changing_station,
          label: l10n.diaperChangeLabel,
          value: l10n.timesCount(stats.totalCount),
          deltaPercent: stats.deltaPercent,
          color: const Color(0xFF52B788),
          subtitle: _buildSubtitle(context),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Daily diaper chart
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
                  l10n.dailyDiaperTrend,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DiaperBarChart(entries: stats.dailyEntries),
              ],
            ),
          ),
      ],
    );
  }

  String? _buildSubtitle(BuildContext context) {
    final l10n = context.l10n;
    final parts = <String>[];
    if (stats.wetCount > 0) parts.add('${l10n.wetDiaper} ${stats.wetCount}');
    if (stats.soiledCount > 0) {
      parts.add('${l10n.soiledDiaper} ${stats.soiledCount}');
    }
    if (stats.bothCount > 0) parts.add('${l10n.bothDiaper} ${stats.bothCount}');
    return parts.isNotEmpty ? parts.join(' · ') : null;
  }
}
