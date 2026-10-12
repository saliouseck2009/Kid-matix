import 'package:kid_matix/core/error/data_state.dart';

/// Gives XP earned outside a quiz, such as in a duel.
///
/// Implemented by the reward feature, which owns the XP. The XP count in
/// the total, the level and the daily goal; the streak and the badges
/// stay as they are, since they follow completed quizzes only.
abstract interface class XpAwardService {
  /// Adds [xp] to the player [profileId], earned in the game named by
  /// [sourceKey], such as `duel`.
  Future<DataState<void>> awardXp({
    required String profileId,
    required int xp,
    required String sourceKey,
  });
}
