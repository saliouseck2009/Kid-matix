import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/extensions/domain_naming.dart';
import 'package:kid_matix/core/extensions/prompt_reading.dart';
import 'package:kid_matix/features/quiz/presentation/widgets/math_picture_labels.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Texts of the quiz that depend on the learning domain.
final class QuizLabels {
  /// Creates the labels of the domains of [domains].
  const QuizLabels({required this.domains, required this.l10n});

  /// Registered learning domains.
  final DomainRegistry domains;

  /// Localized strings.
  final AppLocalizations l10n;

  /// Label above [question]: "Vrai ou faux ?", "Quelle multiplication
  /// donne", what to do with its drawing or its two numbers, or the name
  /// of its unit.
  String describeQuestion(Question question, String domainId) {
    return switch (question.questionTypeId) {
      QuestionTypeIds.trueFalse => l10n.quizTrueFalseLabel,
      QuestionTypeIds.findOperation => switch (domainId) {
        LearningDomainIds.multiplication =>
          l10n.quizFindOperationMultiplication,
        _ => '',
      },
      QuestionTypeIds.compare => l10n.quizCompareLabel,
      _ => switch (_askedDrawing(question)) {
        ObjectsPicture() => l10n.quizCountLabel,
        TenBundlesPicture() => l10n.quizBundlesLabel,
        NumberLinePicture() => l10n.quizNumberLineLabel,
        null => describeUnitOf(question, domainId),
      },
    };
  }

  /// The drawing [question] asks to read: that of a format made for it,
  /// or of a written answer whose prompt is the blank alone; `null` when
  /// the drawing only helps an operation, such as a line next to 7 + 8.
  MathPicture? _askedDrawing(Question question) {
    final bool isAboutDrawing = switch (question.questionTypeId) {
      QuestionTypeIds.countObjects ||
      QuestionTypeIds.tensAndOnes ||
      QuestionTypeIds.numberLine => true,
      QuestionTypeIds.typedAnswer => question.prompt.every(
        (PromptToken token) => token is BlankToken,
      ),
      _ => false,
    };
    return isAboutDrawing ? question.picture : null;
  }

  /// The whole of [question] as one sentence, for a screen reader and the
  /// read-aloud button, when its prompt alone does not say it: "Combien
  /// de mangues ?", "3 paquets de dix et 4 bâtonnets : quel nombre ?",
  /// "34 est-il plus petit, égal ou plus grand que 43 ?", "Quelle
  /// multiplication donne 24 ?"; `null` when the prompt reads as it is,
  /// such as "5 fois 7 égale combien".
  String? speakQuestion(Question question, String domainId) {
    if (question.questionTypeId == QuestionTypeIds.findOperation) {
      return _speakFindOperation(question, domainId);
    }
    if (question.questionTypeId == QuestionTypeIds.compare) {
      final List<NumberToken> numbers = question.prompt
          .whereType<NumberToken>()
          .toList();
      if (numbers.length < 2) return null;
      return l10n.quizCompareSpoken(numbers.first.value, numbers.last.value);
    }
    return switch (_askedDrawing(question)) {
      ObjectsPicture() => l10n.quizCountLabel,
      TenBundlesPicture(:final int tens, :final int ones) =>
        l10n.quizBundlesSpoken(tens, ones),
      final NumberLinePicture line => l10n.quizNumberLineSpoken(
        MathPictureLabels(l10n).listNumbers(line),
      ),
      null => null,
    };
  }

  /// "Quelle multiplication donne 24 ?" for a question that asks for the
  /// operation.
  String? _speakFindOperation(Question question, String domainId) {
    final Iterable<NumberToken> numbers = question.prompt
        .whereType<NumberToken>();
    if (numbers.isEmpty) return null;
    return switch (domainId) {
      LearningDomainIds.multiplication =>
        l10n.quizFindOperationSpokenMultiplication(numbers.last.value),
      _ => null,
    };
  }

  /// Name of the unit of [question], such as "Table de 5"; empty when its
  /// domain lacks it.
  String describeUnitOf(Question question, String domainId) {
    final LearningUnit? unit = domains
        .find(domainId)
        ?.findUnit(question.unitKey);
    return unit == null ? '' : describeUnit(unit, domainId);
  }

  /// Number of the unit of [question], such as 5, or `null` when its
  /// domain lacks it.
  int? unitNumberOf(Question question, String domainId) {
    return domains.find(domainId)?.findUnit(question.unitKey)?.number;
  }

  /// Title of the boss fight of the unit of [question], such as "Boss de
  /// la table de 5" or "Boss · Comparer".
  String describeBoss(Question question, String domainId) {
    return switch (domainId) {
      LearningDomainIds.multiplication => l10n.quizBossTitleMultiplication(
        unitNumberOf(question, domainId) ?? 0,
      ),
      _ => l10n.quizBossTitleUnit(l10n.unitName(domainId, question.unitKey)),
    };
  }

  /// Name of [unit], such as "Table de 5" or "Comparer".
  String describeUnit(LearningUnit unit, String domainId) {
    return l10n.unitName(domainId, unit.key);
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

  /// Whole fact of the mirror of [itemKey], such as "7 × 5 = 35" for
  /// 5 x 7, or `null` when it has none.
  String? describeMirror(String itemKey, String domainId) {
    final LearningDomain? domain = domains.find(domainId);
    final LearningItem? item = domain?.findItem(itemKey);
    final LearningItem? mirror = item == null ? null : domain?.mirrorOf(item);
    if (domain == null || mirror == null) return null;
    return domain.describeItem(mirror).toDisplayText();
  }

  /// Help card of [itemKey], or `null` when its domain lacks it.
  ItemHelp? helpOf(String itemKey, String domainId) {
    final LearningDomain? domain = domains.find(domainId);
    final LearningItem? item = domain?.findItem(itemKey);
    return item == null ? null : domain?.helpOf(item);
  }

  /// Whole fact of [itemKey] with its result, such as "5 × 7 = 35".
  String describeItem(String itemKey, String domainId) {
    final LearningDomain? domain = domains.find(domainId);
    final LearningItem? item = domain?.findItem(itemKey);
    if (domain == null || item == null) return '';
    return domain.describeItem(item).toDisplayText();
  }
}
