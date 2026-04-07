import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import 'supabase_datetime.dart';

/// Supabase Realtime 채널 구독 — 가족 구성원의 실시간 데이터 수신
class RealtimeListener {
  RealtimeListener(this._client, this._db);

  final SupabaseClient _client;
  final AppDatabase _db;

  RealtimeChannel? _channel;
  void Function()? _onRemoteChange;

  void subscribe(String familyId, {void Function()? onRemoteChange}) {
    _onRemoteChange = onRemoteChange;
    _channel?.unsubscribe();

    _channel = _client.channel('family_realtime_$familyId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'feeding_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleFeedingChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'feeding_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleFeedingChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'diaper_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleDiaperChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'sleep_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleSleepChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'sleep_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleSleepChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'temperature_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleTemperatureChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'diary_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleDiaryChange(payload),
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'diary_entries',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'family_id',
          value: familyId,
        ),
        callback: (payload) => _handleDiaryChange(payload),
      );

    _channel!.subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void _handleFeedingChange(PostgresChangePayload payload) {
    final record = payload.newRecord;
    if (record.isEmpty) return;
    _upsertFeeding(record)
        .then((_) => _onRemoteChange?.call())
        .catchError((Object e) => debugPrint('Realtime feeding error: $e'));
  }

  void _handleDiaperChange(PostgresChangePayload payload) {
    final record = payload.newRecord;
    if (record.isEmpty) return;
    _upsertDiaper(record)
        .then((_) => _onRemoteChange?.call())
        .catchError((Object e) => debugPrint('Realtime diaper error: $e'));
  }

  void _handleSleepChange(PostgresChangePayload payload) {
    final record = payload.newRecord;
    if (record.isEmpty) return;
    _upsertSleep(record)
        .then((_) => _onRemoteChange?.call())
        .catchError((Object e) => debugPrint('Realtime sleep error: $e'));
  }

  void _handleTemperatureChange(PostgresChangePayload payload) {
    final record = payload.newRecord;
    if (record.isEmpty) return;
    _upsertTemperature(record)
        .then((_) => _onRemoteChange?.call())
        .catchError((Object e) => debugPrint('Realtime temperature error: $e'));
  }

  // local_id가 있으면 기존 로컬 항목의 PK를 사용하여 업데이트 (자기 자신의 데이터)
  // 없으면 서버 UUID를 PK로 삽입 (다른 기기 데이터)
  String _resolveId(Map<String, dynamic> r) =>
      (r['local_id'] as String?) ?? (r['id'] as String);

  DateTime _parseDateTime(String s) {
    debugPrint('[Realtime] raw timestamp: "$s" → parsed: ${parseSupabaseDateTime(s)}');
    return parseSupabaseDateTime(s);
  }

  Future<void> _upsertFeeding(Map<String, dynamic> r) async {
    final localId = _resolveId(r);
    final existing = await _db.feedingDao.getFeedingById(localId);
    if (existing != null && existing.syncStatus != 'synced') return;
    await _db.feedingDao.upsertFeeding(
      FeedingEntriesTableCompanion(
        id: Value(localId),
        babyId: Value(r['baby_id'] as String),
        familyId: Value(r['family_id'] as String),
        type: Value(r['type'] as String),
        amountMl: Value(r['amount_ml'] as int?),
        durationLeftSec: Value(r['duration_left_sec'] as int?),
        durationRightSec: Value(r['duration_right_sec'] as int?),
        startedAt: Value(_parseDateTime(r['started_at'] as String)),
        endedAt: Value(
          r['ended_at'] != null
              ? _parseDateTime(r['ended_at'] as String)
              : null,
        ),
        syncStatus: const Value('synced'),
        remoteId: Value(r['id'] as String),
      ),
    );
  }

  Future<void> _upsertDiaper(Map<String, dynamic> r) async {
    final localId = _resolveId(r);
    final existing = await _db.diaperDao.getDiaperById(localId);
    if (existing != null && existing.syncStatus != 'synced') return;
    await _db.diaperDao.upsertDiaper(
      DiaperEntriesTableCompanion(
        id: Value(localId),
        babyId: Value(r['baby_id'] as String),
        familyId: Value(r['family_id'] as String),
        type: Value(r['type'] as String),
        occurredAt: Value(_parseDateTime(r['occurred_at'] as String)),
        syncStatus: const Value('synced'),
        remoteId: Value(r['id'] as String),
      ),
    );
  }

  Future<void> _upsertSleep(Map<String, dynamic> r) async {
    final localId = _resolveId(r);
    final existing = await _db.sleepDao.getSleepById(localId);
    if (existing != null && existing.syncStatus != 'synced') return;
    await _db.sleepDao.upsertSleep(
      SleepEntriesTableCompanion(
        id: Value(localId),
        babyId: Value(r['baby_id'] as String),
        familyId: Value(r['family_id'] as String),
        startedAt: Value(_parseDateTime(r['started_at'] as String)),
        endedAt: Value(
          r['ended_at'] != null
              ? _parseDateTime(r['ended_at'] as String)
              : null,
        ),
        quality: Value(r['quality'] as String?),
        syncStatus: const Value('synced'),
        remoteId: Value(r['id'] as String),
      ),
    );
  }

  void _handleDiaryChange(PostgresChangePayload payload) {
    final record = payload.newRecord;
    if (record.isEmpty) return;
    _upsertDiary(record)
        .then((_) => _onRemoteChange?.call())
        .catchError((Object e) => debugPrint('Realtime diary error: $e'));
  }

  Future<void> _upsertDiary(Map<String, dynamic> r) async {
    final localId = _resolveId(r);
    final existing = await _db.diaryDao.getDiaryById(localId);
    if (existing != null && existing.syncStatus != 'synced') return;
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
  }

  Future<void> _upsertTemperature(Map<String, dynamic> r) async {
    final localId = _resolveId(r);
    final existing = await _db.temperatureDao.getTemperatureById(localId);
    if (existing != null && existing.syncStatus != 'synced') return;
    await _db.temperatureDao.upsertTemperature(
      TemperatureEntriesTableCompanion(
        id: Value(localId),
        babyId: Value(r['baby_id'] as String),
        familyId: Value(r['family_id'] as String),
        celsius: Value((r['celsius'] as num).toDouble()),
        method: Value(r['method'] as String? ?? 'axillary'),
        occurredAt: Value(_parseDateTime(r['occurred_at'] as String)),
        syncStatus: const Value('synced'),
        remoteId: Value(r['id'] as String),
      ),
    );
  }
}
