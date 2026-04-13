import 'package:flutter/foundation.dart';

@immutable
class HourlyActivity {
  const HourlyActivity({
    required this.hour,
    required this.feedingCount,
    required this.sleepMinutes,
    required this.diaperCount,
  });

  final int hour;
  final double feedingCount; // daily average
  final double sleepMinutes; // daily average minutes
  final double diaperCount; // daily average

  static const zero = HourlyActivity(
    hour: 0,
    feedingCount: 0,
    sleepMinutes: 0,
    diaperCount: 0,
  );
}

@immutable
class HeatmapData {
  const HeatmapData({required this.hours});

  final List<HourlyActivity> hours; // 24 entries, index = hour (0-23)

  static final empty = HeatmapData(
    hours: List.generate(
      24,
      (i) => HourlyActivity(hour: i, feedingCount: 0, sleepMinutes: 0, diaperCount: 0),
    ),
  );
}
