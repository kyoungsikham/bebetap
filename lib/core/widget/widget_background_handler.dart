import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/diaper/data/diaper_repository_impl.dart';
import '../../features/feeding/data/feeding_repository_impl.dart';
import '../../features/sleep/data/sleep_repository_impl.dart';
import '../../l10n/app_localizations.dart';
import '../database/app_database.dart';
import 'widget_sync_service.dart';

/// 홈 위젯 버튼 탭 시 앱을 띄우지 않고 Dart background isolate에서 실행되는 콜백.
///
/// home_widget 패키지의 registerBackgroundCallback에 등록된다.
/// Android 전용. iOS는 기존 Link → 앱 기동 흐름 유지.
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;

  if (uri.host != 'action') return;
  final segments = uri.pathSegments;
  if (segments.isEmpty) return;

  final db  = AppDatabase();
  final now = DateTime.now();

  try {
    // 새로고침: widget_baby_id 없어도 ?baby= URL 파라미터로 처리 가능
    // babyId/familyId 가드를 여기 두면 familyId 미설정 시 refresh가 막히는 버그 방지
    if (segments[0] == 'refresh') {
      // URL 파라미터를 우선 사용. 없으면 SharedPreferences에서 글로벌 baby ID 조회.
      String targetId = uri.queryParameters['baby'] ?? '';
      if (targetId.isEmpty) {
        try {
          final globalBabyId = await HomeWidget.getWidgetData<String>('widget_baby_id');
          targetId = globalBabyId ?? '';
        } catch (_) {}
      }
      if (targetId.isNotEmpty) await _refreshAll(db, targetId);
      return;
    }

    // 아기 전환: Kotlin이 이미 widget_baby_id를 갱신한 상태. DB 재조회 후 동기화.
    if (segments[0] == 'baby' && segments.length >= 2 && segments[1] == 'switch') {
      final newBabyId = await HomeWidget.getWidgetData<String>('widget_baby_id');
      if (newBabyId != null && newBabyId.isNotEmpty) {
        await _refreshAll(db, newBabyId);
        await HomeWidget.saveWidgetData<String>('widget_selected_baby_id', newBabyId);
      }
      return;
    }

    // 빠른 저장 (분유·모유·유축·이유식·기저귀·수면) — babyId/familyId 필요
    final babyId   = await HomeWidget.getWidgetData<String>('widget_baby_id');
    final familyId = await HomeWidget.getWidgetData<String>('widget_family_id');
    if (babyId == null || babyId.isEmpty || familyId == null || familyId.isEmpty) {
      debugPrint('[WidgetBg] babyId/familyId 없음 — 저장 건너뜀');
      return;
    }

    if (segments.length < 2) return;
    final category = segments[0];
    final value    = segments[1];

    final l = await _loadLocalization();

    switch ('$category/$value') {
      case 'feeding/formula':
        await FeedingRepository(db).saveFormulaFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, l.widgetLabelFormula, now, l);
      case 'feeding/breast':
        await FeedingRepository(db).saveBreastFeeding(
          babyId: babyId, familyId: familyId,
          durationLeftSec: 0, durationRightSec: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, l.widgetLabelBreast, now, l);
      case 'feeding/pumped':
        await FeedingRepository(db).savePumpedFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, l.widgetLabelPumped, now, l);
      case 'feeding/babyFood':
        await FeedingRepository(db).saveBabyFoodFeeding(
          babyId: babyId, familyId: familyId, amountMl: 0, startedAt: now);
        await _pushFeedingHeader(db, babyId, l.widgetLabelBabyFood, now, l);
      case 'diaper/wet':
        await DiaperRepository(db).saveDiaper(
          babyId: babyId, familyId: familyId, type: 'wet', occurredAt: now);
      case 'sleep/toggle':
        await SleepRepository(db).startSleep(
          babyId: babyId, familyId: familyId, startedAt: now);
    }

    // Kotlin WidgetSilentActionCallback 이 updateAll() 로 즉시 갱신함.
    // background isolate 에서는 updateWidget() MethodChannel 미사용.
  } catch (e) {
    debugPrint('[WidgetBg] 저장 실패: $e');
  } finally {
    await db.close();
  }
}

