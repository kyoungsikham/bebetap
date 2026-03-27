import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../data/statistics_repository.dart';
import '../../domain/models/feeding_stats.dart';
import '../../domain/models/period.dart';
import '../../domain/models/sleep_stats.dart';

part 'statistics_provider.g.dart';

@riverpod
StatisticsRepository statisticsRepository(Ref ref) =>
    StatisticsRepository(ref.watch(appDatabaseProvider));

@riverpod
Future<SleepStats> sleepStats(Ref ref, Period period) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return SleepStats.empty;
  return ref.watch(statisticsRepositoryProvider).getSleepStats(baby.id, period);
}

@riverpod
Future<FeedingStats> feedingStats(Ref ref, Period period) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return FeedingStats.empty;
  return ref
      .watch(statisticsRepositoryProvider)
      .getFeedingStats(baby.id, period);
}

@riverpod
Future<int> diaperStats(Ref ref, Period period) async {
  final baby = await ref.watch(selectedBabyProvider.future);
  if (baby == null) return 0;
  return ref
      .watch(statisticsRepositoryProvider)
      .getDiaperCount(baby.id, period);
}
