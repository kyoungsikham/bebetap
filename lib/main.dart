import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/ad_initializer.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeAds();

  KakaoSdk.init(nativeAppKey: '3b9088a9581a023f815855a1cc2c96f5');

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  // 홈 위젯 App Group 설정 (iOS)
  await HomeWidget.setAppGroupId('group.com.bebetap.app');

  runApp(
    const ProviderScope(
      child: BebeTapApp(),
    ),
  );
}
