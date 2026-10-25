import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/learning_item.dart';
import 'package:kid_matix/core/quiz/learning_unit.dart';
import 'package:kid_matix/core/quiz/math_operator.dart';
import 'package:kid_matix/core/quiz/math_picture.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/sentence_part.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_catalog.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_template.dart';
import 'package:kid_matix/features/problem/domain/entities/problem_templates.dart';
import 'package:kid_matix/features/problem/domain/services/problem_domain.dart';

import 'helpers/problem_fixtures.dart';

void main() {
  final ProblemDomain domain = buildProblemDomain();
  final DartRandomSource random = DartRandomSource(seed: 7);

  Question ask(String problemKey, String typeId) {
    return domain.buildQuestion(
      item: domain.findItem('problem:$problemKey')!,
      questionTypeId: typeId,
      random: random,
    );
  }

  group('the path', () {
    test('goes level by level, the traps after the plain problems', () {
      // Assert
      expect(
        domain.units.map((LearningUnit unit) => unit.key).toList(),
        <String>[
          'probs:add1',
          'probs:sub1',
          'probs:mul1',
          'probs:div1',
          'probs:trap1',
          'probs:add2',
          'probs:sub2',
          'probs:mul2',
          'probs:div2',
          'probs:trap2',
          'probs:add3',
          'probs:sub3',
          'probs:mul3',
          'probs:div3',
          'probs:trap3',
        ],
      );
      expect(
        domain.units.map((LearningUnit unit) => unit.number).toList(),
        List<int>.generate(15, (int index) => index + 1),
      );
    });

    test('puts every problem in one unit and every trap after its twin', () {
      // Arrange
      final Map<String, int> positionOf = <String, int>{
        for (final LearningUnit unit in domain.path)
          for (final LearningItem item in unit.items) item.key: unit.number,
      };
      // Assert
      expect(positionOf, hasLength(30));
      for (final ProblemTemplate problem in ProblemTemplates.all) {
        final String? twin = problem.trapOf;
        if (twin == null) continue;
        expect(
          positionOf[problem.key]!,
          greaterThan(positionOf['problem:$twin']!),
          reason: problem.problemKey,
        );
      }
    });

    test('finds items and units by key, and nothing else', () {
      // Assert
      expect(domain.findItem('problem:billes_recues'), isNotNull);
      expect(domain.findItem('word:il_reste'), isNull);
      expect(domain.findItem('problem:unknown'), isNull);
      expect(domain.findUnit('probs:mul2')?.items, hasLength(1));
      expect(domain.findUnit('word:add'), isNull);
      expect(ProblemCatalog.slugOf(ProblemTemplates.all.first), 'sub1');
    });

    test('rejects a duplicate key and a trap without twin', () {
      // Assert
      expect(
        () => ProblemCatalog(<ProblemTemplate>[
          ProblemTemplates.all.first,
          ProblemTemplates.all.first,
        ]),
        throwsFormatException,
      );
      expect(
        () => ProblemCatalog(<ProblemTemplate>[
          ProblemTemplates.all.firstWhere((ProblemTemplate p) => p.isTrap),
        ]),
        throwsFormatException,
      );
    });
  });

  group('the questions', () {
    test('solves the recorded statement step by step', () {
      // Act
      final Question actual = ask(
        'mangues_donnees',
        QuestionTypeIds.solveProblem,
      );
      // Assert
      final BarModelPicture picture = actual.picture! as BarModelPicture;
      expect(actual.itemKey, 'problem:mangues_donnees');
      expect(actual.unitKey, 'probs:sub1');
      expect(
        actual.prompt.single.toString(),
        'Awa a 12 mangues. Elle en donne 5 à sa petite sœur. '
        'Combien de mangues lui reste-t-il ?',
      );
      expect(picture.answer, 7);
      expect(picture.operator, MathOperator.subtract);
      expect(actual.expectedAnswer, const ProblemAnswer());
      expect(actual.recordingKey, 'problem_mangues_donnees');
      expect(actual.choices, contains(const NumberAnswer(7)));
    });

    test('draws the numbers of a bar model about half of the time', () {
      // Act
      final List<Question> actual = <Question>[
        for (int i = 0; i < 40; i++)
          ask('mangues_donnees', QuestionTypeIds.barModel),
      ];
      final int recorded = actual
          .where((Question q) => q.recordingKey != null)
          .length;
      // Assert
      expect(recorded, inInclusiveRange(5, 35));
      for (final Question question in actual) {
        expect((question.picture! as BarModelPicture).answer, greaterThan(0));
        expect(
          question.choices.toSet(),
          hasLength(4),
          reason: 'four different results to pick from',
        );
        expect(
          question.choices,
          contains(NumberAnswer((question.picture! as BarModelPicture).answer)),
        );
      }
    });

    test('asks the operation of a drawn statement with no recording', () {
      for (final ProblemTemplate problem in ProblemTemplates.all) {
        // Act
        final Question actual = ask(
          problem.problemKey,
          QuestionTypeIds.problemOperation,
        );
        // Assert
        expect(actual.expectedAnswer, OperatorAnswer(problem.operation));
        expect(actual.choices, OperatorAnswer.all);
        expect(actual.recordingKey, isNull);
      }
    });

    test('cuts the statement in touchable math words', () {
      // Act
      final Question actual = ask('mangues_donnees', QuestionTypeIds.barModel);
      // Assert
      expect(
        actual.sentence.map((SentencePart part) => part.text).join(),
        actual.prompt.single.toString(),
      );
      expect(
        actual.sentence.map((SentencePart part) => part.wordKey).nonNulls,
        containsAll(<String>['donner', 'il_reste', 'combien']),
      );
    });

    test('builds every type for every problem, without error', () {
      for (final ProblemTemplate problem in ProblemTemplates.all) {
        for (final String type in domain.questionTypeIdsOf(problem)) {
          // Act
          final Question actual = ask(problem.problemKey, type);
          // Assert
          expect(actual.picture, isA<BarModelPicture>());
          expect(actual.itemKey, problem.key);
        }
      }
    });

    test('refuses a type it does not have', () {
      // Assert
      expect(
        () => ask('billes_recues', QuestionTypeIds.multipleChoice),
        throwsArgumentError,
      );
    });
  });

  group('the contract', () {
    test('names the recordings, the language and the help', () {
      // Arrange
      final ProblemTemplate problem = domain.findItem(
        'problem:mangues_donnees',
      )!;
      // Assert
      expect(domain.recordingKeyOf(problem), 'problem_mangues_donnees');
      expect(domain.contentLanguageCode, 'fr');
      expect(domain.recognizedBoxCap, isNull);
      expect(domain.mirrorOf(problem), isNull);
      expect(domain.helpOf(problem).picture, isA<BarModelPicture>());
      expect(
        domain.describeItem(problem).join(' '),
        '12 subtract 5 = 7',
      );
    });
  });
}
