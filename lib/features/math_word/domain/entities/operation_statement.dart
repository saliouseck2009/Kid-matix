import 'package:kid_matix/core/quiz/math_operator.dart';
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
  }) : assert(arithmetic.contains(operation), 'not an operation'),
       wordKeys = List<String>.unmodifiable(wordKeys);

  /// The operators a statement can ask for: the four of the arithmetic,
  /// never a comparison.
  static const Set<MathOperator> arithmetic = <MathOperator>{
    MathOperator.add,
    MathOperator.subtract,
    MathOperator.multiply,
    MathOperator.divide,
  };

  /// Id in the content table, such as `OP-04`.
  final String id;

  /// The statement in French, read aloud.
  final String text;

  /// The right operator.
  final MathOperator operation;

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
