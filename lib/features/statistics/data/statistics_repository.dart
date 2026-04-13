import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/activity_heatmap.dart';
import '../domain/models/comparison_data.dart';
import '../domain/models/daily_timeline.dart';
import '../domain/models/diaper_stats.dart';
import '../domain/models/feeding_stats.dart';
import '../domain/models/sleep_stats.dart';
import '../domain/models/temperature_stats.dart';

class StatisticsRepository {
  const StatisticsRepository(this._db);
  final AppDatabase _db;

  // ── Sleep ──────────────────────────────────────────────────────────────────

  Future<SleepStats> getSleepStats(
    String babyId,
    DateTime from,
    DateTime to, {
    DateTime? babyBirthDate,
  }) async {
    final (prevFrom, prevTo) = _previousRange(from, to);
    final now = DateTime.now();

    final rows = await _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to);
    final prevRows =
        await _db.sleepDao.getSleepsByBabyAndDate(babyId, prevFrom, prevTo);

    int totalSec = 0;
    int napSec = 0;
    int nightSec = 0;
    Duration longestConsecutive = Duration.zero;
    final bedtimes = <TimeOfDay>[];
    final waketimes = <TimeOfDay>[];

    for (final row in rows) {
      final end = row.endedAt ?? now;
      final duration = end.difference(row.startedAt);
      final sec = duration.inSeconds;
      totalSec += sec;

      if (duration > longestConsecutive) {
        longestConsecutive = duration;
      }

      // Classify nap vs night: night = started between 20:00-05:59
      final hour = row.startedAt.hour;
      if (hour >= 20 || hour < 6) {
        nightSec += sec;
        bedtimes.add(TimeOfDay.fromDateTime(row.startedAt));
        if (row.endedAt != null) {
          waketimes.add(TimeOfDay.fromDateTime(row.endedAt!));
        }
      } else {
        napSec += sec;
      }
    }

    int prevTotalSec = prevRows.fold(0, (sum, row) {
      final end = row.endedAt ?? now;
      return sum + end.difference(row.startedAt).inSeconds;
    });

    final dailyEntries = _buildDailySleepEntries(rows, from, to, now);

    // Age-recommended sleep (daily hours, WHO/AAP guidelines)
    double? recMin;
    double? recMax;
    if (babyBirthDate != null) {
      final ageMonths =
          (now.difference(babyBirthDate).inDays / 30.44).floor();
      final rec = _recommendedSleep(ageMonths);
      recMin = rec.$1;
      recMax = rec.$2;
    }

