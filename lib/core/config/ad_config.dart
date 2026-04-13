import 'dart:io';

import 'package:flutter/foundation.dart';

abstract class AdConfig {
  // 인터스티셜 최소 표시 간격 (초)
  static const int interstitialCooldownSeconds = 180;

  // ──── 테스트 ID (Google 공식) ────
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  // ──── 프로덕션 ID ────
  // TODO: AdMob 콘솔(https://admob.google.com)에서 발급받은 ID로 교체하세요.
  static const _homeBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _homeBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _statsBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _statsBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _logBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _logBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _familyBannerAndroid = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _familyBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _babyManageBannerAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _babyManageBannerIos = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _addBabyInterstitialAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _addBabyInterstitialIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  static const _iconSettingsBannerAndroid =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const _iconSettingsBannerIos =
      'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  // ──── 공개 getter (debug 모드에서는 자동으로 테스트 ID 반환) ────
  static String get homeBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid ? _homeBannerAndroid : _homeBannerIos);

  static String get statsBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid ? _statsBannerAndroid : _statsBannerIos);

  static String get logBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid ? _logBannerAndroid : _logBannerIos);

  static String get familyBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid ? _familyBannerAndroid : _familyBannerIos);

  static String get babyManageBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid
          ? _babyManageBannerAndroid
          : _babyManageBannerIos);

  static String get iconSettingsBannerId => kDebugMode
      ? _testId
      : (Platform.isAndroid
          ? _iconSettingsBannerAndroid
          : _iconSettingsBannerIos);

  static String get addBabyInterstitialId => kDebugMode
      ? _testInterstitialId
      : (Platform.isAndroid
          ? _addBabyInterstitialAndroid
          : _addBabyInterstitialIos);

  static String get _testId =>
      Platform.isAndroid ? _testBannerAndroid : _testBannerIos;

  static String get _testInterstitialId => Platform.isAndroid
      ? _testInterstitialAndroid
      : _testInterstitialIos;
}
