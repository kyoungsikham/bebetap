import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../domain/models/period.dart';
import '../providers/statistics_provider.dart';
import '../widgets/period_tab_bar.dart';
import '../widgets/sleep_chart.dart';
import '../widgets/stat_card.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Period _period = Period.week;

  @override
  Widget build(BuildContext context) {
    final sleepAsync = ref.watch(sleepStatsProvider(_period));
    final feedingAsync = ref.watch(feedingStatsProvider(_period));
    final diaperAsync = ref.watch(diaperStatsProvider(_period));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('통계', style: AppTypography.titleLarge),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePadding,
          AppSpacing.md,
          AppSpacing.pagePadding,
          AppSpacing.pagePadding,
        ),
        children: [
          Center(
            child: PeriodTabBar(
              selected: _period,
              onChanged: (p) => setState(() => _period = p),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 수면
          Text(
            '수면',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          sleepAsync.when(
            loading: () => const _SkeletonCard(),
            error: (_, _) => const _ErrorCard(),
            data: (stats) => StatCard(
              icon: Icons.bedtime,
              label: '총 수면',
              value: stats.totalDuration.formatHhMm(),
              deltaPercent: stats.deltaPercent,
              color: const Color(0xFF7B68EE),
              child: _period == Period.week && stats.dailyEntries.isNotEmpty
                  ? SleepBarChart(entries: stats.dailyEntries)
                  : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 수유
          Text(
            '수유',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          feedingAsync.when(
            loading: () => const _SkeletonCard(),
            error: (_, _) => const _ErrorCard(),
            data: (stats) {
              if (stats.totalFormulaMl == 0 && stats.totalBreastSec == 0) {
                return StatCard(
                  icon: Icons.local_drink,
                  label: '수유',
                  value: '기록 없음',
                  color: AppColors.primary,
                );
              }
              return Column(
                children: [
                  if (stats.totalFormulaMl > 0)
                    StatCard(
                      icon: Icons.local_drink,
                      label: '분유',
                      value: '${stats.totalFormulaMl}ml',
                      subtitle: '${stats.feedingCount}회',
                      deltaPercent: stats.formulaDeltaPercent,
                      color: AppColors.primary,
                    ),
                  if (stats.totalFormulaMl > 0 && stats.totalBreastSec > 0)
                    const SizedBox(height: AppSpacing.sm),
                  if (stats.totalBreastSec > 0)
                    StatCard(
                      icon: Icons.favorite_outline,
                      label: '모유',
                      value: stats.totalBreastDuration.formatHhMm(),
                      subtitle: '${stats.feedingCount}회',
                      color: const Color(0xFFE91E8C),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 기저귀
          Text(
            '기저귀',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          diaperAsync.when(
            loading: () => const _SkeletonCard(),
            error: (_, _) => const _ErrorCard(),
            data: (count) => StatCard(
              icon: Icons.baby_changing_station,
              label: '기저귀 교체',
              value: '$count회',
              color: const Color(0xFF52B788),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      alignment: Alignment.center,
      child: Text(
        '데이터를 불러올 수 없습니다',
        style: AppTypography.bodySmall,
      ),
    );
  }
}
