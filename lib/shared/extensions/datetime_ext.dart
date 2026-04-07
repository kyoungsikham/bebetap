import '../../l10n/app_localizations.dart';

extension DateTimeExt on DateTime {
  /// 오늘 자정 (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// 오늘인지 여부
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// 날짜+시간 칩 표시용 포맷 (예: "오늘  오전 8:30" / "Today  8:30 AM")
  String formatDisplayLocalized(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dtDay = DateTime(year, month, day);

    String datePart;
    if (dtDay == today) {
      datePart = l10n.today;
    } else if (dtDay == yesterday) {
      datePart = l10n.yesterday;
    } else {
      final weekdays = [
        l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed,
        l10n.weekdayThu, l10n.weekdayFri, l10n.weekdaySat, l10n.weekdaySun,
      ];
      datePart = l10n.dateFormatFull(month, day, weekdays[weekday - 1]);
    }

    final period = hour < 12 ? l10n.am : l10n.pm;
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final timePart = l10n.displayTime(h, minute.toString().padLeft(2, '0'), period);
    return '$datePart  $timePart';
  }

  /// 연도 포함 긴 날짜 포맷 (예: "2025년 4월 7일 (월)" / "4/7/2025 (Mon)")
  String formatLongLocalized(AppLocalizations l10n) {
    final weekdays = [
      l10n.weekdayMon, l10n.weekdayTue, l10n.weekdayWed,
      l10n.weekdayThu, l10n.weekdayFri, l10n.weekdaySat, l10n.weekdaySun,
    ];
    return l10n.dateFormatLong(year, month, day, weekdays[weekday - 1]);
  }
}

extension DurationExt on Duration {
  /// 로케일 기반 기간 포맷 (예: "3h 30m" / "3시간 30분" / "3時間30分")
  String formatLocalized(AppLocalizations l10n) {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;
    if (h == 0 && m == 0) return l10n.durationSeconds(s);
    if (h == 0) return l10n.durationMinutesOnly(m);
    if (m == 0) return l10n.durationHoursOnly(h);
    return l10n.durationHoursMinutes(h, m);
  }

  /// "3h 30m" 형식 (1분 미만은 "17s") — 로케일 무관
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

  /// 로케일 기반 경과 시간 포맷
  String formatElapsedLocalized(AppLocalizations l10n) {
    if (inMinutes < 1) return l10n.elapsedJustNow;
    if (inMinutes < 60) return l10n.elapsedMinutes(inMinutes);
    final h = inHours;
    final m = inMinutes % 60;
    if (m == 0) return l10n.elapsedHoursOnly(h);
    return l10n.elapsedHoursMinutes(h, m);
  }

  /// 한국어 기간 포맷 (레거시 호환 — l10n 없이 호출되는 경우)
  String formatKorean() {
    final h = inHours;
    final m = inMinutes % 60;
    final s = inSeconds % 60;
    if (h == 0 && m == 0) return '$s초';
    if (h == 0) return '$m분';
    if (m == 0) return '$h시간';
    return '$h시간 $m분';
  }

  /// 한국어 경과 시간 포맷 (레거시 호환)
  String formatElapsedKorean() {
    if (inMinutes < 1) return '방금';
    if (inMinutes < 60) return '$inMinutes분 경과';
    final h = inHours;
    final m = inMinutes % 60;
    if (m == 0) return '$h시간 경과';
    return '$h시간 $m분 경과';
  }
}
