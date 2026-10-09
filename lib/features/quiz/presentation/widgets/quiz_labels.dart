import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/prompt_reading.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the quiz that depend on the learning domain.
final class QuizLabels {
  /// Creates the labels of the domains of [domains].
  const QuizLabels({required this.domains, required this.l10n});

  /// Registered learning domains.
  final DomainRegistry domains;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Label above [question]: "Vrai ou faux ?" or the name of its unit.
  String describeQuestion(Question question, String domainId) {
    if (question.questionTypeId == QuestionTypeIds.trueFalse) {
      return l10n.quizTrueFalseLabel;
    }
    final LearningUnit? unit = domains
        .find(domainId)
        ?.findUnit(
          question.unitKey,
        );
    return unit == null ? '' : describeUnit(unit, domainId);
  }

  /// Name of [unit], such as "Table de 5".
  String describeUnit(LearningUnit unit, String domainId) {
    return switch (domainId) {
      LearningDomainIds.multiplication => l10n.quizMultiplicationUnit(
        unit.number,
      ),
      _ => '',
    };
  }

  /// The unit shared by every item of [itemKeys], or `null` when they
  /// belong to several units.
  LearningUnit? findCommonUnit(List<String> itemKeys, String domainId) {
    final LearningDomain? domain = domains.find(domainId);
    if (domain == null || itemKeys.isEmpty) return null;
    for (final LearningUnit unit in domain.units) {
      final Set<String> keys = unit.items
          .map((LearningItem item) => item.key)
          .toSet();
      if (itemKeys.every(keys.contains)) return unit;
    }
    return null;
  }

  /// Whole fact of [itemKey] with its result, such as "5 × 7 = 35".
  String describeItem(String itemKey, String domainId) {
    final LearningDomain? domain = domains.find(domainId);
    final LearningItem? item = domain?.findItem(itemKey);
    if (domain == null || item == null) return '';
    return domain.describeItem(item).toDisplayText();
  }
}
