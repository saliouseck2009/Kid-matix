import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/core/storage/app_migrations.dart';
import 'package:kid_matix/core/storage/migration_runner.dart';
import 'package:kid_matix/core/storage/progress_reset_hook.dart';
import 'package:kid_matix/core/storage/progress_resetter.dart';
import 'package:kid_matix/core/storage/table_change_bus.dart';
import 'package:kid_matix/features/challenge/data/repositories/record_reset_hook.dart';
import 'package:kid_matix/features/learning_path/data/repositories/stage_progress_reset_hook.dart';
import 'package:kid_matix/features/mascot/data/repositories/mascot_reset_hook.dart';
import 'package:kid_matix/features/mastery/data/repositories/mastery_reset_hook.dart';
import 'package:kid_matix/features/profile/domain/usecases/reset_progress_use_case.dart';
import 'package:kid_matix/features/quiz/data/repositories/quiz_reset_hook.dart';
import 'package:kid_matix/features/reward/data/repositories/reward_reset_hook.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Tables holding the progress of a player, by the column naming them.
const Map<String, String> _progressTables = <String, String>{
  'quiz_session': 'profile_id',
  'item_progress': 'profile_id',
  'stage_progress': 'profile_id',
  'session_reward': 'profile_id',
  'streak': 'profile_id',
  'badge_unlock': 'profile_id',
  'reward_stats': 'profile_id',
  'record': 'profile_id',
};

Future<void> _seedPlayer(Database database, String id) async {
  await database.insert('profile', <String, Object?>{
    'id': id,
    'nickname': 'Player $id',
    'normalized_nickname': 'player $id',
    'avatar': 'avatar1',
    'color': 'violet',
    'total_xp': 1200,
    'level': 5,
    'created_at': 0,
    'updated_at': 0,
  });
  await database.insert('profile_settings', <String, Object?>{
    'profile_id': id,
    'timer_mode': 'relaxed',
    'daily_goal_xp': 50,
    'is_sound_enabled': 0,
    'is_vibration_enabled': 1,
    'is_reduced_motion_enabled': 0,
    'is_everything_unlocked': 1,
    'updated_at': 0,
  });
  final String session = 's-$id';
  await database.insert('quiz_session', <String, Object?>{
    'id': session,
    'profile_id': id,
    'domain_id': 'multiplication',
    'mode': 'path',
    'status': 'completed',
    'started_at': 0,
    'duration_ms': 1000,
    'question_count': 10,
    'correct_count': 9,
    'updated_at': 0,
  });
  await database.insert('quiz_answer', <String, Object?>{
    'session_id': session,
    'position': 1,
    'item_key': 'mul:5x7',
    'question_type_id': 'typedAnswer',
    'is_correct': 1,
    'is_timed_out': 0,
    'is_retry': 0,
    'answer_time_ms': 2000,
    'updated_at': 0,
  });
  final Map<String, Map<String, Object?>> rows = <String, Map<String, Object?>>{
    'item_progress': <String, Object?>{
      'domain_id': 'multiplication',
      'item_key': 'mul:5x7',
      'presentation_count': 3,
      'correct_count': 3,
      'last_answer_times_ms': '2000',
      'box': 3,
    },
    'stage_progress': <String, Object?>{
      'domain_id': 'multiplication',
      'unit_key': 'mul:1',
      'stage': 'boss',
      'best_stars': 3,
      'best_score': 12,
      'completed_at': 0,
    },
    'session_reward': <String, Object?>{
      'session_id': session,
      'xp_earned': 120,
      'xp_version': 1,
      'earned_at': 0,
    },
    'streak': <String, Object?>{'current_streak': 4, 'best_streak': 6},
    'badge_unlock': <String, Object?>{
      'badge_key': 'firstStep',
      'unlocked_at': 0,
    },
    'reward_stats': <String, Object?>{'lightning_answers': 12},
    'record': <String, Object?>{
      'mode': 'timeAttack',
      'best_score': 18,
      'session_id': session,
      'achieved_at': 0,
    },
    'mascot': <String, Object?>{
      'name': 'Bulle',
      'worn_accessories': 'cap',
      'celebrated_stage': 2,
    },
  };
  for (final MapEntry<String, Map<String, Object?>> row in rows.entries) {
    await database.insert(row.key, <String, Object?>{
      'profile_id': id,
      ...row.value,
      'updated_at': 0,
    });
  }
}

Future<int> _count(Database database, String table, String profileId) async {
  final List<Map<String, Object?>> rows = await database.query(
    table,
    where: 'profile_id = ?',
    whereArgs: <Object>[profileId],
  );
  return rows.length;
}

void main() {
  late AppDatabase appDatabase;
  late TableChangeBus changeBus;
  late ResetProgressUseCase resetProgress;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    appDatabase = AppDatabase(
      databaseFactory: databaseFactoryFfi,
      resolvePath: () async => inMemoryDatabasePath,
      migrationRunner: MigrationRunner(migrations: appMigrations),
    );
    final Database database = await appDatabase.database;
    await _seedPlayer(database, 'p1');
    await _seedPlayer(database, 'p2');
    changeBus = TableChangeBus();
    final ProgressResetHooks hooks = ProgressResetHooks()
      ..add(const QuizResetHook())
      ..add(const MasteryResetHook())
      ..add(const StageProgressResetHook())
      ..add(const RewardResetHook())
      ..add(const RecordResetHook())
      ..add(const MascotResetHook());
    resetProgress = ResetProgressUseCase(
      resetter: ProgressResetter(
        database: appDatabase,
        hooks: hooks,
        changeBus: changeBus,
      ),
    );
  });

  tearDown(() async {
    await changeBus.dispose();
    await appDatabase.close();
  });

  test('erases the progress of the player and keeps who they are', () async {
    // Arrange
    final Future<String> actualChange = changeBus
        .watchTable(table: 'item_progress')
        .first;
    // Act
    await resetProgress(params: 'p1');
    // Assert
    final Database database = await appDatabase.database;
    for (final MapEntry<String, String> table in _progressTables.entries) {
      expect(await _count(database, table.key, 'p1'), 0, reason: table.key);
      expect(await _count(database, table.key, 'p2'), 1, reason: table.key);
    }
    expect(await database.query('quiz_answer'), hasLength(1));
    final Map<String, Object?> actualProfile = (await database.query(
      'profile',
      where: 'id = ?',
      whereArgs: <Object>['p1'],
    )).single;
    expect(actualProfile['nickname'], 'Player p1');
    expect(actualProfile['total_xp'], 0);
    expect(actualProfile['level'], 1);
    expect(await _count(database, 'profile_settings', 'p1'), 1);
    final Map<String, Object?> actualMascot = (await database.query(
      'mascot',
      where: 'profile_id = ?',
      whereArgs: <Object>['p1'],
    )).single;
    expect(actualMascot['name'], 'Bulle');
    expect(actualMascot['worn_accessories'], '');
    expect(actualMascot['celebrated_stage'], 1);
    await expectLater(actualChange, completion('item_progress'));
  });
}