/// SharedPreferences에서 app_locale을 읽어 AppLocalizations 반환.
/// background isolate에서는 Riverpod/BuildContext 없이 직접 읽는다.
Future<AppLocalizations> _loadLocalization() async {
  final prefs = await SharedPreferences.getInstance();
  final code  = prefs.getString('app_locale') ?? 'ko';
  return lookupAppLocalizations(Locale(code));
}

/// 새로고침 요청 시 등록된 모든 아기를 재조회해 위젯을 갱신한다.
/// [actionBabyId]: refresh/switch를 트리거한 아기 → 글로벌 fallback 키에 사용.
Future<void> _refreshAll(AppDatabase db, String actionBabyId) async {
  // 등록된 모든 아기 ID 조회 (실패 시 빈 목록 — actionBabyId만 처리)
  String allIdsStr = '';
  String allNamesStr = '';
  try { allIdsStr   = await HomeWidget.getWidgetData<String>('widget_baby_ids')   ?? ''; } catch (_) {}
  try { allNamesStr = await HomeWidget.getWidgetData<String>('widget_baby_names') ?? ''; } catch (_) {}
  final allIds   = allIdsStr.split('|').where((s) => s.isNotEmpty).toList();
  final allNames = allNamesStr.split('|').where((s) => s.isNotEmpty).toList();
  final babyIdsToProcess = allIds.isNotEmpty ? allIds : [actionBabyId];

  final now = DateTime.now();
  final l   = await _loadLocalization();
  final feedingRepo = FeedingRepository(db);
  final diaperRepo  = DiaperRepository(db);
  final sleepRepo   = SleepRepository(db);

  // actionBabyId를 먼저 처리해 핀된 위젯의 0ml 깜빡임 최소화
  final orderedIds = [
    ...babyIdsToProcess.where((id) => id == actionBabyId),
    ...babyIdsToProcess.where((id) => id != actionBabyId),
  ];

  // 글로벌 fallback 키에 쓸 데이터 (action baby 기준 — cycling/refresh UX 유지)
  List<WidgetRecord> globalTop3 = [];
  final globalTotals = List.filled(6, 0);
  String lastLabel = '';
  DateTime? lastTime;
  bool firstPushDone = false;

  for (final babyId in orderedIds) {
    try {
      // 오늘 총량
      final totals = await Future.wait([
        feedingRepo.getDailyFormulaTotalMl(babyId, now),   // 0
        feedingRepo.getDailyPumpedTotalMl(babyId, now),    // 1
        feedingRepo.getDailyBabyFoodTotalMl(babyId, now),  // 2
        feedingRepo.getDailyBreastTotalSec(babyId, now),   // 3
        diaperRepo.getTodayDiaperCount(babyId),             // 4
        sleepRepo.getTodaySleepTotal(babyId).then((d) => d.inMinutes), // 5
      ]);

      // 최근 기록 3건
      final recentFeedings = await db.feedingDao.getRecentFeedingsByBaby(babyId)
          .catchError((_) => <FeedingEntriesTableData>[]);
      final recentDiapers = await db.diaperDao.getRecentDiapers(babyId)
          .catchError((_) => <DiaperEntriesTableData>[]);
      final recentSleeps = await db.sleepDao.getRecentSleeps(babyId)
          .catchError((_) => <SleepEntriesTableData>[]);
      final recentTemps = await db.temperatureDao.getRecentTemperatures(babyId)
          .catchError((_) => <TemperatureEntriesTableData>[]);

      final records = <_WR>[];
      for (final f in recentFeedings) {
        final (label, color) = switch (f.type) {
          'breast'    => (l.widgetLabelBreast,   'breast'),
          'pumped'    => (l.widgetLabelPumped,   'pumped'),
          'baby_food' => (l.widgetLabelBabyFood, 'babyFood'),
          _           => (l.widgetLabelFormula,  'formula'),
        };
        final detail = f.type == 'breast'
            ? _dur(l, (f.durationLeftSec ?? 0) + (f.durationRightSec ?? 0))
            : '${f.amountMl ?? 0}ml';
        records.add(_WR(label, detail, f.startedAt, color));
      }
      for (final d in recentDiapers) {
        final detail = switch (d.type) {
          'wet'    => l.widgetDetailDiaperWet,
          'soiled' => l.widgetDetailDiaperSoiled,
          'both'   => l.widgetDetailDiaperBoth,
          _        => l.widgetDetailDiaperChange,
        };
        records.add(_WR(l.widgetLabelDiaper, detail, d.occurredAt, 'diaper'));
      }
      for (final s in recentSleeps) {
        final detail = s.endedAt == null
            ? l.widgetDetailSleepActive
            : _dur(l, s.endedAt!.difference(s.startedAt).inSeconds);
        records.add(_WR(l.widgetLabelSleep, detail, s.startedAt, 'sleep'));
      }
      for (final t in recentTemps) {
        records.add(_WR(l.widgetLabelTemperature,
            '${t.celsius.toStringAsFixed(1)}°C', t.occurredAt, 'temperature'));
      }
      records.sort((a, b) => b.time.compareTo(a.time));

      final top3 = records.take(3).map((r) => WidgetRecord(
        label: r.label, detail: r.detail, time: r.time, colorCategory: r.color,
      )).toList();

      // per-baby 키 push
      // allIds에 없으면 이름을 알 수 없으므로 빈 문자열 → pushForBaby가 기존 이름을 보존
      final babyNameForId = () {
        final idx = allIds.indexOf(babyId);
        return (idx >= 0 && idx < allNames.length) ? allNames[idx] : '';
      }();
      await WidgetSyncService.pushForBaby(
        babyId: babyId,
        babyName: babyNameForId,
        recentRecords: top3,
        formulaMl:   totals[0],
        pumpedMl:    totals[1],
        babyFoodMl:  totals[2],
        breastSec:   totals[3],
        diaperCount: totals[4],
        sleepMin:    totals[5],
        formatHm:     (h, m) => l.widgetDurationHm(h, m),
        formatMin:    (m) => l.widgetDurationMin(m),
        formatDiaper: (n) => l.widgetDiaperCount(n),
      );

      // actionBabyId(= orderedIds 첫 번째) push 완료 즉시 위젯 갱신 → 0ml 깜빡임 최소화
      if (!firstPushDone) {
        firstPushDone = true;
        WidgetSyncService.triggerUpdate();
      }

      // action baby → 글로벌 키에 사용 (cycling/refresh UX — 해당 아기 데이터 즉시 반영)
      if (babyId == actionBabyId) {
        globalTop3 = top3;
        for (int i = 0; i < 6; i++) { globalTotals[i] = totals[i]; }

        // lastFeedingLabel/Time: action baby의 최근 수유 조회
        final lastFormula = await db.feedingDao
            .getLastFeedingByBabyAndType(babyId, 'formula')
            .catchError((_) => null);
        final lastBreast = await db.feedingDao
            .getLastFeedingByBabyAndType(babyId, 'breast')
            .catchError((_) => null);
        final lastPumped = await db.feedingDao
            .getLastFeedingByBabyAndType(babyId, 'pumped')
            .catchError((_) => null);
        final feedingHeader = <(String, DateTime)>[
          if (lastFormula != null) (l.widgetLabelFormula, lastFormula.startedAt),
          if (lastBreast  != null) (l.widgetLabelBreast,  lastBreast.startedAt),
          if (lastPumped  != null) (l.widgetLabelPumped,  lastPumped.startedAt),
        ]..sort((a, b) => b.$2.compareTo(a.$2));
        if (feedingHeader.isNotEmpty) {
          lastLabel = feedingHeader.first.$1;
          lastTime  = feedingHeader.first.$2;
        }
      }
    } catch (_) {
      // 한 아기 실패가 나머지에 영향 안 줌
    }
  }

  // 공유 텍스트 + 글로벌 총량 push (per-baby 키 write 완료 후)
  await Future.wait([
    WidgetSyncService.pushTodayTotalsLocalized(
      formulaMl:   globalTotals[0],
      pumpedMl:    globalTotals[1],
      babyFoodMl:  globalTotals[2],
      breastSec:   globalTotals[3],
      diaperCount: globalTotals[4],
      sleepMin:    globalTotals[5],
      labelFormula:  l.widgetLabelFormula,
      labelBreast:   l.widgetLabelBreast,
      labelPumped:   l.widgetLabelPumped,
      labelBabyFood: l.widgetLabelBabyFood,
      labelDiaper:   l.widgetLabelDiaper,
      labelSleep:    l.widgetLabelSleep,
      formatHm:  (h, m) => l.widgetDurationHm(h, m),
      formatMin: (m) => l.widgetDurationMin(m),
      formatDiaper: (n) => l.widgetDiaperCount(n),
    ),
    WidgetSyncService.pushLocalizedTexts(
      emptyShort:    l.widgetEmptyShort,
      emptyToday:    l.widgetEmptyToday,
      emptyHint:     l.widgetEmptyHint,
      titleFallback: l.widgetTitleFallback,
      unitMin:       l.widgetUnitMin,
      agoSuffix:     l.widgetAgoSuffix,
    ),
  ]);
  // push()는 마지막에 _update()를 호출해 iOS Timeline / Android 위젯을 갱신한다.
  await WidgetSyncService.push(
    recentRecords: globalTop3,
    lastFeedingLabel: lastLabel,
    lastFeedingTime: lastTime,
  );
}

