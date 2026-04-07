import 'package:drift/drift.dart';
import '../app_database.dart';

part 'diary_dao.g.dart';

@DriftAccessor(tables: [DiaryEntriesTable])
class DiaryDao extends DatabaseAccessor<AppDatabase> with _$DiaryDaoMixin {
  DiaryDao(super.db);

  Future<List<DiaryEntriesTableData>> getDiariesByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(diaryEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.entryDate.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<DiaryEntriesTableData?> getDiaryByBabyAuthorAndDate(
    String babyId,
    String recordedBy,
    DateTime date,
  ) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return (select(diaryEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.recordedBy.equals(recordedBy) &
                t.entryDate.isBetweenValues(dayStart, dayEnd) &
                t.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<DiaryEntriesTableData?> getDiaryById(String id) =>
      (select(diaryEntriesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertDiary(DiaryEntriesTableCompanion entry) =>
      into(diaryEntriesTable).insertOnConflictUpdate(entry);

  Future<void> softDeleteDiary(String id) =>
      (update(diaryEntriesTable)..where((t) => t.id.equals(id))).write(
        DiaryEntriesTableCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> updateSyncStatus(String id, String status,
          {String? remoteId}) =>
      (update(diaryEntriesTable)..where((t) => t.id.equals(id))).write(
        DiaryEntriesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );

  Future<List<DiaryEntriesTableData>> getPendingSync() =>
      (select(diaryEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .get();

  Future<int> getDiaryCountForDate(String babyId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final rows = await (select(diaryEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.entryDate.isBetweenValues(dayStart, dayEnd) &
                t.deletedAt.isNull(),
          ))
        .get();
    return rows.length;
  }
}
