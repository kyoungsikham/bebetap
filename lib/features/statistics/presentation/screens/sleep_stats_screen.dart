import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../providers/statistics_provider.dart';
import '../widgets/sleep_stats_section.dart';
import '../widgets/stats_date_range_bar.dart';
import '../../../../core/config/ad_config.dart';
import '../../../../shared/widgets/banner_ad_widget.dart';

class SleepStatsScreen extends ConsumerWidget {
  const SleepStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(sleepStatsDateRangeProvider);
    final sleepAsync = ref.watch(sleepStatsProvider(range));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(l10n.sleepStatsTitle, style: AppTypography.titleLarge),
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
                ref.read(sleepStatsDateRangeProvider.notifier).setRange(r),
          ),
          const SizedBox(height: AppSpacing.xxl),
          sleepAsync.when(
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
            data: (stats) => SleepStatsSection(
              stats: stats,
              range: range,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BannerAdWidget(adUnitId: AdConfig.statsBannerId),
        ],
      ),
    );
  }
}
