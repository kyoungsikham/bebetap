import 'package:flutter/foundation.dart';

@immutable
class SleepEntry {
  const SleepEntry({
    required this.id,
    required this.babyId,
    required this.familyId,
    required this.startedAt,
    this.endedAt,
    this.quality,
  });

  final String id;
  final String babyId;
  final String familyId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? quality; // good | fair | poor

  bool get isActive => endedAt == null;

  Duration get duration =>
      (endedAt ?? DateTime.now()).difference(startedAt);
}
