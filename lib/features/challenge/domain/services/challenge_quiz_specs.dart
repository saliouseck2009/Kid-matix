import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/services/challenge_rules.dart';

/// Turns a free training or a challenge into the quiz to play.
///
/// The mastery engine draws the questions: low boxes come more often.
final class ChallengeQuizSpecs {
  /// Creates the builder.
  const ChallengeQuizSpecs();

  /// The quiz of [source] in [domain], or `null` when [domain] lacks one
  /// of its units.
  QuizSpec? specOf({
    required LearningDomain domain,
    required ChallengeSource source,
  }) {
    final List<String>? itemKeys = _itemKeysOf(domain, source.unitKeys);
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
    };
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
