import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/baby_food_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart' show FormulaBottomSheet, MlFeedingType;
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../diary/presentation/widgets/diary_bottom_sheet.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';
import '../widgets/date_navigator.dart';
import '../widgets/log_stats_strip.dart';
import '../widgets/timeline_item_tile.dart';

class LogScreen extends ConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(filteredLogTimelineProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(context.l10n.logTitle, style: AppTypography.titleLarge),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 네비게이터
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding - 4,
            ),
            child: const DateNavigator(),
          ),
          const SizedBox(height: AppSpacing.md),

          // 요약 스트립
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePadding,
            ),
            child: const LogStatsStrip(),
          ),
          const SizedBox(height: AppSpacing.md),

          const Divider(height: 1),

          // 타임라인
          Expanded(
            child: timelineAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  context.l10n.logLoadFailed,
                  style: AppTypography.bodyMedium.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55)),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          context.l10n.noLogForDay,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.onSurfaceMuted),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          context.l10n.addLogHint,
                          style: AppTypography.bodySmall
                              .copyWith(color: AppColors.onSurfaceMuted),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePadding,
                    AppSpacing.md,
                    AppSpacing.pagePadding,
                    AppSpacing.pagePadding + 80, // FAB 여백
                  ),
                  itemCount: entries.length,
                  itemBuilder: (context, i) => TimelineItemTile(
                    entry: entries[i],
                    isFirst: i == 0,
                    isLast: i == entries.length - 1,
                    onTap: () => _openEditSheet(context, entries[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: const CircleBorder(),
        onPressed: () => _openAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEditSheet(BuildContext context, TimelineEntry entry) {
    late Widget sheet;
    late String title;
    switch (entry.type) {
      case TimelineEntryType.formula:
        sheet = FormulaBottomSheet(editEntry: entry);
        title = context.l10n.editFormula;
      case TimelineEntryType.pumped:
        sheet = FormulaBottomSheet(editEntry: entry, feedingType: MlFeedingType.pumped);
        title = context.l10n.editPumped;
      case TimelineEntryType.babyFood:
        sheet = BabyFoodBottomSheet(editEntry: entry);
        title = context.l10n.editBabyFood;
      case TimelineEntryType.breast:
        sheet = BreastBottomSheet(editEntry: entry);
        title = context.l10n.editBreast;
      case TimelineEntryType.diaper:
        sheet = DiaperBottomSheet(editEntry: entry);
        title = context.l10n.editDiaper;
      case TimelineEntryType.sleep:
        sheet = SleepBottomSheet(editEntry: entry);
        title = context.l10n.editSleep;
      case TimelineEntryType.temperature:
        sheet = TemperatureBottomSheet(editEntry: entry);
        title = context.l10n.editTemperature;
      case TimelineEntryType.diary:
        sheet = DiaryBottomSheet(editEntry: entry);
        title = context.l10n.diaryLog;
    }
    showAppBottomSheet(context: context, child: sheet, title: title);
  }

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref) async {
    final filter = ref.read(selectedTimelineFilterProvider);
    late Widget sheet;
    late String title;
    switch (filter) {
      case TimelineEntryType.formula:
        sheet = const FormulaBottomSheet();
        title = context.l10n.addFormula;
      case TimelineEntryType.pumped:
        sheet = const FormulaBottomSheet(feedingType: MlFeedingType.pumped);
        title = context.l10n.addPumped;
      case TimelineEntryType.babyFood:
        sheet = const BabyFoodBottomSheet();
        title = context.l10n.addBabyFood;
      case TimelineEntryType.breast:
        sheet = const BreastBottomSheet();
        title = context.l10n.addBreast;
      case TimelineEntryType.diaper:
        sheet = const DiaperBottomSheet();
        title = context.l10n.addDiaper;
      case TimelineEntryType.sleep:
        sheet = const SleepBottomSheet();
        title = context.l10n.addSleep;
      case TimelineEntryType.temperature:
        sheet = const TemperatureBottomSheet();
        title = context.l10n.addTemperature;
      case TimelineEntryType.diary:
        final existing =
            await ref.read(todayDiaryForCurrentUserProvider.future);
        if (!context.mounted) return;
        sheet = existing != null
            ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
            : const DiaryBottomSheet();
        title = existing != null ? context.l10n.editDiary : context.l10n.writeDiary;
    }
    if (!context.mounted) return;
    showAppBottomSheet(context: context, child: sheet, title: title);
  }
}
