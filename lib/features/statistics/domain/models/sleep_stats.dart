import 'package:flutter/foundation.dart';

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
  });

  final Duration totalDuration;
  final Duration? previousTotalDuration;
  final List<DailySleepEntry> dailyEntries;

  double? get deltaPercent {
    final prev = previousTotalDuration;
    if (prev == null || prev.inSeconds == 0) return null;
    return (totalDuration.inSeconds - prev.inSeconds) / prev.inSeconds * 100;
  }

  static const empty = SleepStats(
    totalDuration: Duration.zero,
    dailyEntries: [],
  );
}
