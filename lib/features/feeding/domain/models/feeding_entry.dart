import 'package:flutter/foundation.dart';

@immutable
class FeedingEntry {
  const FeedingEntry({
    required this.id,
    required this.babyId,
    required this.familyId,
    required this.type,
    required this.startedAt,
    this.amountMl,
    this.durationLeftSec,
    this.durationRightSec,
    this.endedAt,
    this.notes,
  });

  final String id;
  final String babyId;
  final String familyId;
  final String type; // formula | breast | baby_food
  final int? amountMl;
  final int? durationLeftSec;
  final int? durationRightSec;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? notes;

  Duration get breastDuration => Duration(
        seconds: (durationLeftSec ?? 0) + (durationRightSec ?? 0),
      );
}
