import '../../../core/database/app_database.dart';
import '../domain/models/timeline_entry.dart';

class LogRepository {
  LogRepository(this._db);

  final AppDatabase _db;

  Future<List<TimelineEntry>> getTimelineForDate(
    String babyId,
    DateTime date,
  ) async {
    final from = DateTime(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 1));

    final results = await Future.wait([
      _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to),
      _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to),
      _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to),
      _db.temperatureDao.getTemperaturesByBabyAndDate(babyId, from, to),
      _db.diaryDao.getDiariesByBabyAndDate(babyId, from, to),
    ]);

    final feedings = results[0] as List<FeedingEntriesTableData>;
    final sleeps = results[1] as List<SleepEntriesTableData>;
    final diapers = results[2] as List<DiaperEntriesTableData>;
    final temps = results[3] as List<TemperatureEntriesTableData>;
    final diaries = results[4] as List<DiaryEntriesTableData>;

    final entries = <TimelineEntry>[
      ...feedings.map(TimelineEntry.fromFeedingRow),
      ...sleeps.map(TimelineEntry.fromSleepRow),
      ...diapers.map(TimelineEntry.fromDiaperRow),
      ...temps.map(TimelineEntry.fromTemperatureRow),
      ...diaries.map(TimelineEntry.fromDiaryRow),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

    return entries;
  }

  Future<void> deleteEntry(TimelineEntry entry) {
    return switch (entry.type) {
      TimelineEntryType.formula ||
      TimelineEntryType.breast ||
      TimelineEntryType.pumped ||
      TimelineEntryType.babyFood =>
        _db.feedingDao.softDeleteFeeding(entry.id),
      TimelineEntryType.sleep => _db.sleepDao.softDeleteSleep(entry.id),
      TimelineEntryType.diaper => _db.diaperDao.softDeleteDiaper(entry.id),
      TimelineEntryType.temperature =>
        _db.temperatureDao.softDeleteTemperature(entry.id),
      TimelineEntryType.diary => _db.diaryDao.softDeleteDiary(entry.id),
    };
  }

  Future<LogDaySummary> getDaySummary(
    String babyId,
    DateTime date,
  ) async {
    final from = DateTime(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 1));

    final results = await Future.wait([
      _db.feedingDao.getDailyFormulaTotalMl(babyId, date),
      _db.feedingDao.getDailyPumpedTotalMl(babyId, date),
      _db.feedingDao.getDailyBabyFoodTotalMl(babyId, date),
      _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to),
      _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to),
      _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to),
      _db.temperatureDao.getTemperaturesByBabyAndDate(babyId, from, to),
      _db.diaryDao.getDiaryCountForDate(babyId, date),
    ]);

    final formulaTotalMl = results[0] as int;
    final pumpedTotalMl = results[1] as int;
    final babyFoodTotalMl = results[2] as int;
    final feedings = results[3] as List<FeedingEntriesTableData>;
    final diapers = results[4] as List<DiaperEntriesTableData>;
    final sleeps = results[5] as List<SleepEntriesTableData>;
    final temps = results[6] as List<TemperatureEntriesTableData>;
    final diaryCount = results[7] as int;

    // 모유 총 시간 (초)
    final breastTotalSec = feedings
        .where((f) => f.type == 'breast')
        .fold<int>(
          0,
          (sum, f) => sum + (f.durationLeftSec ?? 0) + (f.durationRightSec ?? 0),
        );

    // 수면 총 시간
    final sleepTotal = sleeps.fold<Duration>(Duration.zero, (sum, s) {
      final end = s.endedAt ?? DateTime.now();
      return sum + end.difference(s.startedAt);
    });

    return LogDaySummary(
      formulaTotalMl: formulaTotalMl,
      breastTotalSec: breastTotalSec,
      pumpedTotalMl: pumpedTotalMl,
      babyFoodTotalMl: babyFoodTotalMl,
      diaperCount: diapers.length,
      sleepTotal: sleepTotal,
      temperatureCount: temps.length,
      diaryCount: diaryCount,
    );
  }
}
