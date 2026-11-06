// The demo player of the marketing videos and their preloaded progress.
// "Awa" is the placeholder nickname of the mockups: no real child.

import 'package:kid_matix/core/di/injection_container.dart';
import 'package:kid_matix/core/storage/app_database.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_avatar.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_color.dart';
import 'package:kid_matix/features/profile/domain/entities/profile_entity.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_params.dart';
import 'package:kid_matix/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:kid_matix/features/profile/domain/usecases/select_profile_use_case.dart';
import 'package:sqflite/sqflite.dart';

import '../../../test/helpers/data_state_test_extension.dart';

/// Nickname of the demo player.
const String demoNickname = 'Awa';

/// Tables whose five stages are won, boss included: they wear a crown.
/// They are the first three of the learning path, so the table of 5 is
/// the one to play.
const List<int> crownedTables = <int>[1, 2, 10];

/// XP of the demo player: level 4 starts at 600 XP.
const int demoXp = 650;

/// Level reached with [demoXp].
const int demoLevel = 4;

/// Days of the streak; the last one is yesterday, so today's quiz makes
/// it grow on screen.
const int demoStreakDays = 6;

const String _domainId = 'multiplication';
const List<String> _tableStages = <String>[
  'discovery',
  'training',
  'writing',
  'speed',
  'boss',
];
const int _lastMultiplier = 10;
const int _stars = 3;
const int _acquiredBox = 4;
const int _reviewInDays = 7;

/// Creates the demo player with the progress above and opens their
/// session: the app starts on their learning path.
Future<void> seedDemoPlayer() async {
  final ProfileEntity player = (await sl<CreateProfileUseCase>()(
    params: const CreateProfileParams(
      nickname: demoNickname,
      avatar: ProfileAvatar.avatar6,
      color: ProfileColor.violet,
    ),
  )).requireData;
  final Database database = await sl<AppDatabase>().database;
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
  final int playedAt = yesterday
      .add(const Duration(hours: 17))
      .millisecondsSinceEpoch;
  final Batch batch = database.batch();
  for (final int table in crownedTables) {
    for (final String stage in _tableStages) {
      batch.insert('stage_progress', <String, Object?>{
        'profile_id': player.id,
        'domain_id': _domainId,
        'unit_key': 'mul:$table',
        'stage': stage,
        'best_stars': _stars,
        'best_score': _lastMultiplier,
        'completed_at': playedAt,
        'updated_at': playedAt,
      });
    }
    for (int multiplier = 1; multiplier <= _lastMultiplier; multiplier++) {
      batch.insert('item_progress', <String, Object?>{
        'profile_id': player.id,
        'domain_id': _domainId,
        'item_key': 'mul:${table}x$multiplier',
        'presentation_count': 6,
        'correct_count': 6,
        'last_answer_times_ms': '2400,2100,1900,2200,2000',
        'box': _acquiredBox,
        'next_review_at': DateTime(
          today.year,
          today.month,
          today.day + _reviewInDays,
        ).millisecondsSinceEpoch,
        'updated_at': playedAt,
      });
    }
  }
  batch.insert('xp_award', <String, Object?>{
    'id': 'marketing-seed',
    'profile_id': player.id,
    'source_key': 'marketing',
    'xp_earned': demoXp,
    'earned_at': playedAt,
    'updated_at': playedAt,
  });
  batch.update(
    'profile',
    <String, Object?>{'total_xp': demoXp, 'level': demoLevel},
    where: 'id = ?',
    whereArgs: <Object?>[player.id],
  );
  batch.insert('streak', <String, Object?>{
    'profile_id': player.id,
    'current_streak': demoStreakDays,
    'best_streak': demoStreakDays,
    'last_played_day': yesterday.millisecondsSinceEpoch,
    'updated_at': playedAt,
  });
  await batch.commit(noResult: true);
  (await sl<SelectProfileUseCase>()(params: player.id)).requireData;
}
