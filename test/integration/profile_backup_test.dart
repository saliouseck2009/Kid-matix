import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/uuid_id_generator.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/profile_backup_part.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/challenge_backup_part.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_backup_part.dart';
import 'package:kid_matix/features/mascot/data/repositories/mascot_backup_part.dart';
import 'package:kid_matix/features/mastery/data/repositories/mastery_backup_part.dart';
import 'package:kid_matix/features/profile/data/datasources/active_profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/backup_file_data_source.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_codec.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_backup_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/datasources/profile_local_data_source_impl.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_backup_repository_impl.dart';
import 'package:kid_matix/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_import_choice.dart';
import 'package:kid_matix/features/profile/domain/entities/backup_preview_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/export_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/import_backup_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/nickname_checker.dart';
import 'package:kid_matix/features/profile/domain/usecases/pick_backup_use_case.dart';
import 'package:kid_matix/features/quiz/data/repositories/quiz_backup_part.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_backup_part.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/data_state_test_extension.dart';
import '../helpers/in_memory_local_storage.dart';

final class _Clock implements Clock {
  @override
  DateTime now() => DateTime(2026, 10, 12, 18);
}

/// The share sheet and the file picker of a phone.
final class _FakeFiles implements BackupFileDataSource {
  String? sharedName;
  String? sharedContent;
  String? fileToPick;

  @override
  Future<bool> shareFile({
    required String fileName,
    required String content,
  }) async {
    sharedName = fileName;
    sharedContent = content;
    return true;
  }

  @override
  Future<String?> pickFile() async => fileToPick;
}

/// One phone: its database, preferences and backup use cases.
final class _Phone {
  _Phone._(this.appDatabase, this.storage, this.files, this.changeBus) {
    final ProfileBackupParts parts = ProfileBackupParts()
      ..add(const MasteryBackupPart())
      ..add(const StageProgressBackupPart())
      ..add(const RewardBackupPart())
      ..add(const MascotBackupPart())
      ..add(
        ChallengeBackupPart(
          choicesOf: () => TrainingChoiceLocalDataSourceImpl(storage: storage),
        ),
      )
      ..add(const QuizBackupPart());
    final ProfileRepositoryImpl profiles = ProfileRepositoryImpl(
      profiles: ProfileLocalDataSourceImpl(database: appDatabase),
      activeProfile: ActiveProfileLocalDataSourceImpl(storage: storage),
      clock: _Clock(),
      changeBus: changeBus,
    );
    final ProfileBackupRepositoryImpl backups = ProfileBackupRepositoryImpl(
      local: ProfileBackupLocalDataSourceImpl(
        database: appDatabase,
        parts: parts,
        idGenerator: const UuidIdGenerator(),
      ),
      files: files,
      codec: const ProfileBackupCodec(),
      clock: _Clock(),
      readAppVersion: () async => '1.2.0',
      changeBus: changeBus,
    );
    exportProfile = ExportProfileUseCase(repository: backups);
    pickBackup = PickBackupUseCase(backups: backups, profiles: profiles);
    importBackup = ImportBackupUseCase(
      backups: backups,
      profiles: profiles,
      nicknameChecker: NicknameChecker(repository: profiles),
      idGenerator: const UuidIdGenerator(),
    );
  }

  static Future<_Phone> open(String path) async {
    final AppDatabase appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => path,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    return _Phone._(
      appDatabase,
      InMemoryLocalStorage(),
      _FakeFiles(),
      TableChangeBus(),
    );
  }

  final AppDatabase appDatabase;
  final InMemoryLocalStorage storage;
  final _FakeFiles files;
  final TableChangeBus changeBus;
  late final ExportProfileUseCase exportProfile;
  late final PickBackupUseCase pickBackup;
  late final ImportBackupUseCase importBackup;

  Future<Database> get database => appDatabase.database;

