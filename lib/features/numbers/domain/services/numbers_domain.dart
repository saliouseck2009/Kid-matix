import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/numbers/domain/entities/number_item.dart';
import 'package:kid_matix/features/numbers/domain/entities/numbers_unit.dart';
import 'package:kid_matix/features/numbers/domain/services/number_distractor_generator.dart';
import 'package:kid_matix/features/numbers/domain/services/numbers_catalog.dart';

/// The numbers up to 100: counting objects, tens and ones, comparing,
/// ordering on a number line, before and after. Seven units of ten items.
///
/// Every item has a format to pick its answer and one to write it, except
/// the comparisons, whose three signs count as written answers, so every
/// item can be mastered.
final class NumbersDomain implements LearningDomain {
  /// Creates the domain of [units]; [distractors] builds the wrong
  /// answers.
  NumbersDomain({
    List<NumbersUnit>? units,
    this._distractors = const NumberDistractorGenerator(),
  }) : _units = List<NumbersUnit>.unmodifiable(units ?? NumbersCatalog.units);

  /// Identifier of the domain.
  static const String domainId = LearningDomainIds.numbers;

  /// Draw weight of every item: none is easier than the others.
  static const int drawWeight = 1;

  final List<NumbersUnit> _units;
  final NumberDistractorGenerator _distractors;

  late final Map<String, NumberItem> _itemsByKey = <String, NumberItem>{
    for (final NumbersUnit unit in _units)
      for (final NumberItem item in unit.numberItems) item.key: item,
  };

  late final Map<String, NumbersUnit> _unitsByItemKey = <String, NumbersUnit>{
    for (final NumbersUnit unit in _units)
      for (final NumberItem item in unit.numberItems) item.key: unit,
  };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get units => _units;

  @override
  List<LearningUnit> get path => _units;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.countObjects,
    QuestionTypeIds.tensAndOnes,
    QuestionTypeIds.numberLine,
    QuestionTypeIds.compare,
    QuestionTypeIds.typedAnswer,
  ];

  @override
  List<String> questionTypeIdsOf(LearningItem item) {
    return _requireItem(item).questionTypeIds;
  }

  @override
  NumberItem? findItem(String key) => _itemsByKey[key];

  @override
  NumbersUnit? findUnit(String key) {
    for (final NumbersUnit unit in _units) {
      if (unit.key == key) return unit;
    }
    return null;
  }

  @override
  int drawWeightOf(LearningItem item) {
    _requireItem(item);
    return drawWeight;
  }

  @override
  LearningItem? mirrorOf(LearningItem item) {
    _requireItem(item);
    return null;
  }

  @override
  ItemHelp helpOf(LearningItem item) {
    final NumberItem numberItem = _requireItem(item);
    final NumbersUnit unit = _unitsByItemKey[numberItem.key]!;
    return ItemHelp(
      unitFacts: unit.numberItems
          .map((NumberItem other) => other.describe())
          .toList(),
      itemIndex: unit.numberItems.indexOf(numberItem),
      picture: numberItem.solvedPicture,
    );
  }

  @override
  List<PromptToken> describeItem(LearningItem item) {
    return _requireItem(item).describe();
  }

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final NumberItem numberItem = _requireItem(item);
    if (!numberItem.questionTypeIds.contains(questionTypeId)) {
      throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not fit for ${numberItem.key}',
      );
    }
    final String unitKey = _unitsByItemKey[numberItem.key]!.key;
    return switch (numberItem) {
      CompareItem() => _buildComparison(numberItem, unitKey),
      PictureNumberItem() when questionTypeId == QuestionTypeIds.typedAnswer =>
        _buildWritten(numberItem, unitKey),
      PictureNumberItem() => _buildPicked(
        numberItem,
        unitKey,
        questionTypeId,
        random,
      ),
    };
  }

  /// `34 ? 43`, answered with one of the three signs.
  Question _buildComparison(CompareItem item, String unitKey) {
    return Question(
      itemKey: item.key,
      unitKey: unitKey,
      questionTypeId: QuestionTypeIds.compare,
      prompt: <PromptToken>[
        NumberToken(item.first),
        const BlankToken(),
        NumberToken(item.second),
      ],
      choices: ComparisonAnswer.all,
      expectedAnswer: ComparisonAnswer(item.comparison),
    );
  }

  /// The drawing, its number written on the keypad.
  Question _buildWritten(PictureNumberItem item, String unitKey) {
    return Question(
      itemKey: item.key,
      unitKey: unitKey,
      questionTypeId: QuestionTypeIds.typedAnswer,
      prompt: item.prompt,
      picture: item.picture,
      expectedAnswer: NumberAnswer(item.answer),
    );
  }

  /// The drawing, its number picked among three plausible mistakes.
  Question _buildPicked(
    PictureNumberItem item,
    String unitKey,
    String questionTypeId,
    RandomSource random,
  ) {
    final List<int> values = <int>[
      item.answer,
      ..._distractors.generate(
        answer: item.answer,
        mistakes: item.mistakes,
        typicalMistake: item.typicalMistake,
        random: random,
      ),
    ];
    return Question(
      itemKey: item.key,
      unitKey: unitKey,
      questionTypeId: questionTypeId,
      prompt: item.prompt,
      picture: item.picture,
      choices: random.shuffled(values).map(NumberAnswer.new).toList(),
      expectedAnswer: NumberAnswer(item.answer),
    );
  }

  NumberItem _requireItem(LearningItem item) {
    final NumberItem? numberItem = findItem(item.key);
    if (numberItem == null) {
      throw ArgumentError.value(item.key, 'item', 'Not an item of numbers');
    }
    return numberItem;
  }
}
