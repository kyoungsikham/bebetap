import 'package:drift/drift.dart';
import '../app_database.dart';

part 'diaper_dao.g.dart';

@DriftAccessor(tables: [DiaperEntriesTable])
class DiaperDao extends DatabaseAccessor<AppDatabase> with _$DiaperDaoMixin {
  DiaperDao(super.db);

  Stream<List<DiaperEntriesTableData>> watchDiaperByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(diaperEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.occurredAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Future<DiaperEntriesTableData?> getLastDiaper(String babyId) =>
      (select(diaperEntriesTable)
            ..where((t) => t.babyId.equals(babyId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertDiaper(DiaperEntriesTableCompanion entry) =>
      into(diaperEntriesTable).insertOnConflictUpdate(entry);

  Future<void> softDeleteDiaper(String id) =>
      (update(diaperEntriesTable)..where((t) => t.id.equals(id))).write(
        DiaperEntriesTableCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> updateSyncStatus(String id, String status, {String? remoteId}) =>
      (update(diaperEntriesTable)..where((t) => t.id.equals(id))).write(
        DiaperEntriesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );

  Future<int> getTodayDiaperCount(String babyId) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: 1));
    final rows = await (select(diaperEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.occurredAt.isBetweenValues(from, to) &
                t.deletedAt.isNull(),
          ))
        .get();
    return rows.length;
  }

  Future<List<DiaperEntriesTableData>> getDiapersByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(diaperEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.occurredAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            ))
          .get();

  Future<List<DiaperEntriesTableData>> getPendingSync() =>
      (select(diaperEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .get();
}
