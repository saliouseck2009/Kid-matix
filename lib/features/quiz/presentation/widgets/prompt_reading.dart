import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Turns prompt tokens into what the screen shows and what a screen reader
/// says.
///
/// Arithmetic keeps the same order in every language the app plans, so the
/// spoken words are joined token by token.
extension PromptReading on List<PromptToken> {
  /// Text shown, such as `5 × 7 = ?`; [blankText] fills the blank when the
  /// player has typed digits.
  String toDisplayText({String? blankText}) {
    return toDisplayParts(blankText: blankText).join(' ');
  }

  /// One shown piece per token, in order.
  List<String> toDisplayParts({String? blankText}) {
    return map((PromptToken token) {
      return switch (token) {
        NumberToken(:final int value) => '$value',
        OperatorToken(operator: MathOperator.multiply) => '×',
        EqualsToken() => '=',
        BlankToken() => blankText ?? '?',
      };
    }).toList();
  }

  /// Words a screen reader says, such as "5 fois 7 égale combien".
  String toSpokenText(AppLocalizations l10n) {
    return map((PromptToken token) {
      return switch (token) {
        NumberToken(:final int value) => '$value',
        OperatorToken(operator: MathOperator.multiply) => l10n.quizSpokenTimes,
        EqualsToken() => l10n.quizSpokenEquals,
        BlankToken() => l10n.quizSpokenBlank,
      };
    }).join(' ');
  }
}
