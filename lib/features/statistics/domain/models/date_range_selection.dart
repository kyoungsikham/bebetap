import 'package:flutter/foundation.dart';

enum DateRangePreset { day, week, month, custom }

@immutable
class DateRangeSelection {
  const DateRangeSelection._({
    required this.preset,
    required this.from,
    required this.to,
  });

  final DateRangePreset preset;
  final DateTime from;
  final DateTime to;

  factory DateRangeSelection.day([DateTime? date]) {
    final d = date ?? DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return DateRangeSelection._(
      preset: DateRangePreset.day,
      from: today,
      to: today.add(const Duration(days: 1)),
    );
  }

  factory DateRangeSelection.week([DateTime? endDate]) {
    final d = endDate ?? DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return DateRangeSelection._(
      preset: DateRangePreset.week,
      from: today.subtract(const Duration(days: 6)),
      to: today.add(const Duration(days: 1)),
    );
  }

  factory DateRangeSelection.month([DateTime? endDate]) {
    final d = endDate ?? DateTime.now();
    final today = DateTime(d.year, d.month, d.day);
    return DateRangeSelection._(
      preset: DateRangePreset.month,
      from: today.subtract(const Duration(days: 29)),
      to: today.add(const Duration(days: 1)),
    );
  }

  factory DateRangeSelection.custom(DateTime from, DateTime to) {
    final start = DateTime(from.year, from.month, from.day);
    var end = DateTime(to.year, to.month, to.day).add(const Duration(days: 1));
    // Max 180 days (6 months)
    if (end.difference(start).inDays > 180) {
      end = start.add(const Duration(days: 180));
    }
    return DateRangeSelection._(
      preset: DateRangePreset.custom,
      from: start,
      to: end,
    );
  }

  int get days => to.difference(from).inDays;

  (DateTime, DateTime) get previousRange {
    final duration = to.difference(from);
    return (from.subtract(duration), from);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeSelection &&
          preset == other.preset &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(preset, from, to);
}
