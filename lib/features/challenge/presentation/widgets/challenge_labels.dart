import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_code_error.dart';
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
  String unitMark(LearningUnit unit) => l10n.unitMark(domainId, unit.key);

  /// Name of [unit], such as "Table de 5".
  String unitName(LearningUnit unit) => l10n.unitName(domainId, unit.key);

  /// Name of the game of [code]: "Entraînement libre" or
  /// "Contre-la-montre".
  static String describeCodeMode(ChallengeCode code, AppLocalizations l10n) {
    return code.mode.isTraining
        ? l10n.quizModeFreeTraining
        : l10n.quizModeTimeAttack;
  }

  /// The tables of a challenge, inside a line: "table de 7", "tables de 2
  /// et de 5", or "toutes les tables" when they are the [tableCount]
  /// tables. With [isLineStart], the form that begins its own line, such
  /// as "Tables de 2 et de 5".
  static String describeTables(
    List<int> tables,
    AppLocalizations l10n, {
    required int tableCount,
    bool isLineStart = false,
  }) {
    if (tables.length >= tableCount) {
      return isLineStart
          ? l10n.challengeCodeCardTablesAll
          : l10n.challengeCodeTablesAll;
    }
    if (tables.length == 1) {
      return isLineStart
          ? l10n.challengeCodeCardTablesOne(tables.single)
          : l10n.challengeCodeTablesOne(tables.single);
    }
    final List<String> items = tables.map(l10n.challengeCodeTableItem).toList();
    final String first = items.take(items.length - 1).join(', ');
    return isLineStart
        ? l10n.challengeCodeCardTablesMany(first, items.last)
        : l10n.challengeCodeTablesMany(first, items.last);
  }

  /// Message of a refused challenge code.
  static String describeCodeError(
    ChallengeCodeError error,
    AppLocalizations l10n,
  ) {
    return switch (error) {
      ChallengeCodeError.malformed => l10n.challengeCodeErrorMalformed,
      ChallengeCodeError.altered => l10n.challengeCodeErrorAltered,
      ChallengeCodeError.unknownVersion => l10n.challengeCodeErrorVersion,
    };
  }

  /// Name of the quiz played for [sourceKey], such as "Contre-la-montre",
  /// or `null` when it is not a quiz of the challenges.
  static String? describeSource(String? sourceKey, AppLocalizations l10n) {
    return switch (ChallengeSource.tryParse(sourceKey)) {
      TrainingSource() => l10n.quizModeFreeTraining,
      TimeAttackSource() => l10n.quizModeTimeAttack,
      SurvivalSource() => l10n.quizModeSurvival,
      DailyReviewSource() => l10n.quizModeDailyReview,
      MonsterHuntSource() => l10n.quizModeMonsterHunt,
      CodeChallengeSource(:final ChallengeCode code) =>
        code.mode.isTraining
            ? l10n.quizModeFreeTraining
            : l10n.quizModeTimeAttack,
      null => null,
    };
  }
}
