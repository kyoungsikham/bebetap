import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/widget/widget_refresh_helper.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../data/feeding_repository_impl.dart';
import '../../domain/models/feeding_entry.dart';

part 'feeding_provider.g.dart';

@riverpod
FeedingRepository feedingRepository(Ref ref) =>
    FeedingRepository(ref.watch(appDatabaseProvider));

@riverpod
Stream<List<FeedingEntry>> todayFeedings(Ref ref) {
  final babyAsync = ref.watch(selectedBabyProvider);
  final baby = babyAsync.valueOrNull;
  if (baby == null) return const Stream.empty();
  return ref.watch(feedingRepositoryProvider).watchTodayFeedings(baby.id);
}

@riverpod
Future<int> dailyFormulaTotal(Ref ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return 0;
  return ref
      .watch(feedingRepositoryProvider)
      .getDailyFormulaTotalMl(baby.id, DateTime.now());
}

@riverpod
Future<int> dailyPumpedTotal(Ref ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return 0;
  return ref
      .watch(feedingRepositoryProvider)
      .getDailyPumpedTotalMl(baby.id, DateTime.now());
}

@riverpod
Future<int> dailyBabyFoodTotal(Ref ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return 0;
  return ref
      .watch(feedingRepositoryProvider)
      .getDailyBabyFoodTotalMl(baby.id, DateTime.now());
}

@riverpod
class FeedingNotifier extends _$FeedingNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveFormula({
    required int amountMl,
    DateTime? startedAt,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).saveFormulaFeeding(
            babyId: baby.id,
            familyId: baby.familyId,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyFormulaTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }

  Future<void> savePumped({
    required int amountMl,
    DateTime? startedAt,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).savePumpedFeeding(
            babyId: baby.id,
            familyId: baby.familyId,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyPumpedTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }

  Future<void> saveBabyFood({
    required int amountMl,
    DateTime? startedAt,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).saveBabyFoodFeeding(
            babyId: baby.id,
            familyId: baby.familyId,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyBabyFoodTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }

  Future<void> saveBreast({
    required int durationLeftSec,
    required int durationRightSec,
    required DateTime startedAt,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).saveBreastFeeding(
            babyId: baby.id,
            familyId: baby.familyId,
            durationLeftSec: durationLeftSec,
            durationRightSec: durationRightSec,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }

  Future<void> updateFormula(
    String id, {
    required int amountMl,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).updateFormulaFeeding(
            id,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyFormulaTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> updatePumped(
    String id, {
    required int amountMl,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).updatePumpedFeeding(
            id,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyPumpedTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> updateBabyFood(
    String id, {
    required int amountMl,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).updateBabyFoodFeeding(
            id,
            amountMl: amountMl,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyBabyFoodTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> updateBreast(
    String id, {
    required int durationLeftSec,
    required int durationRightSec,
    required DateTime startedAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).updateBreastFeeding(
            id,
            durationLeftSec: durationLeftSec,
            durationRightSec: durationRightSec,
            startedAt: startedAt,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }
}
