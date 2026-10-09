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
