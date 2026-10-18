import 'package:kid_matix/core/quiz/answer.dart';
import 'package:meta/meta.dart';

/// One pair of a match-pairs question: an item, the operation shown on
/// the left and the result to tie it to on the right.
@immutable
final class QuestionPair {
  /// Creates the pair of [itemKey].
  const QuestionPair({
    required this.itemKey,
    required this.operation,
    required this.result,
  });

  /// Key of the item of the pair, such as `mul:5x6`; its mastery records
  /// how the pair was matched.
  final String itemKey;

  /// Left side, such as `5 × 6`.
  final Answer operation;

  /// Right side, such as `30`.
  final Answer result;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuestionPair &&
            other.itemKey == itemKey &&
            other.operation == operation &&
            other.result == result;
  }

  @override
  int get hashCode => Object.hash(itemKey, operation, result);

  @override
  String toString() => '$itemKey: $operation - $result';
}
