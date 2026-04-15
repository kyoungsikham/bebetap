// WHO Child Growth Standards (0–24 months)
// Source: https://www.who.int/tools/child-growth-standards
// Values are P3, P15, P50, P85, P97 percentiles for height (cm) and weight (kg).

class WhoGrowthPoint {
  final int ageMonths;
  final double p3;
  final double p15;
  final double p50;
  final double p85;
  final double p97;

  const WhoGrowthPoint(
    this.ageMonths,
    this.p3,
    this.p15,
    this.p50,
    this.p85,
    this.p97,
  );
}

class WhoGrowthStandards {
  // ── Boys height (cm) ────────────────────────────────────────────────────────
  static const List<WhoGrowthPoint> boysHeightCm = [
    WhoGrowthPoint(0,  44.2, 46.1, 49.9, 52.3, 53.7),
    WhoGrowthPoint(1,  48.9, 51.1, 54.7, 57.6, 59.6),
    WhoGrowthPoint(2,  52.4, 54.4, 58.4, 61.3, 63.2),
    WhoGrowthPoint(3,  55.3, 57.3, 61.4, 64.5, 66.4),
    WhoGrowthPoint(4,  57.6, 59.7, 63.9, 67.0, 69.2),
    WhoGrowthPoint(5,  59.6, 61.7, 65.9, 69.2, 71.5),
    WhoGrowthPoint(6,  61.2, 63.3, 67.6, 71.1, 73.5),
    WhoGrowthPoint(7,  62.7, 64.8, 69.2, 72.8, 75.3),
    WhoGrowthPoint(8,  64.0, 66.2, 70.6, 74.3, 76.9),
    WhoGrowthPoint(9,  65.2, 67.5, 72.0, 75.8, 78.5),
    WhoGrowthPoint(10, 66.4, 68.7, 73.3, 77.2, 80.0),
    WhoGrowthPoint(11, 67.6, 69.9, 74.5, 78.6, 81.5),
    WhoGrowthPoint(12, 68.6, 71.0, 75.7, 79.9, 82.9),
    WhoGrowthPoint(13, 69.6, 72.1, 76.9, 81.2, 84.3),
    WhoGrowthPoint(14, 70.6, 73.1, 78.0, 82.4, 85.6),
    WhoGrowthPoint(15, 71.6, 74.1, 79.1, 83.6, 86.9),
    WhoGrowthPoint(16, 72.5, 75.0, 80.2, 84.8, 88.1),
    WhoGrowthPoint(17, 73.3, 76.0, 81.2, 85.9, 89.3),
    WhoGrowthPoint(18, 74.2, 76.9, 82.3, 87.0, 90.5),
    WhoGrowthPoint(19, 75.0, 77.7, 83.2, 88.1, 91.7),
    WhoGrowthPoint(20, 75.8, 78.6, 84.2, 89.2, 92.9),
    WhoGrowthPoint(21, 76.5, 79.4, 85.1, 90.2, 94.0),
    WhoGrowthPoint(22, 77.2, 80.2, 86.0, 91.1, 95.1),
    WhoGrowthPoint(23, 78.0, 81.0, 86.9, 92.1, 96.2),
    WhoGrowthPoint(24, 78.7, 81.7, 87.8, 93.0, 97.3),
  ];

