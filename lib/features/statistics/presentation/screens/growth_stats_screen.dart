import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/ad_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';
import '../../../baby/domain/models/baby.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../domain/data/who_growth_standards.dart';
import '../widgets/growth_percentile_chart.dart';

class GrowthStatsScreen extends ConsumerWidget {
  const GrowthStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final babyAsync = ref.watch(selectedBabyProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.growthStatsTitle, style: AppTypography.titleLarge),
      ),
      body: babyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(l10n.dataLoadFailed, style: AppTypography.bodySmall),
        ),
        data: (baby) {
          if (baby == null) {
            return _EmptyState(message: l10n.growthStatsEmpty);
          }
          return _GrowthContent(baby: baby);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GrowthContent extends StatelessWidget {
  const _GrowthContent({required this.baby});
  final Baby baby;

  int get _ageMonths {
    final now = DateTime.now();
    final diff = now.difference(baby.birthDate);
    return (diff.inDays / 30.44).floor().clamp(0, 24);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasHeight = baby.heightCm != null;
    final hasWeight = baby.weightKg != null;

    if (!hasHeight && !hasWeight) {
      return _EmptyState(message: l10n.growthStatsEmpty);
    }

    final ageMonths = _ageMonths;
    final gender = baby.gender;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        AppSpacing.pagePadding,
      ),
      children: [
        // 현재 월령 칩
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.growthCurrentAge(ageMonths),
              style: AppTypography.labelSmall.copyWith(
                color: const Color(0xFF26A69A),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // ── 키 카드 ───────────────────────────────────────────────
        if (hasHeight)
          _GrowthCard(
            title: l10n.growthHeightLabel,
            unit: 'cm',
            value: baby.heightCm!,
            ageMonths: ageMonths,
            gender: gender,
            isHeight: true,
          ),

        if (hasHeight) const SizedBox(height: AppSpacing.lg),

        // ── 몸무게 카드 ─────────────────────────────────────────────
        if (hasWeight)
          _GrowthCard(
            title: l10n.growthWeightLabel,
            unit: 'kg',
            value: baby.weightKg!,
            ageMonths: ageMonths,
            gender: gender,
            isHeight: false,
          ),

        const SizedBox(height: AppSpacing.md),

        // WHO 출처 안내
        Text(
          l10n.growthWhoReference,
          style: AppTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.md),
        BannerAdWidget(adUnitId: AdConfig.statsBannerId),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GrowthCard extends StatelessWidget {
  const _GrowthCard({
    required this.title,
    required this.unit,
    required this.value,
    required this.ageMonths,
    required this.gender,
    required this.isHeight,
  });

  final String title;
  final String unit;
  final double value;
  final int ageMonths;
  final String? gender;
  final bool isHeight;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final table = WhoGrowthStandards.tableFor(gender: gender, isHeight: isHeight);
    final median = WhoGrowthStandards.medianAt(table, ageMonths);
    final percentile = WhoGrowthStandards.estimatePercentileBand(table, ageMonths, value);

    final diffText = median != null
        ? (isHeight
            ? '${(value - median).abs().toStringAsFixed(1)} cm'
            : '${(value - median).abs().toStringAsFixed(2)} kg')
        : null;

    final String comparisonText;
    Color comparisonColor;
    if (median == null || diffText == null) {
      comparisonText = l10n.growthNoData;
      comparisonColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    } else if ((value - median).abs() < (isHeight ? 0.5 : 0.05)) {
      comparisonText = l10n.growthOnAverage;
      comparisonColor = const Color(0xFF26A69A);
    } else if (value > median) {
      comparisonText = l10n.growthAboveAverage(diffText);
      comparisonColor = AppColors.primary;
    } else {
      comparisonText = l10n.growthBelowAverage(diffText);
      comparisonColor = AppColors.error.withValues(alpha: 0.8);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 + 현재값
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.labelLarge),
              Text(
                '${value.toStringAsFixed(isHeight ? 1 : 2)} $unit',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // 비교 텍스트 + 백분위
          Row(
            children: [
              Text(
                comparisonText,
                style: AppTypography.bodySmall.copyWith(color: comparisonColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.growthPercentileLabel(percentile),
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF26A69A),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // 차트
          GrowthPercentileChart(
            standards: table,
            unitLabel: unit,
            currentValue: value,
            currentAgeMonths: ageMonths,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.child_care,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.babyManage),
              icon: const Icon(Icons.edit, size: 16),
              label: Text(l10n.growthGoToManage),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
