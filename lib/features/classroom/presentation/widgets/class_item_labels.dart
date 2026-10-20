import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';

/// Writes the items of the class results as the teacher reads them: a
/// fact with its answer (« 7 × 8 = 56 »), or a word.
final class ClassItemLabels {
  /// Creates the labels over the [domains] of the app.
  const ClassItemLabels({required this._domains});

  final DomainRegistry _domains;

  /// The text of [itemKey]; the key itself for an item no domain knows.
  String describe(String itemKey) {
    final LearningDomain? domain = _domains.findByItemKey(itemKey);
    final LearningItem? item = domain?.findItem(itemKey);
    if (domain == null || item == null) return itemKey;
    return domain.describeItem(item).toDisplayText();
  }

  /// The texts of [itemKeys], separated by commas.
  String describeAll(Iterable<String> itemKeys) {
    return itemKeys.map(describe).join(', ');
  }
}
