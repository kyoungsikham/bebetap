import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/baby_food_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart';
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('육아 기록', style: AppTypography.titleLarge),
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
                  '기록을 불러오지 못했어요',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.onSurfaceMuted),
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
                          color: AppColors.onSurfaceMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '이 날은 기록이 없어요',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.onSurfaceMuted),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '+ 버튼을 눌러 기록을 추가해보세요',
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
        foregroundColor: Colors.white,
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
        title = '분유 수정';
      case TimelineEntryType.babyFood:
        sheet = BabyFoodBottomSheet(editEntry: entry);
        title = '이유식 수정';
      case TimelineEntryType.breast:
        sheet = BreastBottomSheet(editEntry: entry);
        title = '모유 수정';
      case TimelineEntryType.diaper:
        sheet = DiaperBottomSheet(editEntry: entry);
        title = '기저귀 수정';
      case TimelineEntryType.sleep:
        sheet = SleepBottomSheet(editEntry: entry);
        title = '수면 수정';
      case TimelineEntryType.temperature:
        sheet = TemperatureBottomSheet(editEntry: entry);
        title = '체온 수정';
    }
    showAppBottomSheet(context: context, child: sheet, title: title);
  }

  void _openAddSheet(BuildContext context, WidgetRef ref) {
    final filter = ref.read(selectedTimelineFilterProvider);
    late Widget sheet;
    late String title;
    switch (filter) {
      case TimelineEntryType.formula:
        sheet = const FormulaBottomSheet();
        title = '분유 수유';
      case TimelineEntryType.babyFood:
        sheet = const BabyFoodBottomSheet();
        title = '이유식 기록';
      case TimelineEntryType.breast:
        sheet = const BreastBottomSheet();
        title = '모유 수유';
      case TimelineEntryType.diaper:
        sheet = const DiaperBottomSheet();
        title = '기저귀';
      case TimelineEntryType.sleep:
        sheet = const SleepBottomSheet();
        title = '수면';
      case TimelineEntryType.temperature:
        sheet = const TemperatureBottomSheet();
        title = '체온 기록';
    }
    showAppBottomSheet(context: context, child: sheet, title: title);
  }
}