  /// Picks [file] and imports it with [choice]; returns the outcome.
  Future<DataState<String>> importFile(
    String file, {
    BackupImportChoice choice = const ImportAsNewPlayer(),
  }) async {
    files.fileToPick = file;
    final DataState<BackupPreviewEntity?> picked = await pickBackup();
    if (picked case DataFailed<BackupPreviewEntity?>(:final exception)) {
      return DataFailed<String>(exception);
    }
    final BackupPreviewEntity preview = picked.requireData!;
    return importBackup(
      params: ImportBackupParams(backup: preview.backup, choice: choice),
    );
  }

  Future<String> idOf(String nickname) async {
    final List<Map<String, Object?>> rows = await (await database).query(
      'profile',
      where: 'nickname = ?',
      whereArgs: <Object>[nickname],
    );
    return rows.single['id']! as String;
  }

  Future<int> countProfiles() async {
    final List<Map<String, Object?>> rows = await (await database).rawQuery(
      'SELECT COUNT(*) AS count FROM profile',
    );
    return rows.single['count']! as int;
  }
}

/// Every table holding a player's data, with the query of their rows.
const Map<String, String> _playerTables = <String, String>{
  'profile': 'SELECT * FROM profile WHERE id = ?',
  'profile_settings': 'SELECT * FROM profile_settings WHERE profile_id = ?',
  'quiz_session': 'SELECT * FROM quiz_session WHERE profile_id = ?',
  'quiz_answer':
      'SELECT a.* FROM quiz_answer a JOIN quiz_session s '
      'ON s.id = a.session_id WHERE s.profile_id = ?',
  'item_progress': 'SELECT * FROM item_progress WHERE profile_id = ?',
  'stage_progress': 'SELECT * FROM stage_progress WHERE profile_id = ?',
  'session_reward': 'SELECT * FROM session_reward WHERE profile_id = ?',
  'xp_award': 'SELECT * FROM xp_award WHERE profile_id = ?',
  'streak': 'SELECT * FROM streak WHERE profile_id = ?',
  'badge_unlock': 'SELECT * FROM badge_unlock WHERE profile_id = ?',
  'reward_stats': 'SELECT * FROM reward_stats WHERE profile_id = ?',
  'mascot': 'SELECT * FROM mascot WHERE profile_id = ?',
  'record': 'SELECT * FROM record WHERE profile_id = ?',
};

/// Identifier columns, given new values on import.
const Set<String> _idColumns = <String>{'id', 'profile_id', 'session_id'};

/// The rows of [profileId] in every table, without their identifiers,
/// sorted: two phones holding the same player give the same snapshot.
Future<Map<String, List<String>>> _snapshot(
  Database database,
  String profileId,
) async {
  final Map<String, List<String>> snapshot = <String, List<String>>{};
  for (final MapEntry<String, String> table in _playerTables.entries) {
    final List<Map<String, Object?>> rows = await database.rawQuery(
      table.value,
      <Object>[profileId],
    );
    snapshot[table.key] =
        rows
            .map(
              (Map<String, Object?> row) => jsonEncode(<String, Object?>{
                for (final MapEntry<String, Object?> column in row.entries)
                  if (!_idColumns.contains(column.key))
                    column.key: column.value,
              }),
            )
            .toList()
          ..sort();
  }
  return snapshot;
}

/// Session identifiers every row of [profileId] points to, which must all
/// be sessions of the player.
Future<void> _expectLinksKept(Database database, String profileId) async {
  final Set<String> sessions = (await database.query(
    'quiz_session',
    where: 'profile_id = ?',
    whereArgs: <Object>[profileId],
  )).map((Map<String, Object?> row) => row['id']! as String).toSet();
  for (final String table in <String>[
    'session_reward',
    'badge_unlock',
    'record',
  ]) {
    final List<Map<String, Object?>> rows = await database.query(
      table,
      where: 'profile_id = ? AND session_id IS NOT NULL',
      whereArgs: <Object>[profileId],
    );
    for (final Map<String, Object?> row in rows) {
      expect(sessions, contains(row['session_id']), reason: table);
    }
  }
}

