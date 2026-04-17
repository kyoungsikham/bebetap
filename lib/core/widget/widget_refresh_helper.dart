import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/baby/presentation/providers/baby_provider.dart';
import '../database/app_database.dart';
import '../providers/database_provider.dart';
import 'widget_sync_service.dart';

/// 기록 저장 후 어느 Provider에서나 호출해 위젯을 최신 상태로 갱신한다.
///
/// - recentRecords: 분유/모유/유축/이유식/기저귀/수면/체온 중 가장 최근 3건
/// - lastFeedingLabel: 분유·모유·유축 중 가장 최근에 기록된 항목 표시 (헤더 경과 텍스트)
Future<void> refreshWidget(Ref ref) async {
  final baby = ref.read(selectedBabyProvider).valueOrNull;
  if (baby == null) return;

  final db = ref.read(appDatabaseProvider);
  final babyId = baby.id;

  final results = await Future.wait([
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'formula'),  // 0
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'breast'),   // 1
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'pumped'),   // 2
    db.feedingDao.getLastFeedingByBaby(babyId),                    // 3 (모든 수유 중 최근)
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

  // ── 헤더: 분유/모유/유축 중 가장 최근 ──────────────────────────
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

  // ── 최근 기록 3건 ──────────────────────────────────────────────
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
    final detail = isActive
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

  unawaited(WidgetSyncService.push(
    recentRecords: records,
    lastFeedingLabel: lastFeedingLabel,
    lastFeedingTime: lastFeedingTime,
  ));
}

String _durLabel(int totalSec) {
  final h = totalSec ~/ 3600;
  final m = (totalSec % 3600) ~/ 60;
  if (h > 0) return '$h시간 $m분';
  return '$m분';
}
