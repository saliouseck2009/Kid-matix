import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/timer_mode.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/features/challenge/data/datasources/training_choice_local_data_source_impl.dart';
import 'package:kid_matix/features/challenge/data/repositories/training_choice_repository_impl.dart';
import 'package:kid_matix/features/challenge/domain/entities/challenge_source.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_time_attack_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/get_training_choice_use_case.dart';
import 'package:kid_matix/features/challenge/domain/usecases/save_training_choice_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../helpers/challenge_fakes.dart';
import '../../../helpers/in_memory_local_storage.dart';
import '../../../helpers/test_quiz_pages.dart';

void main() {
  late InMemoryLocalStorage storage;
  late TrainingChoiceRepositoryImpl repository;

  setUp(() {
    storage = InMemoryLocalStorage();
    repository = TrainingChoiceRepositoryImpl(
      choices: TrainingChoiceLocalDataSourceImpl(storage: storage),
    );
  });

  GetTrainingChoiceUseCase getChoice({
    List<String>? openUnits = const <String>['mul:1', 'mul:2', 'mul:3'],
    TimerMode timerMode = TimerMode.normal,
  }) {
    return GetTrainingChoiceUseCase(
      repository: repository,
      openUnits: FixedOpenUnits(openUnits),
      settings: FixedPlayerSettings(timerMode),
    );
  }

  group('GetTrainingChoiceUseCase', () {
    test('offers the current table, 10 questions and the timer', () async {
      // Act
      final TrainingSource actualChoice = (await getChoice()(
        params: 'p1',
      )).requireData;
      // Assert
      expect(
        actualChoice,
        TrainingSource(
          unitKeys: const <String>['mul:3'],
          questionCount: 10,
          hasTimer: true,
        ),
      );
    });
    test('offers no timer when the player turned it off', () async {
      // Act
      final TrainingSource actualChoice = (await getChoice(
        timerMode: TimerMode.off,
      )(params: 'p1')).requireData;
      // Assert
      expect(actualChoice.hasTimer, isFalse);
    });
    test('offers again the last training of the player', () async {
      // Arrange
      final TrainingSource inputChoice = TrainingSource(
        unitKeys: const <String>['mul:2', 'mul:5'],
        questionCount: 20,
        hasTimer: false,
      );
      await SaveTrainingChoiceUseCase(
        repository: repository,
      )(params: (profileId: 'p1', choice: inputChoice));
      // Act
      final TrainingSource actualChoice = (await getChoice()(
        params: 'p1',
      )).requireData;
      final TrainingSource actualOther = (await getChoice()(
        params: 'p2',
      )).requireData;
      // Assert
      expect(actualChoice, inputChoice);
      expect(actualOther.unitKeys, <String>['mul:3']);
    });
    test('ignores a choice that no longer reads', () async {
      // Arrange
      await storage.writeString(
        key: '${TrainingChoiceLocalDataSourceImpl.keyPrefix}p1',
        value: 'training:oops',
      );
      // Act
      final TrainingSource actualChoice = (await getChoice()(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actualChoice.unitKeys, <String>['mul:3']);
    });
    test('fails when the open tables cannot be read', () async {
      // Act
      final AppException? actualException = (await getChoice(openUnits: null)(
        params: 'p1',
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });

  group('GetTimeAttackUseCase', () {
    test('plays on every table open to the player', () async {
      // Act
      final TimeAttackSource actualSource = (await const GetTimeAttackUseCase(
        openUnits: FixedOpenUnits(<String>['mul:1', 'mul:2']),
      )(params: 'p1')).requireData;
      // Assert
      expect(actualSource.unitKeys, <String>['mul:1', 'mul:2']);
    });
    test('fails when the open tables cannot be read', () async {
      // Act
      final AppException? actualException = (await const GetTimeAttackUseCase(
        openUnits: FixedOpenUnits(null),
      )(params: 'p1')).exceptionOrNull;
      // Assert
      expect(actualException, isA<CacheException>());
    });
  });
}