Future<void> _seedPlayer(
  Database database, {
  required String id,
  required String nickname,
  int level = 5,
}) async {
  await database.insert('profile', <String, Object?>{
    'id': id,
    'nickname': nickname,
    'normalized_nickname': nickname.toLowerCase(),
    'avatar': 'avatar3',
    'color': 'green',
    'total_xp': 1250,
    'level': level,
    'created_at': 1000,
    'last_played_at': 9000,
    'updated_at': 9000,
  });
  await database.insert('profile_settings', <String, Object?>{
    'profile_id': id,
    'timer_mode': 'relaxed',
    'daily_goal_xp': 50,
    'is_sound_enabled': 0,
    'is_vibration_enabled': 1,
    'is_reduced_motion_enabled': 1,
    'is_everything_unlocked': 0,
    'updated_at': 9000,
  });
}

/// A player with something in every table, and one preference.
Future<void> _seedProgress(
  Database database,
  InMemoryLocalStorage storage, {
  required String profileId,
}) async {
  final String boss = 'boss-$profileId';
  final String attack = 'attack-$profileId';
  await database.insert('quiz_session', <String, Object?>{
    'id': boss,
    'profile_id': profileId,
    'domain_id': 'multiplication',
    'mode': 'path',
    'status': 'completed',
    'started_at': 5000,
    'duration_ms': 60000,
    'question_count': 13,
    'correct_count': 12,
    'source_key': 'path:mul:2:boss',
    'boss_outcome': 'defeated',
    'updated_at': 5000,
  });
  await database.insert('quiz_session', <String, Object?>{
    'id': attack,
    'profile_id': profileId,
    'domain_id': 'multiplication',
    'mode': 'timeAttack',
    'status': 'completed',
    'started_at': 6000,
    'duration_ms': 60000,
    'question_count': 14,
    'correct_count': 14,
    'source_key': 'timeAttack:mul:1,2',
    'updated_at': 6000,
  });
  for (final (String session, int position, String item) answer
      in <(String, int, String)>[
        (boss, 0, 'mul:2x3'),
        (boss, 1, 'mul:2x7'),
        (attack, 0, 'mul:2x3'),
      ]) {
    await database.insert('quiz_answer', <String, Object?>{
      'session_id': answer.$1,
      'position': answer.$2,
      'item_key': answer.$3,
      'question_type_id': 'multipleChoice',
      'is_correct': 1,
      'is_timed_out': 0,
      'is_retry': 0,
      'answer_time_ms': 1800,
      'updated_at': 5000,
    });
  }
  for (final (String item, int box) progress in <(String, int)>[
    ('mul:2x3', 5),
    ('mul:2x7', 1),
  ]) {
    await database.insert('item_progress', <String, Object?>{
      'profile_id': profileId,
      'domain_id': 'multiplication',
      'item_key': progress.$1,
      'presentation_count': 6,
      'correct_count': 5,
      'last_answer_times_ms': '1800,2100',
      'box': progress.$2,
      'next_review_at': 86400000,
      'updated_at': 5000,
    });
  }
  for (final (String stage, int stars) result in <(String, int)>[
    ('discovery', 3),
    ('boss', 2),
    ('placement', 0),
  ]) {
    await database.insert('stage_progress', <String, Object?>{
      'profile_id': profileId,
      'domain_id': 'multiplication',
      'unit_key': result.$1 == 'placement' ? 'mul:7' : 'mul:2',
      'stage': result.$1,
      'best_stars': result.$2,
      'best_score': result.$1 == 'placement' ? 1 : 12,
      'completed_at': 5000,
      'updated_at': 5000,
    });
  }
  await _seedRewards(database, profileId: profileId, boss: boss);
  await database.insert('mascot', <String, Object?>{
    'profile_id': profileId,
    'name': 'Pico',
    'worn_accessories': 'cap,roundGlasses',
    'celebrated_stage': 2,
    'updated_at': 5000,
  });
  await database.insert('record', <String, Object?>{
    'profile_id': profileId,
    'mode': 'timeAttack',
    'best_score': 14,
    'session_id': attack,
    'achieved_at': 6000,
    'previous_best': 5,
    'updated_at': 6000,
  });
  await storage.writeString(
    key: '${TrainingChoiceLocalDataSourceImpl.keyPrefix}$profileId',
    value: 'training:mul:2,5:20',
  );
}

