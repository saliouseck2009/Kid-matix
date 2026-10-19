import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/division/domain/entities/division_fact.dart';
import 'package:kid_matix/features/division/domain/services/division_distractor_generator.dart';

/// Builds the questions about a division, one per format.
final class DivisionQuestionBuilder {
  /// Creates the builder; [distractors] builds the wrong answers.
  const DivisionQuestionBuilder({
    this._distractors = const DivisionDistractorGenerator(),
  });

  final DivisionDistractorGenerator _distractors;

  /// The question of type [questionTypeId] about [fact].
  Question build({
    required DivisionFact fact,
    required String questionTypeId,
    required RandomSource random,
  }) {
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

  /// `left ÷ right = result`, a `null` operand shown as the blank.
  static List<PromptToken> operation(
    int? left,
    int? right,
    PromptToken result,
  ) {
    return <PromptToken>[
      if (left == null) const BlankToken() else NumberToken(left),
      const OperatorToken(MathOperator.divide),
      if (right == null) const BlankToken() else NumberToken(right),
      const EqualsToken(),
      result,
    ];
  }

  /// `56 ÷ 7 = ?` with the quotient among three plausible wrong answers.
  Question _buildMultipleChoice(DivisionFact fact, RandomSource random) {
    final List<int> values = <int>[
      fact.quotient,
      ..._distractors.generate(fact: fact, random: random),
    ];
    return Question(
      itemKey: fact.key,
      unitKey: fact.unitKey,
      questionTypeId: QuestionTypeIds.multipleChoice,
      prompt: operation(fact.dividend, fact.divisor, const BlankToken()),
      choices: random.shuffled(values).map(NumberAnswer.new).toList(),
      expectedAnswer: NumberAnswer(fact.quotient),
    );
  }

  /// `72 ÷ 9 = ?`, written on the keypad.
  Question _buildTypedAnswer(DivisionFact fact) {
    return Question(
      itemKey: fact.key,
      unitKey: fact.unitKey,
      questionTypeId: QuestionTypeIds.typedAnswer,
      prompt: operation(fact.dividend, fact.divisor, const BlankToken()),
      expectedAnswer: NumberAnswer(fact.quotient),
    );
  }

  /// `56 ÷ ? = 8` or `? ÷ 7 = 8`, either number hidden at random.
  Question _buildMissingNumber(DivisionFact fact, RandomSource random) {
    final bool hidesDivisor = random.nextInt(2) == 0;
    final PromptToken quotient = NumberToken(fact.quotient);
    return Question(
      itemKey: fact.key,
      unitKey: fact.unitKey,
      questionTypeId: QuestionTypeIds.missingNumber,
      prompt: hidesDivisor
          ? operation(fact.dividend, null, quotient)
          : operation(null, fact.divisor, quotient),
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
      unitKey: fact.unitKey,
      questionTypeId: QuestionTypeIds.trueFalse,
      prompt: operation(fact.dividend, fact.divisor, NumberToken(shown)),
      expectedAnswer: BooleanAnswer(value: isTrue),
    );
  }
}
