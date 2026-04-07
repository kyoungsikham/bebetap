import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/baby_food_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart';
import '../../../sleep/presentation/providers/sleep_provider.dart';
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../diary/presentation/widgets/diary_bottom_sheet.dart';
import '../providers/home_provider.dart';
import 'tracking_tile.dart';
import '../../../log/domain/models/timeline_entry.dart';

class TrackingGrid extends ConsumerWidget {
  const TrackingGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1분마다 재빌드 (경과 시간 갱신)
    ref.watch(minuteTickerProvider);
    final summaryAsync = ref.watch(homeSummaryProvider);
    final activeSleep = ref.watch(activeSleepProvider).valueOrNull;
    final summary = summaryAsync.valueOrNull;
    final visibleTypes = ref.watch(visibleCategoriesProvider);

    // 수유 타입별 경과 레이블 (lastFeedingType 기준으로 해당 타일에만 표시)
    String feedingElapsedLabel() {
      if (summary?.lastFeedingAt == null) return '탭해서 기록';
      return DateTime.now().difference(summary!.lastFeedingAt!).formatElapsedKorean();
    }

    String formulaSublabel = summary?.lastFeedingType == 'formula'
        ? feedingElapsedLabel()
        : (summary != null && summary.todayFormulaTotalMl > 0
            ? '오늘 ${summary.todayFormulaTotalMl}ml'
            : '탭해서 기록');

    String breastSublabel = summary?.lastFeedingType == 'breast'
        ? feedingElapsedLabel()
        : '탭해서 기록';

    String pumpedSublabel = summary?.lastFeedingType == 'pumped'
        ? feedingElapsedLabel()
        : (summary != null && summary.todayPumpedTotalMl > 0
            ? '오늘 ${summary.todayPumpedTotalMl}ml'
            : '탭해서 기록');

    String sleepLabel = '탭해서 기록';
    if (activeSleep != null) {
      sleepLabel = activeSleep.duration.formatKorean();
    } else if (summary?.todaySleepTotal != null &&
        summary!.todaySleepTotal > Duration.zero) {
      sleepLabel = '오늘 ${summary.todaySleepTotal.formatHhMm()}';
    }

    final diaperLabel = summary != null && summary.todayDiaperCount > 0
        ? '오늘 ${summary.todayDiaperCount}회'
        : '탭해서 기록';

    Widget buildTile(TimelineEntryType type) {
      final info = TrackingCategoryInfo.all[type]!;

      switch (type) {
        case TimelineEntryType.formula:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: formulaSublabel,
            color: AppColors.primary,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const FormulaBottomSheet(),
              title: '분유 수유',
            ),
          );
        case TimelineEntryType.breast:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: breastSublabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const BreastBottomSheet(),
              title: '모유 수유',
            ),
          );
        case TimelineEntryType.pumped:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: pumpedSublabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const FormulaBottomSheet(feedingType: MlFeedingType.pumped),
              title: '유축 수유',
            ),
          );
        case TimelineEntryType.diaper:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: diaperLabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const DiaperBottomSheet(),
            ),
          );
        case TimelineEntryType.sleep:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: sleepLabel,
            color: info.color,
            isActive: activeSleep != null,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const SleepBottomSheet(),
              title: '수면',
            ),
          );
        case TimelineEntryType.temperature:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: '탭해서 기록',
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const TemperatureBottomSheet(),
              title: '체온 기록',
            ),
          );
        case TimelineEntryType.babyFood:
          return TrackingTile(
            icon: info.icon,
            label: info.label,
            sublabel: summary != null && summary.todayBabyFoodTotalMl > 0
                ? '오늘 ${summary.todayBabyFoodTotalMl}ml'
                : '탭해서 기록',
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const BabyFoodBottomSheet(),
              title: '이유식 기록',
            ),
          );
        case TimelineEntryType.diary:
          return Consumer(
            builder: (context, ref, _) {
              final diaryAsync = ref.watch(todayDiaryForCurrentUserProvider);
              final hasDiary = diaryAsync.valueOrNull != null;
              return TrackingTile(
                icon: info.icon,
                label: info.label,
                sublabel: hasDiary ? '오늘 작성 완료' : '탭해서 기록',
                color: info.color,
                onTap: () async {
                  final existing =
                      await ref.read(todayDiaryForCurrentUserProvider.future);
                  if (!context.mounted) return;
                  showAppBottomSheet(
                    context: context,
                    child: existing != null
                        ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
                        : const DiaryBottomSheet(),
                    title: existing != null ? '일기 수정' : '일기 쓰기',
                  );
                },
              );
            },
          );
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: visibleTypes.map(buildTile).toList(),
    )
        .animate()
        .fadeIn(duration: 260.ms, curve: Curves.easeOut)
        .slideY(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}
