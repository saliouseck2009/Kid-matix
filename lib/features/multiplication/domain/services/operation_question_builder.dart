import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_types/match_pairs_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/services/random_source.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_fact.dart';
import 'package:kid_matix/features/multiplication/domain/entities/multiplication_table.dart';
import 'package:kid_matix/features/multiplication/domain/services/operation_distractor_generator.dart';

/// Builds the questions whose answers are operations: "find the
/// operation" and "match the pairs" (version 1.1).
final class OperationQuestionBuilder {
  /// Creates the builder; [distractors] draws the wrong operations.
  const OperationQuestionBuilder({required this._distractors});

  final OperationDistractorGenerator _distractors;

  /// `? = 24` with `4 × 6` among three operations that give another
  /// result.
  Question buildFindOperation({
    required MultiplicationFact fact,
    required MultiplicationTable table,
    required RandomSource random,
  }) {
    final List<MultiplicationFact> operations = <MultiplicationFact>[
      fact,
      ..._distractors.generate(fact: fact, random: random),
    ];
    return Question(
      itemKey: fact.key,
      unitKey: table.key,
      questionTypeId: QuestionTypeIds.findOperation,
      prompt: <PromptToken>[
        const BlankToken(),
        const EqualsToken(),
        NumberToken(fact.product),
      ],
      choices: random.shuffled(operations).map(_operationOf).toList(),
      expectedAnswer: _operationOf(fact),
    );
  }

  /// [fact] and three other facts of its [table] to tie to their results:
  /// the results all differ, since the facts of a table do. Operations
  /// and results are shuffled each on its own side.
  Question buildMatchPairs({
    required MultiplicationFact fact,
    required MultiplicationTable table,
    required RandomSource random,
  }) {
    final List<MultiplicationFact> others = random
        .shuffled(
          table.facts
              .where((MultiplicationFact other) => other != fact)
              .toList(),
        )
        .take(MatchPairsQuestionType.pairCount - 1)
        .toList();
    final List<QuestionPair> pairs = random
        .shuffled(<MultiplicationFact>[fact, ...others])
        .map(
          (MultiplicationFact pairFact) => QuestionPair(
            itemKey: pairFact.key,
            operation: _operationOf(pairFact),
            result: NumberAnswer(pairFact.product),
          ),
        )
        .toList();
    return Question(
      itemKey: fact.key,
      unitKey: table.key,
      questionTypeId: QuestionTypeIds.matchPairs,
      prompt: const <PromptToken>[],
      choices: random.shuffled(
        pairs.map((QuestionPair pair) => pair.result).toList(),
      ),
      pairs: pairs,
      expectedAnswer: PairsAnswer(),
    );
  }

  static OperationAnswer _operationOf(MultiplicationFact fact) {
    return OperationAnswer(<PromptToken>[
      NumberToken(fact.table),
      const OperatorToken(MathOperator.multiply),
      NumberToken(fact.multiplier),
    ]);
  }
}
