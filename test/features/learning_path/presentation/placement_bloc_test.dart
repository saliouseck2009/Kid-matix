import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/core/services/dart_random_source.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/build_placement_question_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_use_cases.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_path_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

void main() {
  late InMemoryStageProgressRepository repository;
  late InMemoryPlacementResultRepository results;
  late FakeMasteryService mastery;
  late FakeClock clock;
  late PlacementBloc bloc;

  PlacementBloc buildBloc({PlacementUseCases? useCases}) {
    return PlacementBloc(
      profileId: 'p1',
      useCases:
          useCases ??
          buildTestPlacementUseCases(
            repository: repository,
            mastery: mastery,
            results: results,
          ),
      clock: clock,
    );
  }

  setUp(() {
    repository = InMemoryStageProgressRepository();
    clock = FakeClock(quizStart);
    results = InMemoryPlacementResultRepository(clock: clock);
    mastery = FakeMasteryService();
    bloc = buildBloc();
  });

  tearDown(() => bloc.close());

  Future<PlacementAsking> start() async {
    bloc.add(const PlacementStarted());
    await pumpEventQueue();
    return bloc.state as PlacementAsking;
  }

  /// Answers the question shown: right on the keypad when [isRight],
  /// "Je ne sais pas" otherwise.
  Future<void> answerShown({required bool isRight}) async {
    final PlacementAsking asking = bloc.state as PlacementAsking;
    clock.now_ = clock.now_.add(const Duration(seconds: 5));
    if (!isRight) {
      bloc.add(const PlacementAnswerUnknown());
    } else {
      final NumberAnswer expected =
          asking.question.expectedAnswer as NumberAnswer;
      for (final String digit in '${expected.value}'.split('')) {
        bloc.add(PlacementDigitTyped(digit: int.parse(digit)));
      }
      bloc.add(const PlacementAnswerValidated());
    }
    await pumpEventQueue();
  }

  Future<void> answerAll(List<bool> answers) async {
    for (final bool isRight in answers) {
      if (bloc.state is! PlacementAsking) break;
      await answerShown(isRight: isRight);
    }
  }

  Future<List<String>> readOpenUnits(String domainId) async {
    final LearningPathEntity path =
        (await buildTestPathUseCases(
              repository: repository,
            ).getLearningPath(
              params: LearningPathParams(profileId: 'p1', domainId: domainId),
            ))
            .requireData;
    return <String>[
      for (final TablePathNode table in path.tables)
        if (table.status != TableStatus.locked) table.unitKey,
    ];
  }

  test(
    'offers the test first, then asks the first question of the numbers',
    () async {
      // Assert
      expect(bloc.state, isA<PlacementOffered>());
      // Act
      final PlacementAsking actualAsking = await start();
      // Assert
      expect(actualAsking.journey.skill!.id, 'numbers');
      expect(actualAsking.domainId, 'numbers');
      expect(actualAsking.question.unitKey, 'num:count20');
      expect(actualAsking.askedAt, quizStart);
      expect(actualAsking.progress, 0);
    },
  );

  test('climbs through every skill while all the answers are right', () async {
    // Arrange
    await start();
    // Act
    await answerAll(List<bool>.filled(15, true));
    // Assert
    final PlacementFinished actualFinished = bloc.state as PlacementFinished;
    expect(actualFinished.outcome.isEverythingAcquired, isTrue);
    expect(mastery.recordedAnswers, hasLength(15));
    expect(results.saved, hasLength(1));
    expect(await readOpenUnits('multiplication'), contains('mul:8'));
    expect(await readOpenUnits('division'), contains('div:9'));
  });

  test(
    'stops at the first level not acquired and starts on the first addition',
    () async {
      // Arrange
      await start();
      // Act: the numbers are right, the two first additions are wrong.
      await answerAll(<bool>[true, true, true, false, false, true, true]);
      // Assert
      final PlacementFinished actualFinished = bloc.state as PlacementFinished;
      expect(actualFinished.outcome.recommendedDomainId, 'addition');
      expect(actualFinished.outcome.recommendedUnitKey, 'addsub:add5');
      expect(mastery.recordedAnswers, hasLength(5));
      expect(
        mastery.recordedAnswers.where((ItemAnswer answer) => answer.isCorrect),
        hasLength(3),
      );
      expect(
        mastery.recordedAnswers.first.answerTime,
        const Duration(seconds: 5),
      );
      expect(results.saved.single.profileId, 'p1');
      expect(await readOpenUnits('addition'), <String>['addsub:add5']);
      expect(
        await readOpenUnits('numbers'),
        containsAll(<String>['num:count10', 'num:count20', 'num:order']),
      );
      expect(await readOpenUnits('multiplication'), <String>['mul:1']);
    },
  );

  test('opens the units found up to the hardest right answer', () async {
    // Arrange
    await start();
    // Act: the numbers are right, then the easy and the medium additions.
    await answerAll(<bool>[true, true, true, true, true, false, false, false]);
    // Assert
    expect(await readOpenUnits('addition'), <String>[
      'addsub:add5',
      'addsub:sub5',
      'addsub:add7',
      'addsub:add9',
      'addsub:toten',
    ]);
  });

  test('keeps only the first units when the test is skipped', () async {
    // Act: the player taps « Passer », the page opens the path.
    await bloc.close();
    // Assert
    expect(mastery.recordedAnswers, isEmpty);
    expect(results.saved, isEmpty);
    expect(await readOpenUnits('multiplication'), <String>['mul:1']);
    expect(await readOpenUnits('numbers'), <String>['num:count10']);
  });

  test(
    'keeps the units found but no result when the test is abandoned',
    () async {
      // Arrange
      await start();
      // Act: two right answers, then the player leaves.
      await answerAll(<bool>[true, true]);
      await bloc.close();
      // Assert
      expect(await readOpenUnits('numbers'), <String>[
        'num:count10',
        'num:count20',
        'num:count100',
        'num:tensones',
      ]);
      expect(mastery.recordedAnswers, hasLength(2));
      expect(results.saved, isEmpty);
    },
  );

  test('finds no level when nothing is known', () async {
    // Arrange
    await start();
    // Act
    await answerAll(<bool>[false, false]);
    // Assert
    final PlacementFinished actualFinished = bloc.state as PlacementFinished;
    expect(actualFinished.outcome.skills.single.isAcquired, isFalse);
    expect(actualFinished.outcome.recommendedDomainId, 'numbers');
    expect(actualFinished.outcome.recommendedUnitKey, 'num:count10');
    expect(results.saved, hasLength(1));
  });

  test('fills the progress bar as the skills are climbed', () async {
    // Arrange
    await start();
    // Act
    await answerAll(<bool>[true, true, true]);
    // Assert
    final PlacementAsking actualAsking = bloc.state as PlacementAsking;
    expect(actualAsking.journey.skill!.id, 'addition');
    expect(actualAsking.progress, 0.2);
  });

  test('types, erases and validates digits on the keypad', () async {
    // Arrange
    await start();
    // Act
    bloc
      ..add(const PlacementAnswerValidated())
      ..add(const PlacementDigitTyped(digit: 0))
      ..add(const PlacementDigitTyped(digit: 4))
      ..add(const PlacementDigitTyped(digit: 5))
      ..add(const PlacementDigitTyped(digit: 6))
      ..add(const PlacementDigitTyped(digit: 7))
      ..add(const PlacementDigitErased());
    await pumpEventQueue();
    // Assert
    final PlacementAsking actualAsking = bloc.state as PlacementAsking;
    expect(actualAsking.journey.answeredCount, 0);
    expect(actualAsking.typedDigits, '45');
    expect(mastery.recordedAnswers, isEmpty);
  });

  test('ignores the keys outside a question', () async {
    // Act
    bloc
      ..add(const PlacementDigitTyped(digit: 4))
      ..add(const PlacementDigitErased())
      ..add(const PlacementAnswerValidated())
      ..add(const PlacementAnswerUnknown());
    await pumpEventQueue();
    // Assert
    expect(bloc.state, isA<PlacementOffered>());
  });

  test('fails when a question cannot be built', () async {
    // Arrange
    await bloc.close();
    bloc = buildBloc(
      useCases: PlacementUseCases(
        buildQuestion: BuildPlacementQuestionUseCase(
          domains: DomainRegistry(),
          random: DartRandomSource(seed: 1),
        ),
        answerQuestion: buildTestPlacementUseCases(
          repository: repository,
        ).answerQuestion,
        saveResult: buildTestPlacementUseCases(
          repository: repository,
        ).saveResult,
      ),
    );
    // Act
    bloc.add(const PlacementStarted());
    await pumpEventQueue();
    // Assert
    expect(
      (bloc.state as PlacementFailure).errorCode,
      AppErrorCode.validation,
    );
  });

  test('fails when an answer cannot be recorded', () async {
    // Arrange
    await start();
    mastery.failure = const CacheException();
    // Act
    await answerShown(isRight: false);
    // Assert
    expect((bloc.state as PlacementFailure).errorCode, AppErrorCode.cache);
  });

  test('fails when the result cannot be kept', () async {
    // Arrange
    await start();
    results.saveFailure = const CacheException();
    // Act
    await answerAll(<bool>[false, false]);
    // Assert
    expect((bloc.state as PlacementFailure).errorCode, AppErrorCode.cache);
  });
}
