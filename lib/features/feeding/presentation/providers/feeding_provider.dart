import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
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
class FeedingNotifier extends _$FeedingNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveFormula({required int amountMl}) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(feedingRepositoryProvider).saveFormulaFeeding(
            babyId: baby.id,
            familyId: baby.familyId,
            amountMl: amountMl,
          );
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(dailyFormulaTotalProvider);
      ref.invalidate(homeSummaryProvider);
      ref.read(syncEngineProvider).trigger();
      _pushFeedingWidget(amountMl: amountMl);
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
      ref.read(syncEngineProvider).trigger();
      _pushFeedingWidget();
    });
  }

  void _pushFeedingWidget({int? amountMl}) {
    final now = DateTime.now().toIso8601String();
    unawaited(HomeWidget.saveWidgetData<String>('lastFeedingTime', now));
    if (amountMl != null) {
      unawaited(HomeWidget.saveWidgetData<int>('formulaTotalMl', amountMl));
    }
    unawaited(
      HomeWidget.updateWidget(
        iOSName: 'BebetapWidget',
        androidName: 'BebetapWidget',
      ),
    );
  }
}
