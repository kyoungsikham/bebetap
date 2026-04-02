import 'package:flutter/foundation.dart';

import '../../../../core/database/app_database.dart';
import '../domain/models/home_summary.dart';
import '../../sleep/data/sleep_repository_impl.dart';
import '../../feeding/data/feeding_repository_impl.dart';
import '../../diaper/data/diaper_repository_impl.dart';

class HomeRepository {
  HomeRepository(this._db);

  final AppDatabase _db;

  Future<HomeSummary> getSummary(
    String babyId, {
    double? babyWeightKg,
  }) async {
    final feedingRepo = FeedingRepository(_db);
    final diaperRepo = DiaperRepository(_db);
    final sleepRepo = SleepRepository(_db);

    final results = await Future.wait([
      feedingRepo.getLastFeeding(babyId),
      feedingRepo.getDailyFormulaTotalMl(babyId, DateTime.now()),
      feedingRepo.getDailyPumpedTotalMl(babyId, DateTime.now()),
      feedingRepo.getDailyBabyFoodTotalMl(babyId, DateTime.now()),
      diaperRepo.getTodayDiaperCount(babyId),
      sleepRepo.getTodaySleepTotal(babyId),
    ]);

    final lastFeeding = results[0] as dynamic;
    debugPrint('[HomeSummary] lastFeeding.startedAt: ${lastFeeding?.startedAt}, now: ${DateTime.now()}');
    final formulaTotal = results[1] as int;
    final pumpedTotal = results[2] as int;
    final babyFoodTotal = results[3] as int;
    final diaperCount = results[4] as int;
    final sleepTotal = results[5] as Duration;

    // Active sleep is fetched separately via stream (watchActiveSleep)
    return HomeSummary(
      lastFeedingAt: lastFeeding?.startedAt as DateTime?,
      lastFeedingType: lastFeeding?.type as String?,
      lastFeedingAmountMl: lastFeeding?.amountMl as int?,
      todayFormulaTotalMl: formulaTotal,
      todayPumpedTotalMl: pumpedTotal,
      todayBabyFoodTotalMl: babyFoodTotal,
      todayDiaperCount: diaperCount,
      todaySleepTotal: sleepTotal,
      babyWeightKg: babyWeightKg,
    );
  }
}
