import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';

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

  Future<void> _upsertFeeding(Map<String, dynamic> r) =>
      _db.feedingDao.upsertFeeding(
        FeedingEntriesTableCompanion(
          id: Value(_resolveId(r)),
          babyId: Value(r['baby_id'] as String),
          familyId: Value(r['family_id'] as String),
          type: Value(r['type'] as String),
          amountMl: Value(r['amount_ml'] as int?),
          durationLeftSec: Value(r['duration_left_sec'] as int?),
          durationRightSec: Value(r['duration_right_sec'] as int?),
          startedAt: Value(DateTime.parse(r['started_at'] as String)),
          endedAt: Value(
            r['ended_at'] != null
                ? DateTime.parse(r['ended_at'] as String)
                : null,
          ),
          syncStatus: const Value('synced'),
          remoteId: Value(r['id'] as String),
        ),
      );

  Future<void> _upsertDiaper(Map<String, dynamic> r) =>
      _db.diaperDao.upsertDiaper(
        DiaperEntriesTableCompanion(
          id: Value(_resolveId(r)),
          babyId: Value(r['baby_id'] as String),
          familyId: Value(r['family_id'] as String),
          type: Value(r['type'] as String),
          occurredAt: Value(DateTime.parse(r['occurred_at'] as String)),
          syncStatus: const Value('synced'),
          remoteId: Value(r['id'] as String),
        ),
      );

  Future<void> _upsertSleep(Map<String, dynamic> r) =>
      _db.sleepDao.upsertSleep(
        SleepEntriesTableCompanion(
          id: Value(_resolveId(r)),
          babyId: Value(r['baby_id'] as String),
          familyId: Value(r['family_id'] as String),
          startedAt: Value(DateTime.parse(r['started_at'] as String)),
          endedAt: Value(
            r['ended_at'] != null
                ? DateTime.parse(r['ended_at'] as String)
                : null,
          ),
          quality: Value(r['quality'] as String?),
          syncStatus: const Value('synced'),
          remoteId: Value(r['id'] as String),
        ),
      );

  Future<void> _upsertTemperature(Map<String, dynamic> r) =>
      _db.temperatureDao.upsertTemperature(
        TemperatureEntriesTableCompanion(
          id: Value(_resolveId(r)),
          babyId: Value(r['baby_id'] as String),
          familyId: Value(r['family_id'] as String),
          celsius: Value((r['celsius'] as num).toDouble()),
          method: Value(r['method'] as String? ?? 'axillary'),
          occurredAt: Value(DateTime.parse(r['occurred_at'] as String)),
          syncStatus: const Value('synced'),
          remoteId: Value(r['id'] as String),
        ),
      );
}
