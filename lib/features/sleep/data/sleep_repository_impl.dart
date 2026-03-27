import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../domain/models/sleep_entry.dart';

class SleepRepository {
  SleepRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<SleepEntry?> watchActiveSleep(String babyId) =>
      _db.sleepDao.watchActiveSleep(babyId).map(
            (row) => row != null ? _fromRow(row) : null,
          );

  Future<String> startSleep({
    required String babyId,
    required String familyId,
    DateTime? startedAt,
  }) async {
    final id = _uuid.v4();
    final now = startedAt ?? DateTime.now();
    await _db.sleepDao.upsertSleep(
      SleepEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        startedAt: Value(now),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return id;
  }

  Future<void> endSleep(String id) =>
      _db.sleepDao.endSleep(id, DateTime.now());

  Future<Duration> getTodaySleepTotal(String babyId) =>
      _db.sleepDao.getTodaySleepTotal(babyId);

  SleepEntry _fromRow(SleepEntriesTableData row) => SleepEntry(
        id: row.id,
        babyId: row.babyId,
        familyId: row.familyId,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        quality: row.quality,
      );
}
