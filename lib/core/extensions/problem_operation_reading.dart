import 'package:kid_matix/core/quiz/problem_operation.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// How the screens show and say the four operations of a statement.
extension ProblemOperationReading on ProblemOperation {
  /// The sign on the button: `+`, `−`, `×` or `÷`.
  String get sign {
    return switch (this) {
      ProblemOperation.add => '+',
      ProblemOperation.subtract => '−',
      ProblemOperation.multiply => '×',
      ProblemOperation.divide => '÷',
    };
  }

  /// What a screen reader says for the button, such as "moins".
  String spoken(AppLocalizations l10n) {
    return switch (this) {
      ProblemOperation.add => l10n.quizSpokenPlus,
      ProblemOperation.subtract => l10n.quizSpokenMinus,
      ProblemOperation.multiply => l10n.quizSpokenTimes,
      ProblemOperation.divide => l10n.quizSpokenDividedBy,
    };
  }
}
