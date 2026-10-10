import 'package:meta/meta.dart';

/// One question to ask: the item and the question types fit for it.
///
/// Built by the mastery engine from the player's progress, read by the
/// quiz to generate the question.
@immutable
final class QuizItemPlan {
  /// Creates the plan of one question.
  QuizItemPlan({required this.itemKey, required List<String> questionTypeIds})
    : questionTypeIds = List<String>.unmodifiable(questionTypeIds);

  /// Key of the item to ask, such as `mul:7x8`.
  final String itemKey;

  /// Question types to draw from for this item, never empty.
  final List<String> questionTypeIds;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is QuizItemPlan &&
            other.itemKey == itemKey &&
            _isSameList(other.questionTypeIds, questionTypeIds);
  }

  @override
  int get hashCode => Object.hash(itemKey, Object.hashAll(questionTypeIds));

  @override
  String toString() => '$itemKey $questionTypeIds';

  static bool _isSameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
