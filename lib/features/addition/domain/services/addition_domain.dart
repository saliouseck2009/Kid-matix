import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_fact.dart';
import 'package:kid_matix/features/addition/domain/entities/arithmetic_unit.dart';
import 'package:kid_matix/features/addition/domain/services/addition_catalog.dart';
import 'package:kid_matix/features/addition/domain/services/arithmetic_distractor_generator.dart';

/// The additions and the subtractions, from the facts up to 10 to the
/// numbers up to 100 with carrying: nine units.
///
/// Every fact is asked in the four formats of the multiplication: the
/// result to pick or to write, a missing number, true or false. A mistake
/// recalls the fact of its family (`mirrorOf`): `8 + 7` after `7 + 8`,
/// `15 − 8` after `15 − 7`.
final class AdditionDomain implements LearningDomain {
  /// Creates the domain of [units]; [distractors] builds the wrong
  /// answers.
  AdditionDomain({
    List<ArithmeticUnit>? units,
    this._distractors = const ArithmeticDistractorGenerator(),
  }) : _units = List<ArithmeticUnit>.unmodifiable(
         units ?? AdditionCatalog.units,
       );

  /// Identifier of the domain.
  static const String domainId = LearningDomainIds.addition;

  /// Draw weight of every fact: none is easier than the others.
  static const int drawWeight = 1;

  /// The ten a number line goes through.
  static const int ten = ArithmeticFact.ten;

  final List<ArithmeticUnit> _units;
  final ArithmeticDistractorGenerator _distractors;

  late final Map<String, ArithmeticFact> _factsByKey = <String, ArithmeticFact>{
    for (final ArithmeticUnit unit in _units)
      for (final ArithmeticFact fact in unit.facts) fact.key: fact,
  };

  late final Map<String, ArithmeticUnit> _unitsByFactKey =
      <String, ArithmeticUnit>{
        for (final ArithmeticUnit unit in _units)
          for (final ArithmeticFact fact in unit.facts) fact.key: unit,
      };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get units => _units;

