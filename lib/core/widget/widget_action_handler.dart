import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/baby/domain/models/baby.dart';
import '../../features/baby/presentation/providers/baby_provider.dart';
import '../../features/diaper/presentation/providers/diaper_provider.dart';
import '../../features/feeding/presentation/providers/feeding_provider.dart';
import '../../features/sleep/presentation/providers/sleep_provider.dart';
import '../router/app_routes.dart';
import '../utils/app_keys.dart';
import 'widget_refresh_helper.dart' show refreshWidgetFromWidget;

/// 위젯 클릭으로 열어야 할 로그 탭을 임시 저장하는 provider.
final pendingWidgetTabProvider = StateProvider<String?>((ref) => null);

/// 홈 화면 위젯 버튼 클릭 시 전달되는 URL을 처리하는 핸들러.
class WidgetActionHandler {
  WidgetActionHandler._();

  static StreamSubscription<Uri?>? _sub; // ignore: cancel_subscriptions

  /// 앱 시작 시 한 번 호출. 위젯 클릭 스트림을 구독한다.
  static void init(WidgetRef ref, GoRouter router) {
    _sub?.cancel();

    HomeWidget.initiallyLaunchedFromHomeWidget().then((uri) {
      if (uri != null) _handle(uri, ref, router);
    });

    _sub = HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) _handle(uri, ref, router);
    });
  }

  static void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  /// GoRouter redirect 등 Ref 컨텍스트에서 action URI 를 직접 처리.
  /// bebetap://action/feeding/formula → host="action", pathSegments=["feeding","formula"]
  static void handleActionFromRef(Uri uri, Ref ref) {
    if (uri.host != 'action') return;
    final segments = uri.pathSegments;
    if (segments.length < 2) return;
    _saveAction(segments[0], segments[1], ref.read);
  }

  static void _handle(Uri uri, WidgetRef ref, GoRouter router) {
    debugPrint('[WidgetAction] uri: $uri');
    final host     = uri.host;
    final segments = uri.pathSegments;

    switch (host) {
      case 'action':
        if (segments.isEmpty) return;
        if (segments[0] == 'refresh') {
          refreshWidgetFromWidget(ref);
          return;
        }
        // iOS: 위젯 헤더 ◂/▸ 탭 → 앱이 열리면서 아기 전환
        if (segments[0] == 'baby' && segments.length >= 2) {
          final dir = segments[1]; // 'prev' or 'next'
          if (dir == 'prev' || dir == 'next') {
            unawaited(_switchBaby(dir, ref));
            return;
          }
        }
        if (segments.length < 2) return;
        _saveAction(segments[0], segments[1], ref.read);
      case 'home':
        router.go(AppRoutes.home);
      case 'log':
        router.go(AppRoutes.home);
    }
  }

  // read 함수만 받아 Ref/WidgetRef 모두 지원
  static void _saveAction(
    String category,
    String value,
    T Function<T>(ProviderListenable<T>) read,
  ) {
    final now = DateTime.now();
    switch (category) {
      case 'feeding':
        final notifier = read(feedingNotifierProvider.notifier);
        switch (value) {
          case 'formula':
            notifier.saveFormula(amountMl: 0, startedAt: now);
          case 'pumped':
            notifier.savePumped(amountMl: 0, startedAt: now);
          case 'babyFood':
            notifier.saveBabyFood(amountMl: 0, startedAt: now);
          case 'breast':
            notifier.saveBreast(durationLeftSec: 0, durationRightSec: 0, startedAt: now);
        }
      case 'diaper':
        read(diaperNotifierProvider.notifier).saveDiaper(type: value);
      case 'sleep':
        final sleepNotifier = read(sleepSessionNotifierProvider.notifier);
        if (value == 'toggle') {
          final activeSleep = read(activeSleepProvider).valueOrNull;
          if (activeSleep != null) {
            sleepNotifier.endSleep(activeSleep.id);
          } else {
            sleepNotifier.startSleep();
          }
        } else if (value == 'start') {
          sleepNotifier.startSleep();
        } else if (value == 'end') {
          final activeSleep = read(activeSleepProvider).valueOrNull;
          if (activeSleep != null) sleepNotifier.endSleep(activeSleep.id);
        }
    }
    _showSaved();
  }

  static Future<void> _switchBaby(String dir, WidgetRef ref) async {
    final List<Baby> babies;
    try {
      babies = await ref.read(babiesProvider.future);
    } catch (_) {
      return;
    }
    if (babies.isEmpty) return;
    final currentId = ref.read(selectedBabyIdProvider);
    final idx = babies.indexWhere((b) => b.id == currentId);
    final currentIdx = idx < 0 ? 0 : idx;
    final n = babies.length;
    final nextIdx = dir == 'prev' ? (currentIdx - 1 + n) % n : (currentIdx + 1) % n;
    ref.read(selectedBabyIdProvider.notifier).select(babies[nextIdx].id);
  }

  static void _showSaved() {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text('저장됨'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
