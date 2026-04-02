extension DateTimeExt on DateTime {
  /// 오늘 자정 (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// 오늘인지 여부
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension DurationExt on Duration {
  /// "3시간 30분" 형식 (1분 미만은 "17초")
  String formatKorean() {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;
    if (h == 0 && m == 0) return '$s초';
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  /// "3h 30m" 형식 (1분 미만은 "17s")
  String formatHhMm() {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;
    if (h == 0 && m == 0) return '${s}s';
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// "03:30" 형식 (스탑워치용)
  String formatMmSs() {
    final m = inMinutes;
    final s = inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// 경과 시간 한국어 레이블
  String formatElapsedKorean() {
    if (inMinutes < 1) return '방금';
    if (inMinutes < 60) return '$inMinutes분 경과';
    final h = inHours;
    final m = inMinutes % 60;
    if (m == 0) return '$h시간 경과';
    return '$h시간 $m분 경과';
  }
}
