import 'package:drift/drift.dart';
import '../app_database.dart';

part 'sleep_dao.g.dart';

@DriftAccessor(tables: [SleepEntriesTable])
class SleepDao extends DatabaseAccessor<AppDatabase> with _$SleepDaoMixin {
  SleepDao(super.db);

  /// 현재 진행 중인 수면 세션 (ended_at = null)
  Stream<SleepEntriesTableData?> watchActiveSleep(String babyId) =>
      (select(sleepEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.endedAt.isNull() &
                  t.deletedAt.isNull(),
            )
            ..limit(1))
          .watchSingleOrNull();

  Stream<List<SleepEntriesTableData>> watchSleepByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(sleepEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.startedAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  Future<void> upsertSleep(SleepEntriesTableCompanion entry) =>
      into(sleepEntriesTable).insertOnConflictUpdate(entry);

  Future<void> endSleep(String id, DateTime endedAt) =>
      (update(sleepEntriesTable)..where((t) => t.id.equals(id))).write(
        SleepEntriesTableCompanion(endedAt: Value(endedAt)),
      );

  Future<void> softDeleteSleep(String id) =>
      (update(sleepEntriesTable)..where((t) => t.id.equals(id))).write(
        SleepEntriesTableCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> updateSyncStatus(String id, String status, {String? remoteId}) =>
      (update(sleepEntriesTable)..where((t) => t.id.equals(id))).write(
        SleepEntriesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );

  Future<Duration> getTodaySleepTotal(String babyId) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: 1));
    final rows = await (select(sleepEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.startedAt.isBetweenValues(from, to) &
                t.deletedAt.isNull(),
          ))
        .get();
    int totalSeconds = 0;
    for (final row in rows) {
      final end = row.endedAt ?? now;
      totalSeconds += end.difference(row.startedAt).inSeconds;
    }
    return Duration(seconds: totalSeconds);
  }

  Future<List<SleepEntriesTableData>> getSleepsByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(sleepEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.startedAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            ))
          .get();

  Future<List<SleepEntriesTableData>> getPendingSync() =>
      (select(sleepEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .get();
}
