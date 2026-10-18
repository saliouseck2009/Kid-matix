import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:meta/meta.dart';

/// One division of the tables, such as 56 ÷ 7 = 8: the reverse of the
/// multiplication fact 7 × 8 = 56.
///
/// Its key never changes once released, since the stored progress refers
/// to it: `div:<dividend>/<divisor>`, such as `div:56/7`.
@immutable
final class DivisionFact implements LearningItem {
  /// Creates the division of `divisor × quotient` by [divisor].
  const DivisionFact({required this.divisor, required this.quotient});

  /// Prefix of every key of the division domain.
  static const String keyPrefix = 'div';

  /// The number divided by: the table the fact belongs to.
  final int divisor;

  /// The result of the division.
  final int quotient;

  /// The number divided.
  int get dividend => divisor * quotient;

  @override
  String get key => '$keyPrefix:$dividend/$divisor';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is DivisionFact &&
            other.divisor == divisor &&
            other.quotient == quotient;
  }

  @override
  int get hashCode => Object.hash(divisor, quotient);

  @override
  String toString() => key;
}

/// The multiplication fact that answers a division, such as 7 × 8 = 56
/// for 56 ÷ 7: what the player is reminded of after a mistake.
///
/// It is made of the numbers of the division alone, so the division
/// feature knows nothing of the multiplication feature. It is not an item
/// of the domain: it has no progress and is only described.
@immutable
final class MultiplicationRecall implements LearningItem {
  /// Creates the recall of [fact].
  const MultiplicationRecall(this.fact);

  /// The division the recall answers.
  final DivisionFact fact;

  @override
  String get key => 'recall:${fact.key}';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MultiplicationRecall && other.fact == fact;
  }

  @override
  int get hashCode => fact.hashCode;

  @override
  String toString() => key;
}
