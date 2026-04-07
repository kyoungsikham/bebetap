import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import 'supabase_datetime.dart';

/// 로컬 SQLite → Supabase 동기화 오케스트레이터.
/// 각 save 후 trigger()를 호출해 백그라운드에서 실행된다.
class SyncEngine {
  SyncEngine(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  bool _syncing = false;

  void trigger() {
    if (_syncing) return;
    _syncAll().catchError((Object e) {
      debugPrint('SyncEngine error: $e');
    });
  }

  /// Supabase → 로컬 SQLite: 최근 7일치 데이터 pull
  /// 가족 구성원이 로그인할 때 기존 기록을 가져오기 위해 호출
  Future<void> pullRemoteData(String familyId) async {
    try {
      await Future.wait([
        _pullFeeding(familyId),
        _pullDiaper(familyId),
        _pullSleep(familyId),
        _pullTemperature(familyId),
        _pullDiary(familyId),
      ]);
    } catch (e) {
      debugPrint('SyncEngine pullRemoteData error: $e');
    }
  }

  String _resolveId(Map<String, dynamic> r) =>
      (r['local_id'] as String?) ?? (r['id'] as String);

  Future<void> _pullFeeding(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('feeding_entries')
        .select()
        .eq('family_id', familyId)
        .gte('started_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        final localId = _resolveId(r);
        final existing = await _db.feedingDao.getFeedingById(localId);
        if (existing != null && existing.syncStatus != 'synced') continue;
        await _db.feedingDao.upsertFeeding(
          FeedingEntriesTableCompanion(
            id: Value(localId),
            babyId: Value(r['baby_id'] as String),
            familyId: Value(r['family_id'] as String),
            type: Value(r['type'] as String),
            amountMl: Value(r['amount_ml'] as int?),
            durationLeftSec: Value(r['duration_left_sec'] as int?),
            durationRightSec: Value(r['duration_right_sec'] as int?),
            startedAt: Value(parseSupabaseDateTime(r['started_at'] as String)),
            endedAt: Value(
              r['ended_at'] != null
                  ? parseSupabaseDateTime(r['ended_at'] as String)
                  : null,
            ),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull feeding upsert error: $e');
      }
    }
  }

  Future<void> _pullDiaper(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('diaper_entries')
        .select()
        .eq('family_id', familyId)
        .gte('occurred_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        final localId = _resolveId(r);
        final existing = await _db.diaperDao.getDiaperById(localId);
        if (existing != null && existing.syncStatus != 'synced') continue;
        await _db.diaperDao.upsertDiaper(
          DiaperEntriesTableCompanion(
            id: Value(localId),
            babyId: Value(r['baby_id'] as String),
            familyId: Value(r['family_id'] as String),
            type: Value(r['type'] as String),
            occurredAt: Value(parseSupabaseDateTime(r['occurred_at'] as String)),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull diaper upsert error: $e');
      }
    }
  }

  Future<void> _pullSleep(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('sleep_entries')
        .select()
        .eq('family_id', familyId)
        .gte('started_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        final localId = _resolveId(r);
        final existing = await _db.sleepDao.getSleepById(localId);
        if (existing != null && existing.syncStatus != 'synced') continue;
        await _db.sleepDao.upsertSleep(
          SleepEntriesTableCompanion(
            id: Value(localId),
            babyId: Value(r['baby_id'] as String),
            familyId: Value(r['family_id'] as String),
            startedAt: Value(parseSupabaseDateTime(r['started_at'] as String)),
            endedAt: Value(
              r['ended_at'] != null
                  ? parseSupabaseDateTime(r['ended_at'] as String)
                  : null,
            ),
            quality: Value(r['quality'] as String?),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull sleep upsert error: $e');
      }
    }
  }

  Future<void> _pullTemperature(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('temperature_entries')
        .select()
        .eq('family_id', familyId)
        .gte('occurred_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        await _db.temperatureDao.upsertTemperature(
          TemperatureEntriesTableCompanion(
            id: Value(_resolveId(r)),
            babyId: Value(r['baby_id'] as String),
            familyId: Value(r['family_id'] as String),
            celsius: Value((r['celsius'] as num).toDouble()),
            method: Value(r['method'] as String? ?? 'axillary'),
            occurredAt: Value(parseSupabaseDateTime(r['occurred_at'] as String)),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull temperature upsert error: $e');
      }
    }
  }

  Future<void> _syncAll() async {
    _syncing = true;
    try {
      await Future.wait([
        _syncFeeding(),
        _syncDiaper(),
        _syncSleep(),
        _syncTemperature(),
        _syncDiary(),
      ]);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncFeeding() async {
    final pending = await _db.feedingDao.getPendingSync();
    for (final row in pending) {
      try {
        final payload = {
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': _client.auth.currentUser?.id,
          'type': row.type,
          'amount_ml': row.amountMl,
          'duration_left_sec': row.durationLeftSec,
          'duration_right_sec': row.durationRightSec,
          'started_at': row.startedAt.toUtc().toIso8601String(),
          'ended_at': row.endedAt?.toUtc().toIso8601String(),
          'notes': row.notes,
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('feeding_entries')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('local_id', row.id);
        } else {
          await _client.from('feeding_entries').upsert(payload);
        }
        await _db.feedingDao.updateSyncStatus(row.id, 'synced');
      } catch (e) {
        debugPrint('feeding sync error (${row.id}): $e');
      }
    }
  }

  Future<void> _syncDiaper() async {
    final pending = await _db.diaperDao.getPendingSync();
    for (final row in pending) {
      try {
        final payload = {
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': _client.auth.currentUser?.id,
          'type': row.type,
          'occurred_at': row.occurredAt.toUtc().toIso8601String(),
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('diaper_entries')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('local_id', row.id);
        } else {
          await _client.from('diaper_entries').upsert(payload);
        }
        await _db.diaperDao.updateSyncStatus(row.id, 'synced');
      } catch (e) {
        debugPrint('diaper sync error (${row.id}): $e');
      }
    }
  }

  Future<void> _syncSleep() async {
    final pending = await _db.sleepDao.getPendingSync();
    for (final row in pending) {
      try {
        final payload = {
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': _client.auth.currentUser?.id,
          'started_at': row.startedAt.toUtc().toIso8601String(),
          'ended_at': row.endedAt?.toUtc().toIso8601String(),
          'quality': row.quality,
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('sleep_entries')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('local_id', row.id);
        } else {
          await _client.from('sleep_entries').upsert(payload);
        }
        await _db.sleepDao.updateSyncStatus(row.id, 'synced');
      } catch (e) {
        debugPrint('sleep sync error (${row.id}): $e');
      }
    }
  }

  Future<void> _syncTemperature() async {
    final pending = await _db.temperatureDao.getPendingSync();
    for (final row in pending) {
      try {
        final payload = {
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': _client.auth.currentUser?.id,
          'celsius': row.celsius,
          'method': row.method,
          'occurred_at': row.occurredAt.toUtc().toIso8601String(),
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('temperature_entries')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('local_id', row.id);
        } else {
          await _client.from('temperature_entries').upsert(payload);
        }
        await _db.temperatureDao.updateSyncStatus(row.id, 'synced');
      } catch (e) {
        debugPrint('temperature sync error (${row.id}): $e');
      }
    }
  }

  Future<void> _syncDiary() async {
    final pending = await _db.diaryDao.getPendingSync();
    for (final row in pending) {
      try {
        // entry_date를 YYYY-MM-DD 형식으로 변환
        final entryDate =
            '${row.entryDate.year.toString().padLeft(4, '0')}-'
            '${row.entryDate.month.toString().padLeft(2, '0')}-'
            '${row.entryDate.day.toString().padLeft(2, '0')}';
        final payload = {
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': row.recordedBy ?? _client.auth.currentUser?.id,
          'title': row.title,
          'content': row.content,
          'entry_date': entryDate,
          'author_nickname': row.authorNickname,
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('diary_entries')
              .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
              .eq('local_id', row.id);
        } else {
          await _client.from('diary_entries').upsert(payload);
        }
        await _db.diaryDao.updateSyncStatus(row.id, 'synced');
      } catch (e) {
        debugPrint('diary sync error (${row.id}): $e');
      }
    }
  }

  Future<void> _pullDiary(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('diary_entries')
        .select()
        .eq('family_id', familyId)
        .gte('entry_date', '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}')
        .isFilter('deleted_at', null) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        final localId = _resolveId(r);
        final existing = await _db.diaryDao.getDiaryById(localId);
        if (existing != null && existing.syncStatus != 'synced') continue;
        // entry_date는 'YYYY-MM-DD' 문자열로 옴
        final dateStr = r['entry_date'] as String;
        final parts = dateStr.split('-');
        final entryDate = DateTime.utc(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        await _db.diaryDao.upsertDiary(
          DiaryEntriesTableCompanion(
            id: Value(localId),
            babyId: Value(r['baby_id'] as String),
            familyId: Value(r['family_id'] as String),
            recordedBy: Value(r['recorded_by'] as String?),
            title: Value(r['title'] as String),
            content: Value(r['content'] as String),
            entryDate: Value(entryDate),
            authorNickname: Value(r['author_nickname'] as String?),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull diary upsert error: $e');
      }
    }
  }
}
