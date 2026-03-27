import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../providers/home_provider.dart';

/// 오늘 요약 수치 띠 — 분유 총량 | 수면 합계 | 기저귀 횟수
class StatsStrip extends ConsumerWidget {
  const StatsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);

    return summaryAsync.when(
      loading: () => const _StatsStripSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final targetMl = summary.formulaDailyTargetMl;
        final formulaLabel = targetMl != null
            ? '${summary.todayFormulaTotalMl}/${targetMl}ml'
            : '${summary.todayFormulaTotalMl}ml';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_drink_outlined,
                  value: formulaLabel,
                  label: '분유',
                  color: AppColors.primary,
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.bedtime_outlined,
                  value: summary.todaySleepTotal.formatHhMm(),
                  label: '수면',
                  color: const Color(0xFF7B68EE),
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.baby_changing_station,
                  value: '${summary.todayDiaperCount}회',
                  label: '기저귀',
                  color: const Color(0xFF52B788),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(color: AppColors.onSurface),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style:
              AppTypography.labelSmall.copyWith(color: AppColors.onSurfaceMuted),
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
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.divider,
    );
  }
}

class _StatsStripSkeleton extends StatelessWidget {
  const _StatsStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E8EE),
      highlightColor: const Color(0xFFF8F8FA),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
