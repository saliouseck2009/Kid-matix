import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:meta/meta.dart';

/// One element of a question prompt, such as `7`, `×`, `=` or the blank.
///
/// Prompts are data, never text: the quiz screen renders each token, so no
/// language-specific wording reaches the domain.
@immutable
sealed class PromptToken {
  /// Creates a token.
  const PromptToken();
}

/// A number of the prompt.
final class NumberToken extends PromptToken {
  /// Creates the token of [value].
  const NumberToken(this.value);

  /// Number shown.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NumberToken && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';
}

/// An operator of the prompt.
final class OperatorToken extends PromptToken {
  /// Creates the token of [operator].
  const OperatorToken(this.operator);

  /// Operator shown.
  final MathOperator operator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatorToken && other.operator == operator;

  @override
  int get hashCode => operator.hashCode;

  @override
  String toString() => operator.name;
}

/// The equals sign of the prompt.
final class EqualsToken extends PromptToken {
  /// Creates the token.
  const EqualsToken();

  @override
  bool operator ==(Object other) => other is EqualsToken;

  @override
  int get hashCode => (EqualsToken).hashCode;

  @override
  String toString() => '=';
}

/// The place of the value the player must find.
final class BlankToken extends PromptToken {
  /// Creates the token.
  const BlankToken();

  @override
  bool operator ==(Object other) => other is BlankToken;

  @override
  int get hashCode => (BlankToken).hashCode;

  @override
  String toString() => '?';
}
