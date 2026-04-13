import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/providers/auth_provider.dart';
import '../../data/baby_repository_impl.dart';
import '../../domain/models/baby.dart';

part 'baby_provider.g.dart';

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

/// 현재 선택된 아기 ID. null이면 목록의 첫 번째 아기를 사용.
@riverpod
class SelectedBabyId extends _$SelectedBabyId {
  @override
  String? build() => null;

  void select(String babyId) => state = babyId;
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
