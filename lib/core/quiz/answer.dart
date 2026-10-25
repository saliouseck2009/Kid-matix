import 'package:kid_matix/core/quiz/comparison.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:meta/meta.dart';

/// What a player answers, or what a question expects.
@immutable
sealed class Answer {
  /// Creates an answer.
  const Answer();
}

/// A number, picked among choices or written.
final class NumberAnswer extends Answer {
  /// Creates the answer [value].
  const NumberAnswer(this.value);

  /// Number answered.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NumberAnswer && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NumberAnswer($value)';
}

/// "Vrai" or "Faux" to a statement.
final class BooleanAnswer extends Answer {
  /// Creates the answer [value].
  const BooleanAnswer({required this.value});

  /// Whether the player said the statement is true.
  final bool value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BooleanAnswer && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'BooleanAnswer($value)';
}

/// The sign picked between two numbers: smaller, equal or greater.
final class ComparisonAnswer extends Answer {
  /// Creates the answer [comparison].
  const ComparisonAnswer(this.comparison);

  /// Every answer of a comparison, in the order of its buttons.
  static const List<ComparisonAnswer> all = <ComparisonAnswer>[
    ComparisonAnswer(Comparison.less),
    ComparisonAnswer(Comparison.equal),
    ComparisonAnswer(Comparison.greater),
  ];

  /// How the first number compares with the second.
  final Comparison comparison;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComparisonAnswer && other.comparison == comparison;

  @override
  int get hashCode => comparison.hashCode;

  @override
  String toString() => 'ComparisonAnswer(${comparison.name})';
}

/// An operation picked among choices, such as `4 × 6`, told by its tokens.
final class OperationAnswer extends Answer {
  /// Creates the answer [operation].
  OperationAnswer(List<PromptToken> operation)
    : operation = List<PromptToken>.unmodifiable(operation);

  /// Operation picked, token by token: `4`, `×`, `6`.
  final List<PromptToken> operation;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OperationAnswer) return false;
    if (other.operation.length != operation.length) return false;
    for (int index = 0; index < operation.length; index++) {
      if (other.operation[index] != operation[index]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(operation);

  @override
  String toString() => 'OperationAnswer(${operation.join(' ')})';
}

/// Every pair of a match-pairs question matched, with the items whose
/// operation was first paired with a wrong result.
///
/// The right answer is the one without any missed item.
final class PairsAnswer extends Answer {
  /// Creates the answer; [missedItemKeys] is empty when no pairing failed.
  PairsAnswer({Set<String> missedItemKeys = const <String>{}})
    : missedItemKeys = Set<String>.unmodifiable(missedItemKeys);

  /// Keys of the items paired wrongly at least once, such as `mul:5x6`.
  final Set<String> missedItemKeys;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is PairsAnswer &&
            other.missedItemKeys.length == missedItemKeys.length &&
            other.missedItemKeys.containsAll(missedItemKeys);
  }

  @override
  int get hashCode => Object.hashAllUnordered(missedItemKeys);

  @override
  String toString() => 'PairsAnswer(missed: $missedItemKeys)';
}

/// A math word picked or paired (lot F28), told by its key; [text] is the
/// word as the child reads it, such as "il reste". Two answers are the same
/// when they have the same key.
final class WordAnswer extends Answer {
  /// Creates the answer of the word [wordKey].
  const WordAnswer({required this.wordKey, required this.text});

  /// Key of the math word, such as `il_reste`.
  final String wordKey;

  /// The word written in French, such as "il reste".
  final String text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is WordAnswer && other.wordKey == wordKey;

  @override
  int get hashCode => wordKey.hashCode;

  @override
  String toString() => 'WordAnswer($wordKey)';
}

/// The operator picked for a statement, among the four of the arithmetic
/// (lot F28).
final class OperatorAnswer extends Answer {
  /// Creates the answer [operator].
  const OperatorAnswer(this.operator);

  /// Every answer, in the order of the buttons: + − × ÷.
  static const List<OperatorAnswer> all = <OperatorAnswer>[
    OperatorAnswer(MathOperator.add),
    OperatorAnswer(MathOperator.subtract),
    OperatorAnswer(MathOperator.multiply),
    OperatorAnswer(MathOperator.divide),
  ];

  /// Operator picked.
  final MathOperator operator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperatorAnswer && other.operator == operator;

  @override
  int get hashCode => operator.hashCode;

  @override
  String toString() => 'OperatorAnswer(${operator.name})';
}

/// A word problem solved on its board (lot F30): the steps done, with the
/// number of mistakes made on the way. The right answer is the one with no
/// mistake, as for the pairs.
final class ProblemAnswer extends Answer {
  /// Creates the answer of a board solved with [mistakeCount] mistakes.
  const ProblemAnswer({this.mistakeCount = 0});

  /// Wrong touches made on the way.
  final int mistakeCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProblemAnswer && other.mistakeCount == mistakeCount;

  @override
  int get hashCode => mistakeCount.hashCode;

  @override
  String toString() => 'ProblemAnswer($mistakeCount)';
}
