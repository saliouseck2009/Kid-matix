import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the free training and the challenges.
final class ChallengeLabels {
  /// Creates the labels of [domainId].
  const ChallengeLabels({required this.domainId, required this.l10n});

  /// Learning domain of the tables.
  final String domainId;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Short mark of [unit] on its button, such as "×5".
  String unitMark(LearningUnit unit) {
    return switch (domainId) {
      LearningDomainIds.multiplication => '×${unit.number}',
      _ => '${unit.number}',
    };
  }

  /// Name of [unit], such as "Table de 5".
  String unitName(LearningUnit unit) {
    return switch (domainId) {
      LearningDomainIds.multiplication => l10n.quizMultiplicationUnit(
        unit.number,
      ),
      _ => '',
    };
  }

  /// Name of the quiz played for [sourceKey], such as "Contre-la-montre",
  /// or `null` when it is not a quiz of the challenges.
  static String? describeSource(String? sourceKey, AppLocalizations l10n) {
    return switch (ChallengeSource.tryParse(sourceKey)) {
      TrainingSource() => l10n.quizModeFreeTraining,
      TimeAttackSource() => l10n.quizModeTimeAttack,
      null => null,
    };
  }
}
