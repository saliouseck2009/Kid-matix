import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/services/random_source.dart';

/// Turns a list of items into the questions of a quiz.
///
/// One question per item, in the given order, except that the same item
/// never comes twice in a row: a repeated item is moved after the next
/// different one. Each question gets a type drawn among the allowed ones,
/// so the same [RandomSource] seed always gives the same questions.
final class QuestionGenerator {
  /// Creates the generator.
  const QuestionGenerator();

  /// Builds one question of [domain] per item of [items], with a type
  /// drawn among [questionTypeIds] that the domain supports.
  ///
  /// Throws an [ArgumentError] when the domain supports none of
  /// [questionTypeIds].
  List<Question> generate({
    required LearningDomain domain,
    required List<LearningItem> items,
    required List<String> questionTypeIds,
    required RandomSource random,
  }) {
    final List<String> allowedTypeIds = _supportedTypeIds(
      domain,
      questionTypeIds,
    );
    return _spreadRepeated(items, (LearningItem item) => item.key)
        .map(
          (LearningItem item) =>
              _buildQuestion(domain, item, allowedTypeIds, random),
        )
        .toList();
  }

  /// Builds one question of [domain] per plan of [plans], with a type
  /// drawn among the plan's question types that the domain supports.
  ///
  /// Throws an [ArgumentError] when the domain lacks the item of a plan or
  /// supports none of its question types.
  List<Question> generatePlanned({
    required LearningDomain domain,
    required List<QuizItemPlan> plans,
    required RandomSource random,
  }) {
    return _spreadRepeated(plans, (QuizItemPlan plan) => plan.itemKey).map((
      QuizItemPlan plan,
    ) {
      final LearningItem? item = domain.findItem(plan.itemKey);
      if (item == null) {
        throw ArgumentError.value(plan.itemKey, 'plans', 'Unknown item');
      }
      return _buildQuestion(
        domain,
        item,
        _supportedTypeIds(domain, plan.questionTypeIds),
        random,
      );
    }).toList();
  }

  List<String> _supportedTypeIds(
    LearningDomain domain,
    List<String> questionTypeIds,
  ) {
    final List<String> allowedTypeIds = questionTypeIds
        .where(domain.questionTypeIds.contains)
        .toList();
    if (allowedTypeIds.isEmpty) {
      throw ArgumentError.value(
        questionTypeIds,
        'questionTypeIds',
        'None is supported by the ${domain.id} domain',
      );
    }
    return allowedTypeIds;
  }

  Question _buildQuestion(
    LearningDomain domain,
    LearningItem item,
    List<String> allowedTypeIds,
    RandomSource random,
  ) {
    return domain.buildQuestion(
      item: item,
      questionTypeId: allowedTypeIds[random.nextInt(allowedTypeIds.length)],
      random: random,
    );
  }

  /// Keeps the order of [values] but never puts the same key twice in a
  /// row while another one is left to place in between.
  List<T> _spreadRepeated<T>(List<T> values, String Function(T) keyOf) {
    final List<T> remaining = List<T>.of(values);
    final List<T> ordered = <T>[];
    while (remaining.isNotEmpty) {
      final String? previousKey = ordered.isEmpty ? null : keyOf(ordered.last);
      final int nextIndex = remaining.indexWhere(
        (T value) => keyOf(value) != previousKey,
      );
      ordered.add(remaining.removeAt(nextIndex < 0 ? 0 : nextIndex));
    }
    return ordered;
  }
}
