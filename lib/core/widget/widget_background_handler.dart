import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../features/diaper/data/diaper_repository_impl.dart';
import '../../features/feeding/data/feeding_repository_impl.dart';
import '../../features/sleep/data/sleep_repository_impl.dart';
import '../database/app_database.dart';
import 'widget_sync_service.dart';

/// 홈 위젯 버튼 탭 시 앱을 띄우지 않고 Dart background isolate에서 실행되는 콜백.
///
/// home_widget 패키지의 registerBackgroundCallback에 등록된다.
/// Android 전용. iOS는 기존 Link → 앱 기동 흐름 유지.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  // HomeWidget.saveWidgetData 는 HomeWidgetPreferences 에 저장되므로
  // SharedPreferences.getInstance() 가 아닌 HomeWidget.getWidgetData 로 읽는다.
  final babyId   = await HomeWidget.getWidgetData<String>('widget_baby_id');
  final familyId = await HomeWidget.getWidgetData<String>('widget_family_id');
  if (babyId == null || babyId.isEmpty || familyId == null || familyId.isEmpty) {
    debugPrint('[WidgetBg] babyId/familyId 없음 — 저장 건너뜀');
    return;
  }

  final db  = AppDatabase();
  final now = DateTime.now();

  try {
    // bebetap://action/feeding/formula → host="action", pathSegments=["feeding","formula"]
    if (uri.host != 'action') return;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    // 새로고침: 오늘 총량 + 최근 기록 전체 재동기화
    if (segments[0] == 'refresh') {
      await _refreshAll(db, babyId);
      return;
    }

    // 아기 전환: Kotlin이 이미 widget_baby_id를 갱신한 상태. DB 재조회 후 동기화.
    if (segments[0] == 'baby' && segments.length >= 2 && segments[1] == 'switch') {
      final newBabyId = await HomeWidget.getWidgetData<String>('widget_baby_id');
      if (newBabyId != null && newBabyId.isNotEmpty) {
        await _refreshAll(db, newBabyId);
        // 앱 resume 시 selectedBabyIdProvider가 이 값을 읽어 동기화
        await HomeWidget.saveWidgetData<String>('widget_selected_baby_id', newBabyId);
      }
      return;
    }

    if (segments.length < 2) return;
    final category = segments[0];
    final value    = segments[1];

    switch ('$category/$value') {
      case 'feeding/formula':
        await FeedingRepository(db).saveFormulaFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, '분유', now);
      case 'feeding/breast':
        await FeedingRepository(db).saveBreastFeeding(
          babyId: babyId, familyId: familyId,
          durationLeftSec: 0, durationRightSec: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, '모유', now);
      case 'feeding/pumped':
        await FeedingRepository(db).savePumpedFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, '유축', now);
      case 'feeding/babyFood':
        await FeedingRepository(db).saveBabyFoodFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, '이유식', now);
      case 'diaper/wet':
        await DiaperRepository(db).saveDiaper(
          babyId: babyId, familyId: familyId, type: 'wet', occurredAt: now);
      case 'sleep/toggle':
        // 백그라운드에서는 항상 새 수면 시작 (active 감지 생략)
        await SleepRepository(db).startSleep(
          babyId: babyId, familyId: familyId, startedAt: now);
    }

    // 위젯 데이터는 HomeWidgetPreferences 에 기록되며,
    // Kotlin WidgetSilentActionCallback 이 updateAll() 로 즉시 갱신했다.
    // background isolate 에서는 updateWidget() MethodChannel 미사용.
  } catch (e) {
    debugPrint('[WidgetBg] 저장 실패: $e');
  } finally {
    await db.close();
  }
}

