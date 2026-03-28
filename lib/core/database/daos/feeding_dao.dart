import 'package:drift/drift.dart';
import '../app_database.dart';

part 'feeding_dao.g.dart';

@DriftAccessor(tables: [FeedingEntriesTable])
class FeedingDao extends DatabaseAccessor<AppDatabase> with _$FeedingDaoMixin {
  FeedingDao(super.db);

  Stream<List<FeedingEntriesTableData>> watchFeedingByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(feedingEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.startedAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  Future<FeedingEntriesTableData?> getLastFeedingByBaby(String babyId) =>
      (select(feedingEntriesTable)
            ..where((t) => t.babyId.equals(babyId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> getDailyFormulaTotalMl(String babyId, DateTime date) async {
    final from = DateTime(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 1));
    final rows = await (select(feedingEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.type.equals('formula') &
                t.startedAt.isBetweenValues(from, to) &
                t.deletedAt.isNull(),
          ))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));
  }

  Future<int> getDailyBabyFoodTotalMl(String babyId, DateTime date) async {
    final from = DateTime(date.year, date.month, date.day);
    final to = from.add(const Duration(days: 1));
    final rows = await (select(feedingEntriesTable)
          ..where(
            (t) =>
                t.babyId.equals(babyId) &
                t.type.equals('baby_food') &
                t.startedAt.isBetweenValues(from, to) &
                t.deletedAt.isNull(),
          ))
        .get();
    return rows.fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));
  }

  Future<void> upsertFeeding(FeedingEntriesTableCompanion entry) =>
      into(feedingEntriesTable).insertOnConflictUpdate(entry);

  Future<void> softDeleteFeeding(String id) =>
      (update(feedingEntriesTable)..where((t) => t.id.equals(id))).write(
        FeedingEntriesTableCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> updateSyncStatus(String id, String status, {String? remoteId}) =>
      (update(feedingEntriesTable)..where((t) => t.id.equals(id))).write(
        FeedingEntriesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );

  Stream<List<FeedingEntriesTableData>> watchPendingSync() =>
      (select(feedingEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .watch();

  Future<List<FeedingEntriesTableData>> getFeedingsByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(feedingEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.startedAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            ))
          .get();

  Future<List<FeedingEntriesTableData>> getPendingSync() =>
      (select(feedingEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .get();
}
