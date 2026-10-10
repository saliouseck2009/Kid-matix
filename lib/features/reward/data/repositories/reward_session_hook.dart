import 'dart:developer';

import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/services/clock.dart';
import 'package:kid_matix/core/services/learning_path_service.dart';
import 'package:kid_matix/core/services/mastery_service.dart';
import 'package:kid_matix/core/storage/session_saved_hook.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_local_data_source.dart';
import 'package:kid_matix/features/reward/data/datasources/reward_tables.dart';
import 'package:kid_matix/features/reward/data/models/badge_unlock_local_model.dart';
import 'package:kid_matix/features/reward/data/models/session_reward_local_model.dart';
import 'package:kid_matix/features/reward/data/models/streak_local_model.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_input.dart';
import 'package:kid_matix/features/reward/domain/entities/session_reward_outcome.dart';
import 'package:kid_matix/features/reward/domain/entities/streak_entity.dart';
import 'package:kid_matix/features/reward/domain/services/session_reward_calculator.dart';
import 'package:kid_matix/features/reward/domain/services/xp_policy.dart';
import 'package:sqflite/sqflite.dart';

/// Writes the rewards of a completed quiz in the transaction that saves
/// it: XP, level, streak, counters and badges. An abandoned quiz earns
/// nothing.
///
/// The mastered facts and the stage of the quiz are read before the
/// transaction, through the services of the mastery and the learning
/// path.
final class RewardSessionHook implements SessionSavedHook {
  /// Creates the hook.
  const RewardSessionHook({
    required this._rewards,
    required this._mastery,
    required this._learningPath,
    required this._domains,
    required this._clock,
    this._calculator = const SessionRewardCalculator(),
  });

  static const String _logName = 'reward';

  /// Outcome of a session whose boss was defeated.
  static const String bossDefeated = 'defeated';

  final RewardLocalDataSource _rewards;
  final MasteryService _mastery;
  final LearningPathService _learningPath;
  final DomainRegistry _domains;
  final Clock _clock;
  final SessionRewardCalculator _calculator;

  @override
  Future<SessionWrite> prepare({required SavedQuizSession session}) async {
    if (!session.isCompleted) {
      return (Transaction transaction) async => const <String>[];
    }
    final SessionRewardInput input = SessionRewardInput(
      isCompleted: true,
      correctCount: session.correctCount,
      questionCount: session.questionCount,
      lightningCount: session.lightningCount,
      isStage: _learningPath.isStage(session.sourceKey),
      crownedUnitKey: _learningPath.crownedUnitOf(
        sourceKey: session.sourceKey,
        isBossDefeated: session.bossOutcome == bossDefeated,
      ),
      masteredItemCount: await _masteredCount(session),
      itemCount: _itemCount(session.domainId),
      now: session.endedAt,
    );
    return (Transaction transaction) => _write(transaction, session, input);
  }

  Future<List<String>> _write(
    Transaction transaction,
    SavedQuizSession session,
    SessionRewardInput input,
  ) async {
    final String profileId = session.profileId;
    final StreakLocalModel? streak = await _rewards.getStreak(
      transaction,
      profileId: profileId,
    );
    final SessionRewardOutcome outcome = _calculator.calculate(
      input: input,
      totalXp: await _rewards.getXpEarned(transaction, profileId: profileId),
      streak: streak?.toEntity() ?? const StreakEntity.empty(),
      lightningAnswers: await _rewards.getLightningAnswers(
        transaction,
        profileId: profileId,
      ),
      unlocked: (await _rewards.getBadges(
        transaction,
        profileId: profileId,
      )).map((BadgeUnlockLocalModel badge) => badge.badgeKey).toSet(),
    );
    await _writeOutcome(transaction, session, outcome);
    return const <String>[
      RewardTables.sessionReward,
      RewardTables.streak,
      RewardTables.badgeUnlock,
      RewardTables.profile,
    ];
  }

  Future<void> _writeOutcome(
    Transaction transaction,
    SavedQuizSession session,
    SessionRewardOutcome outcome,
  ) {
    final DateTime now = _clock.now();
    final int earnedAt = session.endedAt.millisecondsSinceEpoch;
    return _rewards.writeRewards(
      transaction,
      reward: SessionRewardLocalModel(
        sessionId: session.id,
        profileId: session.profileId,
        xpEarned: outcome.xp.total,
        xpVersion: XpPolicy.version,
        earnedAt: earnedAt,
        updatedAt: now.millisecondsSinceEpoch,
      ),
      streak: StreakLocalModel.fromEntity(
        profileId: session.profileId,
        streak: outcome.streak,
        updatedAt: now,
      ),
      lightningAnswers: outcome.lightningAnswers,
      badges: <BadgeUnlockLocalModel>[
        for (final String key in outcome.newBadges)
          BadgeUnlockLocalModel(
            profileId: session.profileId,
            badgeKey: key,
            unlockedAt: earnedAt,
            sessionId: session.id,
            updatedAt: now.millisecondsSinceEpoch,
          ),
      ],
      totalXp: outcome.totalXp,
      level: outcome.level.level,
    );
  }

  /// Facts of the domain mastered; 0 when they cannot be read, so the
  /// "Les 120" badge simply waits for the next quiz.
  Future<int> _masteredCount(SavedQuizSession session) async {
    final DataState<Set<String>> mastered = await _mastery.readMasteredItems(
      profileId: session.profileId,
      domainId: session.domainId,
    );
    return switch (mastered) {
      DataSuccess<Set<String>>(:final data) => data.length,
      DataFailed<Set<String>>(:final exception) => () {
        log('Mastered facts not read', name: _logName, error: exception);
        return 0;
      }(),
    };
  }

  int _itemCount(String domainId) {
    final LearningDomain? domain = _domains.find(domainId);
    if (domain == null) return 0;
    return domain.units.fold(
      0,
      (int sum, LearningUnit unit) => sum + unit.items.length,
    );
  }
}
