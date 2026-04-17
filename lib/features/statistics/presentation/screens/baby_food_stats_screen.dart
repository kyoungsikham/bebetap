import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../../domain/models/feeding_stats.dart';
import '../providers/statistics_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/stats_date_range_bar.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class BabyFoodStatsScreen extends ConsumerWidget {
  const BabyFoodStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(babyFoodStatsDateRangeProvider);
    final feedingAsync = ref.watch(feedingStatsProvider(range));
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.babyFoodStatsTitle, style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.md,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        children: [
          StatsDateRangeBar(
            selected: range,
            onChanged: (r) =>
                ref.read(babyFoodStatsDateRangeProvider.notifier).setRange(r),
          ),
          const SizedBox(height: AppSpacing.xxl),
          feedingAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => Center(
              child: Text(l10n.dataLoadFailed,
                  style: AppTypography.bodySmall),
            ),
            data: (stats) =>
                _BabyFoodContent(stats: stats, unit: unit, range: range),
          ),
          const SizedBox(height: AppSpacing.md),
          BannerAdWidget(adUnitId: AdConfig.statsBannerId),
        ],
      ),
    );
  }
}

class _BabyFoodContent extends StatelessWidget {
  const _BabyFoodContent({
    required this.stats,
    required this.unit,
    required this.range,
  });

  final FeedingStats stats;
  final VolumeUnit unit;
  final dynamic range;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (stats.totalBabyFoodMl == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.babyFoodStatsTitle,
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          StatCard(
            icon: Icons.restaurant,
            label: l10n.babyFoodStatsTitle,
            value: l10n.noBabyFoodRecord,
            color: const Color(0xFFFFA000),
          ),
        ],
      );
    }

    // Count baby food entries from daily entries
    final babyFoodCount = stats.dailyEntries
        .where((e) => e.babyFoodMl > 0)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.babyFoodStatsTitle,
          style: AppTypography.titleMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Total baby food
        StatCard(
          icon: Icons.restaurant,
          label: l10n.totalBabyFood,
          value: unit.formatAmount(stats.totalBabyFoodMl),
          color: const Color(0xFFFFA000),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Baby food count
        StatCard(
          icon: Icons.calendar_today,
          label: l10n.babyFoodCount,
          value: l10n.timesCount(babyFoodCount),
          color: const Color(0xFFFFA000),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Daily trend chart
        if (stats.dailyEntries.length > 1)
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
                  l10n.dailyBabyFoodTrend,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _BabyFoodTrendChart(entries: stats.dailyEntries),
              ],
            ),
          ),
      ],
    );
  }
}

class _BabyFoodTrendChart extends StatelessWidget {
  const _BabyFoodTrendChart({required this.entries});

  final List<DailyFeedingEntry> entries;

  static const _color = Color(0xFFFFA000);

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    // 91+ days → weekly average bar chart
    if (entries.length > 90) {
      return _buildWeeklyBar(context);
    }

    return _buildDailyLine(context);
  }

  Widget _buildDailyLine(BuildContext context) {
    final maxMl = entries
        .map((e) => e.babyFoodMl.toDouble())
        .fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxMl > 0 ? maxMl * 1.2 : 100.0;

    final step = entries.length > 60
        ? 7
        : entries.length > 14
            ? 3
            : 1;

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: entries.asMap().entries.map((e) {
                return FlSpot(
                    e.key.toDouble(), e.value.babyFoodMl.toDouble());
              }).toList(),
              isCurved: true,
              color: _color,
              barWidth: 2,
              dotData: FlDotData(show: entries.length <= 14),
              belowBarData: BarAreaData(
                show: true,
                color: _color.withValues(alpha: 0.12),
              ),
            ),
          ],
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
                        fontSize: 9,
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
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.primary.withValues(alpha: 0.06),
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }

  Widget _buildWeeklyBar(BuildContext context) {
    final weeks = <({DateTime startDate, double avgMl})>[];
    for (var i = 0; i < entries.length; i += 7) {
      final chunk = entries.sublist(i, (i + 7).clamp(0, entries.length));
      final avg =
          chunk.fold<int>(0, (s, e) => s + e.babyFoodMl) / chunk.length;
      weeks.add((startDate: chunk.first.date, avgMl: avg));
    }

    final maxMl =
        weeks.map((w) => w.avgMl).fold(0.0, (a, b) => a > b ? a : b);
    final maxY = maxMl > 0 ? maxMl * 1.2 : 100.0;
    final barWidth = weeks.length <= 12 ? 16.0 : 10.0;

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: weeks.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.avgMl,
                  color: _color,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
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
                  if (i < 0 || i >= weeks.length) {
                    return const SizedBox.shrink();
                  }
                  final d = weeks[i].startDate;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${d.month}/${d.day}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                        fontSize: 9,
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
    );
  }
}
