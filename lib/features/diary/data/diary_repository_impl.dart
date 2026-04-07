import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/diary_entry.dart';

class DiaryRepository {
  DiaryRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<DiaryEntry> saveDiary({
    required String babyId,
    required String familyId,
    required String title,
    required String content,
    required DateTime entryDate,
    String? recordedBy,
    String? authorNickname,
  }) async {
    final id = _uuid.v4();
    final date = DateTime.utc(entryDate.year, entryDate.month, entryDate.day);
    await _db.diaryDao.upsertDiary(
      DiaryEntriesTableCompanion(
        id: Value(id),
        babyId: Value(babyId),
        familyId: Value(familyId),
        recordedBy: Value(recordedBy),
        title: Value(title),
        content: Value(content),
        entryDate: Value(date),
        authorNickname: Value(authorNickname),
        localId: Value(id),
        syncStatus: const Value('pending_create'),
      ),
    );
    return DiaryEntry(
      id: id,
      babyId: babyId,
      familyId: familyId,
      title: title,
      content: content,
      entryDate: date,
      recordedBy: recordedBy,
      authorNickname: authorNickname,
    );
  }

  Future<void> updateDiary(
    String id, {
    required String title,
    required String content,
  }) async {
    final existing = await _db.diaryDao.getDiaryById(id);
    if (existing == null) return;
    await _db.diaryDao.upsertDiary(
      DiaryEntriesTableCompanion(
        id: Value(id),
        babyId: Value(existing.babyId),
        familyId: Value(existing.familyId),
        recordedBy: Value(existing.recordedBy),
        title: Value(title),
        content: Value(content),
        entryDate: Value(existing.entryDate),
        authorNickname: Value(existing.authorNickname),
        localId: Value(existing.localId ?? id),
        syncStatus: const Value('pending_update'),
        remoteId: Value(existing.remoteId),
      ),
    );
  }

  Future<DiaryEntry?> getTodayDiaryForAuthor(
    String babyId,
    String recordedBy,
  ) async {
    final now = DateTime.now();
    final row = await _db.diaryDao.getDiaryByBabyAuthorAndDate(
      babyId,
      recordedBy,
      now,
    );
    return row != null ? _fromRow(row) : null;
  }

  Future<List<DiaryEntry>> getDiariesForDate(
    String babyId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.diaryDao.getDiariesByBabyAndDate(babyId, from, to);
    return rows.map(_fromRow).toList();
  }

  DiaryEntry _fromRow(DiaryEntriesTableData row) => DiaryEntry(
        id: row.id,
        babyId: row.babyId,
        familyId: row.familyId,
        title: row.title,
        content: row.content,
        entryDate: row.entryDate,
        recordedBy: row.recordedBy,
        authorNickname: row.authorNickname,
      );
}
