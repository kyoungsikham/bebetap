import 'package:drift/drift.dart';
import '../app_database.dart';

part 'baby_dao.g.dart';

@DriftAccessor(tables: [BabiesTable])
class BabyDao extends DatabaseAccessor<AppDatabase> with _$BabyDaoMixin {
  BabyDao(super.db);

  Stream<List<BabiesTableData>> watchBabiesByFamily(String familyId) =>
      (select(babiesTable)
            ..where((t) => t.familyId.equals(familyId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  Future<BabiesTableData?> getBabyById(String id) =>
      (select(babiesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> upsertBaby(BabiesTableCompanion entry) =>
      into(babiesTable).insertOnConflictUpdate(entry);

  Future<void> updateSyncStatus(String id, String status, {String? remoteId}) =>
      (update(babiesTable)..where((t) => t.id.equals(id))).write(
        BabiesTableCompanion(
          syncStatus: Value(status),
          remoteId: remoteId != null ? Value(remoteId) : const Value.absent(),
        ),
      );
}