Future<void> _seedRewards(
  Database database, {
  required String profileId,
  required String boss,
}) async {
  await database.insert('session_reward', <String, Object?>{
    'session_id': boss,
    'profile_id': profileId,
    'xp_earned': 175,
    'xp_version': 1,
    'earned_at': 5000,
    'updated_at': 5000,
  });
  await database.insert('xp_award', <String, Object?>{
    'id': 'duel-$profileId',
    'profile_id': profileId,
    'source_key': 'duel',
    'xp_earned': 120,
    'earned_at': 7000,
    'updated_at': 7000,
  });
  await database.insert('streak', <String, Object?>{
    'profile_id': profileId,
    'current_streak': 4,
    'best_streak': 9,
    'last_played_day': 8000,
    'joker_used_week': 3000,
    'updated_at': 8000,
  });
  await database.insert('badge_unlock', <String, Object?>{
    'profile_id': profileId,
    'badge_key': 'firstStep',
    'unlocked_at': 5000,
    'session_id': boss,
    'updated_at': 5000,
  });
  await database.insert('badge_unlock', <String, Object?>{
    'profile_id': profileId,
    'badge_key': 'regular',
    'unlocked_at': 8000,
    'updated_at': 8000,
  });
  await database.insert('reward_stats', <String, Object?>{
    'profile_id': profileId,
    'lightning_answers': 33,
    'updated_at': 5000,
  });
}

/// Rewrites the file [text] with [change] applied to its JSON object.
String _edit(String text, void Function(Map<String, Object?> json) change) {
  final Map<String, Object?> json = jsonDecode(text) as Map<String, Object?>;
  change(json);
  return jsonEncode(json);
}

Map<String, Object?> _section(Map<String, Object?> json, String name) {
  return (json['sections']! as Map<String, Object?>)[name]!
      as Map<String, Object?>;
}

