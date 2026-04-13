import 'package:flutter/material.dart';

@immutable
class DailySleepEntry {
  const DailySleepEntry({required this.date, required this.duration});
  final DateTime date;
  final Duration duration;
}

@immutable
class SleepStats {
  const SleepStats({
    required this.totalDuration,
    required this.dailyEntries,
    this.previousTotalDuration,
    this.napTotal = Duration.zero,
    this.nightTotal = Duration.zero,
    this.longestConsecutive = Duration.zero,
    this.bedtimes = const [],
    this.waketimes = const [],
    this.ageRecommendedMin,
    this.ageRecommendedMax,
  });

  final Duration totalDuration;
  final Duration? previousTotalDuration;
  final List<DailySleepEntry> dailyEntries;

  /// Nap sleep total (started between 6:00-19:59)
  final Duration napTotal;

  /// Night sleep total (started between 20:00-5:59)
  final Duration nightTotal;

  /// Longest uninterrupted sleep session in the period
  final Duration longestConsecutive;

  /// Bedtimes (night sleep start times) for consistency analysis
  final List<TimeOfDay> bedtimes;

  /// Wake times (night sleep end times) for consistency analysis
  final List<TimeOfDay> waketimes;

  /// Age-recommended daily sleep hours range (WHO/AAP)
  final double? ageRecommendedMin;
  final double? ageRecommendedMax;

  double? get deltaPercent {
    final prev = previousTotalDuration;
    if (prev == null || prev.inSeconds == 0) return null;
    return (totalDuration.inSeconds - prev.inSeconds) / prev.inSeconds * 100;
  }

  /// Average daily sleep for the period
  double get avgDailyHours {
    if (dailyEntries.isEmpty) return 0;
    final totalHours = totalDuration.inMinutes / 60.0;
    return totalHours / dailyEntries.length;
  }

  /// Bedtime consistency score (0.0 = inconsistent, 1.0 = perfectly consistent)
  double? get bedtimeConsistency {
    if (bedtimes.length < 2) return null;
    final minutes = bedtimes.map((t) => t.hour * 60 + t.minute).toList();
    // Adjust for crossing midnight
    final adjusted = minutes.map((m) => m < 360 ? m + 1440 : m).toList();
    final mean = adjusted.reduce((a, b) => a + b) / adjusted.length;
    final variance =
        adjusted.map((m) => (m - mean) * (m - mean)).reduce((a, b) => a + b) /
            adjusted.length;
    final stdDev = variance > 0 ? _sqrt(variance) : 0.0;
    // 0 stdDev = 1.0 score, 120min stdDev = 0.0 score
    return (1.0 - (stdDev / 120.0)).clamp(0.0, 1.0);
  }

  static double _sqrt(double value) {
    if (value <= 0) return 0;
    double x = value;
    for (int i = 0; i < 20; i++) {
      x = (x + value / x) / 2;
    }
    return x;
  }

  static const empty = SleepStats(
    totalDuration: Duration.zero,
    dailyEntries: [],
  );
}
