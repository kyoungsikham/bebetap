import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/widget/widget_refresh_helper.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../data/temperature_repository_impl.dart';

part 'temperature_provider.g.dart';

@riverpod
TemperatureRepository temperatureRepository(Ref ref) =>
    TemperatureRepository(ref.watch(appDatabaseProvider));

@riverpod
class TemperatureNotifier extends _$TemperatureNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateTemperature(
    String id, {
    required double celsius,
    required String method,
    required DateTime occurredAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(temperatureRepositoryProvider).updateTemperature(
            id,
            celsius: celsius,
            method: method,
            occurredAt: occurredAt,
          );
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }

  Future<void> saveTemperature({
    required double celsius,
    required String method,
  }) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(temperatureRepositoryProvider).saveTemperature(
            babyId: baby.id,
            familyId: baby.familyId,
            celsius: celsius,
            method: method,
          );
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(logTimelineProvider);
      ref.read(syncEngineProvider).trigger();
      unawaited(refreshWidget(ref));
    });
  }
}
