import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/presentation/providers/baby_provider.dart';
import '../../features/diaper/data/diaper_repository_impl.dart';
import '../../features/feeding/data/feeding_repository_impl.dart';
import '../../features/sleep/data/sleep_repository_impl.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'widget_sync_service.dart';

/// 기록 저장 후 어느 Provider에서나 호출해 위젯을 최신 상태로 갱신한다.
Future<void> refreshWidget(Ref ref) => _refreshImpl(ref.read);

/// WidgetRef 환경(widget_action_handler 등)에서 호출하는 버전.
Future<void> refreshWidgetFromWidget(WidgetRef ref) => _refreshImpl(ref.read);

/// 실제 갱신 로직 — Ref.read / WidgetRef.read 모두 동일한 시그니처를 가짐.
Future<void> _refreshImpl(
  T Function<T>(ProviderListenable<T>) read,
) async {
  final baby = read(selectedBabyProvider).valueOrNull;
  if (baby == null) return;

  final db     = read(appDatabaseProvider);
  final babyId = baby.id;
  final today  = DateTime.now();

  final results = await Future.wait([
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'formula'),  // 0
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'breast'),   // 1
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'pumped'),   // 2
    db.feedingDao.getLastFeedingByBaby(babyId),                    // 3
    db.diaperDao.getLastDiaper(babyId),                            // 4
    db.sleepDao.getLastSleep(babyId),                              // 5
    db.temperatureDao.getLastTemperature(babyId),                  // 6
  ]);

  final lastFormula = results[0] as FeedingEntriesTableData?;
  final lastBreast  = results[1] as FeedingEntriesTableData?;
  final lastPumped  = results[2] as FeedingEntriesTableData?;
  final anyFeeding  = results[3] as FeedingEntriesTableData?;
  final lastDiaper  = results[4] as DiaperEntriesTableData?;
  final lastSleep   = results[5] as SleepEntriesTableData?;
  final lastTemp    = results[6] as TemperatureEntriesTableData?;

  // ── 헤더: 분유/모유/유축 중 가장 최근 ─────────────────────────
  String lastFeedingLabel = '';
  DateTime? lastFeedingTime;

  final feedingCandidates = <(String, DateTime)>[
    if (lastFormula != null) ('분유', lastFormula.startedAt),
    if (lastBreast  != null) ('모유', lastBreast.startedAt),
    if (lastPumped  != null) ('유축', lastPumped.startedAt),
  ]..sort((a, b) => b.$2.compareTo(a.$2));

  if (feedingCandidates.isNotEmpty) {
    lastFeedingLabel = feedingCandidates.first.$1;
    lastFeedingTime  = feedingCandidates.first.$2;
  }

  // ── 최근 기록 3건 ─────────────────────────────────────────────
  final candidates = <WidgetRecord>[];

  if (anyFeeding != null) {
    final label = switch (anyFeeding.type) {
      'breast'    => '모유',
      'pumped'    => '유축',
      'baby_food' => '이유식',
      _           => '분유',
    };
    final detail = anyFeeding.type == 'breast'
        ? _durLabel((anyFeeding.durationLeftSec ?? 0) + (anyFeeding.durationRightSec ?? 0))
        : '${anyFeeding.amountMl ?? 0}ml';
    candidates.add(WidgetRecord(label: label, detail: detail, time: anyFeeding.startedAt));
  }

  if (lastDiaper != null) {
    final detail = switch (lastDiaper.type) {
      'wet'    => '소변',
      'soiled' => '대변',
      'both'   => '소변+대변',
      _        => '교체',
    };
    candidates.add(WidgetRecord(label: '기저귀', detail: detail, time: lastDiaper.occurredAt));
  }

  if (lastSleep != null) {
    final isActive = lastSleep.endedAt == null;
    final detail   = isActive
        ? '자는 중'
        : _durLabel(lastSleep.endedAt!.difference(lastSleep.startedAt).inSeconds);
    candidates.add(WidgetRecord(label: '수면', detail: detail, time: lastSleep.startedAt));
  }

  if (lastTemp != null) {
    candidates.add(WidgetRecord(
      label: '체온',
      detail: '${lastTemp.celsius.toStringAsFixed(1)}°C',
      time: lastTemp.occurredAt,
    ));
  }

  candidates.sort((a, b) => b.time.compareTo(a.time));
  final records = candidates.take(3).toList();

  // ── 오늘 총량 ─────────────────────────────────────────────────
  final feedingRepo = FeedingRepository(db);
  final diaperRepo  = DiaperRepository(db);
  final sleepRepo   = SleepRepository(db);

  final results2 = await Future.wait([
    feedingRepo.getDailyFormulaTotalMl(babyId, today),  // 0
    feedingRepo.getDailyPumpedTotalMl(babyId, today),   // 1
    feedingRepo.getDailyBabyFoodTotalMl(babyId, today), // 2
    feedingRepo.getDailyBreastTotalSec(babyId, today),  // 3
    diaperRepo.getTodayDiaperCount(babyId),             // 4
    sleepRepo.getTodaySleepTotal(babyId).then(          // 5
        (d) => d.inMinutes),
  ]);

  unawaited(WidgetSyncService.push(
    recentRecords: records,
    lastFeedingLabel: lastFeedingLabel,
    lastFeedingTime: lastFeedingTime,
  ));
  unawaited(WidgetSyncService.pushTodayTotals(
    formulaMl:   results2[0],
    pumpedMl:    results2[1],
    babyFoodMl:  results2[2],
    breastSec:   results2[3],
    diaperCount: results2[4],
    sleepMin:    results2[5],
  ));
  // 백그라운드 콜백용 아기 컨텍스트 저장
  final allBabies = read(babiesProvider).valueOrNull ?? [];
  final idx = allBabies.indexWhere((b) => b.id == baby.id);
  unawaited(WidgetSyncService.pushBabyContext(
    babies: allBabies.map((b) => (id: b.id, familyId: b.familyId, name: b.name)).toList(),
    selectedIndex: idx < 0 ? 0 : idx,
  ));
}

String _durLabel(int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  if (h > 0) return '$h시간 $m분';
  return '$m분';
}
