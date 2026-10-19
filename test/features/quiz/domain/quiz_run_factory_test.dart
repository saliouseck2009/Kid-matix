import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/frozen_question_generator.dart';
import 'package:kid_matix/core/quiz/learning_domain_ids.dart';
import 'package:kid_matix/core/quiz/question.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_item_plan.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/seeded_draw.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_run.dart';
import 'package:kid_matix/features/quiz/domain/entities/quiz_turn.dart';
import 'package:kid_matix/features/quiz/domain/services/quiz_run_factory.dart';
import 'package:kid_matix/features/quiz/domain/usecases/build_quiz_params.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/quiz_fixtures.dart';

const List<String> _typed = <String>[QuestionTypeIds.typedAnswer];

QuizItemPlan _plan(String itemKey, [List<String> types = _typed]) {
  return QuizItemPlan(itemKey: itemKey, questionTypeIds: types);
}

List<String> _askedKeys(QuizRun run) {
  return run.queue.map((QuizTurn turn) => turn.question.itemKey).toList();
}

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  QuizRunFactory factory() {
    return buildQuizRunFactory(random: DartRandomSource(seed: 5));
  }

  group('QuizRunFactory.generate', () {
    test('asks the planned items in order and starts the run now', () {
      // Arrange
      final List<QuizItemPlan> inputPlans = <QuizItemPlan>[
        _plan('mul:7x8'),
        _plan('mul:7x3'),
        _plan('mul:7x8'),
      ];
      // Act
      final QuizRun actualRun = factory()
          .generate(
            params: buildParams(itemKeys: tableKeys(7)),
            domain: domain,
            plans: inputPlans,
          )
          .requireData;
      // Assert
      expect(_askedKeys(actualRun), <String>['mul:7x8', 'mul:7x3', 'mul:7x8']);
      expect(actualRun.sessionId, 'session-1');
      expect(actualRun.startedAt, quizStart);
      expect(actualRun.scoredQuestionCount, 3);
      expect(actualRun.profileId, 'profile-1');
    });
    test('fails with a validation error on an unknown question type', () {
      // Act
      final AppException? actualError = factory()
          .generate(
            params: buildParams(itemKeys: tableKeys(7)),
            domain: domain,
            plans: <QuizItemPlan>[
              _plan('mul:7x8', const <String>['unknown']),
            ],
          )
          .exceptionOrNull;
      // Assert
      expect(actualError, isA<ValidationException>());
    });
  });

  group('QuizRunFactory.generateMixed', () {
    test('builds each question in the domain of its item', () {
      // Arrange
      const BuildQuizParams inputParams = BuildQuizParams(
        profileId: 'profile-1',
        domainId: LearningDomainIds.mixed,
        mode: QuizMode.freeTraining,
        itemKeys: <String>['mul:7x8', 'add:7+8'],
        questionTypeIds: _typed,
      );
      // Act
      final QuizRun actualRun = factory()
          .generateMixed(
            params: inputParams,
            plans: <QuizItemPlan>[_plan('add:7+8'), _plan('mul:7x8')],
          )
          .requireData;
      // Assert
      expect(_askedKeys(actualRun), <String>['add:7+8', 'mul:7x8']);
      expect(actualRun.domainId, LearningDomainIds.mixed);
    });
  });

  group('QuizRunFactory.generateSeeded', () {
    test('asks the questions of the frozen generator', () {
      // Arrange
      const SeededDraw inputDraw = SeededDraw(seed: 31, version: 1);
      final BuildQuizParams inputParams = BuildQuizParams(
        profileId: 'profile-1',
        domainId: MultiplicationDomain.domainId,
        mode: QuizMode.timeAttack,
        itemKeys: tableKeys(6),
        questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
        questionCount: 15,
      );
      final List<Question> expectedQuestions = const FrozenQuestionGenerator()
          .generate(
            domain: domain,
            itemKeys: tableKeys(6),
            questionTypeIds: const <String>[QuestionTypeIds.multipleChoice],
            questionCount: 15,
            draw: inputDraw,
          );
      // Act
      final QuizRun actualRun = factory()
          .generateSeeded(params: inputParams, domain: domain, draw: inputDraw)
          .requireData;
      // Assert
      expect(
        actualRun.queue.map((QuizTurn turn) => turn.question),
        expectedQuestions,
      );
    });
  });

  group('QuizRunFactory.createRun', () {
    test('keeps the time factors of the known question types only', () {
      // Act
      final QuizRun actualRun = factory().createRun(
        params: buildParams(
          itemKeys: tableKeys(7),
          questionTypeIds: const <String>[
            QuestionTypeIds.typedAnswer,
            QuestionTypeIds.matchPairs,
            'unknown',
          ],
        ),
        questions: const <Question>[],
      );
      // Assert
      expect(actualRun.timeFactors, <String, int>{
        QuestionTypeIds.typedAnswer: 1,
        QuestionTypeIds.matchPairs: 2,
      });
      expect(actualRun.queue, isEmpty);
    });
    test('sets a boss for a boss fight and no schedule without a limit', () {
      // Arrange
      final BuildQuizParams inputParams = BuildQuizParams(
        profileId: 'profile-1',
        domainId: MultiplicationDomain.domainId,
        mode: QuizMode.freeTraining,
        itemKeys: tableKeys(7),
        questionTypeIds: _typed,
        isBossFight: true,
      );
      // Act
      final QuizRun actualRun = factory().createRun(
        params: inputParams,
        questions: const <Question>[],
      );
      // Assert
      expect(actualRun.boss, isNotNull);
      expect(actualRun.timeLimit, isNull);
      expect(actualRun.timeSchedule, isNull);
    });
  });
}