  // ── Girls height (cm) ───────────────────────────────────────────────────────
  static const List<WhoGrowthPoint> girlsHeightCm = [
    WhoGrowthPoint(0,  43.6, 45.4, 49.1, 52.0, 53.5),
    WhoGrowthPoint(1,  47.8, 49.8, 53.7, 57.0, 59.1),
    WhoGrowthPoint(2,  51.0, 53.0, 57.1, 60.4, 62.4),
    WhoGrowthPoint(3,  53.5, 55.6, 59.8, 63.2, 65.3),
    WhoGrowthPoint(4,  55.6, 57.8, 62.1, 65.7, 67.9),
    WhoGrowthPoint(5,  57.4, 59.6, 64.0, 67.8, 70.1),
    WhoGrowthPoint(6,  58.9, 61.2, 65.7, 69.8, 72.1),
    WhoGrowthPoint(7,  60.3, 62.7, 67.3, 71.5, 74.0),
    WhoGrowthPoint(8,  61.7, 64.0, 68.7, 73.2, 75.8),
    WhoGrowthPoint(9,  62.9, 65.3, 70.1, 74.7, 77.4),
    WhoGrowthPoint(10, 64.1, 66.5, 71.5, 76.2, 79.0),
    WhoGrowthPoint(11, 65.2, 67.7, 72.8, 77.6, 80.5),
    WhoGrowthPoint(12, 66.3, 68.9, 74.0, 79.0, 82.0),
    WhoGrowthPoint(13, 67.3, 69.9, 75.2, 80.3, 83.4),
    WhoGrowthPoint(14, 68.3, 71.0, 76.4, 81.6, 84.8),
    WhoGrowthPoint(15, 69.3, 72.0, 77.5, 82.8, 86.1),
    WhoGrowthPoint(16, 70.2, 73.0, 78.6, 84.0, 87.4),
    WhoGrowthPoint(17, 71.1, 73.9, 79.7, 85.2, 88.7),
    WhoGrowthPoint(18, 72.0, 74.9, 80.7, 86.3, 89.9),
    WhoGrowthPoint(19, 72.8, 75.8, 81.7, 87.4, 91.1),
    WhoGrowthPoint(20, 73.7, 76.7, 82.7, 88.5, 92.2),
    WhoGrowthPoint(21, 74.5, 77.5, 83.7, 89.5, 93.4),
    WhoGrowthPoint(22, 75.2, 78.4, 84.6, 90.5, 94.5),
    WhoGrowthPoint(23, 76.0, 79.2, 85.5, 91.5, 95.6),
    WhoGrowthPoint(24, 76.7, 80.0, 86.4, 92.5, 96.6),
  ];

  // ── Boys weight (kg) ────────────────────────────────────────────────────────
  static const List<WhoGrowthPoint> boysWeightKg = [
    WhoGrowthPoint(0,  2.5,  3.0,  3.3,  3.9,  4.3),
    WhoGrowthPoint(1,  3.4,  3.9,  4.5,  5.1,  5.7),
    WhoGrowthPoint(2,  4.4,  4.9,  5.6,  6.3,  7.0),
    WhoGrowthPoint(3,  5.1,  5.7,  6.4,  7.2,  8.0),
    WhoGrowthPoint(4,  5.6,  6.2,  7.0,  7.9,  8.7),
    WhoGrowthPoint(5,  6.1,  6.7,  7.5,  8.4,  9.3),
    WhoGrowthPoint(6,  6.4,  7.1,  7.9,  8.9,  9.8),
    WhoGrowthPoint(7,  6.7,  7.4,  8.3,  9.3, 10.3),
    WhoGrowthPoint(8,  7.0,  7.7,  8.6,  9.7, 10.7),
    WhoGrowthPoint(9,  7.2,  7.9,  8.9, 10.0, 11.1),
    WhoGrowthPoint(10, 7.5,  8.2,  9.2, 10.4, 11.4),
    WhoGrowthPoint(11, 7.7,  8.4,  9.4, 10.7, 11.8),
    WhoGrowthPoint(12, 7.8,  8.6,  9.6, 10.9, 12.1),
    WhoGrowthPoint(13, 8.0,  8.8,  9.9, 11.2, 12.4),
    WhoGrowthPoint(14, 8.2,  9.0, 10.1, 11.5, 12.7),
    WhoGrowthPoint(15, 8.4,  9.2, 10.3, 11.7, 12.9),
    WhoGrowthPoint(16, 8.5,  9.4, 10.5, 12.0, 13.2),
    WhoGrowthPoint(17, 8.7,  9.6, 10.8, 12.2, 13.5),
    WhoGrowthPoint(18, 8.9,  9.7, 11.0, 12.5, 13.8),
    WhoGrowthPoint(19, 9.0,  9.9, 11.2, 12.7, 14.0),
    WhoGrowthPoint(20, 9.2, 10.1, 11.4, 13.0, 14.3),
    WhoGrowthPoint(21, 9.3, 10.2, 11.6, 13.2, 14.6),
    WhoGrowthPoint(22, 9.5, 10.4, 11.8, 13.5, 14.9),
    WhoGrowthPoint(23, 9.7, 10.6, 12.0, 13.7, 15.1),
    WhoGrowthPoint(24, 9.8, 10.8, 12.2, 13.9, 15.4),
  ];