void main() {
  late Directory directory;
  late _Phone phoneA;
  late _Phone phoneB;
  late String file;
  late Map<String, List<String>> expectedSnapshot;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('kid_matix_backup');
    phoneA = await _Phone.open('${directory.path}/a.db');
    phoneB = await _Phone.open('${directory.path}/b.db');
    final Database databaseA = await phoneA.database;
    await _seedPlayer(databaseA, id: 'a1', nickname: 'Awa');
    await _seedProgress(databaseA, phoneA.storage, profileId: 'a1');
    await _seedPlayer(databaseA, id: 'a2', nickname: 'Bob', level: 2);
    await _seedProgress(databaseA, phoneA.storage, profileId: 'a2');
    expectedSnapshot = await _snapshot(databaseA, 'a1');
    final DataState<bool> exported = await phoneA.exportProfile(params: 'a1');
    expect(exported.requireData, true);
    file = phoneA.files.sharedContent!;
  });

  tearDown(() async {
    await phoneA.appDatabase.close();
    await phoneB.appDatabase.close();
    directory.deleteSync(recursive: true);
  });

  group('Profile backup', () {
    test('writes a versioned .kidmatix file of one player', () {
      // Act
      final Map<String, Object?> actualJson =
          jsonDecode(file) as Map<String, Object?>;
      // Assert
      expect(phoneA.files.sharedName, 'KidMatix-Awa-2026-10-12.kidmatix');
      expect(actualJson['format'], 'kidmatix-profile');
      expect(actualJson['version'], 1);
      expect(actualJson['appVersion'], '1.2.0');
      expect(actualJson['exportedAt'], isA<String>());
      expect(
        (actualJson['sections']! as Map<String, Object?>).keys,
        unorderedEquals(<String>[
          'profile',
          'quiz',
          'mastery',
          'learningPath',
          'reward',
          'mascot',
          'challenge',
        ]),
      );
      expect(file, isNot(contains('Bob')));
    });

    test('brings every row of the player to another phone', () async {
      // Act
      final DataState<String> actualImport = await phoneB.importFile(file);
      // Assert
      expect(actualImport.requireData, 'Awa');
      final Database databaseB = await phoneB.database;
      final String actualId = await phoneB.idOf('Awa');
      expect(actualId, isNot('a1'));
      expect(await _snapshot(databaseB, actualId), expectedSnapshot);
      await _expectLinksKept(databaseB, actualId);
      expect(
        await phoneB.storage.readString(
          key: '${TrainingChoiceLocalDataSourceImpl.keyPrefix}$actualId',
        ),
        'training:mul:2,5:20',
      );
      expect(await phoneB.countProfiles(), 1);
    });

    test('keeps level, streak, stars, mastery, badges and mascot', () async {
      // Act
      await phoneB.importFile(file);
      // Assert
      final Database databaseB = await phoneB.database;
      final String id = await phoneB.idOf('Awa');
      final Map<String, Object?> profile = (await databaseB.query(
        'profile',
        where: 'id = ?',
        whereArgs: <Object>[id],
      )).single;
      expect(profile['level'], 5);
      expect(profile['total_xp'], 1250);
      final List<Map<String, Object?>> streak = await databaseB.query(
        'streak',
        where: 'profile_id = ?',
        whereArgs: <Object>[id],
      );
      expect(streak.single['current_streak'], 4);
      final List<Map<String, Object?>> stars = await databaseB.query(
        'stage_progress',
        where: 'profile_id = ? AND stage = ?',
        whereArgs: <Object>[id, 'boss'],
      );
      expect(stars.single['best_stars'], 2);
      final List<Map<String, Object?>> boxes = await databaseB.query(
        'item_progress',
        where: 'profile_id = ? AND item_key = ?',
        whereArgs: <Object>[id, 'mul:2x3'],
      );
      expect(boxes.single['box'], 5);
      final List<Map<String, Object?>> mascot = await databaseB.query(
        'mascot',
        where: 'profile_id = ?',
        whereArgs: <Object>[id],
      );
      expect(mascot.single['name'], 'Pico');
    });

    test(
      'replaces the player with the same nickname, keeping their id',
      () async {
        // Arrange
        final Database databaseB = await phoneB.database;
        await _seedPlayer(databaseB, id: 'b1', nickname: 'Awa', level: 1);
        await databaseB.insert('item_progress', <String, Object?>{
          'profile_id': 'b1',
          'domain_id': 'multiplication',
          'item_key': 'mul:9x9',
          'presentation_count': 1,
          'correct_count': 0,
          'last_answer_times_ms': '',
          'box': 1,
          'updated_at': 1,
        });
        phoneB.files.fileToPick = file;
        final DataState<BackupPreviewEntity?> picked = await phoneB
            .pickBackup();
        final BackupPreviewEntity preview = picked.requireData!;
        // Act
        final DataState<String> actualImport = await phoneB.importBackup(
          params: ImportBackupParams(
            backup: preview.backup,
            choice: ReplacePlayer(profileId: preview.conflictingProfile!.id),
          ),
        );
        // Assert
        expect(preview.conflictingProfile?.id, 'b1');
        expect(actualImport.requireData, 'Awa');
        expect(await phoneB.countProfiles(), 1);
        expect(await phoneB.idOf('Awa'), 'b1');
        expect(await _snapshot(databaseB, 'b1'), expectedSnapshot);
      },
    );

    test('imports under another nickname, twice, without collision', () async {
      // Arrange
      final Database databaseB = await phoneB.database;
      await _seedPlayer(databaseB, id: 'b1', nickname: 'Awa', level: 1);
      // Act
      final DataState<String> actualFirst = await phoneB.importFile(
        file,
        choice: const RenamePlayer(nickname: 'Awa Deux'),
      );
      final DataState<String> actualSecond = await phoneB.importFile(
        file,
        choice: const RenamePlayer(nickname: '  Awa   Trois '),
      );
      // Assert
      expect(actualFirst.requireData, 'Awa Deux');
      expect(actualSecond.requireData, 'Awa Trois');
      expect(await phoneB.countProfiles(), 3);
      for (final String nickname in <String>['Awa Deux', 'Awa Trois']) {
        final String id = await phoneB.idOf(nickname);
        final Map<String, List<String>> actualSnapshot = await _snapshot(
          databaseB,
          id,
        );
        expect(
          actualSnapshot..remove('profile'),
          Map<String, List<String>>.of(expectedSnapshot)..remove('profile'),
        );
        await _expectLinksKept(databaseB, id);
      }
    });

    test('refuses a new nickname already taken', () async {
      // Arrange
      final Database databaseB = await phoneB.database;
      await _seedPlayer(databaseB, id: 'b1', nickname: 'Awa');
      await _seedPlayer(databaseB, id: 'b2', nickname: 'Lina');
      // Act
      final DataState<String> actualImport = await phoneB.importFile(
        file,
        choice: const RenamePlayer(nickname: 'lina'),
      );
      // Assert
      expect(actualImport.exceptionOrNull?.code, AppErrorCode.conflict);
      expect(await phoneB.countProfiles(), 2);
    });

    test('refuses a damaged file', () async {
      // Act
      final DataState<String> actualTruncated = await phoneB.importFile(
        file.substring(0, file.length ~/ 2),
      );
      final DataState<String> actualOtherFile = await phoneB.importFile(
        '{"format": "notes", "version": 1}',
      );
      final DataState<String> actualNotJson = await phoneB.importFile(
        'PK\u0003',
      );
      // Assert
      for (final DataState<String> actual in <DataState<String>>[
        actualTruncated,
        actualOtherFile,
        actualNotJson,
      ]) {
        expect(actual.exceptionOrNull?.code, AppErrorCode.invalidFile);
      }
      expect(await phoneB.countProfiles(), 0);
    });

    test('refuses a malformed row and writes nothing at all', () async {
      // Arrange
      final String damaged = _edit(file, (Map<String, Object?> json) {
        final Map<String, Object?> mastery = _section(json, 'mastery');
        final List<Object?> items = mastery['items']! as List<Object?>;
        (items.first! as Map<String, Object?>)['box'] = 'five';
      });
      // Act
      final DataState<String> actualImport = await phoneB.importFile(damaged);
      // Assert
      expect(actualImport.exceptionOrNull?.code, AppErrorCode.invalidFile);
      expect(await phoneB.countProfiles(), 0);
      final Database databaseB = await phoneB.database;
      expect(await databaseB.query('quiz_session'), isEmpty);
    });

    test('refuses rows pointing to a session missing from the file', () async {
      // Arrange
      final String damaged = _edit(file, (Map<String, Object?> json) {
        _section(json, 'quiz')['sessions'] = <Object?>[];
        _section(json, 'quiz')['answers'] = <Object?>[];
      });
      // Act
      final DataState<String> actualImport = await phoneB.importFile(damaged);
      // Assert
      expect(actualImport.exceptionOrNull?.code, AppErrorCode.invalidFile);
      expect(await phoneB.countProfiles(), 0);
    });

    test('refuses a file of a newer version', () async {
      // Arrange
      final String newer = _edit(file, (Map<String, Object?> json) {
        json['version'] = 2;
        json['sections'] = 'a layout this app does not know';
      });
      // Act
      final DataState<String> actualImport = await phoneB.importFile(newer);
      // Assert
      expect(
        actualImport.exceptionOrNull?.code,
        AppErrorCode.unsupportedVersion,
      );
      expect(await phoneB.countProfiles(), 0);
    });

    test('ignores unknown keys and reads a file missing sections', () async {
      // Arrange
      final String other = _edit(file, (Map<String, Object?> json) {
        json['comment'] = 'written by a later 1.x';
        final Map<String, Object?> sections =
            json['sections']! as Map<String, Object?>;
        sections['coins'] = <String, Object?>{'balance': 40};
        sections.remove('mascot');
        final Map<String, Object?> reward = _section(json, 'reward');
        (reward['streak']! as Map<String, Object?>)['future_column'] = 1;
      });
      // Act
      final DataState<String> actualImport = await phoneB.importFile(other);
      // Assert
      expect(actualImport.requireData, 'Awa');
      final Database databaseB = await phoneB.database;
      final Map<String, List<String>> actualSnapshot = await _snapshot(
        databaseB,
        await phoneB.idOf('Awa'),
      );
      expect(actualSnapshot['mascot'], isEmpty);
      expect(actualSnapshot['streak'], expectedSnapshot['streak']);
    });
  });
}
