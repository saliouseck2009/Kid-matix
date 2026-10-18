import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/answer_nature.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/prompt_token.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_pair.dart';
import 'package:kid_matix/core/quiz/question_type.dart';
import 'package:kid_matix/core/quiz/question_types/app_question_types.dart';
import 'package:kid_matix/core/quiz/question_types/find_operation_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/match_pairs_question_type.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';

OperationAnswer _operation(int left, int right) {
  return OperationAnswer(<PromptToken>[
    NumberToken(left),
    const OperatorToken(MathOperator.multiply),
    NumberToken(right),
  ]);
}

QuestionPair _pair(int left, int right) {
  return QuestionPair(
    itemKey: 'mul:${left}x$right',
    operation: _operation(left, right),
    result: NumberAnswer(left * right),
  );
}

Question _pairsQuestion() {
  final List<QuestionPair> pairs = <QuestionPair>[
    _pair(3, 4),
    _pair(3, 6),
    _pair(3, 9),
    _pair(3, 5),
  ];
  return Question(
    itemKey: 'mul:3x6',
    unitKey: 'mul:3',
    questionTypeId: QuestionTypeIds.matchPairs,
    prompt: const <PromptToken>[],
    choices: pairs.map((QuestionPair pair) => pair.result).toList(),
    pairs: pairs,
    expectedAnswer: PairsAnswer(),
  );
}

void main() {
  group('question types of version 1.1', () {
    test('are registered after those of version 1.0', () {
      // Act
      final List<String> actualIds = appQuestionTypes
          .map((QuestionType type) => type.id)
          .toList();
      // Assert
      expect(actualIds.toSet(), hasLength(actualIds.length));
      expect(
        actualIds.sublist(4, 6),
        <String>[QuestionTypeIds.findOperation, QuestionTypeIds.matchPairs],
      );
    });
    test('count as recognized answers, capped by the mastery', () {
      // Assert
      expect(
        const FindOperationQuestionType().answerNature,
        AnswerNature.recognized,
      );
      expect(
        const MatchPairsQuestionType().answerNature,
        AnswerNature.recognized,
      );
    });
    test('give twice the time to match pairs only', () {
      // Assert
      expect(const FindOperationQuestionType().timeFactor, 1);
      expect(const MatchPairsQuestionType().timeFactor, 2);
      expect(
        appQuestionTypes
            .where((QuestionType type) => type.timeFactor != 1)
            .map((QuestionType type) => type.id),
        <String>[QuestionTypeIds.matchPairs],
      );
    });
  });

  group('FindOperationQuestionType', () {
    final Question inputQuestion = Question(
      itemKey: 'mul:4x6',
      unitKey: 'mul:4',
      questionTypeId: QuestionTypeIds.findOperation,
      prompt: const <PromptToken>[
        BlankToken(),
        EqualsToken(),
        NumberToken(24),
      ],
      choices: <Answer>[_operation(5, 5), _operation(4, 6)],
      expectedAnswer: _operation(4, 6),
    );

    test('accepts the operation expected', () {
      // Act
      final bool actualIsCorrect = const FindOperationQuestionType().isCorrect(
        question: inputQuestion,
        answer: _operation(4, 6),
      );
      // Assert
      expect(actualIsCorrect, isTrue);
    });
    test('refuses another operation, even the same the other way', () {
      // Act
      final bool actualOther = const FindOperationQuestionType().isCorrect(
        question: inputQuestion,
        answer: _operation(5, 5),
      );
      final bool actualMirror = const FindOperationQuestionType().isCorrect(
        question: inputQuestion,
        answer: _operation(6, 4),
      );
      // Assert
      expect(actualOther, isFalse);
      expect(actualMirror, isFalse);
    });
  });

  group('MatchPairsQuestionType', () {
    test('accepts pairs matched without a mistake', () {
      // Act
      final bool actualIsCorrect = const MatchPairsQuestionType().isCorrect(
        question: _pairsQuestion(),
        answer: PairsAnswer(),
      );
      // Assert
      expect(actualIsCorrect, isTrue);
    });
    test('refuses pairs matched after a mistake', () {
      // Act
      final bool actualIsCorrect = const MatchPairsQuestionType().isCorrect(
        question: _pairsQuestion(),
        answer: PairsAnswer(missedItemKeys: <String>{'mul:3x9'}),
      );
      // Assert
      expect(actualIsCorrect, isFalse);
    });
    test('refuses an answer of another kind', () {
      // Act
      final bool actualIsCorrect = const MatchPairsQuestionType().isCorrect(
        question: _pairsQuestion(),
        answer: const NumberAnswer(12),
      );
      // Assert
      expect(actualIsCorrect, isFalse);
    });
  });

  group('answers and questions of version 1.1', () {
    test('compare operations by their tokens', () {
      // Assert
      expect(_operation(4, 6), _operation(4, 6));
      expect(_operation(4, 6).hashCode, _operation(4, 6).hashCode);
      expect(_operation(4, 6), isNot(_operation(6, 4)));
      expect(_operation(4, 6), isNot(const NumberAnswer(24)));
      expect(
        OperationAnswer(const <PromptToken>[NumberToken(4)]),
        isNot(_operation(4, 6)),
      );
      expect(_operation(4, 6).toString(), contains('4'));
    });
    test('compare pairs answers by the items missed, in any order', () {
      // Arrange
      final PairsAnswer inputFirst = PairsAnswer(
        missedItemKeys: <String>{'mul:3x4', 'mul:3x9'},
      );
      final PairsAnswer inputSecond = PairsAnswer(
        missedItemKeys: <String>{'mul:3x9', 'mul:3x4'},
      );
      // Assert
      expect(inputFirst, inputSecond);
      expect(inputFirst.hashCode, inputSecond.hashCode);
      expect(inputFirst, isNot(PairsAnswer()));
      expect(
        inputFirst,
        isNot(PairsAnswer(missedItemKeys: <String>{'mul:3x4'})),
      );
      expect(inputFirst.toString(), contains('mul:3x9'));
    });
    test('list the items of a question: its pairs, or its own item', () {
      // Arrange
      final Question inputSingle = Question(
        itemKey: 'mul:3x4',
        unitKey: 'mul:3',
        questionTypeId: QuestionTypeIds.multipleChoice,
        prompt: const <PromptToken>[NumberToken(3)],
        expectedAnswer: const NumberAnswer(12),
      );
      // Assert
      expect(inputSingle.itemKeys, <String>['mul:3x4']);
      expect(_pairsQuestion().itemKeys, <String>[
        'mul:3x4',
        'mul:3x6',
        'mul:3x9',
        'mul:3x5',
      ]);
    });
    test('compare questions with their pairs', () {
      // Assert
      expect(_pairsQuestion(), _pairsQuestion());
      expect(_pairsQuestion().hashCode, _pairsQuestion().hashCode);
      expect(_pair(3, 4), _pair(3, 4));
      expect(_pair(3, 4).hashCode, _pair(3, 4).hashCode);
      expect(_pair(3, 4), isNot(_pair(3, 5)));
      expect(_pair(3, 4).toString(), contains('mul:3x4'));
    });
  });
}