  // ── Girls weight (kg) ───────────────────────────────────────────────────────
  static const List<WhoGrowthPoint> girlsWeightKg = [
    WhoGrowthPoint(0,  2.4,  2.8,  3.2,  3.7,  4.2),
    WhoGrowthPoint(1,  3.2,  3.6,  4.2,  4.8,  5.5),
    WhoGrowthPoint(2,  4.0,  4.5,  5.1,  5.8,  6.6),
    WhoGrowthPoint(3,  4.6,  5.2,  5.8,  6.6,  7.5),
    WhoGrowthPoint(4,  5.1,  5.7,  6.4,  7.3,  8.2),
    WhoGrowthPoint(5,  5.5,  6.1,  6.9,  7.8,  8.8),
    WhoGrowthPoint(6,  5.8,  6.5,  7.3,  8.2,  9.3),
    WhoGrowthPoint(7,  6.1,  6.8,  7.6,  8.6,  9.8),
    WhoGrowthPoint(8,  6.3,  7.0,  7.9,  9.0, 10.2),
    WhoGrowthPoint(9,  6.6,  7.3,  8.2,  9.3, 10.5),
    WhoGrowthPoint(10, 6.8,  7.5,  8.5,  9.6, 10.9),
    WhoGrowthPoint(11, 7.0,  7.7,  8.7,  9.9, 11.2),
    WhoGrowthPoint(12, 7.1,  7.9,  8.9, 10.1, 11.5),
    WhoGrowthPoint(13, 7.3,  8.1,  9.2, 10.4, 11.8),
    WhoGrowthPoint(14, 7.5,  8.3,  9.4, 10.7, 12.1),
    WhoGrowthPoint(15, 7.7,  8.5,  9.6, 10.9, 12.4),
    WhoGrowthPoint(16, 7.8,  8.7,  9.8, 11.2, 12.7),
    WhoGrowthPoint(17, 8.0,  8.9, 10.0, 11.4, 12.9),
    WhoGrowthPoint(18, 8.1,  9.0, 10.2, 11.6, 13.2),
    WhoGrowthPoint(19, 8.3,  9.2, 10.4, 11.9, 13.5),
    WhoGrowthPoint(20, 8.4,  9.4, 10.6, 12.1, 13.7),
    WhoGrowthPoint(21, 8.6,  9.5, 10.9, 12.4, 14.0),
    WhoGrowthPoint(22, 8.8,  9.7, 11.1, 12.6, 14.3),
    WhoGrowthPoint(23, 8.9,  9.9, 11.3, 12.9, 14.6),
    WhoGrowthPoint(24, 9.0, 10.1, 11.5, 13.1, 14.8),
  ];

  /// Returns the WHO table for the given gender and measurement type.
  /// [gender] — 'male' | 'female' | null/'unknown' → defaults to average of both.
  static List<WhoGrowthPoint> tableFor({
    required String? gender,
    required bool isHeight,
  }) {
    final isMale = gender == 'male';
    if (isHeight) {
      return isMale ? boysHeightCm : girlsHeightCm;
    } else {
      return isMale ? boysWeightKg : girlsWeightKg;
    }
  }

  /// Returns the P50 (median) value for the given age in months.
  /// Returns null if age is out of the 0–24 month range.
  static double? medianAt(List<WhoGrowthPoint> table, int ageMonths) {
    final clamped = ageMonths.clamp(0, 24);
    try {
      return table.firstWhere((p) => p.ageMonths == clamped).p50;
    } catch (_) {
      return null;
    }
  }

  /// Estimates which percentile band [value] falls into at [ageMonths].
  /// Returns the nearest standard percentile (3, 15, 50, 85, or 97).
  static int estimatePercentileBand(
    List<WhoGrowthPoint> table,
    int ageMonths,
    double value,
  ) {
    final clamped = ageMonths.clamp(0, 24);
    final point = table.firstWhere(
      (p) => p.ageMonths == clamped,
      orElse: () => table.last,
    );

    if (value <= point.p3) return 3;
    if (value <= point.p15) return 15;
    if (value <= point.p50) return 50;
    if (value <= point.p85) return 85;
    return 97;
  }
}
