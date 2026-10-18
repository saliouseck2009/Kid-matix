import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_error_code.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/quiz/answer.dart';
import 'package:kid_matix/core/quiz/item_answer.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_bloc.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_event.dart';
import 'package:kid_matix/features/learning_path/presentation/bloc/placement_state.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';
import '../../../helpers/test_path_pages.dart';
import '../../quiz/helpers/quiz_fixtures.dart';

const LearningPathParams _params = LearningPathParams(
  profileId: 'p1',
  domainId: 'multiplication',
);

void main() {
  late InMemoryStageProgressRepository repository;
  late FakeMasteryService mastery;
  late FakeClock clock;
  late PlacementBloc bloc;

  PlacementBloc buildBloc({LearningPathParams params = _params}) {
    return PlacementBloc(
      params: params,
      useCases: buildTestPlacementUseCases(
        repository: repository,
        mastery: mastery,
      ),
      clock: clock,
    );
  }

  setUp(() {
    repository = InMemoryStageProgressRepository();
    mastery = FakeMasteryService();
    clock = FakeClock(quizStart);
    bloc = buildBloc();
  });

  tearDown(() => bloc.close());

  Future<PlacementAsking> start() async {
    bloc.add(const PlacementStarted());
    await pumpEventQueue();
    return bloc.state as PlacementAsking;
  }

  /// Answers the question shown: right when its table is in [known], "Je
  /// ne sais pas" otherwise.
  Future<void> answerShown(Set<int> known) async {
    final PlacementAsking asking = bloc.state as PlacementAsking;
    clock.now_ = clock.now_.add(const Duration(seconds: 5));
    if (!known.contains(asking.question.unitNumber)) {
      bloc.add(const PlacementAnswerUnknown());
    } else {
      final NumberAnswer expected =
          asking.question.question.expectedAnswer as NumberAnswer;
      for (final String digit in '${expected.value}'.split('')) {
        bloc.add(PlacementDigitTyped(digit: int.parse(digit)));
      }
      bloc.add(const PlacementAnswerValidated());
    }
    await pumpEventQueue();
  }

  Future<List<String>> readOpenTables() async {
    final LearningPathEntity path = (await buildTestPathUseCases(
      repository: repository,
    ).getLearningPath(params: _params)).requireData;
    return <String>[
      for (final TablePathNode table in path.tables)
        if (table.status != TableStatus.locked) table.unitKey,
    ];
  }

  test('offers the test first, then asks the table of 1', () async {
    // Assert
    expect(bloc.state, isA<PlacementOffered>());
    // Act
    final PlacementAsking actualAsking = await start();
    // Assert
    expect(actualAsking.index, 0);
    expect(actualAsking.question.unitNumber, 1);
    expect(actualAsking.test.questions, hasLength(12));
    expect(actualAsking.askedAt, quizStart);
  });

  test('opens the tables 1, 2 and 10 when the test is passed so', () async {
    // Arrange
    await start();
    // Act
    for (int index = 0; index < 12; index++) {
      await answerShown(<int>{1, 2, 10});
    }
    // Assert
    final PlacementFinished actualFinished = bloc.state as PlacementFinished;
    expect(actualFinished.knownUnitKeys, <String>{'mul:1', 'mul:2', 'mul:10'});
    expect(
      actualFinished.units
          .where((({int number, bool isKnown}) unit) => unit.isKnown)
          .map((({int number, bool isKnown}) unit) => unit.number),
      <int>[1, 2, 10],
    );
    expect(actualFinished.units, hasLength(12));
    expect(await readOpenTables(), <String>['mul:1', 'mul:2', 'mul:10']);
    expect(mastery.recordedAnswers, hasLength(12));
    expect(
      mastery.recordedAnswers.where((ItemAnswer answer) => answer.isCorrect),
      hasLength(3),
    );
    expect(
      mastery.recordedAnswers.first.answerTime,
      const Duration(seconds: 5),
    );
  });

  test('keeps only the table of 1 when the test is skipped', () async {
    // Act: the player taps « Passer », the page opens the path.
    await bloc.close();
    // Assert
    expect(mastery.recordedAnswers, isEmpty);
    expect(await readOpenTables(), <String>['mul:1']);
  });

  test('keeps the tables found when the test is left midway', () async {
    // Arrange
    await start();
    // Act: the tables of 1 to 4 are asked, then the player leaves.
    for (int index = 0; index < 4; index++) {
      await answerShown(<int>{2, 3, 7});
    }
    await bloc.close();
    // Assert
    expect(await readOpenTables(), <String>['mul:1', 'mul:2', 'mul:3']);
    expect(mastery.recordedAnswers, hasLength(4));
  });

  test('finds no table when none is known', () async {
    // Arrange
    await start();
    // Act
    for (int index = 0; index < 12; index++) {
      await answerShown(const <int>{});
    }
    // Assert
    final PlacementFinished actualFinished = bloc.state as PlacementFinished;
    expect(actualFinished.knownUnitKeys, isEmpty);
    expect(await readOpenTables(), <String>['mul:1']);
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
    expect(actualAsking.index, 0);
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

  test('fails when the test cannot be built', () async {
    // Arrange
    await bloc.close();
    bloc = buildBloc(
      params: const LearningPathParams(profileId: 'p1', domainId: 'division'),
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
    await answerShown(const <int>{});
    // Assert
    expect((bloc.state as PlacementFailure).errorCode, AppErrorCode.cache);
  });
}
