import 'package:kid_matix/core/entities/currency.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/recognition_cap.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/core/services/sentence_splitter.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_catalog.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_instance.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_unit.dart';
import 'package:kid_matix/features/problem/domain/services/problem_calculation.dart';

/// Word problems: a story, its bar model, the operation, the calculation.
/// One item per template (`problem:<key>`), so the mastery follows each
/// story, not each number.
///
/// A problem is asked in three ways: solved step by step (the recorded
/// statement with its fixed numbers), on the bar model (fixed or drawn
/// numbers), or reduced to the choice of its operation (drawn numbers, the
/// short format of the timed stages).
final class ProblemDomain implements LearningDomain, RecognitionCap {
  /// Creates the domain of [catalog]. Without a [splitter] no word of the
  /// statements can be touched.
  ProblemDomain({
    required this.catalog,
    this.splitter,
    this.currency = Currency.defaultCurrency,
  });

  /// Identifier of the domain.
  static const String domainId = LearningDomainIds.problems;

  /// Draw weight of every problem.
  static const int drawWeight = 1;

  /// The recorded statement comes one time in this many on the bar model;
  /// the other times the numbers are drawn.
  static const int recordedOneIn = 2;

  /// The problems and the units.
  final ProblemCatalog catalog;

  /// Cuts the statements for the words to touch.
  final SentenceSplitter? splitter;

  /// The money of the statements.
  final Currency currency;

  late final Map<String, ProblemUnit> _unitsBySlug = <String, ProblemUnit>{
    for (final ProblemUnit unit in catalog.units) unit.slug: unit,
  };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get units => catalog.units;

  @override
  List<LearningUnit> get path => catalog.units;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.solveProblem,
    QuestionTypeIds.barModel,
    QuestionTypeIds.problemOperation,
  ];

  @override
  List<String> questionTypeIdsOf(LearningItem item) {
    _requireProblem(item);
    return questionTypeIds;
  }

  @override
  ProblemTemplate? findItem(String key) {
    const String prefix = '${ProblemTemplate.keyPrefix}:';
    if (!key.startsWith(prefix)) return null;
    return catalog.problemOf(key.substring(prefix.length));
  }

  @override
  ProblemUnit? findUnit(String key) {
    const String prefix = '${ProblemUnit.keyPrefix}:';
    if (!key.startsWith(prefix)) return null;
    return _unitsBySlug[key.substring(prefix.length)];
  }

  @override
  int drawWeightOf(LearningItem item) {
    _requireProblem(item);
    return drawWeight;
  }

  @override
  LearningItem? mirrorOf(LearningItem item) {
    _requireProblem(item);
    return null;
  }

  /// A problem takes several right steps and right answers on spaced days
  /// to climb: picking among choices has no cap here.
  @override
  int? get recognizedBoxCap => null;

  @override
  String? recordingKeyOf(LearningItem item) =>
      _requireProblem(item).recordingKey;

  /// The statements are French, whatever the language of the interface.
  @override
  String get contentLanguageCode => 'fr';

  @override
  ItemHelp helpOf(LearningItem item) {
    final ProblemTemplate problem = _requireProblem(item);
    final ProblemUnit unit = _unitsBySlug[ProblemCatalog.slugOf(problem)]!;
    return ItemHelp(
      unitFacts: <List<PromptToken>>[
        for (final ProblemTemplate other in unit.problems) describeItem(other),
      ],
      itemIndex: unit.problems.indexOf(problem),
      picture: problem.fixedInstance(currency: currency).picture,
    );
  }

  /// The calculation of the recorded statement, such as `12 − 5 = 7`.
  @override
  List<PromptToken> describeItem(LearningItem item) {
    return const ProblemCalculation().tokensOf(
      _requireProblem(item).fixedInstance(currency: currency).picture,
    );
  }

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final ProblemTemplate problem = _requireProblem(item);
    if (!questionTypeIds.contains(questionTypeId)) {
      throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not fit for ${problem.key}',
      );
    }
    final bool isRecorded = switch (questionTypeId) {
      QuestionTypeIds.solveProblem => true,
      QuestionTypeIds.barModel => random.nextInt(recordedOneIn) == 0,
      _ => false,
    };
    final ProblemInstance instance = isRecorded
        ? problem.fixedInstance(currency: currency)
        : problem.drawnInstance(random.nextInt, currency: currency);
    final bool asksOperation =
        questionTypeId == QuestionTypeIds.problemOperation;
    return Question(
      itemKey: problem.key,
      unitKey: catalog.units
          .firstWhere((ProblemUnit unit) => unit.problems.contains(problem))
          .key,
      questionTypeId: questionTypeId,
      prompt: <PromptToken>[TextToken(instance.statement)],
      sentence: _sentenceOf(instance.statement),
      picture: instance.picture,
      choices: asksOperation
          ? OperatorAnswer.all
          : const ProblemCalculation().choicesOf(instance.picture, random),
      expectedAnswer: asksOperation
          ? OperatorAnswer(problem.operation)
          : const ProblemAnswer(),
      recordingKey: isRecorded ? problem.recordingKey : null,
    );
  }

  List<SentencePart> _sentenceOf(String statement) {
    return splitter?.split(statement) ??
        <SentencePart>[SentencePart(statement)];
  }

  ProblemTemplate _requireProblem(LearningItem item) {
    final ProblemTemplate? problem = findItem(item.key);
    if (problem == null) {
      throw ArgumentError.value(item.key, 'item', 'Not a word problem');
    }
    return problem;
  }
}
