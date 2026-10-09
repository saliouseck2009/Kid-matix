import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/question.dart';
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
    return _spreadRepeatedItems(items)
        .map(
          (LearningItem item) => domain.buildQuestion(
            item: item,
            questionTypeId:
                allowedTypeIds[random.nextInt(allowedTypeIds.length)],
            random: random,
          ),
        )
        .toList();
  }

  /// Keeps the order of [items] but never puts the same item twice in a
  /// row while another one is left to place in between.
  List<LearningItem> _spreadRepeatedItems(List<LearningItem> items) {
    final List<LearningItem> remaining = List<LearningItem>.of(items);
    final List<LearningItem> ordered = <LearningItem>[];
    while (remaining.isNotEmpty) {
      final String? previousKey = ordered.isEmpty ? null : ordered.last.key;
      final int nextIndex = remaining.indexWhere(
        (LearningItem item) => item.key != previousKey,
      );
      ordered.add(remaining.removeAt(nextIndex < 0 ? 0 : nextIndex));
    }
    return ordered;
  }
}
