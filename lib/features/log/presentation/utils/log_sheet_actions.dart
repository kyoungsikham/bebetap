import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/utils/quick_record.dart';
import '../../../../shared/widgets/app_bottom_sheet.dart';
import '../../../diaper/presentation/widgets/diaper_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/baby_food_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/breast_bottom_sheet.dart';
import '../../../feeding/presentation/widgets/formula_bottom_sheet.dart'
    show FormulaBottomSheet, MlFeedingType;
import '../../../sleep/presentation/widgets/sleep_bottom_sheet.dart';
import '../../../temperature/presentation/widgets/temperature_bottom_sheet.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../diary/presentation/widgets/diary_bottom_sheet.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';

void openEditSheet(BuildContext context, WidgetRef ref, TimelineEntry entry) {
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
  final bool canDelete = entry.type != TimelineEntryType.diary ||
      entry.rawRecordedBy == Supabase.instance.client.auth.currentUser?.id;

  showAppBottomSheet(
    context: context,
    child: sheet,
    title: title,
    titleTrailing: canDelete
        ? IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            tooltip: context.l10n.delete,
            onPressed: () => confirmDelete(context, ref, entry),
          )
        : null,
  );
}

Future<void> confirmDelete(
  BuildContext context,
  WidgetRef ref,
  TimelineEntry entry,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.deleteConfirmTitle),
      content: Text(context.l10n.deleteConfirmMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await ref.read(logRepositoryProvider).deleteEntry(entry);
  ref.invalidate(logTimelineProvider);
  if (context.mounted) Navigator.of(context).pop();
}

Future<void> openAddSheetForTab(BuildContext context, WidgetRef ref, String tab) async {
  if (!context.mounted) return;
  switch (tab) {
    case 'formula':
      await quickAddRecord(context, ref, TimelineEntryType.formula);
    case 'breast':
      await quickAddRecord(context, ref, TimelineEntryType.breast);
    case 'pumped':
      await quickAddRecord(context, ref, TimelineEntryType.pumped);
    case 'baby_food':
      await quickAddRecord(context, ref, TimelineEntryType.babyFood);
    case 'sleep':
      await quickAddRecord(context, ref, TimelineEntryType.sleep);
    case 'diaper':
      await quickAddRecord(context, ref, TimelineEntryType.diaper);
    case 'temperature':
      if (!context.mounted) return;
      showAppBottomSheet(
        context: context,
        child: const TemperatureBottomSheet(),
        title: context.l10n.addTemperature,
      );
    case 'diary':
      final existing = await ref.read(todayDiaryForCurrentUserProvider.future);
      if (!context.mounted) return;
      showAppBottomSheet(
        context: context,
        child: existing != null
            ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
            : const DiaryBottomSheet(),
        title: existing != null ? context.l10n.editDiary : context.l10n.writeDiary,
      );
    default:
      return;
  }
}

Future<void> openAddSheetForType(
    BuildContext context, WidgetRef ref, TimelineEntryType type) async {
  if (needsBottomSheet(type)) {
    if (type == TimelineEntryType.temperature) {
      showAppBottomSheet(
        context: context,
        child: const TemperatureBottomSheet(),
        title: context.l10n.addTemperature,
      );
    } else {
      // diary
      final existing = await ref.read(todayDiaryForCurrentUserProvider.future);
      if (!context.mounted) return;
      showAppBottomSheet(
        context: context,
        child: existing != null
            ? DiaryBottomSheet(editEntry: existing.toTimelineEntry())
            : const DiaryBottomSheet(),
        title: existing != null ? context.l10n.editDiary : context.l10n.writeDiary,
      );
    }
    return;
  }
  await quickAddRecord(context, ref, type);
}
