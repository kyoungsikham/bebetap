import 'package:flutter/foundation.dart';

@immutable
class DailyDiaperEntry {
  const DailyDiaperEntry({
    required this.date,
    required this.wet,
    required this.soiled,
    required this.both,
    required this.dry,
  });

  final DateTime date;
  final int wet;
  final int soiled;
  final int both;
  final int dry;

  int get total => wet + soiled + both + dry;
}

@immutable
class DiaperStats {
  const DiaperStats({
    required this.totalCount,
    required this.wetCount,
    required this.soiledCount,
    required this.bothCount,
    required this.dryCount,
    required this.dailyEntries,
    this.previousTotalCount,
  });

  final int totalCount;
  final int wetCount;
  final int soiledCount;
  final int bothCount;
  final int dryCount;
  final int? previousTotalCount;
  final List<DailyDiaperEntry> dailyEntries;

  double? get deltaPercent {
    final prev = previousTotalCount;
    if (prev == null || prev == 0) return null;
    return (totalCount - prev) / prev * 100;
  }

  static const empty = DiaperStats(
    totalCount: 0,
    wetCount: 0,
    soiledCount: 0,
    bothCount: 0,
    dryCount: 0,
    dailyEntries: [],
  );
}
