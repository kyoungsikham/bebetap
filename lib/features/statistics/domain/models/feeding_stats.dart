import 'package:flutter/foundation.dart';

@immutable
class DailyFeedingEntry {
  const DailyFeedingEntry({
    required this.date,
    required this.formulaMl,
    required this.pumpedMl,
    required this.babyFoodMl,
    required this.breastSec,
    required this.count,
  });

  final DateTime date;
  final int formulaMl;
  final int pumpedMl;
  final int babyFoodMl;
  final int breastSec;
  final int count;

  int get totalMl => formulaMl + pumpedMl + babyFoodMl;
}

@immutable
class FeedingStats {
  const FeedingStats({
    required this.totalFormulaMl,
    required this.totalBreastSec,
    required this.feedingCount,
    this.previousFormulaMl,
    this.dailyEntries = const [],
    this.avgIntervalHours,
    this.leftRightRatio,
    this.totalBreastCount = 0,
    this.totalFormulaCount = 0,
    this.totalPumpedMl = 0,
    this.totalBabyFoodMl = 0,
    this.previousBreastSec,
  });

  final int totalFormulaMl;
  final int totalBreastSec;
  final int feedingCount;
  final int? previousFormulaMl;

  /// Daily breakdown for trend chart
  final List<DailyFeedingEntry> dailyEntries;

  /// Average hours between consecutive feedings
  final double? avgIntervalHours;

  /// Left breast ratio (0.0-1.0), null if no breast feeding
  final double? leftRightRatio;

  /// Counts by type
  final int totalBreastCount;
  final int totalFormulaCount;

  /// Other feeding totals
  final int totalPumpedMl;
  final int totalBabyFoodMl;

  /// Previous period breast total for delta
  final int? previousBreastSec;

  Duration get totalBreastDuration => Duration(seconds: totalBreastSec);

  int get totalIntakeMl => totalFormulaMl + totalPumpedMl + totalBabyFoodMl;

  double? get formulaDeltaPercent {
    final prev = previousFormulaMl;
    if (prev == null || prev == 0) return null;
    return (totalFormulaMl - prev) / prev * 100;
  }

  double? get breastDeltaPercent {
    final prev = previousBreastSec;
    if (prev == null || prev == 0) return null;
    return (totalBreastSec - prev) / prev * 100;
  }

  static const empty = FeedingStats(
    totalFormulaMl: 0,
    totalBreastSec: 0,
    feedingCount: 0,
  );
}
