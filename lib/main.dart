import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/ad_initializer.dart';
import 'core/config/app_config.dart';
import 'features/premium/data/iap_service.dart';
import 'features/premium/presentation/providers/iap_provider.dart';
import 'shared/providers/default_landing_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeAds();

  KakaoSdk.init(nativeAppKey: '3b9088a9581a023f815855a1cc2c96f5');

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // IAP 단일 인스턴스 생성 및 스트림 구독 시작.
  // ProviderScope에 override로 주입해 앱 전역에서 동일 인스턴스를 사용한다.
  // (앱 재시작 시 미완료 구매 처리를 위해 runApp 이전에 init 필요)
  final iapService = IapService();
  await iapService.init();

  // 홈 위젯 App Group 설정 (iOS)
  await HomeWidget.setAppGroupId('group.com.bebetap.app');

  await preloadDefaultLanding();

  runApp(
    ProviderScope(
      overrides: [
        iapServiceProvider.overrideWithValue(iapService),
      ],
      child: const BebeTapApp(),
    ),
  );
}
