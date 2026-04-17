import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/widget/widget_refresh_helper.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../data/diaper_repository_impl.dart';

part 'diaper_provider.g.dart';

@riverpod
DiaperRepository diaperRepository(Ref ref) =>
    DiaperRepository(ref.watch(appDatabaseProvider));

@riverpod
class DiaperNotifier extends _$DiaperNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateDiaper(
    String id, {
    required String type,
    required DateTime occurredAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(diaperRepositoryProvider).updateDiaper(
            id,
            type: type,
            occurredAt: occurredAt,
          );
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> saveDiaper({required String type, DateTime? occurredAt}) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(diaperRepositoryProvider).saveDiaper(
            babyId: baby.id,
            familyId: baby.familyId,
            type: type,
            occurredAt: occurredAt,
          );
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }
}
