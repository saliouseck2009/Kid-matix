import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_help.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';
import 'package:kid_matix/features/division/domain/entities/division_unit.dart';
import 'package:kid_matix/features/division/domain/services/division_distractor_generator.dart';

/// The divisions of the multiplication tables: the 120 facts of the
/// tables 1 to 12 up to x 10, read backwards, such as 56 ÷ 7 = 8.
///
/// One unit per divisor, on the path in the order of the multiplication
/// tables. After a mistake, the player is reminded of the multiplication
/// that gives the same numbers (see [mirrorOf]).
final class DivisionDomain implements LearningDomain {
  /// Creates the domain; [distractors] builds the wrong answers.
  DivisionDomain({
    this._distractors = const DivisionDistractorGenerator(),
  }) : units = List<DivisionUnit>.unmodifiable(
         List<DivisionUnit>.generate(
           unitCount,
           (int index) =>
               DivisionUnit(number: index + 1, lastQuotient: lastQuotient),
         ),
       );

  /// Identifier of the domain.
  static const String domainId = LearningDomainIds.division;

  /// Number of units, from 1 to [unitCount]: the tables of multiplication.
  static const int unitCount = 12;

  /// Highest quotient of every unit: the highest multiplier of a table.
  static const int lastQuotient = 10;

  /// Order of the units on the learning path: that of the multiplication
  /// tables, simplest first.
  static const List<int> pathOrder = <int>[
    1,
    2,
    10,
    5,
    3,
    4,
    6,
    9,
    7,
    8,
    11,
    12,
  ];

  /// Draw weight of most divisions.
  static const int standardDrawWeight = 2;

  /// Draw weight of the quotients 1 and 10 outside the units of 1 and 10,
  /// half the standard one: 70 ÷ 7 is easy once the table of 10 is known.
  static const int easyDrawWeight = 1;

  /// Quotients that make a division easy outside its own unit.
  static const List<int> easyQuotients = <int>[1, 10];

  final DivisionDistractorGenerator _distractors;

  /// The 12 units, the divisions by 1 first.
  @override
  final List<DivisionUnit> units;

