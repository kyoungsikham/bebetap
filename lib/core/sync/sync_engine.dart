import 'dart:async';

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
  Timer? _debounceTimer;

  /// 세션 내 이미 pull한 범위를 기억해 중복 요청을 방지
  final Set<String> _pulledStatsRanges = {};

  /// 동일 범위 동시 요청 방지를 위한 in-flight Completer 맵
  final Map<String, Completer<void>> _pendingStatsRanges = {};

  /// 3초 디바운스: 연속 저장 시 API 호출을 하나로 통합
  void trigger() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      if (_syncing) return;
      _syncAll().catchError((Object e) {
        debugPrint('SyncEngine error: $e');
      });
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

  /// 통계 화면용: 특정 날짜 범위 데이터만 pull.
  /// 같은 범위는 세션 내 1회만 요청한다 (동시 요청도 보호).
  Future<void> pullStatsRange(
    String familyId,
    DateTime from,
    DateTime to,
  ) async {
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay = DateTime(to.year, to.month, to.day);
    final cacheKey =
        '$familyId|${fromDay.millisecondsSinceEpoch}|${toDay.millisecondsSinceEpoch}';

    if (_pulledStatsRanges.contains(cacheKey)) return;

    // 동일 키로 진행 중인 요청이 있으면 그 결과를 기다린다
    final inflight = _pendingStatsRanges[cacheKey];
    if (inflight != null) {
      await inflight.future;
      return;
    }

    final completer = Completer<void>();
    _pendingStatsRanges[cacheKey] = completer;
    try {
      await Future.wait([
        _pullFeedingRange(familyId, fromDay, toDay),
        _pullDiaperRange(familyId, fromDay, toDay),
        _pullSleepRange(familyId, fromDay, toDay),
        _pullTemperatureRange(familyId, fromDay, toDay),
      ]);
      _pulledStatsRanges.add(cacheKey);
      completer.complete();
    } catch (e) {
      completer.completeError(e);
      debugPrint('SyncEngine pullStatsRange error: $e');
    } finally {
      _pendingStatsRanges.remove(cacheKey);
    }
  }

  String _resolveId(Map<String, dynamic> r) =>
      (r['local_id'] as String?) ?? (r['id'] as String);

  Future<void> _pullFeedingRange(String familyId, DateTime from, DateTime to) =>
      _pullFeeding(familyId, from: from, to: to);

  Future<void> _pullDiaperRange(String familyId, DateTime from, DateTime to) =>
      _pullDiaper(familyId, from: from, to: to);

  Future<void> _pullSleepRange(String familyId, DateTime from, DateTime to) =>
      _pullSleep(familyId, from: from, to: to);

  Future<void> _pullTemperatureRange(
          String familyId, DateTime from, DateTime to) =>
      _pullTemperature(familyId, from: from, to: to);

  Future<void> _pullFeeding(String familyId,
      {DateTime? from, DateTime? to}) async {
    from ??= DateTime.now().subtract(const Duration(days: 7));
    var query = _client
        .from('feeding_entries')
        .select(
          'id, baby_id, family_id, type, amount_ml, duration_left_sec, '
          'duration_right_sec, started_at, ended_at, local_id',
        )
        .eq('family_id', familyId)
        .gte('started_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null);
    if (to != null) {
      query = query.lte('started_at', to.toUtc().toIso8601String());
    }
    final rows = await query.limit(500) as List<dynamic>;
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

  Future<void> _pullDiaper(String familyId,
      {DateTime? from, DateTime? to}) async {
    from ??= DateTime.now().subtract(const Duration(days: 7));
    var query = _client
        .from('diaper_entries')
        .select('id, baby_id, family_id, type, occurred_at, local_id')
        .eq('family_id', familyId)
        .gte('occurred_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null);
    if (to != null) {
      query = query.lte('occurred_at', to.toUtc().toIso8601String());
    }
    final rows = await query.limit(500) as List<dynamic>;
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
            occurredAt:
                Value(parseSupabaseDateTime(r['occurred_at'] as String)),
            syncStatus: const Value('synced'),
            remoteId: Value(r['id'] as String),
          ),
        );
      } catch (e) {
        debugPrint('pull diaper upsert error: $e');
      }
    }
  }

  Future<void> _pullSleep(String familyId,
      {DateTime? from, DateTime? to}) async {
    from ??= DateTime.now().subtract(const Duration(days: 7));
    var query = _client
        .from('sleep_entries')
        .select(
          'id, baby_id, family_id, started_at, ended_at, quality, local_id',
        )
        .eq('family_id', familyId)
        .gte('started_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null);
    if (to != null) {
      query = query.lte('started_at', to.toUtc().toIso8601String());
    }
    final rows = await query.limit(500) as List<dynamic>;
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

  Future<void> _pullTemperature(String familyId,
      {DateTime? from, DateTime? to}) async {
    from ??= DateTime.now().subtract(const Duration(days: 7));
    var query = _client
        .from('temperature_entries')
        .select(
          'id, baby_id, family_id, celsius, method, occurred_at, local_id',
        )
        .eq('family_id', familyId)
        .gte('occurred_at', from.toUtc().toIso8601String())
        .isFilter('deleted_at', null);
    if (to != null) {
      query = query.lte('occurred_at', to.toUtc().toIso8601String());
    }
    final rows = await query.limit(500) as List<dynamic>;
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
            occurredAt:
                Value(parseSupabaseDateTime(r['occurred_at'] as String)),
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
    if (pending.isEmpty) return;

    final upserts = <Map<String, dynamic>>[];
    final deleteIds = <String>[];
    final userId = _client.auth.currentUser?.id;

    for (final row in pending) {
      if (row.syncStatus == 'pending_delete') {
        deleteIds.add(row.id);
      } else {
        upserts.add({
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': userId,
          'type': row.type,
          'amount_ml': row.amountMl,
          'duration_left_sec': row.durationLeftSec,
          'duration_right_sec': row.durationRightSec,
          'started_at': row.startedAt.toUtc().toIso8601String(),
          'ended_at': row.endedAt?.toUtc().toIso8601String(),
          'notes': row.notes,
          'local_id': row.id,
        });
      }
    }

    try {
      if (upserts.isNotEmpty) {
        await _client.from('feeding_entries').upsert(upserts);
      }
      if (deleteIds.isNotEmpty) {
        await _client
            .from('feeding_entries')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('local_id', deleteIds);
      }
      for (final row in pending) {
        await _db.feedingDao.updateSyncStatus(row.id, 'synced');
      }
    } catch (e) {
      debugPrint('feeding sync error: $e');
    }
  }

  Future<void> _syncDiaper() async {
    final pending = await _db.diaperDao.getPendingSync();
    if (pending.isEmpty) return;

    final upserts = <Map<String, dynamic>>[];
    final deleteIds = <String>[];
    final userId = _client.auth.currentUser?.id;

    for (final row in pending) {
      if (row.syncStatus == 'pending_delete') {
        deleteIds.add(row.id);
      } else {
        upserts.add({
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': userId,
          'type': row.type,
          'occurred_at': row.occurredAt.toUtc().toIso8601String(),
          'local_id': row.id,
        });
      }
    }

    try {
      if (upserts.isNotEmpty) {
        await _client.from('diaper_entries').upsert(upserts);
      }
      if (deleteIds.isNotEmpty) {
        await _client
            .from('diaper_entries')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('local_id', deleteIds);
      }
      for (final row in pending) {
        await _db.diaperDao.updateSyncStatus(row.id, 'synced');
      }
    } catch (e) {
      debugPrint('diaper sync error: $e');
    }
  }

  Future<void> _syncSleep() async {
    final pending = await _db.sleepDao.getPendingSync();
    if (pending.isEmpty) return;

    final upserts = <Map<String, dynamic>>[];
    final deleteIds = <String>[];
    final userId = _client.auth.currentUser?.id;

    for (final row in pending) {
      if (row.syncStatus == 'pending_delete') {
        deleteIds.add(row.id);
      } else {
        upserts.add({
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': userId,
          'started_at': row.startedAt.toUtc().toIso8601String(),
          'ended_at': row.endedAt?.toUtc().toIso8601String(),
          'quality': row.quality,
          'local_id': row.id,
        });
      }
    }

    try {
      if (upserts.isNotEmpty) {
        await _client.from('sleep_entries').upsert(upserts);
      }
      if (deleteIds.isNotEmpty) {
        await _client
            .from('sleep_entries')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('local_id', deleteIds);
      }
      for (final row in pending) {
        await _db.sleepDao.updateSyncStatus(row.id, 'synced');
      }
    } catch (e) {
      debugPrint('sleep sync error: $e');
    }
  }

  Future<void> _syncTemperature() async {
    final pending = await _db.temperatureDao.getPendingSync();
    if (pending.isEmpty) return;

    final upserts = <Map<String, dynamic>>[];
    final deleteIds = <String>[];
    final userId = _client.auth.currentUser?.id;

    for (final row in pending) {
      if (row.syncStatus == 'pending_delete') {
        deleteIds.add(row.id);
      } else {
        upserts.add({
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': userId,
          'celsius': row.celsius,
          'method': row.method,
          'occurred_at': row.occurredAt.toUtc().toIso8601String(),
          'local_id': row.id,
        });
      }
    }

    try {
      if (upserts.isNotEmpty) {
        await _client.from('temperature_entries').upsert(upserts);
      }
      if (deleteIds.isNotEmpty) {
        await _client
            .from('temperature_entries')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('local_id', deleteIds);
      }
      for (final row in pending) {
        await _db.temperatureDao.updateSyncStatus(row.id, 'synced');
      }
    } catch (e) {
      debugPrint('temperature sync error: $e');
    }
  }

  Future<void> _syncDiary() async {
    final pending = await _db.diaryDao.getPendingSync();
    if (pending.isEmpty) return;

    final upserts = <Map<String, dynamic>>[];
    final deleteIds = <String>[];
    final userId = _client.auth.currentUser?.id;

    for (final row in pending) {
      if (row.syncStatus == 'pending_delete') {
        deleteIds.add(row.id);
      } else {
        final entryDate =
            '${row.entryDate.year.toString().padLeft(4, '0')}-'
            '${row.entryDate.month.toString().padLeft(2, '0')}-'
            '${row.entryDate.day.toString().padLeft(2, '0')}';
        upserts.add({
          'id': row.remoteId ?? row.id,
          'baby_id': row.babyId,
          'family_id': row.familyId,
          'recorded_by': row.recordedBy ?? userId,
          'title': row.title,
          'content': row.content,
          'entry_date': entryDate,
          'author_nickname': row.authorNickname,
          'local_id': row.id,
        });
      }
    }

    try {
      if (upserts.isNotEmpty) {
        await _client.from('diary_entries').upsert(upserts);
      }
      if (deleteIds.isNotEmpty) {
        await _client
            .from('diary_entries')
            .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
            .inFilter('local_id', deleteIds);
      }
      for (final row in pending) {
        await _db.diaryDao.updateSyncStatus(row.id, 'synced');
      }
    } catch (e) {
      debugPrint('diary sync error: $e');
    }
  }

  Future<void> _pullDiary(String familyId) async {
    final from = DateTime.now().subtract(const Duration(days: 7));
    final rows = await _client
        .from('diary_entries')
        .select(
          'id, baby_id, family_id, recorded_by, title, content, '
          'entry_date, author_nickname, local_id',
        )
        .eq('family_id', familyId)
        .gte(
          'entry_date',
          '${from.year}-${from.month.toString().padLeft(2, '0')}-'
          '${from.day.toString().padLeft(2, '0')}',
        )
        .isFilter('deleted_at', null)
        .limit(500) as List<dynamic>;
    for (final raw in rows) {
      final r = raw as Map<String, dynamic>;
      try {
        final localId = _resolveId(r);
        final existing = await _db.diaryDao.getDiaryById(localId);
        if (existing != null && existing.syncStatus != 'synced') continue;
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
