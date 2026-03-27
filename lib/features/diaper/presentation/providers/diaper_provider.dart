import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../data/diaper_repository_impl.dart';

part 'diaper_provider.g.dart';

@riverpod
DiaperRepository diaperRepository(Ref ref) =>
    DiaperRepository(ref.watch(appDatabaseProvider));

@riverpod
class DiaperNotifier extends _$DiaperNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> saveDiaper({required String type}) async {
    final baby = ref.read(selectedBabyProvider).valueOrNull;
    if (baby == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(diaperRepositoryProvider).saveDiaper(
            babyId: baby.id,
            familyId: baby.familyId,
            type: type,
          );
      ref.invalidate(homeSummaryProvider);
      ref.read(syncEngineProvider).trigger();
    });
  }
}

