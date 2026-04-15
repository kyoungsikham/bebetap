import 'dart:async' show unawaited;

import 'package:home_widget/home_widget.dart';

/// 홈 화면 위젯에 데이터를 push하는 서비스.
///
/// 각 provider의 save 메서드에서 호출하여 모든 위젯 종류를 일괄 갱신한다.
/// iOS: BebetapWidget (WidgetBundle), Android: 각 Receiver 클래스별 updateWidget 호출
class WidgetSyncService {
  WidgetSyncService._();

  // ── iOS widget kind 목록 (WidgetCenter.reloadTimelines에 사용) ──────────────
  static const _iosKinds = [
    'FormulaWidget',
    'BreastWidget',
    'PumpedWidget',
    'DiaperWidget',
    'SleepWidget',
    'TemperatureWidget',
    'BabyFoodWidget',
    'AllInOneWidget',
    'EssentialWidget',
    'NewbornWidget',
    'BabyFoodStageWidget',
  ];

  // ── Android receiver 이름 목록 ──────────────────────────────────────────────
  static const _androidReceivers = [
    'FormulaWidgetReceiver',
    'BreastWidgetReceiver',
    'PumpedWidgetReceiver',
    'DiaperWidgetReceiver',
    'SleepWidgetReceiver',
    'TemperatureWidgetReceiver',
    'BabyFoodWidgetReceiver',
    'AllInOneWidgetReceiver',
    'EssentialWidgetReceiver',
    'NewbornWidgetReceiver',
    'BabyFoodStageWidgetReceiver',
  ];

  // ── 데이터 push 헬퍼 ────────────────────────────────────────────────────────

  static Future<void> pushFormula({
    required DateTime time,
    required int totalMl,
  }) async {
    final iso = time.toUtc().toIso8601String();
    await HomeWidget.saveWidgetData<String>('lastFeedingTime', iso);
    await HomeWidget.saveWidgetData<String>('lastFormulaTime', iso);
    await HomeWidget.saveWidgetData<int>('formulaTotalMl', totalMl);
    _updateAll();
  }

  static Future<void> pushBreast({required DateTime time}) async {
    final iso = time.toUtc().toIso8601String();
    await HomeWidget.saveWidgetData<String>('lastFeedingTime', iso);
    await HomeWidget.saveWidgetData<String>('lastBreastTime', iso);
    _updateAll();
  }

  static Future<void> pushPumped({
    required DateTime time,
    required int totalMl,
  }) async {
    final iso = time.toUtc().toIso8601String();
    await HomeWidget.saveWidgetData<String>('lastFeedingTime', iso);
    await HomeWidget.saveWidgetData<String>('lastPumpedTime', iso);
    await HomeWidget.saveWidgetData<int>('pumpedTotalMl', totalMl);
    _updateAll();
  }

  static Future<void> pushBabyFood({
    required DateTime time,
    required int totalMl,
  }) async {
    final iso = time.toUtc().toIso8601String();
    await HomeWidget.saveWidgetData<String>('lastBabyFoodTime', iso);
    await HomeWidget.saveWidgetData<int>('babyFoodTotalMl', totalMl);
    _updateAll();
  }

  static Future<void> pushDiaper({
    required String type,
    required int countToday,
  }) async {
    await HomeWidget.saveWidgetData<int>('diaperCountToday', countToday);
    await HomeWidget.saveWidgetData<String>('lastDiaperType', type);
    await HomeWidget.saveWidgetData<String>(
        'lastDiaperTime', DateTime.now().toUtc().toIso8601String());
    _updateAll();
  }

  static Future<void> pushSleepStart({required DateTime startedAt}) async {
    await HomeWidget.saveWidgetData<bool>('sleepActive', true);
    await HomeWidget.saveWidgetData<String>(
        'sleepStartTime', startedAt.toUtc().toIso8601String());
    _updateAll();
  }

  static Future<void> pushSleepEnd({required int todaySleepMin}) async {
    await HomeWidget.saveWidgetData<bool>('sleepActive', false);
    await HomeWidget.saveWidgetData<int>('todaySleepMin', todaySleepMin);
    _updateAll();
  }

  static Future<void> pushTemperature({
    required double celsius,
    required DateTime time,
  }) async {
    await HomeWidget.saveWidgetData<double>('lastTempCelsius', celsius);
    await HomeWidget.saveWidgetData<String>(
        'lastTempTime', time.toUtc().toIso8601String());
    _updateAll();
  }

  /// 앱 시작 시 DB 전체 데이터를 위젯에 일괄 동기화한다.
  /// 개별 push 메서드와 달리 UserDefaults 저장을 한 번에 처리하고
  /// 위젯 리로드도 한 번만 호출하므로 효율적이다.
  static Future<void> pushInitialData({
    DateTime? lastFormulaTime,
    int formulaTotalMl = 0,
    DateTime? lastBreastTime,
    DateTime? lastPumpedTime,
    int pumpedTotalMl = 0,
    DateTime? lastBabyFoodTime,
    int babyFoodTotalMl = 0,
    String lastDiaperType = '',
    int diaperCountToday = 0,
    bool sleepActive = false,
    DateTime? sleepStartTime,
    int todaySleepMin = 0,
    double lastTempCelsius = 0,
    DateTime? lastTempTime,
  }) async {
    String toIso(DateTime? dt) =>
        dt != null ? dt.toUtc().toIso8601String() : '';

    await Future.wait([
      HomeWidget.saveWidgetData<String>('lastFormulaTime', toIso(lastFormulaTime)),
      HomeWidget.saveWidgetData<String>('lastFeedingTime', toIso(lastFormulaTime ?? lastBreastTime ?? lastPumpedTime)),
      HomeWidget.saveWidgetData<int>('formulaTotalMl', formulaTotalMl),
      HomeWidget.saveWidgetData<String>('lastBreastTime', toIso(lastBreastTime)),
      HomeWidget.saveWidgetData<String>('lastPumpedTime', toIso(lastPumpedTime)),
      HomeWidget.saveWidgetData<int>('pumpedTotalMl', pumpedTotalMl),
      HomeWidget.saveWidgetData<String>('lastBabyFoodTime', toIso(lastBabyFoodTime)),
      HomeWidget.saveWidgetData<int>('babyFoodTotalMl', babyFoodTotalMl),
      HomeWidget.saveWidgetData<String>('lastDiaperType', lastDiaperType),
      HomeWidget.saveWidgetData<int>('diaperCountToday', diaperCountToday),
      HomeWidget.saveWidgetData<bool>('sleepActive', sleepActive),
      HomeWidget.saveWidgetData<String>('sleepStartTime', toIso(sleepStartTime)),
      HomeWidget.saveWidgetData<int>('todaySleepMin', todaySleepMin),
      HomeWidget.saveWidgetData<double>('lastTempCelsius', lastTempCelsius),
      HomeWidget.saveWidgetData<String>('lastTempTime', toIso(lastTempTime)),
    ]);
    _updateAll();
  }

  // ── 전체 위젯 갱신 ──────────────────────────────────────────────────────────

  static void _updateAll() {
    // iOS: 각 위젯 kind별로 WidgetCenter.reloadTimelines 호출
    // Android: 각 Receiver 클래스별로 APPWIDGET_UPDATE 브로드캐스트
    final iosIter = _iosKinds.iterator;
    final androidIter = _androidReceivers.iterator;
    while (iosIter.moveNext() | androidIter.moveNext()) {
      unawaited(
        HomeWidget.updateWidget(
          iOSName: iosIter.current,
          androidName: androidIter.current,
        ),
      );
    }
  }
}
