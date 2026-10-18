import 'package:kid_matix/core/quiz/problem_operation.dart';
import 'package:meta/meta.dart';

/// A short statement for « Quelle opération ? »: the child picks +, −, ×
/// or ÷ without computing. Section 3 of `docs/product/math-words.md`.
@immutable
final class OperationStatement {
  /// Creates the statement.
  OperationStatement({
    required this.id,
    required this.text,
    required this.operation,
    required List<String> wordKeys,
  }) : wordKeys = List<String>.unmodifiable(wordKeys);

  /// Id in the content table, such as `OP-04`.
  final String id;

  /// The statement in French, read aloud.
  final String text;

  /// The right operation.
  final ProblemOperation operation;

  /// Keys of the math words the statement uses; each one is trained by it.
  final List<String> wordKeys;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is OperationStatement && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}
