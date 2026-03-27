import '../../../core/database/app_database.dart';
import '../domain/models/feeding_stats.dart';
import '../domain/models/period.dart';
import '../domain/models/sleep_stats.dart';

class StatisticsRepository {
  const StatisticsRepository(this._db);
  final AppDatabase _db;

  Future<SleepStats> getSleepStats(String babyId, Period period) async {
    final (from, to) = period.dateRange;
    final (prevFrom, prevTo) = period.previousDateRange;
    final now = DateTime.now();

    final rows = await _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to);
    final prevRows =
        await _db.sleepDao.getSleepsByBabyAndDate(babyId, prevFrom, prevTo);

    int totalSec = rows.fold(0, (sum, row) {
      final end = row.endedAt ?? now;
      return sum + end.difference(row.startedAt).inSeconds;
    });

    int prevTotalSec = prevRows.fold(0, (sum, row) {
      final end = row.endedAt ?? now;
      return sum + end.difference(row.startedAt).inSeconds;
    });

    final dailyEntries = _buildDailyEntries(rows, from, to, now);

    return SleepStats(
      totalDuration: Duration(seconds: totalSec),
      previousTotalDuration: Duration(seconds: prevTotalSec),
      dailyEntries: dailyEntries,
    );
  }

  List<DailySleepEntry> _buildDailyEntries(
    List<SleepEntriesTableData> rows,
    DateTime from,
    DateTime to,
    DateTime now,
  ) {
    final days = to.difference(from).inDays;
    final entries = <DailySleepEntry>[];

    for (int i = 0; i < days; i++) {
      final date = DateTime(from.year, from.month, from.day + i);
      final nextDate = date.add(const Duration(days: 1));

      final dayRows = rows.where(
        (r) => !r.startedAt.isBefore(date) && r.startedAt.isBefore(nextDate),
      );

      final sec = dayRows.fold<int>(0, (sum, row) {
        final end = row.endedAt ?? now;
        return sum + end.difference(row.startedAt).inSeconds;
      });

      entries.add(DailySleepEntry(date: date, duration: Duration(seconds: sec)));
    }

    return entries;
  }

  Future<FeedingStats> getFeedingStats(String babyId, Period period) async {
    final (from, to) = period.dateRange;
    final (prevFrom, prevTo) = period.previousDateRange;

    final rows =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to);
    final prevRows =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, prevFrom, prevTo);

    final totalFormulaMl = rows
        .where((r) => r.type == 'formula')
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));

    final totalBreastSec = rows
        .where((r) => r.type == 'breast')
        .fold<int>(
          0,
          (sum, r) =>
              sum + (r.durationLeftSec ?? 0) + (r.durationRightSec ?? 0),
        );

    final prevFormulaMl = prevRows
        .where((r) => r.type == 'formula')
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));

    return FeedingStats(
      totalFormulaMl: totalFormulaMl,
      totalBreastSec: totalBreastSec,
      feedingCount: rows.length,
      previousFormulaMl: prevFormulaMl,
    );
  }

  Future<int> getDiaperCount(String babyId, Period period) async {
    final (from, to) = period.dateRange;
    final rows =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to);
    return rows.length;
  }
}
