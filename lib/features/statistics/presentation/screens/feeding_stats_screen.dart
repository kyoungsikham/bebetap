import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/feeding_stats_section.dart';
import '../widgets/stats_date_range_bar.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class FeedingStatsScreen extends ConsumerWidget {
  const FeedingStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(feedingStatsDateRangeProvider);
    final feedingAsync = ref.watch(feedingStatsProvider(range));
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.feedingStatsTitle, style: AppTypography.titleLarge),
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
                ref.read(feedingStatsDateRangeProvider.notifier).setRange(r),
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
            data: (stats) => FeedingStatsSection(
              stats: stats,
              range: range,
              volumeUnit: unit,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BannerAdWidget(adUnitId: AdConfig.statsBannerId),
        ],
      ),
    );
  }
}
