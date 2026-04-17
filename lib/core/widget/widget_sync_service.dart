import 'dart:async' show unawaited;

import 'package:home_widget/home_widget.dart';

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

  static const _iosKind = 'BebeTapWidget';
  static const _androidReceiver = 'BebeTapWidgetReceiver';

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

  static void _update() {
    unawaited(HomeWidget.updateWidget(
      iOSName: _iosKind,
      androidName: _androidReceiver,
    ));
  }
}