/// 새로고침 요청 시 DB에서 총량 + 최근 기록을 모두 재조회해 위젯을 갱신한다.
Future<void> _refreshAll(AppDatabase db, String babyId) async {
  final feedingRepo = FeedingRepository(db);
  final diaperRepo  = DiaperRepository(db);
  final sleepRepo   = SleepRepository(db);
  final now         = DateTime.now();

  // 오늘 총량
  final totals = await Future.wait([
    feedingRepo.getDailyFormulaTotalMl(babyId, now),  // 0
    feedingRepo.getDailyPumpedTotalMl(babyId, now),   // 1
    feedingRepo.getDailyBabyFoodTotalMl(babyId, now), // 2
    feedingRepo.getDailyBreastTotalSec(babyId, now),  // 3
    diaperRepo.getTodayDiaperCount(babyId),            // 4
    sleepRepo.getTodaySleepTotal(babyId).then((d) => d.inMinutes), // 5
  ]);
  await WidgetSyncService.pushTodayTotals(
    formulaMl:   totals[0],
    pumpedMl:    totals[1],
    babyFoodMl:  totals[2],
    breastSec:   totals[3],
    diaperCount: totals[4],
    sleepMin:    totals[5],
  );

  // 최근 기록 3건
  final recents = await Future.wait([
    db.feedingDao.getLastFeedingByBaby(babyId),
    db.diaperDao.getLastDiaper(babyId),
    db.sleepDao.getLastSleep(babyId),
  ]);
  final lastFeeding = recents[0] as FeedingEntriesTableData?;
  final lastDiaper  = recents[1] as DiaperEntriesTableData?;
  final lastSleep   = recents[2] as SleepEntriesTableData?;

  final records = <_WR>[];
  if (lastFeeding != null) {
    final label = switch (lastFeeding.type) {
      'breast'    => '모유',
      'pumped'    => '유축',
      'baby_food' => '이유식',
      _           => '분유',
    };
    final detail = lastFeeding.type == 'breast'
        ? _dur((lastFeeding.durationLeftSec ?? 0) + (lastFeeding.durationRightSec ?? 0))
        : '${lastFeeding.amountMl ?? 0}ml';
    records.add(_WR(label, detail, lastFeeding.startedAt));
  }
  if (lastDiaper != null) {
    final detail = switch (lastDiaper.type) {
      'wet'    => '소변',
      'soiled' => '대변',
      'both'   => '소변+대변',
      _        => '교체',
    };
    records.add(_WR('기저귀', detail, lastDiaper.occurredAt));
  }
  if (lastSleep != null) {
    final detail = lastSleep.endedAt == null
        ? '자는 중'
        : _dur(lastSleep.endedAt!.difference(lastSleep.startedAt).inSeconds);
    records.add(_WR('수면', detail, lastSleep.startedAt));
  }
  records.sort((a, b) => b.time.compareTo(a.time));

  String lastLabel = '';
  DateTime? lastTime;
  if (lastFeeding != null) {
    lastLabel = switch (lastFeeding.type) {
      'breast'    => '모유',
      'pumped'    => '유축',
      'baby_food' => '이유식',
      _           => '분유',
    };
    lastTime = lastFeeding.startedAt;
  }

  await WidgetSyncService.push(
    recentRecords: records.take(3).map((r) => WidgetRecord(
      label: r.label, detail: r.detail, time: r.time,
    )).toList(),
    lastFeedingLabel: lastLabel,
    lastFeedingTime: lastTime,
  );
  // sentinel: Kotlin WidgetRefreshActionCallback이 폴링해 updateAll() 재호출
  await HomeWidget.saveWidgetData<String>(
    'widget_refresh_ts',
    DateTime.now().millisecondsSinceEpoch.toString(),
  );
}

class _WR {
  _WR(this.label, this.detail, this.time);
  final String label, detail;
  final DateTime time;
}

String _dur(int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  return h > 0 ? '$h시간 $m분' : '$m분';
}

/// 수유 저장 후 위젯 헤더(마지막 수유 + 오늘 총량)를 즉시 갱신한다.
Future<void> _pushFeedingHeader(
  AppDatabase db,
  String babyId,
  String label,
  DateTime now,
) async {
  await Future.wait([
    HomeWidget.saveWidgetData<String>('lastFeedingLabel', label),
    HomeWidget.saveWidgetData<String>(
        'lastFeedingTime', now.toUtc().toIso8601String()),
  ]);

  // 오늘 총량 갱신
  final repo = FeedingRepository(db);
  final int formulaMl, pumpedMl, babyFoodMl, breastSec;
  switch (label) {
    case '분유':
      formulaMl  = await repo.getDailyFormulaTotalMl(babyId, now);
      pumpedMl   = 0; babyFoodMl = 0; breastSec = 0;
    case '유축':
      pumpedMl   = await repo.getDailyPumpedTotalMl(babyId, now);
      formulaMl  = 0; babyFoodMl = 0; breastSec = 0;
    case '이유식':
      babyFoodMl = await repo.getDailyBabyFoodTotalMl(babyId, now);
      formulaMl  = 0; pumpedMl = 0; breastSec = 0;
    case '모유':
      breastSec  = await repo.getDailyBreastTotalSec(babyId, now);
      formulaMl  = 0; pumpedMl = 0; babyFoodMl = 0;
    default:
      return;
  }
  await WidgetSyncService.pushTodayTotals(
    formulaMl:  formulaMl,
    pumpedMl:   pumpedMl,
    babyFoodMl: babyFoodMl,
    breastSec:  breastSec,
  );
}