  late final Map<String, DivisionFact> _factsByKey = <String, DivisionFact>{
    for (final DivisionUnit unit in units)
      for (final DivisionFact fact in unit.facts) fact.key: fact,
  };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get path => List<LearningUnit>.unmodifiable(
    pathOrder.map((int number) => units[number - 1]),
  );

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
  ];

  @override
  List<String> questionTypeIdsOf(LearningItem item) => questionTypeIds;

  @override
  DivisionFact? findItem(String key) => _factsByKey[key];

  @override
  DivisionUnit? findUnit(String key) {
    for (final DivisionUnit unit in units) {
      if (unit.key == key) return unit;
    }
    return null;
  }

  @override
  int drawWeightOf(LearningItem item) {
    final DivisionFact fact = _requireFact(item);
    final bool isEasy =
        easyQuotients.contains(fact.quotient) &&
        !easyQuotients.contains(fact.divisor);
    return isEasy ? easyDrawWeight : standardDrawWeight;
  }

  /// The multiplication that gives the same numbers, such as 7 × 8 = 56
  /// for 56 ÷ 7: a [MultiplicationRecall], described by [describeItem].
  @override
  MultiplicationRecall mirrorOf(LearningItem item) {
    return MultiplicationRecall(_requireFact(item));
  }

  /// The divisions of the unit, and a grid of dots that shares the
  /// dividend in as many equal rows as the divisor: 7 rows of 8 dots for
  /// 56 ÷ 7.
  @override
  ItemHelp helpOf(LearningItem item) {
    final DivisionFact fact = _requireFact(item);
    return ItemHelp(
      unitFacts: units[fact.divisor - 1].facts.map(describeItem).toList(),
      itemIndex: fact.quotient - 1,
      dotGrid: DotGrid(rows: fact.divisor, columns: fact.quotient),
    );
  }

  /// `56 ÷ 7 = 8` for a division, `7 × 8 = 56` for its recall.
  @override
  List<PromptToken> describeItem(LearningItem item) {
    if (item is MultiplicationRecall) {
      final DivisionFact fact = item.fact;
      return <PromptToken>[
        NumberToken(fact.divisor),
        const OperatorToken(MathOperator.multiply),
        NumberToken(fact.quotient),
        const EqualsToken(),
        NumberToken(fact.dividend),
      ];
    }
    final DivisionFact fact = _requireFact(item);
    return _prompt(fact.dividend, fact.divisor, NumberToken(fact.quotient));
  }

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final DivisionFact fact = _requireFact(item);
    return switch (questionTypeId) {
      QuestionTypeIds.multipleChoice => _buildMultipleChoice(fact, random),
      QuestionTypeIds.typedAnswer => _buildTypedAnswer(fact),
      QuestionTypeIds.missingNumber => _buildMissingNumber(fact, random),
      QuestionTypeIds.trueFalse => _buildTrueFalse(fact, random),
      _ => throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not supported by the division domain',
      ),
    };
  }

  /// `56 ÷ 7 = ?` with the quotient among three plausible wrong answers.
  Question _buildMultipleChoice(DivisionFact fact, RandomSource random) {
    final List<int> values = <int>[
      fact.quotient,
      ..._distractors.generate(fact: fact, random: random),
    ];
    return Question(
      itemKey: fact.key,
      unitKey: units[fact.divisor - 1].key,
      questionTypeId: QuestionTypeIds.multipleChoice,
      prompt: _prompt(fact.dividend, fact.divisor, const BlankToken()),
      choices: random.shuffled(values).map(NumberAnswer.new).toList(),
      expectedAnswer: NumberAnswer(fact.quotient),
    );
  }

  /// `72 ÷ 9 = ?`, written on the keypad.
  Question _buildTypedAnswer(DivisionFact fact) {
    return Question(
      itemKey: fact.key,
      unitKey: units[fact.divisor - 1].key,
      questionTypeId: QuestionTypeIds.typedAnswer,
      prompt: _prompt(fact.dividend, fact.divisor, const BlankToken()),
      expectedAnswer: NumberAnswer(fact.quotient),
    );
  }

  /// `56 ÷ ? = 8` or `? ÷ 7 = 8`, either number hidden at random.
  Question _buildMissingNumber(DivisionFact fact, RandomSource random) {
    final bool hidesDivisor = random.nextInt(2) == 0;
    final PromptToken quotient = NumberToken(fact.quotient);
    return Question(
      itemKey: fact.key,
      unitKey: units[fact.divisor - 1].key,
      questionTypeId: QuestionTypeIds.missingNumber,
      prompt: hidesDivisor
          ? _prompt(fact.dividend, null, quotient)
          : _prompt(null, fact.divisor, quotient),
      expectedAnswer: NumberAnswer(hidesDivisor ? fact.divisor : fact.dividend),
    );
  }

  /// `56 ÷ 7 = 8` or a plausible mistake such as `56 ÷ 7 = 9`, true one
  /// time out of two.
  Question _buildTrueFalse(DivisionFact fact, RandomSource random) {
    final bool isTrue = random.nextInt(2) == 0;
    final int shown = isTrue
        ? fact.quotient
        : _distractors.generate(fact: fact, random: random, count: 1).single;
    return Question(
      itemKey: fact.key,
      unitKey: units[fact.divisor - 1].key,
      questionTypeId: QuestionTypeIds.trueFalse,
      prompt: _prompt(fact.dividend, fact.divisor, NumberToken(shown)),
      expectedAnswer: BooleanAnswer(value: isTrue),
    );
  }

  DivisionFact _requireFact(LearningItem item) {
    final DivisionFact? fact = findItem(item.key);
    if (fact == null) {
      throw ArgumentError.value(item.key, 'item', 'Not a division fact');
    }
    return fact;
  }

  /// `left ÷ right = result`, a `null` operand shown as the blank.
  static List<PromptToken> _prompt(int? left, int? right, PromptToken result) {
    return <PromptToken>[
      if (left == null) const BlankToken() else NumberToken(left),
      const OperatorToken(MathOperator.divide),
      if (right == null) const BlankToken() else NumberToken(right),
      const EqualsToken(),
      result,
    ];
  }
}
