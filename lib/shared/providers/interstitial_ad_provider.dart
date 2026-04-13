import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/config/ad_config.dart';
import 'ad_free_provider.dart';

final interstitialAdProvider =
    Provider<InterstitialAdService>((ref) => InterstitialAdService(ref));

class InterstitialAdService {
  InterstitialAdService(this._ref) {
    _preload();
  }

  final Ref _ref;
  InterstitialAd? _ad;
  DateTime? _lastShown;

  void _preload() {
    InterstitialAd.load(
      adUnitId: AdConfig.addBabyInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _ad!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _preload(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _ad = null;
              _preload();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _ad = null;
        },
      ),
    );
  }

  /// 아기 추가 완료 후 호출. 광고 제거 구매, 쿨다운, 로드 상태를 모두 확인합니다.
  Future<void> showIfReady() async {
    final adFree = _ref.read(adFreeProvider).valueOrNull ?? false;
    if (adFree) return;

    final now = DateTime.now();
    if (_lastShown != null &&
        now.difference(_lastShown!).inSeconds <
            AdConfig.interstitialCooldownSeconds) {
      return;
    }

    if (_ad == null) return;

    _lastShown = now;
    await _ad!.show();
  }
}
