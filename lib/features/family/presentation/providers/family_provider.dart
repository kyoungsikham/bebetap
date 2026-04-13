import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:riverpod_annotation/riverpod_annotation.dart' hide Family;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/sync/realtime_listener.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../diary/presentation/providers/diary_provider.dart';
import '../../../feeding/presentation/providers/feeding_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../log/presentation/providers/log_provider.dart';
import '../../../sleep/presentation/providers/sleep_provider.dart';
import '../../data/family_repository_impl.dart';
import '../../domain/models/family.dart';
import '../../domain/models/family_member.dart';

part 'family_provider.g.dart';

@Riverpod(keepAlive: true)
FamilyRepository familyRepository(Ref ref) {
  ref.watch(authStateProvider); // auth 변경 시 재생성 → 인메모리 캐시 초기화
  return FamilyRepository(Supabase.instance.client);
}

@riverpod
Future<Family?> myFamily(Ref ref) {
  ref.watch(authStateProvider); // auth 변경 시 자동 re-fetch
  return ref.watch(familyRepositoryProvider).getMyFamily();
}

@riverpod
Future<List<FamilyMember>> familyMembers(Ref ref) async {
  final family = await ref.watch(myFamilyProvider.future);
  if (family == null) return [];
  return ref.watch(familyRepositoryProvider).getMembers(family.id);
}

@riverpod
class FamilyNotifier extends _$FamilyNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> createFamily(String name, {String? nickname}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(familyRepositoryProvider).createFamily(name, nickname: nickname);
      ref.invalidate(myFamilyProvider);
      ref.invalidate(familyMembersProvider);
    });
  }

  Future<void> joinFamily(String inviteCode, {String? nickname}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(familyRepositoryProvider).joinFamily(inviteCode, nickname: nickname);
      ref.invalidate(myFamilyProvider);
      ref.invalidate(familyMembersProvider);
      ref.invalidate(babiesProvider);
    });
  }
}

/// 가족 실시간 동기화 활성화 — keepAlive: true로 한번 활성화되면 계속 유지
@Riverpod(keepAlive: true)
void familyRealtime(Ref ref) {
  final listener = RealtimeListener(
    Supabase.instance.client,
    ref.watch(appDatabaseProvider),
  );

  ref.listen(myFamilyProvider, (_, next) async {
    final family = next.valueOrNull;
    if (family != null) {
      listener.subscribe(family.id, onRemoteChange: () {
        ref.invalidate(homeSummaryProvider);
        ref.invalidate(todayFeedingsProvider);
        ref.invalidate(activeSleepProvider);
        ref.invalidate(logTimelineProvider);
        ref.invalidate(logDaySummaryProvider);
        ref.invalidate(todayDiaryForCurrentUserProvider);
      });
      // 초기 데이터 pull: 가족 구성원 로그인 시 기존 기록 가져오기
      await ref.read(syncEngineProvider).pullRemoteData(family.id);
      ref.invalidate(homeSummaryProvider);
      ref.invalidate(todayFeedingsProvider);
      ref.invalidate(logTimelineProvider);
      ref.invalidate(logDaySummaryProvider);
      ref.invalidate(todayDiaryForCurrentUserProvider);
    } else {
      listener.unsubscribe();
    }
  }, fireImmediately: true);

  ref.onDispose(listener.unsubscribe);
}
