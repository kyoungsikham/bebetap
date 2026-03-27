import 'package:flutter/foundation.dart';

@immutable
class FeedingStats {
  const FeedingStats({
    required this.totalFormulaMl,
    required this.totalBreastSec,
    required this.feedingCount,
    this.previousFormulaMl,
  });

  final int totalFormulaMl;
  final int totalBreastSec;
  final int feedingCount;
  final int? previousFormulaMl;

  Duration get totalBreastDuration => Duration(seconds: totalBreastSec);

  double? get formulaDeltaPercent {
    final prev = previousFormulaMl;
    if (prev == null || prev == 0) return null;
    return (totalFormulaMl - prev) / prev * 100;
  }

  static const empty = FeedingStats(
    totalFormulaMl: 0,
    totalBreastSec: 0,
    feedingCount: 0,
  );
}
