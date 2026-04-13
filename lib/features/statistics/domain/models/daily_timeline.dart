import 'package:flutter/foundation.dart';

enum TimelineEventType { sleep, formula, breast, pumped, babyFood, diaper }

@immutable
class TimelineEvent {
  const TimelineEvent({
    required this.type,
    required this.start,
    required this.end,
    this.subType,
  });

  final TimelineEventType type;
  final DateTime start;
  final DateTime end;
  final String? subType;
}

@immutable
class DayTimeline {
  const DayTimeline({
    required this.date,
    required this.events,
  });

  final DateTime date;
  final List<TimelineEvent> events;
}

@immutable
class TimelineData {
  const TimelineData({required this.days});

  final List<DayTimeline> days;

  static const empty = TimelineData(days: []);
}
