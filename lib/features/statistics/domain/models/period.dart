import '../../../../l10n/app_localizations.dart';

enum Period { day, week, month }

extension PeriodExt on Period {
  String get label {
    switch (this) {
      case Period.day:
        return '오늘';
      case Period.week:
        return '주간';
      case Period.month:
        return '월간';
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      Period.day => l10n.periodDay,
      Period.week => l10n.periodWeek,
      Period.month => l10n.periodMonth,
    };
  }

  /// (from, to) — from: inclusive, to: exclusive
  (DateTime, DateTime) get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (this) {
      case Period.day:
        return (today, today.add(const Duration(days: 1)));
      case Period.week:
        return (
          today.subtract(const Duration(days: 6)),
          today.add(const Duration(days: 1)),
        );
      case Period.month:
        return (
          today.subtract(const Duration(days: 29)),
          today.add(const Duration(days: 1)),
        );
    }
  }

  (DateTime, DateTime) get previousDateRange {
    final (from, to) = dateRange;
    final duration = to.difference(from);
    return (from.subtract(duration), from);
  }

  int get days {
    switch (this) {
      case Period.day:
        return 1;
      case Period.week:
        return 7;
      case Period.month:
        return 30;
    }
  }
}