  @override
  List<LearningUnit> get path => _units;

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
  ];

  @override
  List<String> questionTypeIdsOf(LearningItem item) {
    _requireFact(item);
    return questionTypeIds;
  }

  @override
  ArithmeticFact? findItem(String key) => _factsByKey[key];

  @override
  ArithmeticUnit? findUnit(String key) {
    for (final ArithmeticUnit unit in _units) {
      if (unit.key == key) return unit;
    }
    return null;
  }

  @override
  int drawWeightOf(LearningItem item) {
    _requireFact(item);
    return drawWeight;
  }

  /// The other fact of the same operation and family that the domain
  /// teaches: `8 + 7` for `7 + 8`, `15 − 8` for `15 − 7`; `null` when the
  /// two numbers are equal or the domain lacks it.
  @override
  ArithmeticFact? mirrorOf(LearningItem item) {
    final ArithmeticFact fact = _requireFact(item);
    for (final ArithmeticFact member in fact.family) {
      if (member != fact && member.operator == fact.operator) {
        return findItem(member.key);
      }
    }
    return null;
  }

  /// The facts of [item]'s family that the domain teaches, [item]
  /// included: `7 + 8`, `8 + 7`, `15 − 7` and `15 − 8` for `7 + 8`.
  List<ArithmeticFact> familyOf(LearningItem item) {
    final ArithmeticFact fact = _requireFact(item);
    return <ArithmeticFact>[
      for (final ArithmeticFact member in fact.family) ?findItem(member.key),
    ];
  }

  @override
  String? recordingKeyOf(LearningItem item) => null;

  @override
  String? get contentLanguageCode => null;

  @override
  ItemHelp helpOf(LearningItem item) {
    final ArithmeticFact fact = _requireFact(item);
    final ArithmeticUnit unit = _unitsByFactKey[fact.key]!;
    return ItemHelp(
      unitFacts: unit.facts
          .map((ArithmeticFact other) => other.describe())
          .toList(),
      itemIndex: unit.facts.indexOf(fact),
      picture: _pictureOf(fact, unit.aid),
    );
  }

  @override
  List<PromptToken> describeItem(LearningItem item) {
    return _requireFact(item).describe();
  }

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final ArithmeticFact fact = _requireFact(item);
    return switch (questionTypeId) {
      QuestionTypeIds.multipleChoice => _buildMultipleChoice(fact, random),
      QuestionTypeIds.typedAnswer => _buildTypedAnswer(fact),
      QuestionTypeIds.missingNumber => _buildMissingNumber(fact, random),
      QuestionTypeIds.trueFalse => _buildTrueFalse(fact, random),
      _ => throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not supported by the addition domain',
      ),
    };
  }

  /// `7 + 8 = ?` with the result among three plausible wrong answers.
  Question _buildMultipleChoice(ArithmeticFact fact, RandomSource random) {
    final List<int> values = <int>[
      fact.result,
      ..._distractors.generate(fact: fact, random: random),
    ];
    return Question(
      itemKey: fact.key,
      unitKey: _unitsByFactKey[fact.key]!.key,
      questionTypeId: QuestionTypeIds.multipleChoice,
      prompt: fact.prompt(),
      choices: random.shuffled(values).map(NumberAnswer.new).toList(),
      expectedAnswer: NumberAnswer(fact.result),
    );
  }

  /// `7 + 8 = ?`, written on the keypad.
  Question _buildTypedAnswer(ArithmeticFact fact) {
    return Question(
      itemKey: fact.key,
      unitKey: _unitsByFactKey[fact.key]!.key,
      questionTypeId: QuestionTypeIds.typedAnswer,
      prompt: fact.prompt(),
      expectedAnswer: NumberAnswer(fact.result),
    );
  }

  /// `7 + ? = 15` or `? + 8 = 15`, either number hidden at random; the
  /// unit of the complements to 10 always hides the right one.
  Question _buildMissingNumber(ArithmeticFact fact, RandomSource random) {
    final ArithmeticUnit unit = _unitsByFactKey[fact.key]!;
    final bool hidesRight =
        unit.aid == ArithmeticAid.completeToTen || random.nextInt(2) == 0;
    return Question(
      itemKey: fact.key,
      unitKey: unit.key,
      questionTypeId: QuestionTypeIds.missingNumber,
      prompt: fact.prompt(
        hidden: hidesRight ? HiddenPart.right : HiddenPart.left,
      ),
      expectedAnswer: NumberAnswer(hidesRight ? fact.right : fact.left),
    );
  }

  /// `7 + 8 = 15` or a plausible mistake such as `7 + 8 = 17`, true one
  /// time out of two.
  Question _buildTrueFalse(ArithmeticFact fact, RandomSource random) {
    final bool isTrue = random.nextInt(2) == 0;
    final int shown = isTrue
        ? fact.result
        : _distractors.wrongStatementResult(fact: fact, random: random);
    return Question(
      itemKey: fact.key,
      unitKey: _unitsByFactKey[fact.key]!.key,
      questionTypeId: QuestionTypeIds.trueFalse,
      prompt: fact.promptWithResult(shown),
      expectedAnswer: BooleanAnswer(value: isTrue),
    );
  }

  /// The drawing of the help card of [fact].
  ///
  /// A line goes from one number to the other through the ten when the
  /// operation crosses it (7, 10, 15) and highlights the result; bundles
  /// of ten show the result of a big number; the complement to 10 is the
  /// gap from the number to 10 (from 10 down to the result for a
  /// subtraction).
  MathPicture _pictureOf(ArithmeticFact fact, ArithmeticAid aid) {
    return switch (aid) {
      ArithmeticAid.tenBundles => TenBundlesPicture(
        tens: fact.result ~/ ten,
        ones: fact.result % ten,
      ),
      ArithmeticAid.completeToTen when fact.isAddition => NumberLinePicture(
        values: <int>[fact.left, ten],
        highlightIndex: 1,
      ),
      ArithmeticAid.completeToTen => NumberLinePicture(
        values: <int>[fact.result, ten],
        highlightIndex: 0,
      ),
      ArithmeticAid.numberLine => _lineOf(fact),
    };
  }

  /// The line from the smaller to the larger number of [fact], with the
  /// ten between them when there is one.
  MathPicture _lineOf(ArithmeticFact fact) {
    final int low = fact.isAddition ? fact.left : fact.result;
    final int high = fact.isAddition ? fact.result : fact.left;
    final bool hasTenBetween = low < ten && ten < high;
    final List<int> values = <int>[low, if (hasTenBetween) ten, high];
    return NumberLinePicture(
      values: values,
      highlightIndex: fact.isAddition ? values.length - 1 : 0,
    );
  }

  ArithmeticFact _requireFact(LearningItem item) {
    final ArithmeticFact? fact = findItem(item.key);
    if (fact == null) {
      throw ArgumentError.value(item.key, 'item', 'Not an addition fact');
    }
    return fact;
  }
}
