import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/comparison_radar_chart.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  const ComparisonScreen({super.key});

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  int _ageDays = 0;
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final babiesAsync = ref.watch(babiesProvider);

    // Default to selected baby's current age
    if (!_initialized) {
      ref.listen(selectedBabyProvider, (_, next) {
        next.whenData((baby) {
          if (baby != null && !_initialized) {
            final age = DateTime.now().difference(baby.birthDate).inDays;
            setState(() {
              _ageDays = age;
              _initialized = true;
            });
          }
        });
      });
      final baby = ref.read(selectedBabyProvider).valueOrNull;
      if (baby != null) {
        _ageDays = DateTime.now().difference(baby.birthDate).inDays;
        _initialized = true;
      }
    }

    final comparisonAsync = ref.watch(babyComparisonProvider(_ageDays));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.babyComparison, style: AppTypography.titleLarge),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // Age selector
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
                  l10n.comparisonAge,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '$_ageDays ${l10n.daysLabel}',
                      style: AppTypography.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${(_ageDays / 30.44).toStringAsFixed(1)} ${l10n.monthsLabel})',
                      style: AppTypography.bodySmall.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                babiesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (babies) {
                    final maxAge = babies
                        .map((b) =>
                            DateTime.now().difference(b.birthDate).inDays)
                        .fold(0, (a, b) => a > b ? a : b);
                    return Slider(
                      value: _ageDays.toDouble().clamp(0, maxAge.toDouble()),
                      min: 0,
                      max: maxAge.toDouble().clamp(1, 1095), // max 3 years
                      divisions: maxAge.clamp(1, 1095),
                      onChanged: (v) => setState(() => _ageDays = v.round()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Comparison chart
          comparisonAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => Center(
              child: Text(l10n.dataLoadFailed, style: AppTypography.bodySmall),
            ),
            data: (result) {
              if (result.babies.length < 2) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.comparisonNeedTwoBabies,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.55),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ComparisonRadarChart(result: result),
                  const SizedBox(height: AppSpacing.xxl),
                  // Detail cards
                  ...result.babies.map((b) => _BabyDetailCard(data: b)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BabyDetailCard extends StatelessWidget {
  const _BabyDetailCard({required this.data});
  final dynamic data; // BabyComparisonData

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
            data.babyName,
            style: AppTypography.titleMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _DetailItem(
                icon: Icons.bedtime,
                label: l10n.sleepSection,
                value: '${(data.totalSleepMinutes / 60).toStringAsFixed(1)}h',
              ),
              const SizedBox(width: AppSpacing.lg),
              _DetailItem(
                icon: Icons.local_drink,
                label: l10n.feedingSection,
                value: '${data.totalFeedingMl}ml',
              ),
              const SizedBox(width: AppSpacing.lg),
              _DetailItem(
                icon: Icons.baby_changing_station,
                label: l10n.diaperSection,
                value: l10n.timesCount(data.totalDiaperCount),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
