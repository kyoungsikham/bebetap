import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'daos/baby_dao.dart';
import 'daos/feeding_dao.dart';
import 'daos/diaper_dao.dart';
import 'daos/sleep_dao.dart';
import 'daos/temperature_dao.dart';
import 'daos/diary_dao.dart';

part 'app_database.g.dart';

// -------------------------------------------------------
// 테이블 정의
// -------------------------------------------------------

class BabiesTable extends Table {
  @override
  String get tableName => 'babies';

  TextColumn get id          => text()();
  TextColumn get familyId    => text()();
  TextColumn get name        => text()();
  DateTimeColumn get birthDate => dateTime()();
  TextColumn get gender      => text().withDefault(const Constant('unknown'))();
  RealColumn get weightKg    => real().nullable()();
  TextColumn get photoUrl    => text().nullable()();
  BoolColumn get isActive    => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // 동기화
  TextColumn get syncStatus  => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId    => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FeedingEntriesTable extends Table {
  @override
  String get tableName => 'feeding_entries';

  TextColumn get id                  => text()();
  TextColumn get babyId              => text()();
  TextColumn get familyId            => text()();
  TextColumn get recordedBy          => text().nullable()();
  TextColumn get type                => text()(); // formula | breast | pumped | baby_food
  IntColumn get amountMl             => integer().nullable()();
  IntColumn get durationLeftSec      => integer().nullable()();
  IntColumn get durationRightSec     => integer().nullable()();
  DateTimeColumn get startedAt       => dateTime()();
  DateTimeColumn get endedAt         => dateTime().nullable()();
  TextColumn get notes               => text().nullable()();
  TextColumn get localId             => text().nullable()();
  DateTimeColumn get createdAt       => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt       => dateTime().nullable()();

  // 동기화
  TextColumn get syncStatus  => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId    => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DiaperEntriesTable extends Table {
  @override
  String get tableName => 'diaper_entries';

  TextColumn get id          => text()();
  TextColumn get babyId      => text()();
  TextColumn get familyId    => text()();
  TextColumn get recordedBy  => text().nullable()();
  TextColumn get type        => text()(); // wet | soiled | both | dry
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get localId     => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // 동기화
  TextColumn get syncStatus  => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId    => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SleepEntriesTable extends Table {
  @override
  String get tableName => 'sleep_entries';

  TextColumn get id          => text()();
  TextColumn get babyId      => text()();
  TextColumn get familyId    => text()();
  TextColumn get recordedBy  => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt   => dateTime().nullable()();
  TextColumn get quality     => text().nullable()(); // good | fair | poor
  TextColumn get localId     => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // 동기화
  TextColumn get syncStatus  => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId    => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TemperatureEntriesTable extends Table {
  @override
  String get tableName => 'temperature_entries';

  TextColumn get id          => text()();
  TextColumn get babyId      => text()();
  TextColumn get familyId    => text()();
  TextColumn get recordedBy  => text().nullable()();
  RealColumn get celsius     => real()();
  TextColumn get method      => text()(); // rectal | axillary | ear | forehead
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get localId     => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // 동기화
  TextColumn get syncStatus  => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId    => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DiaryEntriesTable extends Table {
  @override
  String get tableName => 'diary_entries';

  TextColumn get id             => text()();
  TextColumn get babyId         => text()();
  TextColumn get familyId       => text()();
  TextColumn get recordedBy     => text().nullable()();
  TextColumn get title          => text()();
  TextColumn get content        => text()();
  DateTimeColumn get entryDate  => dateTime()(); // 자정 UTC로 저장
  TextColumn get authorNickname => text().nullable()();
  TextColumn get localId        => text().nullable()();
  DateTimeColumn get createdAt  => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt  => dateTime().nullable()();

  // 동기화
  TextColumn get syncStatus => text().withDefault(const Constant('pending_create'))();
  TextColumn get remoteId   => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';

  IntColumn get id         => integer().autoIncrement()();
  TextColumn get tableName_ => text().named('table_name')();
  TextColumn get localId   => text()();
  TextColumn get operation => text()(); // create | update | delete
  TextColumn get payload   => text()(); // JSON
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// -------------------------------------------------------
// AppDatabase
// -------------------------------------------------------

@DriftDatabase(
  tables: [
    BabiesTable,
    FeedingEntriesTable,
    DiaperEntriesTable,
    SleepEntriesTable,
    TemperatureEntriesTable,
    DiaryEntriesTable,
    SyncQueueTable,
  ],
  daos: [
    BabyDao,
    FeedingDao,
    DiaperDao,
    SleepDao,
    TemperatureDao,
    DiaryDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(diaryEntriesTable);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'bebetap_local');
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(syncQueueTable).go();
      await delete(diaryEntriesTable).go();
      await delete(temperatureEntriesTable).go();
      await delete(sleepEntriesTable).go();
      await delete(diaperEntriesTable).go();
      await delete(feedingEntriesTable).go();
      await delete(babiesTable).go();
    });
  }
}
