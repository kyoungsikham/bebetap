import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../../family/presentation/providers/family_provider.dart';
import '../../data/statistics_repository.dart';
import '../../domain/models/activity_heatmap.dart';
import '../../domain/models/daily_timeline.dart';
import '../../domain/models/comparison_data.dart';
import '../../domain/models/date_range_selection.dart';
import '../../domain/models/diaper_stats.dart';
import '../../domain/models/feeding_stats.dart';
import '../../domain/models/insight.dart';
import '../../domain/models/sleep_stats.dart';
import '../../domain/models/temperature_stats.dart';
import '../../domain/services/insights_engine.dart';

part 'statistics_provider.g.dart';

@riverpod
StatisticsRepository statisticsRepository(Ref ref) =>
    StatisticsRepository(ref.watch(appDatabaseProvider));

// ── Date Range State ─────────────────────────────────────────────────────────

@riverpod
class StatsDateRange extends _$StatsDateRange {
  @override
  DateRangeSelection build() => DateRangeSelection.week();

  void setRange(DateRangeSelection range) => state = range;
}

// ── Stats Providers ──────────────────────────────────────────────────────────

/// 통계용 범위 데이터를 Supabase에서 pull한 뒤 로컬 DB를 반환
Future<void> _pullStatsIfNeeded(Ref ref, DateRangeSelection range) async {
  final family = await ref.read(myFamilyProvider.future);
  if (family == null) return;
  await ref
      .read(syncEngineProvider)
      .pullStatsRange(family.id, range.from, range.to);
}

@riverpod
Future<SleepStats> sleepStats(Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return SleepStats.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getSleepStats(
        baby.id,
        range.from,
        range.to,
        babyBirthDate: baby.birthDate,
      );
}

@riverpod
Future<FeedingStats> feedingStats(Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return FeedingStats.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getFeedingStats(
        baby.id,
        range.from,
        range.to,
      );
}

@riverpod
Future<DiaperStats> diaperStats(Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return DiaperStats.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getDiaperStats(
        baby.id,
        range.from,
        range.to,
      );
}

@riverpod
Future<TemperatureStats> temperatureStats(
    Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return TemperatureStats.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getTemperatureStats(
        baby.id,
        range.from,
        range.to,
      );
}

@riverpod
Future<HeatmapData> activityHeatmap(
    Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return HeatmapData.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getActivityHeatmap(
        baby.id,
        range.from,
        range.to,
      );
}

@riverpod
Future<TimelineData> dailyTimeline(
    Ref ref, DateRangeSelection range) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return TimelineData.empty;
  await _pullStatsIfNeeded(ref, range);
  return ref.watch(statisticsRepositoryProvider).getDailyTimeline(
        baby.id,
        range.from,
        range.to,
      );
}

// ── Sub-page Date Ranges ────────────────────────────────────────────────────

@riverpod
class FeedingStatsDateRange extends _$FeedingStatsDateRange {
  @override
  DateRangeSelection build() => DateRangeSelection.week();

  void setRange(DateRangeSelection range) => state = range;
}

@riverpod
class BabyFoodStatsDateRange extends _$BabyFoodStatsDateRange {
  @override
  DateRangeSelection build() => DateRangeSelection.week();

  void setRange(DateRangeSelection range) => state = range;
}

@riverpod
class SleepStatsDateRange extends _$SleepStatsDateRange {
  @override
  DateRangeSelection build() => DateRangeSelection.week();

  void setRange(DateRangeSelection range) => state = range;
}

// ── Insights ─────────────────────────────────────────────────────────────────

@riverpod
Future<List<Insight>> parentInsights(Ref ref) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return [];

  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 14));
  final to = now.add(const Duration(days: 1));

  final feedings =
      await db.feedingDao.getFeedingsByBabyAndDate(baby.id, from, to);
  final sleeps = await db.sleepDao.getSleepsByBabyAndDate(baby.id, from, to);
  final diapers =
      await db.diaperDao.getDiapersByBabyAndDate(baby.id, from, to);
  final temps =
      await db.temperatureDao.getTemperaturesByBabyAndDate(baby.id, from, to);

  return InsightsEngine().generateInsights(
    recentFeedings: feedings,
    recentSleeps: sleeps,
    recentDiapers: diapers,
    recentTemperatures: temps,
    babyBirthDate: baby.birthDate,
  );
}

// ── Baby Comparison ──────────────────────────────────────────────────────────

@riverpod
Future<ComparisonResult> babyComparison(Ref ref, int ageDays) async {
  final babies = await ref.watch(babiesProvider.future);
  final repo = ref.watch(statisticsRepositoryProvider);

  final results = await Future.wait(
    babies.map((b) => repo.getBabyDataAtAge(
          b.id,
          b.name,
          b.birthDate,
          ageDays,
          weightKg: b.weightKg,
        )),
  );

  return ComparisonResult(targetAgeDays: ageDays, babies: results);
}
