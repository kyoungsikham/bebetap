import 'package:flutter/foundation.dart';

@immutable
class BabyComparisonData {
  const BabyComparisonData({
    required this.babyId,
    required this.babyName,
    required this.ageInDays,
    required this.totalSleepMinutes,
    required this.totalFeedingMl,
    required this.totalDiaperCount,
    this.weightKg,
  });

  final String babyId;
  final String babyName;
  final int ageInDays;
  final int totalSleepMinutes;
  final int totalFeedingMl;
  final int totalDiaperCount;
  final double? weightKg;
}

@immutable
class ComparisonResult {
  const ComparisonResult({
    required this.targetAgeDays,
    required this.babies,
  });

  final int targetAgeDays;
  final List<BabyComparisonData> babies;
}
