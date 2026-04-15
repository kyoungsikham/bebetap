import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../../domain/models/daily_timeline.dart';
import '../providers/statistics_provider.dart';
import '../widgets/daily_timeline_chart.dart';
import '../widgets/insight_card.dart';
import '../widgets/pattern_date_range_bar.dart';
import '../widgets/stats_nav_card.dart';
import 'comparison_screen.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final _activeFilters = <TimelineEventType>{};
  bool _filtersInitialized = false;

  /// Map TimelineEntryType (icon settings) → TimelineEventType (chart filter)
  static const _entryToEventType = <TimelineEntryType, TimelineEventType>{
    TimelineEntryType.formula: TimelineEventType.formula,
    TimelineEntryType.breast: TimelineEventType.breast,
    TimelineEntryType.pumped: TimelineEventType.pumped,
    TimelineEntryType.babyFood: TimelineEventType.babyFood,
    TimelineEntryType.diaper: TimelineEventType.diaper,
    TimelineEntryType.sleep: TimelineEventType.sleep,
  };

  /// Types that appear as filter chips (exclude temperature, diary)
  static const _filterableTypes = {
    TimelineEntryType.formula,
    TimelineEntryType.breast,
    TimelineEntryType.pumped,
    TimelineEntryType.babyFood,
    TimelineEntryType.diaper,
    TimelineEntryType.sleep,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final range = ref.watch(statsDateRangeProvider);
    final timelineAsync = ref.watch(dailyTimelineProvider(range));
    final visibleCategories = ref.watch(visibleCategoriesProvider);

    // Initialize filters from icon settings (once)
    if (!_filtersInitialized) {
      _filtersInitialized = true;
      for (final type in visibleCategories) {
        final eventType = _entryToEventType[type];
        if (eventType != null) _activeFilters.add(eventType);
      }
    }

    // Visible filterable types for chips
    final visibleFilterable = visibleCategories
        .where((t) => _filterableTypes.contains(t))
        .toList();

    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final colorIndex = baby != null
        ? babies.indexWhere((b) => b.id == baby.id)
        : -1;

    // Determine which nav cards to show
    final hasFeedingTypes = visibleCategories.any((t) =>
        t == TimelineEntryType.formula ||
        t == TimelineEntryType.breast ||
        t == TimelineEntryType.pumped);
    final hasBabyFood =
        visibleCategories.contains(TimelineEntryType.babyFood);
    final hasSleep = visibleCategories.contains(TimelineEntryType.sleep);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (baby != null) ...[
              BabyAvatarWidget(
                photoUrl: baby.photoUrl,
                gender: baby.gender,
                colorIndex: colorIndex >= 0 ? colorIndex : null,
                size: 32,
              ),
              const SizedBox(width: 8),
            ],
            Text(baby?.name ?? l10n.statistics, style: AppTypography.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows, size: 22),
            tooltip: l10n.babyComparison,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ComparisonScreen(),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.md,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        children: [
          // Date range selector (day/week toggle + arrows)
          PatternDateRangeBar(
            selected: range,
            onChanged: (r) =>
                ref.read(statsDateRangeProvider.notifier).setRange(r),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Section title
          Text(
            l10n.lifePattern,
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.lifePatternTip,
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Filter chips (horizontal scroll)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: visibleFilterable.map((entryType) {
                final eventType = _entryToEventType[entryType]!;
                final info = TrackingCategoryInfo.all[entryType]!;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: TimelineFilterChip(
                    label: info.localizedLabel(l10n),
                    type: eventType,
                    selected: _activeFilters.contains(eventType),
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _activeFilters.add(eventType);
                        } else {
                          _activeFilters.remove(eventType);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Timeline chart
          timelineAsync.when(
            loading: () => const _SkeletonCard(height: 200),
            error: (_, _) => const SizedBox.shrink(),
            data: (data) {
              final hasData = data.days.any((d) => d.events.isNotEmpty);
              if (!hasData) {
                return Container(
                  height: 200,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Theme.of(context).dividerColor),
                  ),
                  child: Text(
                    l10n.dataLoadFailed,
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ),
                );
              }
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: Theme.of(context).dividerColor),
                ),
                child: DailyTimelineChart(
                  data: data,
                  activeFilters: _activeFilters,
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Insights
          Builder(
            builder: (context) {
              final insightsAsync = ref.watch(parentInsightsProvider);
              return insightsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (insights) {
                  if (insights.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.insightsTitle,
                        style: AppTypography.titleMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final insight in insights) ...[
                        InsightCard(
                          insight: insight,
                          resolvedBody: resolveInsightBody(l10n, insight),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              );
            },
          ),

          // Navigation cards to sub-pages
          if (hasFeedingTypes)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatsNavCard(
                icon: Icons.local_drink,
                title: l10n.feedingStatsTitle,
                color: const Color(0xFF5B7FFF),
                onTap: () => context.push(AppRoutes.feedingStats),
              ),
            ),
          if (hasBabyFood)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatsNavCard(
                icon: Icons.restaurant,
                title: l10n.babyFoodStatsTitle,
                color: const Color(0xFFFF9800),
                onTap: () => context.push(AppRoutes.babyFoodStats),
              ),
            ),
          if (hasSleep)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatsNavCard(
                icon: Icons.bedtime,
                title: l10n.sleepStatsTitle,
                color: const Color(0xFF7B68EE),
                onTap: () => context.push(AppRoutes.sleepStats),
              ),
            ),
          if (baby != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatsNavCard(
                icon: Icons.monitor_weight,
                title: l10n.growthStatsTitle,
                color: const Color(0xFF26A69A),
                onTap: () => context.push(AppRoutes.growthStats),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          BannerAdWidget(adUnitId: AdConfig.statsBannerId),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({this.height = 80});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
    );
  }
}
