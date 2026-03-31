import 'package:drift/drift.dart';
import '../app_database.dart';

part 'temperature_dao.g.dart';

@DriftAccessor(tables: [TemperatureEntriesTable])
class TemperatureDao extends DatabaseAccessor<AppDatabase>
    with _$TemperatureDaoMixin {
  TemperatureDao(super.db);

  Stream<List<TemperatureEntriesTableData>> watchTemperatureByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(temperatureEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.occurredAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .watch();

  Future<List<TemperatureEntriesTableData>> getTemperaturesByBabyAndDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) =>
      (select(temperatureEntriesTable)
            ..where(
              (t) =>
                  t.babyId.equals(babyId) &
                  t.occurredAt.isBetweenValues(from, to) &
                  t.deletedAt.isNull(),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]))
          .get();

  Future<TemperatureEntriesTableData?> getLastTemperature(String babyId) =>
      (select(temperatureEntriesTable)
            ..where((t) => t.babyId.equals(babyId) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertTemperature(TemperatureEntriesTableCompanion entry) =>
      into(temperatureEntriesTable).insertOnConflictUpdate(entry);

  Future<void> softDeleteTemperature(String id) =>
      (update(temperatureEntriesTable)..where((t) => t.id.equals(id))).write(
        TemperatureEntriesTableCompanion(deletedAt: Value(DateTime.now())),
      );

  Future<void> updateSyncStatus(String id, String status,
          {String? remoteId}) =>
      (update(temperatureEntriesTable)..where((t) => t.id.equals(id))).write(
        TemperatureEntriesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );

  Future<TemperatureEntriesTableData?> getTemperatureById(String id) =>
      (select(temperatureEntriesTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<TemperatureEntriesTableData>> getPendingSync() =>
      (select(temperatureEntriesTable)
            ..where((t) => t.syncStatus.isNotValue('synced')))
          .get();
}
