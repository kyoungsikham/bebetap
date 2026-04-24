import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../../../shared/utils/baby_age.dart';
import '../../../../shared/widgets/baby_avatar_widget.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../log/domain/models/timeline_entry.dart';
import '../../domain/models/daily_timeline.dart';
import '../../domain/models/date_range_selection.dart';
import '../providers/statistics_provider.dart';
import '../widgets/daily_timeline_chart.dart';
import '../widgets/pattern_date_range_bar.dart';
import '../widgets/stats_nav_card.dart';
import '../widgets/stats_summary_card.dart';
import 'comparison_screen.dart';

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

    // Determine which nav cards to show
    final hasFeedingTypes = visibleCategories.any((t) =>
        t == TimelineEntryType.formula ||
        t == TimelineEntryType.breast ||
        t == TimelineEntryType.pumped);
    final hasBabyFood =
        visibleCategories.contains(TimelineEntryType.babyFood);
    final hasSleep = visibleCategories.contains(TimelineEntryType.sleep);

    return Scaffold(
      body: Column(
        children: [
          _StatisticsHeader(
            onCompareTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ComparisonScreen()),
            ),
          ),
          Expanded(
            child: ListView(
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
          const SizedBox(height: AppSpacing.lg),

          // Summary cards
          _SummarySection(range: range),
          const SizedBox(height: AppSpacing.lg),

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
                color: const Color(0xFFFFA000),
                onTap: () => context.push(AppRoutes.babyFoodStats),
              ),
            ),
          if (hasSleep)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: StatsNavCard(
                icon: Icons.bedtime,
                title: l10n.sleepStatsTitle,
                color: const Color(0xFF5C6BC0),
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
        ],
      ),
    ),
        ],
      ),
    );
  }
}

class _StatisticsHeader extends ConsumerStatefulWidget {
  const _StatisticsHeader({required this.onCompareTap});

  final VoidCallback onCompareTap;

  @override
  ConsumerState<_StatisticsHeader> createState() => _StatisticsHeaderState();
}

class _StatisticsHeaderState extends ConsumerState<_StatisticsHeader> {
  final _avatarKey = GlobalKey();

  void _showBabyPopup(List babies, String? currentId) {
    final box =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        pos.dx,
        pos.dy + size.height + 6,
        pos.dx + size.width,
        pos.dy + size.height + 6,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: babies.asMap().entries.map<PopupMenuEntry<String>>((entry) {
        final index = entry.key;
        final baby = entry.value;
        final isSelected = baby.id == currentId;
        return PopupMenuItem<String>(
          value: baby.id,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BabyAvatarWidget(
                photoUrl: baby.photoUrl,
                gender: baby.gender,
                colorIndex: index,
                size: 36,
              ),
              const SizedBox(width: 10),
              Text(
                baby.name,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check, size: 16),
              ],
            ],
          ),
        );
      }).toList(),
    ).then((selectedId) {
      if (selectedId != null) {
        ref.read(selectedBabyIdProvider.notifier).select(selectedId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;

    final baby = ref.watch(selectedBabyProvider).valueOrNull;
    final babies = ref.watch(babiesProvider).valueOrNull ?? [];
    final selectedId = ref.watch(selectedBabyIdProvider);
    final name = baby?.name ?? l10n.statistics;
    final ageLabel = baby != null ? babyAgeLabel(context, baby.birthDate) : null;
    final babyColorIndex =
        baby != null ? babies.indexWhere((b) => b.id == baby.id) : 0;
    final canSwitch = babies.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [Color(0xFF1A1020), Color(0xFF161520), Color(0xFF121218)]
              : const [Color(0xFFFFEEF0), Color(0xFFFFF5F6), Color(0xFFFFFFFF)],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      child: Row(
        children: [
          Stack(
            key: _avatarKey,
            clipBehavior: Clip.none,
            children: [
              BabyAvatarWidget(
                photoUrl: baby?.photoUrl,
                gender: baby?.gender,
                colorIndex: babyColorIndex >= 0 ? babyColorIndex : null,
                size: 48,
                onTap: canSwitch
                    ? () => _showBabyPopup(babies, selectedId)
                    : null,
              ),
              if (babies.length > 1)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: GestureDetector(
                    onTap: () => _showBabyPopup(babies, selectedId),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.expand_more,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Text(name, style: AppTypography.titleLarge),
          if (ageLabel != null) ...[
            const SizedBox(width: 8),
            Text(
              ageLabel,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.compare_arrows, size: 22),
            tooltip: l10n.babyComparison,
            onPressed: widget.onCompareTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends ConsumerWidget {
  const _SummarySection({required this.range});
  final DateRangeSelection range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final sleepAsync = ref.watch(sleepStatsProvider(range));
    final feedingAsync = ref.watch(feedingStatsProvider(range));

    final cards = <Widget>[];

    // Sleep summary
    sleepAsync.whenData((sleep) {
      final avg = sleep.avgDailyHours;
      final min = sleep.ageRecommendedMin;
      final max = sleep.ageRecommendedMax;
      if (avg <= 0 || min == null || max == null) return;

      final hoursStr = avg.toStringAsFixed(1);
      String text;
      Color color;
      if (avg >= min && avg <= max) {
        text = l10n.statsSleepInRange(hoursStr);
        color = const Color(0xFF26A69A);
      } else if (avg < min) {
        final diff = (min - avg).toStringAsFixed(1);
        text = l10n.statsSleepBelow(hoursStr, diff);
        color = const Color(0xFFFFA000);
      } else {
        final diff = (avg - max).toStringAsFixed(1);
        text = l10n.statsSleepAbove(hoursStr, diff);
        color = const Color(0xFFFFA000);
      }
      cards.add(StatsSummaryCard(
        icon: Icons.bedtime,
        text: text,
        color: color,
      ));
    });

    // Feeding summary
    feedingAsync.whenData((feeding) {
      final delta = feeding.formulaDeltaPercent ?? feeding.breastDeltaPercent;
      if (delta == null) return;

      String text;
      Color color;
      if (delta.abs() < 5) {
        text = l10n.statsFeedingSame;
        color = const Color(0xFF26A69A);
      } else if (delta > 0) {
        text = l10n.statsFeedingUp(delta.abs().toStringAsFixed(0));
        color = const Color(0xFF5B7FFF);
      } else {
        text = l10n.statsFeedingDown(delta.abs().toStringAsFixed(0));
        color = const Color(0xFFFFA000);
      }
      cards.add(StatsSummaryCard(
        icon: Icons.local_drink,
        text: text,
        color: color,
      ));
    });

    if (cards.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statsSummaryTitle,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...cards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: card,
            )),
      ],
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
