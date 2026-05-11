import 'dart:async' show unawaited;
import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/presentation/providers/baby_provider.dart';
import '../../features/diaper/data/diaper_repository_impl.dart';
import '../../features/feeding/data/feeding_repository_impl.dart';
import '../../features/sleep/data/sleep_repository_impl.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/providers/locale_provider.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'widget_sync_service.dart';

/// 기록 저장 후 어느 Provider에서나 호출해 위젯을 최신 상태로 갱신한다.
Future<void> refreshWidget(Ref ref) => _refreshImpl(ref.read);

/// WidgetRef 환경(widget_action_handler 등)에서 호출하는 버전.
Future<void> refreshWidgetFromWidget(WidgetRef ref) => _refreshImpl(ref.read);

/// 실제 갱신 로직 — 등록된 모든 아기의 per-baby 키를 push하고
/// 글로벌 fallback 키는 첫 번째 아기 데이터로 채운다.
Future<void> _refreshImpl(
  T Function<T>(ProviderListenable<T>) read,
) async {
  final allBabies = read(babiesProvider).valueOrNull ?? [];
  if (allBabies.isEmpty) return;

  final selectedBaby = read(selectedBabyProvider).valueOrNull;
  final db    = read(appDatabaseProvider);
  final today = DateTime.now();

  final locale = read(localeProvider).valueOrNull ?? const Locale('ko');
  final l = lookupAppLocalizations(locale);

  final feedingRepo = FeedingRepository(db);
  final diaperRepo  = DiaperRepository(db);
  final sleepRepo   = SleepRepository(db);

  // 선택된 아기를 먼저 처리해 핀된 위젯의 0ml 깜빡임 최소화
  final selectedId = selectedBaby?.id ?? allBabies.first.id;
  final orderedBabies = [
    ...allBabies.where((b) => b.id == selectedId),
    ...allBabies.where((b) => b.id != selectedId),
  ];
  final firstBabyId = orderedBabies.first.id;

  // 글로벌 fallback 키에 쓸 데이터 (선택된 아기 기준)
  List<WidgetRecord> globalRecords = [];
  String globalLastFeedingLabel = '';
  DateTime? globalLastFeedingTime;
  final globalResults2 = <int>[0, 0, 0, 0, 0, 0];
  bool firstPushDone = false;

  for (final baby in orderedBabies) {
    final babyId = baby.id;
    try {
      // ── 최근 기록 및 마지막 수유 조회 ────────────────────────────
      final lastResults = await Future.wait([
        db.feedingDao.getLastFeedingByBabyAndType(babyId, 'formula'),  // 0
        db.feedingDao.getLastFeedingByBabyAndType(babyId, 'breast'),   // 1
        db.feedingDao.getLastFeedingByBabyAndType(babyId, 'pumped'),   // 2
        db.feedingDao.getRecentFeedingsByBaby(babyId),                 // 3
        db.diaperDao.getRecentDiapers(babyId),                         // 4
        db.sleepDao.getRecentSleeps(babyId),                           // 5
        db.temperatureDao.getRecentTemperatures(babyId),               // 6
      ]);

      final lastFormula    = lastResults[0] as FeedingEntriesTableData?;
      final lastBreast     = lastResults[1] as FeedingEntriesTableData?;
      final lastPumped     = lastResults[2] as FeedingEntriesTableData?;
      final recentFeedings = lastResults[3] as List<FeedingEntriesTableData>;
      final recentDiapers  = lastResults[4] as List<DiaperEntriesTableData>;
      final recentSleeps   = lastResults[5] as List<SleepEntriesTableData>;
      final recentTemps    = lastResults[6] as List<TemperatureEntriesTableData>;

      // ── 헤더: 분유/모유/유축 중 가장 최근 ─────────────────────────
      String lastFeedingLabel = '';
      DateTime? lastFeedingTime;

      final feedingCandidates = <(String, DateTime)>[
        if (lastFormula != null) (l.widgetLabelFormula, lastFormula.startedAt),
        if (lastBreast  != null) (l.widgetLabelBreast,  lastBreast.startedAt),
        if (lastPumped  != null) (l.widgetLabelPumped,  lastPumped.startedAt),
      ]..sort((a, b) => b.$2.compareTo(a.$2));

      if (feedingCandidates.isNotEmpty) {
        lastFeedingLabel = feedingCandidates.first.$1;
        lastFeedingTime  = feedingCandidates.first.$2;
      }

      // ── 최근 기록 3건 (모든 카테고리 통합 후 시간순) ────────────────
      final candidates = <WidgetRecord>[];

      for (final f in recentFeedings) {
        final (label, color) = switch (f.type) {
          'breast'    => (l.widgetLabelBreast,   'breast'),
          'pumped'    => (l.widgetLabelPumped,   'pumped'),
          'baby_food' => (l.widgetLabelBabyFood, 'babyFood'),
          _           => (l.widgetLabelFormula,  'formula'),
        };
        final detail = f.type == 'breast'
            ? _durLabel(l, (f.durationLeftSec ?? 0) + (f.durationRightSec ?? 0))
            : '${f.amountMl ?? 0}ml';
        candidates.add(WidgetRecord(
          label: label, detail: detail, time: f.startedAt, colorCategory: color));
      }

      for (final d in recentDiapers) {
        final detail = switch (d.type) {
          'wet'    => l.widgetDetailDiaperWet,
          'soiled' => l.widgetDetailDiaperSoiled,
          'both'   => l.widgetDetailDiaperBoth,
          _        => l.widgetDetailDiaperChange,
        };
        candidates.add(WidgetRecord(
          label: l.widgetLabelDiaper, detail: detail, time: d.occurredAt,
          colorCategory: 'diaper'));
      }

      for (final s in recentSleeps) {
        final detail = s.endedAt == null
            ? l.widgetDetailSleepActive
            : _durLabel(l, s.endedAt!.difference(s.startedAt).inSeconds);
        candidates.add(WidgetRecord(
          label: l.widgetLabelSleep, detail: detail, time: s.startedAt,
          colorCategory: 'sleep'));
      }

      for (final t in recentTemps) {
        candidates.add(WidgetRecord(
          label: l.widgetLabelTemperature,
          detail: '${t.celsius.toStringAsFixed(1)}°C',
          time: t.occurredAt,
          colorCategory: 'temperature',
        ));
      }

      candidates.sort((a, b) => b.time.compareTo(a.time));
      final records = candidates.take(3).toList();

      // ── 오늘 총량 ─────────────────────────────────────────────────
      final results2 = await Future.wait([
        feedingRepo.getDailyFormulaTotalMl(babyId, today),  // 0
        feedingRepo.getDailyPumpedTotalMl(babyId, today),   // 1
        feedingRepo.getDailyBabyFoodTotalMl(babyId, today), // 2
        feedingRepo.getDailyBreastTotalSec(babyId, today),  // 3
        diaperRepo.getTodayDiaperCount(babyId),             // 4
        sleepRepo.getTodaySleepTotal(babyId).then(          // 5
            (d) => d.inMinutes),
      ]);

      // ── per-baby 키 push ──────────────────────────────────────────
      await WidgetSyncService.pushForBaby(
        babyId: babyId,
        babyName: baby.name,
        recentRecords: records,
        formulaMl:   results2[0],
        pumpedMl:    results2[1],
        babyFoodMl:  results2[2],
        breastSec:   results2[3],
        diaperCount: results2[4],
        sleepMin:    results2[5],
        formatHm:     (h, m) => l.widgetDurationHm(h, m),
        formatMin:    (m) => l.widgetDurationMin(m),
        formatDiaper: (n) => l.widgetDiaperCount(n),
      );

      // 선택된 아기(= orderedBabies 첫 번째) push 완료 즉시 위젯 갱신 → 0ml 깜빡임 최소화
      if (!firstPushDone) {
        firstPushDone = true;
        WidgetSyncService.triggerUpdate();
      }

      // 선택된 아기 → 글로벌 fallback 키에 사용
      if (babyId == firstBabyId) {
        globalRecords          = records;
        globalLastFeedingLabel = lastFeedingLabel;
        globalLastFeedingTime  = lastFeedingTime;
        for (int i = 0; i < 6; i++) { globalResults2[i] = results2[i]; }
      }
    } catch (_) {
      // 한 아기 실패가 나머지에 영향 안 줌
    }
  }

  // ── 공유/글로벌 키 push (per-baby 키가 모두 write된 뒤) ────────────
  final selectedIdx = allBabies.indexWhere((b) => b.id == (selectedBaby?.id ?? ''));
  await Future.wait([
    WidgetSyncService.pushTodayTotalsLocalized(
      formulaMl:   globalResults2[0],
      pumpedMl:    globalResults2[1],
      babyFoodMl:  globalResults2[2],
      breastSec:   globalResults2[3],
      diaperCount: globalResults2[4],
      sleepMin:    globalResults2[5],
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
    WidgetSyncService.pushBabyContext(
      babies: allBabies.map((b) => (id: b.id, familyId: b.familyId, name: b.name)).toList(),
      selectedIndex: selectedIdx < 0 ? 0 : selectedIdx,
    ),
  ]);
  // push()는 글로벌 r1/r2/r3 + lastFeeding 저장 후 _update()를 호출한다.
  // 위 await 완료 후 실행되므로 per-baby 키는 이미 기록 완료 상태.
  unawaited(WidgetSyncService.push(
    recentRecords: globalRecords,
    lastFeedingLabel: globalLastFeedingLabel,
    lastFeedingTime: globalLastFeedingTime,
  ));
}

String _durLabel(AppLocalizations l, int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  return h > 0 ? l.widgetDurationHm(h, m) : l.widgetDurationMin(m);
}
