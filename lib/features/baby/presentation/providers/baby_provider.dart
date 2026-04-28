import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../data/baby_repository_impl.dart';
import '../../domain/models/baby.dart';

part 'baby_provider.g.dart';

const _kSelectedBabyIdKey = 'selected_baby_id';

// ── Repository ────────────────────────────────────────────────────────────────

@riverpod
BabyRepository babyRepository(Ref ref) {
  ref.watch(authStateProvider); // auth 변경 시 재생성 → 인메모리 캐시 초기화
  return BabyRepository(Supabase.instance.client);
}

// ── Baby list ─────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
Future<List<Baby>> babies(Ref ref) {
  ref.watch(authStateProvider); // auth 상태 변경 시 자동 re-fetch
  return ref.watch(babyRepositoryProvider).fetchBabies();
}

// ── Selected baby ─────────────────────────────────────────────────────────────

/// 현재 선택된 아기 ID. SharedPreferences에 영구 저장되며, 로그아웃 시 초기화됨.
@Riverpod(keepAlive: true)
class SelectedBabyId extends _$SelectedBabyId {
  @override
  String? build() {
    _restoreFromPrefs();
    ref.listen(authStateProvider, (_, next) {
      if (next.value?.event == AuthChangeEvent.signedOut) _clear();
    });
    return null;
  }

  Future<void> _restoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kSelectedBabyIdKey);
    if (saved != null && state == null) state = saved;
  }

  Future<void> select(String babyId) async {
    state = babyId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelectedBabyIdKey, babyId);
  }

  Future<void> _clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSelectedBabyIdKey);
  }
}

/// 선택된 아기 (없으면 목록 첫 번째).
@riverpod
Future<Baby?> selectedBaby(Ref ref) async {
  final list = await ref.watch(babiesProvider.future);
  if (list.isEmpty) return null;
  final id = ref.watch(selectedBabyIdProvider);
  if (id != null) {
    return list.firstWhere((b) => b.id == id, orElse: () => list.first);
  }
  return list.first;
}

// ── Baby manage notifier ─────────────────────────────────────────────────────

class BabyManageNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateBaby({
    required String id,
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(babyRepositoryProvider).updateBaby(
            id: id,
            name: name,
            birthDate: birthDate,
            gender: gender,
            weightKg: weightKg,
            heightCm: heightCm,
            photoUrl: photoUrl,
          );
      ref.invalidate(babiesProvider);
    });
  }

  Future<void> addBaby({
    required String familyId,
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? photoUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(babyRepositoryProvider).addBabyToFamily(
            familyId: familyId,
            name: name,
            birthDate: birthDate,
            gender: gender,
            weightKg: weightKg,
            heightCm: heightCm,
            photoUrl: photoUrl,
          );
      ref.invalidate(babiesProvider);
    });
  }
}

final babyManageNotifierProvider =
    AsyncNotifierProvider<BabyManageNotifier, void>(BabyManageNotifier.new);

// ── Baby setup notifier ───────────────────────────────────────────────────────

/// 온보딩에서 가족 + 아기 생성을 처리하는 Notifier.
@riverpod
class BabySetupNotifier extends _$BabySetupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Baby?> createBaby({
    required String name,
    required DateTime birthDate,
    String? gender,
    double? weightKg,
    double? heightCm,
    String? nickname,
    String? photoUrl,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      final baby = await ref.read(babyRepositoryProvider).createBabyWithFamily(
            name: name,
            birthDate: birthDate,
            gender: gender,
            weightKg: weightKg,
            heightCm: heightCm,
            nickname: nickname,
            photoUrl: photoUrl,
          );
      ref.invalidate(babiesProvider);
      return baby;
    });
    state = result.when(
      data: (_) => const AsyncData(null),
      loading: () => const AsyncLoading(),
      error: (e, st) => AsyncError(e, st),
    );
    return result.valueOrNull;
  }
}
