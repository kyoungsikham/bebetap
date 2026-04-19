import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/diaper/presentation/providers/diaper_provider.dart';
import '../../features/feeding/presentation/providers/feeding_provider.dart';
import '../../features/log/domain/models/timeline_entry.dart';
import '../../features/sleep/presentation/providers/sleep_provider.dart';

bool needsBottomSheet(TimelineEntryType type) =>
    type == TimelineEntryType.temperature || type == TimelineEntryType.diary;

Future<void> quickAddRecord(
  BuildContext context,
  WidgetRef ref,
  TimelineEntryType type,
) async {
  switch (type) {
    case TimelineEntryType.formula:
      await ref.read(feedingNotifierProvider.notifier).saveFormula(amountMl: 0);
    case TimelineEntryType.pumped:
      await ref.read(feedingNotifierProvider.notifier).savePumped(amountMl: 0);
    case TimelineEntryType.babyFood:
      await ref.read(feedingNotifierProvider.notifier).saveBabyFood(amountMl: 0);
    case TimelineEntryType.breast:
      await ref.read(feedingNotifierProvider.notifier).saveBreast(
            durationLeftSec: 0,
            durationRightSec: 0,
            startedAt: DateTime.now(),
          );
    case TimelineEntryType.diaper:
      await ref.read(diaperNotifierProvider.notifier).saveDiaper(type: 'wet');
    case TimelineEntryType.sleep:
      final active = ref.read(activeSleepProvider).valueOrNull;
      if (active != null) {
        await ref
            .read(sleepSessionNotifierProvider.notifier)
            .endSleep(active.id);
      } else {
        await ref.read(sleepSessionNotifierProvider.notifier).startSleep();
      }
    case TimelineEntryType.temperature:
    case TimelineEntryType.diary:
      return;
  }
}
