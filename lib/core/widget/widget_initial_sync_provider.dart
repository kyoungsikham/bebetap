import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/database_provider.dart';
import '../../features/baby/presentation/providers/baby_provider.dart';
import 'widget_sync_service.dart';

/// 앱 시작 시 DB의 오늘 데이터를 위젯(UserDefaults)에 일괄 동기화하는 provider.
///
/// [selectedBabyProvider]가 준비되면 자동으로 실행된다.
/// app.dart의 build 메서드에서 ref.listen으로 구독하여 provider를 활성화한다.
final widgetInitialSyncProvider = FutureProvider<void>((ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return;

  final db = ref.read(appDatabaseProvider);
  final babyId = baby.id;
  final now = DateTime.now();

  // 모든 위젯 데이터 병렬 조회
  final results = await Future.wait([
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'formula'),   // 0
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'breast'),    // 1
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'pumped'),    // 2
    db.feedingDao.getLastFeedingByBabyAndType(babyId, 'baby_food'), // 3
    db.diaperDao.getLastDiaper(babyId),                             // 4
    db.temperatureDao.getLastTemperature(babyId),                   // 5
    db.feedingDao.getDailyFormulaTotalMl(babyId, now),              // 6
    db.feedingDao.getDailyPumpedTotalMl(babyId, now),               // 7
    db.feedingDao.getDailyBabyFoodTotalMl(babyId, now),             // 8
    db.diaperDao.getTodayDiaperCount(babyId),                       // 9
    db.sleepDao.getTodaySleepTotal(babyId),                         // 10
    db.sleepDao.watchActiveSleep(babyId).first,                     // 11
  ]);

  final lastFormula   = results[0];
  final lastBreast    = results[1];
  final lastPumped    = results[2];
  final lastBabyFood  = results[3];
  final lastDiaper    = results[4];
  final lastTemp      = results[5];
  final formulaTotal  = results[6] as int;
  final pumpedTotal   = results[7] as int;
  final babyFoodTotal = results[8] as int;
  final diaperCount   = results[9] as int;
  final sleepTotal    = results[10] as Duration;
  final activeSleep   = results[11];

  unawaited(WidgetSyncService.pushInitialData(
    lastFormulaTime:  (lastFormula  as dynamic)?.startedAt  as DateTime?,
    formulaTotalMl:   formulaTotal,
    lastBreastTime:   (lastBreast   as dynamic)?.startedAt  as DateTime?,
    lastPumpedTime:   (lastPumped   as dynamic)?.startedAt  as DateTime?,
    pumpedTotalMl:    pumpedTotal,
    lastBabyFoodTime: (lastBabyFood as dynamic)?.startedAt  as DateTime?,
    babyFoodTotalMl:  babyFoodTotal,
    lastDiaperType:   (lastDiaper   as dynamic)?.type       as String? ?? '',
    diaperCountToday: diaperCount,
    sleepActive:      activeSleep != null,
    sleepStartTime:   (activeSleep  as dynamic)?.startedAt  as DateTime?,
    todaySleepMin:    sleepTotal.inMinutes,
    lastTempCelsius:  (lastTemp     as dynamic)?.celsius     as double? ?? 0,
    lastTempTime:     (lastTemp     as dynamic)?.occurredAt  as DateTime?,
  ));
});
