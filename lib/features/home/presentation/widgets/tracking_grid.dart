import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
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
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    final l10n = context.l10n;

    // 수유 타입별 경과 레이블 (lastFeedingType 기준으로 해당 타일에만 표시)
    String feedingElapsedLabel() {
      if (summary?.lastFeedingAt == null) return l10n.tapToRecord;
      return DateTime.now()
          .difference(summary!.lastFeedingAt!)
          .formatElapsedLocalized(l10n);
    }

    String formulaSublabel = summary?.lastFeedingType == 'formula'
        ? feedingElapsedLabel()
        : (summary != null && summary.todayFormulaTotalMl > 0
            ? l10n.todayAmount(unit.formatAmount(summary.todayFormulaTotalMl))
            : l10n.tapToRecord);

    String breastSublabel = summary?.lastFeedingType == 'breast'
        ? feedingElapsedLabel()
        : l10n.tapToRecord;

    String pumpedSublabel = summary?.lastFeedingType == 'pumped'
        ? feedingElapsedLabel()
        : (summary != null && summary.todayPumpedTotalMl > 0
            ? l10n.todayAmount(unit.formatAmount(summary.todayPumpedTotalMl))
            : l10n.tapToRecord);

    String sleepLabel = l10n.tapToRecord;
    if (activeSleep != null) {
      sleepLabel = activeSleep.duration.formatLocalized(l10n);
    } else if (summary?.todaySleepTotal != null &&
        summary!.todaySleepTotal > Duration.zero) {
      sleepLabel = l10n.todayDuration(summary.todaySleepTotal.formatHhMm());
    }

    final diaperLabel = summary != null && summary.todayDiaperCount > 0
        ? l10n.todayCount(summary.todayDiaperCount)
        : l10n.tapToRecord;

    Widget buildTile(TimelineEntryType type) {
      final info = TrackingCategoryInfo.all[type]!;

      switch (type) {
        case TimelineEntryType.formula:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
            sublabel: formulaSublabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const FormulaBottomSheet(),
              title: l10n.formulaBottomSheetTitle,
            ),
          );
        case TimelineEntryType.breast:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
            sublabel: breastSublabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const BreastBottomSheet(),
              title: l10n.breastBottomSheetTitle,
            ),
          );
        case TimelineEntryType.pumped:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
            sublabel: pumpedSublabel,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const FormulaBottomSheet(feedingType: MlFeedingType.pumped),
              title: l10n.pumpedBottomSheetTitle,
            ),
          );
        case TimelineEntryType.diaper:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
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
            label: info.localizedLabel(l10n),
            sublabel: sleepLabel,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF607D8B)
                : info.color,
            isActive: activeSleep != null,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const SleepBottomSheet(),
              title: l10n.sleep,
            ),
          );
        case TimelineEntryType.temperature:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
            sublabel: l10n.tapToRecord,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const TemperatureBottomSheet(),
              title: l10n.temperatureRecordTitle,
            ),
          );
        case TimelineEntryType.babyFood:
          return TrackingTile(
            icon: info.icon,
            label: info.localizedLabel(l10n),
            sublabel: summary != null && summary.todayBabyFoodTotalMl > 0
                ? l10n.todayAmount(unit.formatAmount(summary.todayBabyFoodTotalMl))
                : l10n.tapToRecord,
            color: info.color,
            onTap: () => showAppBottomSheet(
              context: context,
              child: const BabyFoodBottomSheet(),
              title: l10n.babyFoodBottomSheetTitle,
            ),
          );
        case TimelineEntryType.diary:
          return Consumer(
            builder: (context, ref, _) {
              final diaryAsync = ref.watch(todayDiaryForCurrentUserProvider);
              final hasDiary = diaryAsync.valueOrNull != null;
              final innerL10n = context.l10n;
              return TrackingTile(
                icon: info.icon,
                label: info.localizedLabel(innerL10n),
                sublabel: hasDiary ? innerL10n.diaryDoneToday : innerL10n.tapToRecord,
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
                    title: existing != null
                        ? context.l10n.diaryEditTitle
                        : context.l10n.diaryWriteTitle,
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
