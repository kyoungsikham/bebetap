import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/widget/widget_sync_service.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../data/sleep_repository_impl.dart';
import '../../domain/models/sleep_entry.dart';

part 'sleep_provider.g.dart';

@riverpod
SleepRepository sleepRepository(Ref ref) =>
    SleepRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<SleepEntry?> activeSleep(Ref ref) {
  final baby = ref.watch(selectedBabyProvider).valueOrNull;
  if (baby == null) return Stream.value(null);
  return ref.watch(sleepRepositoryProvider).watchActiveSleep(baby.id);
}

@riverpod
class SleepSessionNotifier extends _$SleepSessionNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> startSleep({DateTime? startedAt}) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(sleepRepositoryProvider).startSleep(
            babyId: baby.id,
            familyId: baby.familyId,
            startedAt: startedAt,
          );
      ref.invalidate(activeSleepProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(WidgetSyncService.pushSleepStart(
        startedAt: startedAt ?? DateTime.now(),
      ));
    });
  }

  Future<void> updateSleep(
    String id, {
    required DateTime startedAt,
    DateTime? endedAt,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(sleepRepositoryProvider);
      await repo.updateSleep(id, startedAt: startedAt, endedAt: endedAt);
      ref.invalidate(activeSleepProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      if (endedAt != null && baby != null) {
        final total = await repo.getTodaySleepTotal(baby.id);
        unawaited(WidgetSyncService.pushSleepEnd(
          todaySleepMin: total.inMinutes,
        ));
      }
    });
  }

  Future<void> endSleep(String sleepId, {DateTime? endedAt}) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(sleepRepositoryProvider);
      await repo.endSleep(sleepId, endedAt: endedAt);
      ref.invalidate(activeSleepProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      final total = baby != null
          ? await repo.getTodaySleepTotal(baby.id)
          : Duration.zero;
      unawaited(WidgetSyncService.pushSleepEnd(todaySleepMin: total.inMinutes));
    });
  }
}
