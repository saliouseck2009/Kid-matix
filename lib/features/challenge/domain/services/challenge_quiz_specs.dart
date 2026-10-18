import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_mode.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';
import 'package:kid_matix/features/challenge/domain/services/code_challenge_rules.dart';

/// Turns a free training or a challenge into the quiz to play.
///
/// The mastery engine draws the questions: low boxes come more often.
/// For the daily review it picks them among every fact of every domain:
/// the overdue first, then the least known; for the monster hunt, the
/// player's monsters twice each, then the same as a review. A game
/// replayed from a challenge code draws its questions from the seed of
/// the code alone, the same on every phone.
final class ChallengeQuizSpecs {
  /// Creates the builder.
  const ChallengeQuizSpecs();

  /// The quiz of [source] in [domain], or `null` when [domain] lacks one
  /// of its units.
  QuizSpec? specOf({
    required LearningDomain domain,
    required ChallengeSource source,
  }) {
    final List<String>? unitKeys = switch (source) {
      DailyReviewSource() || MonsterHuntSource() => <String>[
        for (final LearningUnit unit in domain.units) unit.key,
      ],
      CodeChallengeSource(:final ChallengeCode code) => unitKeysOf(
        domain,
        code.tables,
      ),
      _ => source.unitKeys,
    };
    final List<String>? itemKeys = unitKeys == null
        ? null
        : _itemKeysOf(domain, unitKeys);
    if (itemKeys == null || itemKeys.isEmpty) return null;
    return switch (source) {
      TrainingSource(:final int questionCount, :final bool hasTimer) =>
        QuizSpec(
          domainId: domain.id,
          mode: QuizMode.freeTraining,
          itemKeys: itemKeys,
          questionTypeIds: ChallengeRules.trainingQuestionTypeIds,
          questionCount: questionCount,
          baseTimeLimit: hasTimer ? ChallengeRules.trainingTimeLimit : null,
          keepsTimer: hasTimer,
          sourceKey: source.toKey(),
        ),
      TimeAttackSource() => QuizSpec(
        domainId: domain.id,
        mode: QuizMode.timeAttack,
        itemKeys: itemKeys,
        questionTypeIds: ChallengeRules.timeAttackQuestionTypeIds,
        questionCount: ChallengeRules.timeAttackQuestionCount,
        totalTimeLimit: ChallengeRules.timeAttackTime,
        sourceKey: source.toKey(),
      ),
      SurvivalSource() => QuizSpec(
        domainId: domain.id,
        mode: QuizMode.survival,
        itemKeys: itemKeys,
        questionTypeIds: ChallengeRules.survivalQuestionTypeIds,
        questionCount: ChallengeRules.survivalQuestionCount,
        baseTimeLimit: ChallengeRules.survivalTimeSchedule.start,
        timeSchedule: ChallengeRules.survivalTimeSchedule,
        // The timer is the point of the mode: it stays when the player
        // turned it off.
        keepsTimer: true,
        lives: ChallengeRules.survivalLives,
        sourceKey: source.toKey(),
      ),
      DailyReviewSource() => _dailyReviewSpec(itemKeys, source.toKey()),
      MonsterHuntSource() => QuizSpec(
        domainId: domain.id,
        mode: QuizMode.monsterHunt,
        itemKeys: itemKeys,
        questionTypeIds: ChallengeRules.monsterHuntQuestionTypeIds,
        selection: QuizSelection.monsterHunt,
        questionCount: ChallengeRules.monsterHuntQuestionCount,
        sourceKey: source.toKey(),
      ),
      CodeChallengeSource(:final ChallengeCode code) => _codedSpecOf(
        domain,
        code,
        itemKeys,
        source.toKey(),
      ),
    };
  }

  /// The daily review over every item of [domains]: it mixes the missed
  /// items of every domain (owner's decision, 2026-10-18); `null` when
  /// [domains] hold no item.
  QuizSpec? dailyReviewOf(List<LearningDomain> domains) {
    final List<String> itemKeys = <String>[
      for (final LearningDomain domain in domains)
        for (final LearningUnit unit in domain.units)
          for (final LearningItem item in unit.items) item.key,
    ];
    if (itemKeys.isEmpty) return null;
    return _dailyReviewSpec(itemKeys, DailyReviewSource().toKey());
  }

  QuizSpec _dailyReviewSpec(List<String> itemKeys, String sourceKey) {
    return QuizSpec(
      domainId: LearningDomainIds.mixed,
      mode: QuizMode.dailyReview,
      itemKeys: itemKeys,
      questionTypeIds: ChallengeRules.dailyReviewQuestionTypeIds,
      selection: QuizSelection.review,
      questionCount: ChallengeRules.dailyReviewQuestionCount,
      sourceKey: sourceKey,
    );
  }

  /// Keys of the units numbered [tables] in [domain], or `null` when one
  /// is missing.
  static List<String>? unitKeysOf(LearningDomain domain, List<int> tables) {
    final List<String> keys = <String>[];
    for (final int table in tables) {
      final LearningUnit? unit = domain.units
          .where((LearningUnit unit) => unit.number == table)
          .firstOrNull;
      if (unit == null) return null;
      keys.add(unit.key);
    }
    return keys;
  }

  /// The game of [code]: the timer rules of its mode, the questions of
  /// its seed.
  QuizSpec _codedSpecOf(
    LearningDomain domain,
    ChallengeCode code,
    List<String> itemKeys,
    String sourceKey,
  ) {
    final bool hasTimer = code.mode == ChallengeCodeMode.timedTraining;
    return QuizSpec(
      domainId: domain.id,
      mode: code.mode.isTraining ? QuizMode.freeTraining : QuizMode.timeAttack,
      itemKeys: itemKeys,
      questionTypeIds: CodeChallengeRules.questionTypeIdsOf(code.mode),
      questionCount: code.questionCount,
      baseTimeLimit: hasTimer ? ChallengeRules.trainingTimeLimit : null,
      keepsTimer: hasTimer,
      totalTimeLimit: code.mode.isTraining
          ? null
          : ChallengeRules.timeAttackTime,
      sourceKey: sourceKey,
      seededDraw: SeededDraw(seed: code.seed, version: code.generatorVersion),
    );
  }

  List<String>? _itemKeysOf(LearningDomain domain, List<String> unitKeys) {
    final List<String> keys = <String>[];
    for (final String unitKey in unitKeys) {
      final LearningUnit? unit = domain.findUnit(unitKey);
      if (unit == null) return null;
      keys.addAll(unit.items.map((LearningItem item) => item.key));
    }
    return keys;
  }
}
