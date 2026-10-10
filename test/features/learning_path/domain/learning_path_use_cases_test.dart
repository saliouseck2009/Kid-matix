import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/app_exception.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/core/quiz/domain_registry.dart';
import 'package:kid_matix/core/quiz/question_types/question_type_ids.dart';
import 'package:kid_matix/core/quiz/quiz_mode.dart';
import 'package:kid_matix/core/quiz/quiz_selection.dart';
import 'package:kid_matix/core/quiz/quiz_spec.dart';
import 'package:kid_matix/core/services/player_settings_service.dart';
import 'package:kid_matix/features/learning_path/domain/entities/learning_path_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_source.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/stage_progress_repository.dart';
import 'package:kid_matix/features/learning_path/domain/services/stage_quiz_specs.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_learning_path_use_case.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/learning_path_params.dart';
import 'package:kid_matix/features/multiplication/domain/services/multiplication_domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/fake_mastery_service.dart';

final class _MockRepository extends Mock implements StageProgressRepository {}

final class _MockSettings extends Mock implements PlayerSettingsService {}

const LearningPathParams _params = LearningPathParams(
  profileId: 'p1',
  domainId: 'multiplication',
);

void main() {
  final MultiplicationDomain domain = MultiplicationDomain();
  const StageQuizSpecs specs = StageQuizSpecs();

  group('StageQuizSpecs', () {
    QuizSpec specOf(String unitKey, StageKind stage) => specs.specOf(
      domain: domain,
      source: StageSource(unitKey: unitKey, stage: stage),
    )!;

    test('asks the 10 facts in order with answers to pick to discover', () {
      // Act
      final QuizSpec actualSpec = specOf('mul:5', StageKind.discovery);
      // Assert
      expect(actualSpec.mode, QuizMode.path);
      expect(actualSpec.itemKeys.first, 'mul:5x1');
      expect(actualSpec.itemKeys, hasLength(10));
      expect(actualSpec.selection, QuizSelection.inOrder);
      expect(actualSpec.questionTypeIds, <String>[
        QuestionTypeIds.multipleChoice,
      ]);
      expect(actualSpec.baseTimeLimit, isNull);
      expect(actualSpec.sourceKey, 'path:mul:5:discovery');
    });
    test('shuffles the writing stage with answers to write', () {
      // Act
      final QuizSpec actualSpec = specOf('mul:5', StageKind.writing);
      // Assert
      expect(actualSpec.selection, QuizSelection.shuffled);
      expect(actualSpec.questionTypeIds, <String>[
        QuestionTypeIds.typedAnswer,
        QuestionTypeIds.missingNumber,
      ]);
    });
    test('gives 10 seconds per question at the speed stage', () {
      // Act
      final QuizSpec actualSpec = specOf('mul:5', StageKind.speed);
      // Assert
      expect(actualSpec.baseTimeLimit, const Duration(seconds: 10));
      expect(actualSpec.questionTypeIds, hasLength(4));
    });
    test('mixes 15 questions of the tables seen in a review', () {
      // Act
      final QuizSpec actualSpec = specOf('review:1', StageKind.review);
      // Assert
      expect(actualSpec.questionCount, 15);
      expect(actualSpec.selection, QuizSelection.mastery);
      expect(actualSpec.itemKeys, hasLength(30));
      expect(
        actualSpec.itemKeys.map((String key) => key.split('x').first).toSet(),
        <String>{'mul:1', 'mul:2', 'mul:10'},
      );
    });
    test('fights the boss on the table, then on the tables seen', () {
      // Act
      final QuizSpec actualFirst = specOf('mul:1', StageKind.boss);
      final QuizSpec actualFifth = specOf('mul:5', StageKind.boss);
      // Assert
      expect(actualFirst.isBossFight, isTrue);
      expect(actualFirst.baseTimeLimit, const Duration(seconds: 8));
      expect(actualFirst.questionTypeIds, hasLength(4));
      expect(actualFirst.followUpQuestionCount, 10);
      expect(actualFirst.followUpItemKeys, actualFirst.itemKeys);
      expect(actualFifth.itemKeys.first, 'mul:5x1');
      expect(
        actualFifth.followUpItemKeys
            .map((String key) => key.split('x').first)
            .toSet(),
        <String>{'mul:1', 'mul:2', 'mul:10'},
      );
    });
    test('has no quiz for an unknown table or review', () {
      // Assert
      expect(
        specs.specOf(
          domain: domain,
          source: const StageSource(unitKey: 'mul:13', stage: StageKind.speed),
        ),
        isNull,
      );
      expect(
        specs.specOf(
          domain: domain,
          source: const StageSource(
            unitKey: 'review:5',
            stage: StageKind.review,
          ),
        ),
        isNull,
      );
    });
  });

  group('GetLearningPathUseCase', () {
    late _MockRepository mockRepository;
    late _MockSettings mockSettings;
    late GetLearningPathUseCase useCase;
    late FakeMasteryService mastery;

    setUp(() {
      mockRepository = _MockRepository();
      mockSettings = _MockSettings();
      mastery = FakeMasteryService();
      useCase = GetLearningPathUseCase(
        repository: mockRepository,
        domains: DomainRegistry()..register(domain),
        settings: mockSettings,
        mastery: mastery,
      );
      when(
        () => mockSettings.readEverythingUnlocked(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(false));
      when(
        () => mockRepository.getProgress(
          profileId: any(named: 'profileId'),
          domainId: any(named: 'domainId'),
        ),
      ).thenAnswer(
        (_) async => DataSuccess<List<StageProgressEntity>>(
          <StageProgressEntity>[
            StageProgressEntity(
              profileId: 'p1',
              domainId: 'multiplication',
              unitKey: 'mul:1',
              stage: StageKind.discovery,
              bestStars: 2,
              bestScore: 8,
              completedAt: DateTime(2026, 10, 10),
            ),
          ],
        ),
      );
    });

    test('builds the path of the player from the stored stars', () async {
      // Act
      final LearningPathEntity actualPath = (await useCase(
        params: _params,
      )).requireData;
      // Assert
      expect(actualPath.tables, hasLength(12));
      expect(actualPath.tables.first.totalStars, 2);
      expect(actualPath.tables.first.nextStage?.kind, StageKind.training);
    });
    test('opens everything when the setting says so', () async {
      // Arrange
      when(
        () => mockSettings.readEverythingUnlocked(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(true));
      // Act
      final LearningPathEntity actualPath = (await useCase(
        params: _params,
      )).requireData;
      // Assert
      expect(actualPath.tables.last.status, TableStatus.open);
    });
    test('fails on an unknown domain', () async {
      // Act
      final AppException? actualException = (await useCase(
        params: const LearningPathParams(profileId: 'p1', domainId: 'div'),
      )).exceptionOrNull;
      // Assert
      expect(actualException, isA<ValidationException>());
    });
    test('fails when the settings or the progress cannot be read', () async {
      // Arrange
      when(
        () => mockSettings.readEverythingUnlocked(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataFailed<bool>(CacheException()));
      // Act
      final AppException? actualSettings = (await useCase(
        params: _params,
      )).exceptionOrNull;
      when(
        () => mockSettings.readEverythingUnlocked(
          profileId: any(named: 'profileId'),
        ),
      ).thenAnswer((_) async => const DataSuccess<bool>(false));
      when(
        () => mockRepository.getProgress(
          profileId: any(named: 'profileId'),
          domainId: any(named: 'domainId'),
        ),
      ).thenAnswer(
        (_) async =>
            const DataFailed<List<StageProgressEntity>>(CacheException()),
      );
      final AppException? actualProgress = (await useCase(
        params: _params,
      )).exceptionOrNull;
      // Assert
      mastery.failure = const CacheException();
      final AppException? actualMastery = (await useCase(
        params: _params,
      )).exceptionOrNull;
      expect(actualSettings, isA<CacheException>());
      expect(actualProgress, isA<CacheException>());
      expect(actualMastery, isA<CacheException>());
    });
    test('tells whether a stage can be played now', () async {
      // Arrange
      final LearningPathEntity inputPath = (await useCase(
        params: _params,
      )).requireData;
      // Act
      bool playable(String unitKey, StageKind stage) => specs.isPlayable(
        path: inputPath,
        source: StageSource(unitKey: unitKey, stage: stage),
      );
      // Assert
      expect(playable('mul:1', StageKind.training), isTrue);
      expect(playable('mul:1', StageKind.writing), isFalse);
      expect(playable('mul:2', StageKind.discovery), isFalse);
      expect(playable('review:1', StageKind.review), isFalse);
      expect(playable('mul:13', StageKind.discovery), isFalse);
    });
  });
}
