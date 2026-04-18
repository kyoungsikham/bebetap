import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart'; // brand colors만 사용
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../providers/home_provider.dart';

/// 오늘 요약 수치 띠 — 분유 총량 | 수면 합계 | 기저귀 횟수
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
        final formulaLabel = unit.formatAmount(summary.todayFormulaTotalMl);

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.local_drink_outlined,
                  value: formulaLabel,
                  label: context.l10n.statsFormulaLabel,
                  color: AppColors.primary,
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.bedtime_outlined,
                  value: summary.todaySleepTotal.formatHhMm(),
                  label: context.l10n.statsSleepLabel,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF607D8B)
                      : const Color(0xFF607D8B),
                ),
              ),
              _Divider(),
              Expanded(
                child: _StatItem(
                  icon: Icons.baby_changing_station,
                  value: '${summary.todayDiaperCount}회',
                  label: context.l10n.statsDiaperLabel,
                  color: const Color(0xFF00BFA5),
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
          style: AppTypography.labelLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.55),
          ),
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
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A34) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
