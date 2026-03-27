import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../domain/models/temperature_entry.dart';

class TemperatureRepository {
  TemperatureRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<TemperatureEntry> saveTemperature({
    required String babyId,
    required String familyId,
    required double celsius,
    required String method,
    DateTime? occurredAt,
  }) async {
    final id = _uuid.v4();
    final now = occurredAt ?? DateTime.now();
    await _db.temperatureDao.upsertTemperature(
      TemperatureEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        celsius: Value(celsius),
        method: Value(method),
        occurredAt: Value(now),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return TemperatureEntry(
      id: id,
      babyId: babyId,
      familyId: familyId,
      celsius: celsius,
      method: method,
      occurredAt: now,
    );
  }

  Future<TemperatureEntry?> getLastTemperature(String babyId) async {
    final row = await _db.temperatureDao.getLastTemperature(babyId);
    return row != null ? _fromRow(row) : null;
  }

  TemperatureEntry _fromRow(TemperatureEntriesTableData row) =>
      TemperatureEntry(
        id: row.id,
        babyId: row.babyId,
        familyId: row.familyId,
        celsius: row.celsius,
        method: row.method,
        occurredAt: row.occurredAt,
      );
}
