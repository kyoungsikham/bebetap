import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/diaper/presentation/providers/diaper_provider.dart';
import '../../features/sleep/presentation/providers/sleep_provider.dart';
import '../router/app_routes.dart';

/// 위젯 클릭으로 열어야 할 로그 탭을 임시 저장하는 provider.
/// LogScreen이 이 값을 listen하여 바텀 시트를 자동으로 연다.
final pendingWidgetTabProvider = StateProvider<String?>((ref) => null);

/// 홈 화면 위젯 버튼 클릭 시 전달되는 URL을 처리하는 핸들러.
///
/// URL 스킴: `bebetap://action/CATEGORY/VALUE`
///   - `bebetap://action/diaper/wet`
///   - `bebetap://action/diaper/soiled`
///   - `bebetap://action/diaper/both`
///   - `bebetap://action/sleep/start`
///   - `bebetap://action/sleep/end`
///
/// 로그 화면 이동 URL:
///   - `bebetap://log/formula`
///   - `bebetap://log/breast`
///   - `bebetap://log/pumped`
///   - `bebetap://log/baby_food`
class WidgetActionHandler {
  WidgetActionHandler._();

  static StreamSubscription<Uri?>? _sub; // ignore: cancel_subscriptions

  /// 앱 시작 시 한 번 호출. 위젯 클릭 스트림을 구독한다.
  static void init(WidgetRef ref, GoRouter router) {
    _sub?.cancel();

    // 앱이 종료된 상태에서 위젯 클릭으로 실행된 경우
    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) _handle(uri, ref, router);
    });

    // 앱이 백그라운드/포그라운드 상태에서 위젯 클릭
    _sub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _handle(uri, ref, router);
    });
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  static void _handle(Uri uri, WidgetRef ref, GoRouter router) {
    debugPrint('[WidgetAction] uri: $uri');
    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    switch (segments[0]) {
      case 'action':
        if (segments.length < 3) return;
        _handleAction(segments[1], segments[2], ref);
      case 'log':
        final tab = segments.length > 1 ? segments[1] : null;
        ref.read(pendingWidgetTabProvider.notifier).state = tab;
        router.go(AppRoutes.log);
    }
  }

  static void _handleAction(String category, String value, WidgetRef ref) {
    switch (category) {
      case 'diaper':
        ref.read(diaperNotifierProvider.notifier).saveDiaper(type: value);
      case 'sleep':
        final sleepNotifier = ref.read(sleepSessionNotifierProvider.notifier);
        if (value == 'start') {
          sleepNotifier.startSleep();
        } else if (value == 'end') {
          // 활성 수면 ID를 읽어서 종료
          final activeSleep = ref.read(activeSleepProvider).valueOrNull;
          if (activeSleep != null) {
            sleepNotifier.endSleep(activeSleep.id);
          }
        }
    }
  }
}
