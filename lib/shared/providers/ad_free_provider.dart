import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kAdFreeKey = 'ad_free_purchased';

final adFreeProvider =
    AsyncNotifierProvider<AdFreeNotifier, bool>(AdFreeNotifier.new);

class AdFreeNotifier extends AsyncNotifier<bool> {
  StreamSubscription<List<Map<String, dynamic>>>? _realtimeSub;

  @override
  Future<bool> build() async {
    // 1. SharedPreferences 캐시 즉시 반환 (오프라인에서도 광고 없음 유지)
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getBool(_kAdFreeKey) ?? false;

    // 2. 로그인 상태면 서버에서 is_premium 조회 → 캐시 덮어쓰기
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await _syncFromServer(user.id, prefs);

      // 3. realtime 구독: Edge Function이 profiles.is_premium 업데이트 시 즉시 반영
      _subscribeRealtime(user.id, prefs);
    }

    // ref 해제 시 구독 취소
    ref.onDispose(() {
      _realtimeSub?.cancel();
      Supabase.instance.client
          .channel('ad_free_profile')
          .unsubscribe();
    });

    return prefs.getBool(_kAdFreeKey) ?? cached;
  }

  Future<void> _syncFromServer(String userId, SharedPreferences prefs) async {
    try {
      final row = await Supabase.instance.client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();

      final isPremium = (row['is_premium'] as bool?) ?? false;
      await _updateCache(isPremium, prefs);
    } catch (e) {
      // 네트워크 오류 시 캐시 유지
    }
  }

  void _subscribeRealtime(String userId, SharedPreferences prefs) {
    Supabase.instance.client
        .channel('ad_free_profile')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            final isPremium =
                (payload.newRecord['is_premium'] as bool?) ?? false;
            _updateCache(isPremium, prefs);
          },
        )
        .subscribe();
  }

  Future<void> _updateCache(bool value, SharedPreferences prefs) async {
    state = AsyncData(value);
    await prefs.setBool(_kAdFreeKey, value);
  }

  /// 로그아웃 시 호출 — 캐시를 false로 초기화
  Future<void> reset() async {
    _realtimeSub?.cancel();
    Supabase.instance.client.channel('ad_free_profile').unsubscribe();
    state = const AsyncData(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAdFreeKey, false);
  }
}
