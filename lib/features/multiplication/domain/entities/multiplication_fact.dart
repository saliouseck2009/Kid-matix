import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:meta/meta.dart';

/// One fact of a multiplication table, such as 7 x 8.
@immutable
final class MultiplicationFact implements LearningItem {
  /// Creates the fact [table] x [multiplier].
  const MultiplicationFact({required this.table, required this.multiplier});

  /// Prefix of every multiplication key.
  static const String keyPrefix = 'mul';

  /// Table the fact belongs to: the left operand.
  final int table;

  /// Right operand.
  final int multiplier;

  /// Result of the fact.
  int get product => table * multiplier;

  /// Stable key, `mul:7x8` for 7 x 8; never changes once released.
  @override
  String get key => '$keyPrefix:${table}x$multiplier';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MultiplicationFact &&
            other.table == table &&
            other.multiplier == multiplier;
  }

  @override
  int get hashCode => Object.hash(table, multiplier);

  @override
  String toString() => key;
}
