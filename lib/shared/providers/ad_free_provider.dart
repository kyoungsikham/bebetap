import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kAdFreeKey = 'ad_free_purchased';

final adFreeProvider =
    AsyncNotifierProvider<AdFreeNotifier, bool>(AdFreeNotifier.new);

class AdFreeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAdFreeKey) ?? false;
  }

  /// 광고 제거 구매 완료 시 호출. 향후 인앱 결제 검증 후 이 메서드를 호출.
  Future<void> setPurchased(bool value) async {
    state = AsyncData(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAdFreeKey, value);
  }
}