class _WR {
  _WR(this.label, this.detail, this.time, this.color);
  final String label, detail, color;
  final DateTime time;
}

String _dur(AppLocalizations l, int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  return h > 0 ? l.widgetDurationHm(h, m) : l.widgetDurationMin(m);
}

/// 수유 저장 후 위젯 헤더(마지막 수유 + 오늘 총량)를 즉시 갱신한다.
Future<void> _pushFeedingHeader(
  AppDatabase db,
  String babyId,
  String label,
  DateTime now,
  AppLocalizations l,
) async {
  await Future.wait([
    HomeWidget.saveWidgetData<String>('lastFeedingLabel', label),
    HomeWidget.saveWidgetData<String>(
        'lastFeedingTime', now.toUtc().toIso8601String()),
  ]);

  // 오늘 총량 갱신 (수유 종목만 갱신, 나머지는 기존 값 유지)
  final repo = FeedingRepository(db);
  final int formulaMl, pumpedMl, babyFoodMl, breastSec;
  if (label == l.widgetLabelFormula) {
    formulaMl  = await repo.getDailyFormulaTotalMl(babyId, now);
    pumpedMl   = 0; babyFoodMl = 0; breastSec = 0;
  } else if (label == l.widgetLabelPumped) {
    pumpedMl   = await repo.getDailyPumpedTotalMl(babyId, now);
    formulaMl  = 0; babyFoodMl = 0; breastSec = 0;
  } else if (label == l.widgetLabelBabyFood) {
    babyFoodMl = await repo.getDailyBabyFoodTotalMl(babyId, now);
    formulaMl  = 0; pumpedMl = 0; breastSec = 0;
  } else if (label == l.widgetLabelBreast) {
    breastSec  = await repo.getDailyBreastTotalSec(babyId, now);
    formulaMl  = 0; pumpedMl = 0; babyFoodMl = 0;
  } else {
    return;
  }
  await WidgetSyncService.pushTodayTotalsLocalized(
    formulaMl:   formulaMl,
    pumpedMl:    pumpedMl,
    babyFoodMl:  babyFoodMl,
    breastSec:   breastSec,
    diaperCount: 0,
    sleepMin:    0,
    labelFormula:  l.widgetLabelFormula,
    labelBreast:   l.widgetLabelBreast,
    labelPumped:   l.widgetLabelPumped,
    labelBabyFood: l.widgetLabelBabyFood,
    labelDiaper:   l.widgetLabelDiaper,
    labelSleep:    l.widgetLabelSleep,
    formatHm:  (h, m) => l.widgetDurationHm(h, m),
    formatMin: (m) => l.widgetDurationMin(m),
    formatDiaper: (n) => l.widgetDiaperCount(n),
  );
}
