import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../domain/models/diaper_entry.dart';

class DiaperRepository {
  DiaperRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<DiaperEntry> saveDiaper({
    required String babyId,
    required String familyId,
    required String type,
    DateTime? occurredAt,
  }) async {
    final id = _uuid.v4();
    final now = occurredAt ?? DateTime.now();
    await _db.diaperDao.upsertDiaper(
      DiaperEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        type: Value(type),
        occurredAt: Value(now),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return DiaperEntry(
      id: id,
      babyId: babyId,
      familyId: familyId,
      type: type,
      occurredAt: now,
    );
  }

  Future<int> getTodayDiaperCount(String babyId) =>
      _db.diaperDao.getTodayDiaperCount(babyId);

  Future<DiaperEntry?> getLastDiaper(String babyId) async {
    final row = await _db.diaperDao.getLastDiaper(babyId);
    return row != null ? _fromRow(row) : null;
  }

  Future<void> updateDiaper(
    String id, {
    required String type,
    required DateTime occurredAt,
  }) async {
    final existing = await _db.diaperDao.getDiaperById(id);
    if (existing == null) return;
    await _db.diaperDao.upsertDiaper(
      DiaperEntriesTableCompanion(
        id: Value(id),
        babyId: Value(existing.babyId),
        familyId: Value(existing.familyId),
        type: Value(type),
        occurredAt: Value(occurredAt),
        localId: Value(existing.localId ?? id),
        syncStatus: const Value('pending_update'),
        remoteId: Value(existing.remoteId),
      ),
    );
  }

  DiaperEntry _fromRow(DiaperEntriesTableData row) => DiaperEntry(
        id: row.id,
        babyId: row.babyId,
        familyId: row.familyId,
        type: row.type,
        occurredAt: row.occurredAt,
      );
}
