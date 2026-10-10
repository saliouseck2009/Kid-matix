import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/reward/domain/entities/badge_unlock_entity.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';

/// XP earned by one quiz, with its player and end.
typedef SessionXp = ({String profileId, int xp, DateTime earnedAt});

/// XP, streak and badges of each player, written by the session hook.
abstract interface class RewardRepository {
  /// Returns the streak of [profileId], empty before the first quiz.
  Future<DataState<StreakEntity>> getStreak({required String profileId});

  /// Returns the badges of [profileId], oldest first.
  Future<DataState<List<BadgeUnlockEntity>>> getBadges({
    required String profileId,
  });

  /// Returns the XP [profileId] earned from [from], included, to [to],
  /// excluded; every XP without bounds.
  Future<DataState<int>> getXpEarned({
    required String profileId,
    DateTime? from,
    DateTime? to,
  });

  /// Returns the XP of [sessionId] with its player and end, or `null` for
  /// a quiz without reward, abandoned or unknown.
  Future<DataState<SessionXp?>> getSessionXp({required String sessionId});

  /// Emits an event each time the rewards of a player change.
  Stream<void> watchChanges();
}
