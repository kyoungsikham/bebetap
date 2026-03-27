import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

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

  Future<void> _syncAll() async {
    _syncing = true;
    try {
      await Future.wait([
        _syncFeeding(),
        _syncDiaper(),
        _syncSleep(),
        _syncTemperature(),
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
          'started_at': row.startedAt.toIso8601String(),
          'ended_at': row.endedAt?.toIso8601String(),
          'notes': row.notes,
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('feeding_entries')
              .update({'deleted_at': DateTime.now().toIso8601String()})
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
          'occurred_at': row.occurredAt.toIso8601String(),
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('diaper_entries')
              .update({'deleted_at': DateTime.now().toIso8601String()})
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
          'started_at': row.startedAt.toIso8601String(),
          'ended_at': row.endedAt?.toIso8601String(),
          'quality': row.quality,
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('sleep_entries')
              .update({'deleted_at': DateTime.now().toIso8601String()})
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
          'occurred_at': row.occurredAt.toIso8601String(),
          'local_id': row.id,
        };
        if (row.syncStatus == 'pending_delete') {
          await _client
              .from('temperature_entries')
              .update({'deleted_at': DateTime.now().toIso8601String()})
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
}
