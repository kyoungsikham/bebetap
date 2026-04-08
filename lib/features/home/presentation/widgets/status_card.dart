import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart'; // semantic colors만 사용
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../providers/home_provider.dart';
import '../../../sleep/presentation/providers/sleep_provider.dart';

/// 홈 상단 상태 카드 — 마지막 수유 경과 시간 또는 현재 수면 중 표시
class StatusCard extends ConsumerWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1분마다 재빌드
    ref.watch(minuteTickerProvider);
    final summaryAsync = ref.watch(homeSummaryProvider);
    final activeSleepAsync = ref.watch(activeSleepProvider);
    final activeSleep = activeSleepAsync.valueOrNull;

    return summaryAsync.when(
      loading: () => const _StatusCardSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;
        // 수면 중 표시
        if (activeSleep != null) {
          final elapsed = activeSleep.duration;
          return _StatusCardContent(
            icon: Icons.bedtime,
            iconColor: AppColors.primary,
            label: context.l10n.sleepActive,
            elapsed: elapsed.formatLocalized(context.l10n),
            bgColor: AppColors.primary.withValues(alpha: 0.06),
            borderColor: AppColors.primary.withValues(alpha: 0.2),
          );
        }

        // 마지막 수유 경과
        if (summary.lastFeedingAt != null) {
          final elapsed =
              DateTime.now().difference(summary.lastFeedingAt!);
          final isWarning =
              elapsed.inHours >= 3 && elapsed.inHours < 4;
          final isAlert = elapsed.inHours >= 4;

          Color bgColor;
          Color borderColor;
          Color iconColor;
          if (isAlert) {
            bgColor = AppColors.error.withValues(alpha: 0.06);
            borderColor = AppColors.error.withValues(alpha: 0.3);
            iconColor = AppColors.error;
          } else if (isWarning) {
            bgColor = AppColors.warning.withValues(alpha: 0.08);
            borderColor = AppColors.warning.withValues(alpha: 0.4);
            iconColor = AppColors.warning;
          } else {
            bgColor = AppColors.success.withValues(alpha: 0.06);
            borderColor = AppColors.success.withValues(alpha: 0.2);
            iconColor = AppColors.success;
          }

          final l10n = context.l10n;
          final typeLabel = switch (summary.lastFeedingType) {
            'breast' => l10n.typeBreastFeeding,
            'pumped' => l10n.typePumpedFeeding,
            'baby_food' => l10n.typeBabyFood,
            _ => l10n.typeFormulaFeeding,
          };
          final amountLabel = summary.lastFeedingType != 'breast' &&
                  summary.lastFeedingAmountMl != null
              ? ' · ${unit.formatAmount(summary.lastFeedingAmountMl!)}'
              : '';
          final statusIcon = switch (summary.lastFeedingType) {
            'breast' => Icons.favorite_outline,
            'pumped' => Icons.water_drop_outlined,
            'baby_food' => Icons.restaurant,
            _ => Icons.local_drink_outlined,
          };

          return _StatusCardContent(
            icon: statusIcon,
            iconColor: iconColor,
            label: '$typeLabel$amountLabel',
            elapsed: elapsed.formatElapsedLocalized(context.l10n),
            bgColor: bgColor,
            borderColor: borderColor,
          );
        }

        // 기록 없음
        final cs = Theme.of(context).colorScheme;
        return _StatusCardContent(
          icon: Icons.child_care,
          iconColor: cs.onSurface.withValues(alpha: 0.45),
          label: context.l10n.noRecord,
          elapsed: context.l10n.startRecordingHint,
          bgColor: cs.surfaceContainerHighest,
          borderColor: Theme.of(context).dividerColor,
        );
      },
    );
  }
}

class _StatusCardContent extends StatelessWidget {
  const _StatusCardContent({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.elapsed,
    required this.bgColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String elapsed;
  final Color bgColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(
                  elapsed,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
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

class _StatusCardSkeleton extends StatelessWidget {
  const _StatusCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A34) : const Color(0xFFE8E8EE),
      highlightColor: isDark ? const Color(0xFF3A3A46) : const Color(0xFFF8F8FA),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A34) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
