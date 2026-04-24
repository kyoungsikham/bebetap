import 'package:flutter/foundation.dart';

import '../../../sleep/domain/models/sleep_entry.dart';

@immutable
class HomeSummary {
  const HomeSummary({
    this.lastFeedingAt,
    this.lastFeedingType,
    this.lastFeedingAmountMl,
    this.todayFormulaTotalMl = 0,
    this.todayBreastTotalSec = 0,
    this.todayPumpedTotalMl = 0,
    this.todayBabyFoodTotalMl = 0,
    this.todayDiaperCount = 0,
    this.todaySleepTotal = Duration.zero,
    this.activeSleep,
    this.babyWeightKg,
  });

  factory HomeSummary.empty() => const HomeSummary();

  final DateTime? lastFeedingAt;
  final String? lastFeedingType; // formula | breast | pumped
  final int? lastFeedingAmountMl;
  final int todayFormulaTotalMl;
  final int todayBreastTotalSec;
  final int todayPumpedTotalMl;
  final int todayBabyFoodTotalMl;
  final int todayDiaperCount;
  final Duration todaySleepTotal;
  final SleepEntry? activeSleep;
  final double? babyWeightKg;

  int? get formulaDailyTargetMl =>
      babyWeightKg != null ? (babyWeightKg! * 150).toInt() : null;
}