    return SleepStats(
      totalDuration: Duration(seconds: totalSec),
      previousTotalDuration: Duration(seconds: prevTotalSec),
      dailyEntries: dailyEntries,
      napTotal: Duration(seconds: napSec),
      nightTotal: Duration(seconds: nightSec),
      longestConsecutive: longestConsecutive,
      bedtimes: bedtimes,
      waketimes: waketimes,
      ageRecommendedMin: recMin,
      ageRecommendedMax: recMax,
    );
  }

  List<DailySleepEntry> _buildDailySleepEntries(
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

  /// WHO/AAP recommended daily sleep hours by age in months
  (double, double) _recommendedSleep(int ageMonths) {
    if (ageMonths < 4) return (14.0, 17.0);
    if (ageMonths < 12) return (12.0, 15.0);
    if (ageMonths < 24) return (11.0, 14.0);
    if (ageMonths < 36) return (10.0, 13.0);
    return (10.0, 13.0);
  }

  // ── Feeding ────────────────────────────────────────────────────────────────

  Future<FeedingStats> getFeedingStats(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final (prevFrom, prevTo) = _previousRange(from, to);

    final rows =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to);
    final prevRows =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, prevFrom, prevTo);

    int totalFormulaMl = 0;
    int totalPumpedMl = 0;
    int totalBabyFoodMl = 0;
    int totalBreastSec = 0;
    int totalLeftSec = 0;
    int totalRightSec = 0;
    int formulaCount = 0;
    int breastCount = 0;

    for (final r in rows) {
      switch (r.type) {
        case 'formula':
          totalFormulaMl += r.amountMl ?? 0;
          formulaCount++;
        case 'pumped':
          totalPumpedMl += r.amountMl ?? 0;
        case 'baby_food':
          totalBabyFoodMl += r.amountMl ?? 0;
        case 'breast':
          final left = r.durationLeftSec ?? 0;
          final right = r.durationRightSec ?? 0;
          totalLeftSec += left;
          totalRightSec += right;
          totalBreastSec += left + right;
          breastCount++;
      }
    }

    final prevFormulaMl = prevRows
        .where((r) => r.type == 'formula')
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));
    final prevBreastSec = prevRows
        .where((r) => r.type == 'breast')
        .fold<int>(
          0,
          (sum, r) =>
              sum + (r.durationLeftSec ?? 0) + (r.durationRightSec ?? 0),
        );

    // Average interval between feedings
    double? avgIntervalHours;
    if (rows.length >= 2) {
      final sorted = [...rows]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
      double totalIntervalMin = 0;
      for (int i = 1; i < sorted.length; i++) {
        totalIntervalMin +=
            sorted[i].startedAt.difference(sorted[i - 1].startedAt).inMinutes;
      }
      avgIntervalHours = totalIntervalMin / (sorted.length - 1) / 60.0;
    }

    // Left/right ratio
    double? leftRightRatio;
    final totalLR = totalLeftSec + totalRightSec;
    if (totalLR > 0) {
      leftRightRatio = totalLeftSec / totalLR;
    }

    // Daily entries
    final dailyEntries = _buildDailyFeedingEntries(rows, from, to);

    return FeedingStats(
      totalFormulaMl: totalFormulaMl,
      totalBreastSec: totalBreastSec,
      feedingCount: rows.length,
      previousFormulaMl: prevFormulaMl,
      dailyEntries: dailyEntries,
      avgIntervalHours: avgIntervalHours,
      leftRightRatio: leftRightRatio,
      totalBreastCount: breastCount,
      totalFormulaCount: formulaCount,
      totalPumpedMl: totalPumpedMl,
      totalBabyFoodMl: totalBabyFoodMl,
      previousBreastSec: prevBreastSec,
    );
  }

  List<DailyFeedingEntry> _buildDailyFeedingEntries(
    List<FeedingEntriesTableData> rows,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays;
    final entries = <DailyFeedingEntry>[];
    for (int i = 0; i < days; i++) {
      final date = DateTime(from.year, from.month, from.day + i);
      final nextDate = date.add(const Duration(days: 1));
      final dayRows = rows.where(
        (r) => !r.startedAt.isBefore(date) && r.startedAt.isBefore(nextDate),
      );

      int formulaMl = 0;
      int pumpedMl = 0;
      int babyFoodMl = 0;
      int breastSec = 0;
      int count = 0;
      for (final r in dayRows) {
        count++;
        switch (r.type) {
          case 'formula':
            formulaMl += r.amountMl ?? 0;
          case 'pumped':
            pumpedMl += r.amountMl ?? 0;
          case 'baby_food':
            babyFoodMl += r.amountMl ?? 0;
          case 'breast':
            breastSec += (r.durationLeftSec ?? 0) + (r.durationRightSec ?? 0);
        }
      }
      entries.add(DailyFeedingEntry(
        date: date,
        formulaMl: formulaMl,
        pumpedMl: pumpedMl,
        babyFoodMl: babyFoodMl,
        breastSec: breastSec,
        count: count,
      ));
    }
    return entries;
  }

  // ── Diaper ─────────────────────────────────────────────────────────────────

  Future<DiaperStats> getDiaperStats(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final (prevFrom, prevTo) = _previousRange(from, to);

    final rows =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to);
    final prevRows =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, prevFrom, prevTo);

    int wet = 0, soiled = 0, both = 0, dry = 0;
    for (final r in rows) {
      switch (r.type) {
        case 'wet':
          wet++;
        case 'soiled':
          soiled++;
        case 'both':
          both++;
        case 'dry':
          dry++;
      }
    }

    final dailyEntries = _buildDailyDiaperEntries(rows, from, to);

    return DiaperStats(
      totalCount: rows.length,
      wetCount: wet,
      soiledCount: soiled,
      bothCount: both,
      dryCount: dry,
      previousTotalCount: prevRows.length,
      dailyEntries: dailyEntries,
    );
  }

  List<DailyDiaperEntry> _buildDailyDiaperEntries(
    List<DiaperEntriesTableData> rows,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays;
    final entries = <DailyDiaperEntry>[];
    for (int i = 0; i < days; i++) {
      final date = DateTime(from.year, from.month, from.day + i);
      final nextDate = date.add(const Duration(days: 1));
      final dayRows = rows.where(
        (r) => !r.occurredAt.isBefore(date) && r.occurredAt.isBefore(nextDate),
      );

      int wet = 0, soiled = 0, both = 0, dry = 0;
      for (final r in dayRows) {
        switch (r.type) {
          case 'wet':
            wet++;
          case 'soiled':
            soiled++;
          case 'both':
            both++;
          case 'dry':
            dry++;
        }
      }
      entries.add(DailyDiaperEntry(
        date: date,
        wet: wet,
        soiled: soiled,
        both: both,
        dry: dry,
      ));
    }
    return entries;
  }

  // ── Temperature ────────────────────────────────────────────────────────────

  Future<TemperatureStats> getTemperatureStats(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.temperatureDao
        .getTemperaturesByBabyAndDate(babyId, from, to);

    if (rows.isEmpty) return TemperatureStats.empty;

    double sum = 0;
    double maxC = -1;
    double minC = 100;
    for (final r in rows) {
      sum += r.celsius;
      if (r.celsius > maxC) maxC = r.celsius;
      if (r.celsius < minC) minC = r.celsius;
    }

    final dailyEntries = _buildDailyTemperatureEntries(rows, from, to);

    return TemperatureStats(
      latestCelsius: rows.first.celsius, // rows are DESC ordered
      avgCelsius: sum / rows.length,
      maxCelsius: maxC,
      minCelsius: minC,
      measurementCount: rows.length,
      dailyEntries: dailyEntries,
    );
  }

  List<DailyTemperatureEntry> _buildDailyTemperatureEntries(
    List<TemperatureEntriesTableData> rows,
    DateTime from,
    DateTime to,
  ) {
    final days = to.difference(from).inDays;
    final entries = <DailyTemperatureEntry>[];
    for (int i = 0; i < days; i++) {
      final date = DateTime(from.year, from.month, from.day + i);
      final nextDate = date.add(const Duration(days: 1));
      final dayRows = rows.where(
        (r) => !r.occurredAt.isBefore(date) && r.occurredAt.isBefore(nextDate),
      );
      if (dayRows.isEmpty) continue;

      double sum = 0;
      double maxC = -1;
      for (final r in dayRows) {
        sum += r.celsius;
        if (r.celsius > maxC) maxC = r.celsius;
      }
      entries.add(DailyTemperatureEntry(
        date: date,
        avgCelsius: sum / dayRows.length,
        maxCelsius: maxC,
        count: dayRows.length,
      ));
    }
    return entries;
  }

  // ── Heatmap ────────────────────────────────────────────────────────────────

  Future<HeatmapData> getActivityHeatmap(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final numDays = math.max(1, to.difference(from).inDays);

    final feedings =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to);
    final sleeps =
        await _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to);
    final diapers =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to);
    final now = DateTime.now();

    // Initialize hourly buckets
    final feedingCounts = List.filled(24, 0);
    final sleepMinutes = List.filled(24, 0.0);
    final diaperCounts = List.filled(24, 0);

    for (final f in feedings) {
      feedingCounts[f.startedAt.hour]++;
    }

    for (final d in diapers) {
      diaperCounts[d.occurredAt.hour]++;
    }

    // Sleep: compute overlap with each hour bucket across all days
    for (final s in sleeps) {
      final end = s.endedAt ?? now;
      // Walk through each hour the sleep spans
      var cursor = s.startedAt;
      while (cursor.isBefore(end)) {
        final hourEnd = DateTime(cursor.year, cursor.month, cursor.day, cursor.hour + 1);
        final segmentEnd = hourEnd.isBefore(end) ? hourEnd : end;
        final minutes = segmentEnd.difference(cursor).inMinutes.toDouble();
        sleepMinutes[cursor.hour] += minutes;
        cursor = hourEnd;
      }
    }

    final hours = List.generate(24, (h) {
      return HourlyActivity(
        hour: h,
        feedingCount: feedingCounts[h] / numDays,
        sleepMinutes: sleepMinutes[h] / numDays,
        diaperCount: diaperCounts[h] / numDays,
      );
    });

    return HeatmapData(hours: hours);
  }

  // ── Daily Timeline ─────────────────────────────────────────────────────────

  Future<TimelineData> getDailyTimeline(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final now = DateTime.now();
    final sleeps = await _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to);
    final feedings =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to);
    final diapers =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to);

    final numDays = to.difference(from).inDays;
    final days = <DayTimeline>[];

    for (int i = 0; i < numDays; i++) {
      final dayStart = DateTime(from.year, from.month, from.day + i);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final events = <TimelineEvent>[];

      // Sleep events — clip to day boundaries
      for (final s in sleeps) {
        final sEnd = s.endedAt ?? now;
        if (sEnd.isBefore(dayStart) || !s.startedAt.isBefore(dayEnd)) continue;
        final clippedStart = s.startedAt.isBefore(dayStart) ? dayStart : s.startedAt;
        final clippedEnd = sEnd.isAfter(dayEnd) ? dayEnd : sEnd;
        if (!clippedEnd.isAfter(clippedStart)) continue;
        events.add(TimelineEvent(
          type: TimelineEventType.sleep,
          start: clippedStart,
          end: clippedEnd,
        ));
      }

      // Feeding events
      for (final f in feedings) {
        if (f.startedAt.isBefore(dayStart) || !f.startedAt.isBefore(dayEnd)) {
          continue;
        }
        DateTime fEnd;
        if (f.endedAt != null) {
          fEnd = f.endedAt!;
        } else if (f.type == 'breast') {
          final durSec =
              (f.durationLeftSec ?? 0) + (f.durationRightSec ?? 0);
          fEnd = f.startedAt.add(Duration(seconds: durSec > 0 ? durSec : 900));
        } else {
          fEnd = f.startedAt.add(const Duration(minutes: 15));
        }
        // Clip to day boundary
        if (fEnd.isAfter(dayEnd)) fEnd = dayEnd;
        final feedType = switch (f.type) {
          'breast' => TimelineEventType.breast,
          'pumped' => TimelineEventType.pumped,
          'baby_food' => TimelineEventType.babyFood,
          _ => TimelineEventType.formula,
        };
        events.add(TimelineEvent(
          type: feedType,
          start: f.startedAt,
          end: fEnd,
          subType: f.type,
        ));
      }

      // Diaper events — small marker
      for (final d in diapers) {
        if (d.occurredAt.isBefore(dayStart) || !d.occurredAt.isBefore(dayEnd)) {
          continue;
        }
        events.add(TimelineEvent(
          type: TimelineEventType.diaper,
          start: d.occurredAt,
          end: d.occurredAt.add(const Duration(minutes: 5)),
          subType: d.type,
        ));
      }

      days.add(DayTimeline(date: dayStart, events: events));
    }

    return TimelineData(days: days);
  }

  // ── Comparison ─────────────────────────────────────────────────────────────

  Future<BabyComparisonData> getBabyDataAtAge(
    String babyId,
    String babyName,
    DateTime birthDate,
    int ageDays, {
    double? weightKg,
  }) async {
    final targetDate = DateTime(
      birthDate.year,
      birthDate.month,
      birthDate.day + ageDays,
    );
    final from = targetDate;
    final to = targetDate.add(const Duration(days: 1));
    final now = DateTime.now();

    final sleeps = await _db.sleepDao.getSleepsByBabyAndDate(babyId, from, to);
    final feedings =
        await _db.feedingDao.getFeedingsByBabyAndDate(babyId, from, to);
    final diapers =
        await _db.diaperDao.getDiapersByBabyAndDate(babyId, from, to);

    final sleepMin = sleeps.fold<int>(0, (sum, r) {
      final end = r.endedAt ?? now;
      return sum + end.difference(r.startedAt).inMinutes;
    });

    final feedingMl = feedings.fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));

    return BabyComparisonData(
      babyId: babyId,
      babyName: babyName,
      ageInDays: ageDays,
      totalSleepMinutes: sleepMin,
      totalFeedingMl: feedingMl,
      totalDiaperCount: diapers.length,
      weightKg: weightKg,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  (DateTime, DateTime) _previousRange(DateTime from, DateTime to) {
    final duration = to.difference(from);
    return (from.subtract(duration), from);
  }
}
