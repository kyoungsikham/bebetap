import 'dart:async' show unawaited;

import 'package:home_widget/home_widget.dart';

import '../../shared/models/widget_settings.dart';

/// 위젯 한 행에 표시되는 최근 기록 데이터
class WidgetRecord {
  const WidgetRecord({
    required this.label,
    required this.detail,
    required this.time,
    this.colorCategory = '',
  });

  final String label;         // 번역된 라벨 ("Formula", "분유", "ミルク" 등)
  final String detail;        // 번역된 상세 ("140ml", "Wet", "소변" 등)
  final DateTime time;        // 발생 시각
  final String colorCategory; // 도트 색상용 enum ("formula","breast","diaper","sleep","temperature")
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
          HomeWidget.saveWidgetData<String>('${key}_color', r.colorCategory),
        ]);
      } else {
        saves.addAll([
          HomeWidget.saveWidgetData<String>('${key}_label', ''),
          HomeWidget.saveWidgetData<String>('${key}_detail', ''),
          HomeWidget.saveWidgetData<String>('${key}_time', ''),
          HomeWidget.saveWidgetData<String>('${key}_color', ''),
        ]);
      }
    }

    await Future.wait(saves);
    _update();
  }

  /// 위젯 정적 텍스트 및 단위 문자열을 push한다 (언어 변경 시 호출).
  static Future<void> pushLocalizedTexts({
    required String emptyShort,
    required String emptyToday,
    required String emptyHint,
    required String titleFallback,
    required String unitMin,
    required String agoSuffix,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<String>('widget_empty_short',   emptyShort),
      HomeWidget.saveWidgetData<String>('widget_empty_today',   emptyToday),
      HomeWidget.saveWidgetData<String>('widget_empty_hint',    emptyHint),
      HomeWidget.saveWidgetData<String>('widget_title_fallback', titleFallback),
      HomeWidget.saveWidgetData<String>('widget_unit_min',      unitMin),
      HomeWidget.saveWidgetData<String>('widget_ago_suffix',    agoSuffix),
    ]);
  }

  /// 오늘 총량 — 라벨(번역)과 포맷된 값 문자열을 함께 push한다.
  static Future<void> pushTodayTotalsLocalized({
    required int formulaMl,
    required int pumpedMl,
    required int babyFoodMl,
    required int breastSec,
    required int diaperCount,
    required int sleepMin,
    required String labelFormula,
    required String labelBreast,
    required String labelPumped,
    required String labelBabyFood,
    required String labelDiaper,
    required String labelSleep,
    required String Function(int h, int m) formatHm,
    required String Function(int m) formatMin,
    required String Function(int n) formatDiaper,
  }) async {
    String breastVal() {
      final h = breastSec ~/ 3600;
      final m = (breastSec % 3600) ~/ 60;
      return h > 0 ? formatHm(h, m) : formatMin(m);
    }
    String sleepVal() {
      final h = sleepMin ~/ 60;
      final m = sleepMin % 60;
      return h > 0 ? formatHm(h, m) : formatMin(m);
    }
    await Future.wait([
      HomeWidget.saveWidgetData<String>('today_formula_ml',    formulaMl.toString()),
      HomeWidget.saveWidgetData<String>('today_pumped_ml',     pumpedMl.toString()),
      HomeWidget.saveWidgetData<String>('today_babyfood_ml',   babyFoodMl.toString()),
      HomeWidget.saveWidgetData<String>('today_breast_sec',    breastSec.toString()),
      HomeWidget.saveWidgetData<String>('today_diaper_count',  diaperCount.toString()),
      HomeWidget.saveWidgetData<String>('today_sleep_min',     sleepMin.toString()),
      HomeWidget.saveWidgetData<String>('today_formula_label',  labelFormula),
      HomeWidget.saveWidgetData<String>('today_breast_label',   labelBreast),
      HomeWidget.saveWidgetData<String>('today_pumped_label',   labelPumped),
      HomeWidget.saveWidgetData<String>('today_babyfood_label', labelBabyFood),
      HomeWidget.saveWidgetData<String>('today_diaper_label',   labelDiaper),
      HomeWidget.saveWidgetData<String>('today_sleep_label',    labelSleep),
      HomeWidget.saveWidgetData<String>('today_breast_value',   breastSec > 0 ? breastVal() : ''),
      HomeWidget.saveWidgetData<String>('today_sleep_value',    sleepMin  > 0 ? sleepVal()  : ''),
      HomeWidget.saveWidgetData<String>('today_diaper_value',   diaperCount > 0 ? formatDiaper(diaperCount) : ''),
    ]);
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
    _update();
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

  /// 특정 아기의 데이터를 `key_babyId` 접미사 키로 push한다.
  /// Android의 인스턴스별 위젯 고정 기능에서 이 키를 우선 조회한다.
  static Future<void> pushForBaby({
    required String babyId,
    required String babyName,
    required List<WidgetRecord> recentRecords,
    required int formulaMl,
    required int pumpedMl,
    required int babyFoodMl,
    required int breastSec,
    required int diaperCount,
    required int sleepMin,
    required String Function(int h, int m) formatHm,
    required String Function(int m) formatMin,
    required String Function(int n) formatDiaper,
  }) async {
    String toIso(DateTime dt) => dt.toUtc().toIso8601String();
    String breastVal() {
      final h = breastSec ~/ 3600;
      final m = (breastSec % 3600) ~/ 60;
      return h > 0 ? formatHm(h, m) : formatMin(m);
    }
    String sleepVal() {
      final h = sleepMin ~/ 60;
      final m = sleepMin % 60;
      return h > 0 ? formatHm(h, m) : formatMin(m);
    }

    // 이름이 비어 있으면 저장 건너뜀 → ConfigureActivity가 즉시 저장한 올바른 이름 보존
    final saves = <Future<void>>[
      if (babyName.isNotEmpty)
        HomeWidget.saveWidgetData<String>('widget_baby_name_$babyId', babyName),
    ];
    for (int i = 0; i < 3; i++) {
      final key = 'r${i + 1}';
      if (i < recentRecords.length) {
        final r = recentRecords[i];
        saves.addAll([
          HomeWidget.saveWidgetData<String>('${key}_label_$babyId',  r.label),
          HomeWidget.saveWidgetData<String>('${key}_detail_$babyId', r.detail),
          HomeWidget.saveWidgetData<String>('${key}_time_$babyId',   toIso(r.time)),
          HomeWidget.saveWidgetData<String>('${key}_color_$babyId',  r.colorCategory),
        ]);
      } else {
        saves.addAll([
          HomeWidget.saveWidgetData<String>('${key}_label_$babyId',  ''),
          HomeWidget.saveWidgetData<String>('${key}_detail_$babyId', ''),
          HomeWidget.saveWidgetData<String>('${key}_time_$babyId',   ''),
          HomeWidget.saveWidgetData<String>('${key}_color_$babyId',  ''),
        ]);
      }
    }
    saves.addAll([
      HomeWidget.saveWidgetData<String>('today_formula_ml_$babyId',   formulaMl.toString()),
      HomeWidget.saveWidgetData<String>('today_pumped_ml_$babyId',    pumpedMl.toString()),
      HomeWidget.saveWidgetData<String>('today_babyfood_ml_$babyId',  babyFoodMl.toString()),
      HomeWidget.saveWidgetData<String>('today_breast_sec_$babyId',   breastSec.toString()),
      HomeWidget.saveWidgetData<String>('today_diaper_count_$babyId', diaperCount.toString()),
      HomeWidget.saveWidgetData<String>('today_sleep_min_$babyId',    sleepMin.toString()),
      HomeWidget.saveWidgetData<String>('today_breast_value_$babyId', breastSec > 0 ? breastVal() : ''),
      HomeWidget.saveWidgetData<String>('today_sleep_value_$babyId',  sleepMin  > 0 ? sleepVal()  : ''),
      HomeWidget.saveWidgetData<String>('today_diaper_value_$babyId', diaperCount > 0 ? formatDiaper(diaperCount) : ''),
    ]);
    await Future.wait(saves);
  }

  static void triggerUpdate() => _update();

  static void _update() {
    unawaited(HomeWidget.updateWidget(
      iOSName: iosKind,
      qualifiedAndroidName: androidReceiver,
    ));
    unawaited(HomeWidget.updateWidget(
      iOSName: iosKind,
      qualifiedAndroidName: androidCompactReceiver,
    ));
  }
}
