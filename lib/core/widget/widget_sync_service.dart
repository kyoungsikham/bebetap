import 'dart:async' show unawaited;

import 'package:home_widget/home_widget.dart';

import '../../shared/models/widget_settings.dart';

/// 위젯 한 행에 표시되는 최근 기록 데이터
class WidgetRecord {
  const WidgetRecord({
    required this.label,
    required this.detail,
    required this.time,
  });

  final String label;   // "분유", "기저귀", "수면" 등
  final String detail;  // "140ml", "소변", "자는 중" 등
  final DateTime time;  // 발생 시각
}

/// 홈 화면 위젯에 데이터를 push하는 서비스.
///
/// 단일 BebeTap 위젯에 최근 기록 3개와 마지막 수유 경과를 저장한다.
class WidgetSyncService {
  WidgetSyncService._();

  static const iosKind = 'BebeTapWidget';
  static const androidReceiver = 'com.bebetap.app.glance.BebeTapWidgetReceiver';
  static const androidCompactReceiver = 'com.bebetap.app.glance.BebeTapCompactWidgetReceiver';

  /// 위젯 데이터 전체를 한 번에 저장하고 위젯을 갱신한다.
  static Future<void> push({
    required List<WidgetRecord> recentRecords,
    String lastFeedingLabel = '',
    DateTime? lastFeedingTime,
  }) async {
    String toIso(DateTime? dt) =>
        dt != null ? dt.toUtc().toIso8601String() : '';

    final saves = <Future<void>>[
      HomeWidget.saveWidgetData<String>('lastFeedingLabel', lastFeedingLabel),
      HomeWidget.saveWidgetData<String>('lastFeedingTime', toIso(lastFeedingTime)),
    ];

    for (int i = 0; i < 3; i++) {
      final key = 'r${i + 1}';
      if (i < recentRecords.length) {
        final r = recentRecords[i];
        saves.addAll([
          HomeWidget.saveWidgetData<String>('${key}_label', r.label),
          HomeWidget.saveWidgetData<String>('${key}_detail', r.detail),
          HomeWidget.saveWidgetData<String>('${key}_time', toIso(r.time)),
        ]);
      } else {
        saves.addAll([
          HomeWidget.saveWidgetData<String>('${key}_label', ''),
          HomeWidget.saveWidgetData<String>('${key}_detail', ''),
          HomeWidget.saveWidgetData<String>('${key}_time', ''),
        ]);
      }
    }

    await Future.wait(saves);
    _update();
  }

  /// 백그라운드 콜백 및 아기 전환에 필요한 컨텍스트를 push한다.
  ///
  /// [babies] 전체 아기 목록, [selectedIndex] 현재 선택된 인덱스.
  static Future<void> pushBabyContext({
    required List<({String id, String familyId, String name})> babies,
    required int selectedIndex,
  }) async {
    if (babies.isEmpty) return;
    final idx = selectedIndex.clamp(0, babies.length - 1);
    final cur = babies[idx];
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_baby_id',       cur.id),
      HomeWidget.saveWidgetData<String>('widget_family_id',     cur.familyId),
      HomeWidget.saveWidgetData<String>('widget_baby_name',     cur.name),
      HomeWidget.saveWidgetData<String>('widget_baby_index',    idx.toString()),
      HomeWidget.saveWidgetData<String>('widget_baby_ids',      babies.map((b) => b.id).join('|')),
      HomeWidget.saveWidgetData<String>('widget_baby_names',    babies.map((b) => b.name).join('|')),
      HomeWidget.saveWidgetData<String>('widget_baby_family_ids', babies.map((b) => b.familyId).join('|')),
    ]);
  }

  /// 오늘 총량(ml/sec)을 push한다. 위젯 헤더 두 번째 줄에 표시된다.
  static Future<void> pushTodayTotals({
    required int formulaMl,
    required int pumpedMl,
    required int babyFoodMl,
    required int breastSec,
    int diaperCount = 0,
    int sleepMin = 0,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('today_formula_ml',  formulaMl.toString()),
      HomeWidget.saveWidgetData<String>('today_pumped_ml',   pumpedMl.toString()),
      HomeWidget.saveWidgetData<String>('today_babyfood_ml', babyFoodMl.toString()),
      HomeWidget.saveWidgetData<String>('today_breast_sec',  breastSec.toString()),
      HomeWidget.saveWidgetData<String>('today_diaper_count', diaperCount.toString()),
      HomeWidget.saveWidgetData<String>('today_sleep_min',    sleepMin.toString()),
    ]);
  }

  /// 위젯 설정(테마·투명도·버튼 목록)을 네이티브에 push한다.
  static Future<void> pushSettings(WidgetSettings settings) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_theme', settings.themeMode.name),
      HomeWidget.saveWidgetData<String>(
          'widget_opacity', settings.opacity.toStringAsFixed(2)),
      HomeWidget.saveWidgetData<String>(
          'widget_buttons',
          settings.selectedButtons.map((e) => e.name).join(',')),
    ]);
    _update();
  }

  static void _update() {
    unawaited(HomeWidget.updateWidget(
      iOSName: iosKind,
      androidName: androidReceiver,
    ));
    unawaited(HomeWidget.updateWidget(
      iOSName: iosKind,
      androidName: androidCompactReceiver,
    ));
  }
}
