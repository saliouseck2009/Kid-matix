import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_domain.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/services/distractor_generator.dart';

/// The multiplication tables from 1 to 12, up to x 10: 120 facts.
final class MultiplicationDomain implements LearningDomain {
  /// Creates the domain; [distractors] builds the wrong answers.
  MultiplicationDomain({
    this._distractors = const DistractorGenerator(),
  }) : tables = List<MultiplicationTable>.unmodifiable(
         List<MultiplicationTable>.generate(
           tableCount,
           (int index) => MultiplicationTable(
             number: index + 1,
             lastMultiplier: lastMultiplier,
           ),
         ),
       );

  /// Identifier of the domain.
  static const String domainId = 'multiplication';

  /// Number of tables, from 1 to [tableCount].
  static const int tableCount = 12;

  /// Highest multiplier of every table.
  static const int lastMultiplier = 10;

  /// Order of the tables on the learning path, simplest first.
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

  final DistractorGenerator _distractors;

  /// The 12 tables, table of 1 first.
  final List<MultiplicationTable> tables;

  late final Map<String, MultiplicationFact> _factsByKey =
      <String, MultiplicationFact>{
        for (final MultiplicationTable table in tables)
          for (final MultiplicationFact fact in table.facts) fact.key: fact,
      };

  @override
  String get id => domainId;

  @override
  List<LearningUnit> get units => tables;

  @override
  List<LearningUnit> get path => List<LearningUnit>.unmodifiable(
    pathOrder.map((int number) => tables[number - 1]),
  );

  @override
  List<String> get questionTypeIds => const <String>[
    QuestionTypeIds.multipleChoice,
    QuestionTypeIds.typedAnswer,
    QuestionTypeIds.missingNumber,
    QuestionTypeIds.trueFalse,
  ];

  @override
  MultiplicationFact? findItem(String key) => _factsByKey[key];

  @override
  Question buildQuestion({
    required LearningItem item,
    required String questionTypeId,
    required RandomSource random,
  }) {
    final MultiplicationFact? fact = findItem(item.key);
    if (fact == null) {
      throw ArgumentError.value(item.key, 'item', 'Not a multiplication fact');
    }
    return switch (questionTypeId) {
      QuestionTypeIds.multipleChoice => _buildMultipleChoice(fact, random),
      QuestionTypeIds.typedAnswer => _buildTypedAnswer(fact),
      QuestionTypeIds.missingNumber => _buildMissingNumber(fact, random),
      QuestionTypeIds.trueFalse => _buildTrueFalse(fact, random),
      _ => throw ArgumentError.value(
        questionTypeId,
        'questionTypeId',
        'Not supported by the multiplication domain',
      ),
    };
  }

  /// `7 × 8 = ?` with the result among three plausible wrong answers.
  Question _buildMultipleChoice(MultiplicationFact fact, RandomSource random) {
    final List<int> values = <int>[
      fact.product,
      ..._distractors.generate(fact: fact, random: random),
    ];
    return Question(
      itemKey: fact.key,
      questionTypeId: QuestionTypeIds.multipleChoice,
      prompt: _prompt(fact.table, fact.multiplier, const BlankToken()),
      choices: random.shuffled(values).map(NumberAnswer.new).toList(),
      expectedAnswer: NumberAnswer(fact.product),
    );
  }

  /// `6 × 9 = ?`, written on the keypad.
  Question _buildTypedAnswer(MultiplicationFact fact) {
    return Question(
      itemKey: fact.key,
      questionTypeId: QuestionTypeIds.typedAnswer,
      prompt: _prompt(fact.table, fact.multiplier, const BlankToken()),
      expectedAnswer: NumberAnswer(fact.product),
    );
  }

  /// `7 × ? = 56` or `? × 8 = 56`, either operand hidden at random.
  Question _buildMissingNumber(MultiplicationFact fact, RandomSource random) {
    final bool hidesMultiplier = random.nextInt(2) == 0;
    final PromptToken product = NumberToken(fact.product);
    return Question(
      itemKey: fact.key,
      questionTypeId: QuestionTypeIds.missingNumber,
      prompt: hidesMultiplier
          ? _prompt(fact.table, null, product)
          : _prompt(null, fact.multiplier, product),
      expectedAnswer: NumberAnswer(
        hidesMultiplier ? fact.multiplier : fact.table,
      ),
    );
  }

  /// `6 × 7 = 42` or a plausible mistake such as `6 × 7 = 48`, true one
  /// time out of two.
  Question _buildTrueFalse(MultiplicationFact fact, RandomSource random) {
    final bool isTrue = random.nextInt(2) == 0;
    final int shown = isTrue
        ? fact.product
        : _distractors.generate(fact: fact, random: random, count: 1).single;
    return Question(
      itemKey: fact.key,
      questionTypeId: QuestionTypeIds.trueFalse,
      prompt: _prompt(fact.table, fact.multiplier, NumberToken(shown)),
      expectedAnswer: BooleanAnswer(value: isTrue),
    );
  }

  /// `left × right = result`, a `null` operand shown as the blank.
  static List<PromptToken> _prompt(int? left, int? right, PromptToken result) {
    return <PromptToken>[
      if (left == null) const BlankToken() else NumberToken(left),
      const OperatorToken(MathOperator.multiply),
      if (right == null) const BlankToken() else NumberToken(right),
      const EqualsToken(),
      result,
    ];
  }
}
