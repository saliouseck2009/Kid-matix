import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/services/random_source.dart';

/// A subject to learn, such as multiplication.
///
/// The quiz, the mastery engine and the rewards know only this contract,
/// so a new domain is a new module and nothing else changes.
abstract interface class LearningDomain {
  /// Stable identifier, such as `multiplication`.
  String get id;

  /// Units in their natural order.
  List<LearningUnit> get units;

  /// Units in the order of the learning path.
  List<LearningUnit> get path;

  /// Identifiers of the question types the domain can build.
  List<String> get questionTypeIds;

  /// Returns the item of [key], or `null` when the domain has none.
  LearningItem? findItem(String key);

  /// Builds a question of type [questionTypeId] about [item], drawing
  /// choices and positions from [random].
  ///
  /// [questionTypeId] must be one of [questionTypeIds] and [item] one of
  /// the domain's items.
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  });
}
