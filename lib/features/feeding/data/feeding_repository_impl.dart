import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../domain/models/feeding_entry.dart';

class FeedingRepository {
  FeedingRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<FeedingEntry>> watchTodayFeedings(String babyId) {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day);
    final to = from.add(const Duration(days: 1));
    return _db.feedingDao
        .watchFeedingByBabyAndDate(babyId, from, to)
        .map((rows) => rows.map(_fromRow).toList());
  }

  Future<FeedingEntry?> getLastFeeding(String babyId) async {
    final row = await _db.feedingDao.getLastFeedingByBaby(babyId);
    return row != null ? _fromRow(row) : null;
  }

  Future<int> getDailyFormulaTotalMl(String babyId, DateTime date) =>
      _db.feedingDao.getDailyFormulaTotalMl(babyId, date);

  Future<FeedingEntry> saveFormulaFeeding({
    required String babyId,
    required String familyId,
    required int amountMl,
    DateTime? startedAt,
  }) async {
    final id = _uuid.v4();
    final now = startedAt ?? DateTime.now();
    await _db.feedingDao.upsertFeeding(
      FeedingEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        type: const Value('formula'),
        amountMl: Value(amountMl),
        startedAt: Value(now),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return FeedingEntry(
      id: id,
      babyId: babyId,
      familyId: familyId,
      type: 'formula',
      amountMl: amountMl,
      startedAt: now,
    );
  }

  Future<FeedingEntry> saveBreastFeeding({
    required String babyId,
    required String familyId,
    required int durationLeftSec,
    required int durationRightSec,
    required DateTime startedAt,
    DateTime? endedAt,
  }) async {
    final id = _uuid.v4();
    final end = endedAt ?? DateTime.now();
    await _db.feedingDao.upsertFeeding(
      FeedingEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        type: const Value('breast'),
        durationLeftSec: Value(durationLeftSec),
        durationRightSec: Value(durationRightSec),
        startedAt: Value(startedAt),
        endedAt: Value(end),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return FeedingEntry(
      id: id,
      babyId: babyId,
      familyId: familyId,
      type: 'breast',
      durationLeftSec: durationLeftSec,
      durationRightSec: durationRightSec,
      startedAt: startedAt,
      endedAt: end,
    );
  }

  FeedingEntry _fromRow(FeedingEntriesTableData row) => FeedingEntry(
        id: row.id,
        babyId: row.babyId,
        familyId: row.familyId,
        type: row.type,
        amountMl: row.amountMl,
        durationLeftSec: row.durationLeftSec,
        durationRightSec: row.durationRightSec,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        notes: row.notes,
      );
}
