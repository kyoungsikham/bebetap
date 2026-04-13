import 'package:flutter/foundation.dart';

@immutable
class DailyTemperatureEntry {
  const DailyTemperatureEntry({
    required this.date,
    required this.avgCelsius,
    required this.maxCelsius,
    required this.count,
  });

  final DateTime date;
  final double avgCelsius;
  final double maxCelsius;
  final int count;
}

@immutable
class TemperatureStats {
  const TemperatureStats({
    required this.latestCelsius,
    required this.avgCelsius,
    required this.maxCelsius,
    required this.minCelsius,
    required this.measurementCount,
    required this.dailyEntries,
  });

  final double? latestCelsius;
  final double? avgCelsius;
  final double? maxCelsius;
  final double? minCelsius;
  final int measurementCount;
  final List<DailyTemperatureEntry> dailyEntries;

  bool get hasFever => (latestCelsius ?? 0) >= 37.5;

  static const empty = TemperatureStats(
    latestCelsius: null,
    avgCelsius: null,
    maxCelsius: null,
    minCelsius: null,
    measurementCount: 0,
    dailyEntries: [],
  );
}
