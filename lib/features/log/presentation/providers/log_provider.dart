import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/database_provider.dart';
import '../../../baby/presentation/providers/baby_provider.dart';
import '../../data/log_repository.dart';
import '../../domain/models/timeline_entry.dart';

part 'log_provider.g.dart';

// ─── 선택된 날짜 (기본값: 오늘) ───────────────────────────────────────────────

@riverpod
class SelectedLogDate extends _$SelectedLogDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) => state = date;

  void previousDay() =>
      state = state.subtract(const Duration(days: 1));

  void nextDay() {
    final next = state.add(const Duration(days: 1));
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (next.isBefore(tomorrow)) state = next;
  }
}

// ─── 리포지토리 ────────────────────────────────────────────────────────────────

@riverpod
LogRepository logRepository(Ref ref) =>
    LogRepository(ref.watch(appDatabaseProvider));

// ─── 타임라인 ──────────────────────────────────────────────────────────────────

@riverpod
Future<List<TimelineEntry>> logTimeline(Ref ref) {
  final baby = ref.watch(selectedBabyProvider).valueOrNull;
  final date = ref.watch(selectedLogDateProvider);
  if (baby == null) return Future.value([]);
  return ref.watch(logRepositoryProvider).getTimelineForDate(baby.id, date);
}

// ─── 카테고리 필터 (null = 전체) ──────────────────────────────────────────────

@Riverpod(keepAlive: true)
class SelectedTimelineFilter extends _$SelectedTimelineFilter {
  @override
  TimelineEntryType build() => TimelineEntryType.formula;

  void setFilter(TimelineEntryType type) => state = type;
}

// ─── 필터 적용된 타임라인 ─────────────────────────────────────────────────────

@riverpod
Future<List<TimelineEntry>> filteredLogTimeline(Ref ref) async {
  final entries = await ref.watch(logTimelineProvider.future);
  final filter = ref.watch(selectedTimelineFilterProvider);
  return entries.where((e) => e.type == filter).toList();
}

// ─── 요약 (타임라인 변경 시 자동 재조회) ─────────────────────────────────────

@riverpod
Future<LogDaySummary> logDaySummary(Ref ref) async {
  ref.watch(logTimelineProvider); // 타임라인 변경 시 trigger
  final baby = ref.watch(selectedBabyProvider).valueOrNull;
  final date = ref.watch(selectedLogDateProvider);
  if (baby == null) return LogDaySummary.empty();
  return ref.watch(logRepositoryProvider).getDaySummary(baby.id, date);
}
