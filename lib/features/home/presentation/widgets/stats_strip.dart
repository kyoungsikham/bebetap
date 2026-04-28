import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../../../../shared/utils/text_measure.dart';
import '../../domain/models/home_summary.dart';
import '../providers/home_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';

double _labelFontSizeForCount(int count) => switch (count) {
      >= 6 => 8.5,
      5 => 9.0,
      _ => 10.0,
    };

/// 오늘 요약 수치 띠 — 기록된 항목만 동적으로 표시
class StatsStrip extends ConsumerWidget {
  const StatsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    return summaryAsync.when(
      loading: () => const _StatsStripSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final items = _buildItems(summary, unit, context.l10n);
        if (items.isEmpty) return const SizedBox.shrink();

        final scrollable = items.length > 4;
        final cardWidth = computeAdaptiveCardWidth(
          labels: items.map((e) => e.label).toList(),
          style: AppTypography.labelSmall.copyWith(
            fontSize: _labelFontSizeForCount(items.length),
          ),
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
          baseline: 68,
          horizontalPadding: 8,
          maxCap: 110,
        );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: scrollable ? AppSpacing.sm : AppSpacing.md,
            vertical: AppSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: scrollable
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (i > 0) _Divider(),
                        SizedBox(
                          width: cardWidth,
                          child: _StatItem(
                            icon: items[i].icon,
                            value: items[i].value,
                            label: items[i].label,
                            color: items[i].color,
                            count: items.length,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              : Row(
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      if (i > 0) _Divider(),
                      Expanded(
                        child: _StatItem(
                          icon: items[i].icon,
                          value: items[i].value,
                          label: items[i].label,
                          color: items[i].color,
                          count: items.length,
                        ),
                      ),
                    ],
                  ],
                ),
        );
      },
    );
  }

  List<_ItemData> _buildItems(HomeSummary summary, VolumeUnit unit, AppLocalizations l10n) {
    final result = <_ItemData>[];

    void add(TimelineEntryType type, String value) {
      final info = TrackingCategoryInfo.all[type]!;
      result.add(_ItemData(
        icon: info.icon,
        color: info.color,
        label: info.localizedLabel(l10n),
        value: value,
      ));
    }

    if (summary.todayFormulaTotalMl > 0) {
      add(TimelineEntryType.formula, unit.formatAmount(summary.todayFormulaTotalMl));
    }
    if (summary.todayBreastTotalSec > 0) {
      add(TimelineEntryType.breast, Duration(seconds: summary.todayBreastTotalSec).formatCompact());
    }
    if (summary.todayPumpedTotalMl > 0) {
      add(TimelineEntryType.pumped, unit.formatAmount(summary.todayPumpedTotalMl));
    }
    if (summary.todayBabyFoodTotalMl > 0) {
      add(TimelineEntryType.babyFood, unit.formatAmount(summary.todayBabyFoodTotalMl));
    }
    if (summary.todaySleepTotal > Duration.zero) {
      add(TimelineEntryType.sleep, summary.todaySleepTotal.formatCompact());
    }
    if (summary.todayDiaperCount > 0) {
      add(TimelineEntryType.diaper, l10n.timesCount(summary.todayDiaperCount));
    }

    return result;
  }
}

class _ItemData {
  const _ItemData({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.count,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final int count;

  double get _valueFontSize => switch (count) {
        >= 6 => 10.0,
        5 => 11.0,
        4 => 12.0,
        _ => 13.0,
      };


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontSize: _valueFontSize,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: _labelFontSizeForCount(count),
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Theme.of(context).dividerColor,
    );
  }
}

class _StatsStripSkeleton extends StatelessWidget {
  const _StatsStripSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A34) : const Color(0xFFE8E8EE),
      highlightColor: isDark ? const Color(0xFF3A3A46) : const Color(0xFFF8F8FA),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A34) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
