import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/error/data_state.dart';
import 'package:kid_matix/features/learning_path/domain/entities/domain_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_outcome.dart';
import 'package:kid_matix/features/learning_path/domain/entities/placement_result_entity.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_kind.dart';
import 'package:kid_matix/features/learning_path/domain/entities/stage_progress_entity.dart';
import 'package:kid_matix/features/learning_path/domain/repositories/placement_result_repository.dart';
import 'package:kid_matix/features/learning_path/domain/usecases/get_path_overview_use_case.dart';

import '../../../helpers/data_state_test_extension.dart';
import '../../../helpers/test_path_pages.dart';

/// Placement tests fixed by the test, the latest first.
final class _FixedPlacements implements PlacementResultRepository {
  _FixedPlacements(this.history);

  final List<PlacementResultEntity> history;

  @override
  Future<DataState<List<PlacementResultEntity>>> getHistory({
    required String profileId,
  }) async => DataSuccess<List<PlacementResultEntity>>(history);

  @override
  Future<DataState<void>> save({
    required String profileId,
    required PlacementOutcome outcome,
  }) async => const DataSuccess<void>(null);

  @override
  Stream<void> watchChanges() => const Stream<void>.empty();
}

/// A placement test that recommended starting [domainId] at [unitKey].
PlacementResultEntity _recommending(String domainId, String unitKey) {
  return PlacementResultEntity(
    takenAt: DateTime(2026, 11, 1),
    domains: <DomainResultEntity>[
      DomainResultEntity(
        domainId: domainId,
        level: 0,
        skillCount: 2,
        unitCount: 0,
        startUnitKey: unitKey,
      ),
    ],
  );
}

StageProgressEntity _stars(
  String domainId,
  String unitKey,
  StageKind stage, {
  int stars = 3,
}) {
  return StageProgressEntity(
    profileId: 'p1',
    domainId: domainId,
    unitKey: unitKey,
    stage: stage,
    bestStars: stars,
    bestScore: 10,
    completedAt: DateTime(2026, 11, 1),
  );
}

/// The writing stage, which makes a unit done, of every unit in [keys].
List<StageProgressEntity> _done(String domainId, List<String> keys) {
  return <StageProgressEntity>[
    for (final String key in keys) _stars(domainId, key, StageKind.writing),
  ];
}

const List<String> _numberUnits = <String>[
  'num:count10',
  'num:count20',
  'num:count100',
  'num:tensones',
  'num:compare',
  'num:order',
  'num:beforeafter',
];

void main() {
  GetPathOverviewUseCase buildUseCase({
    List<StageProgressEntity> progress = const <StageProgressEntity>[],
    List<PlacementResultEntity> history = const <PlacementResultEntity>[],
  }) {
    return buildTestOverviewUseCase(
      repository: InMemoryStageProgressRepository(progress),
      results: _FixedPlacements(history),
    );
  }

  DomainProgressEntity progressOf(PathOverviewEntity overview, String id) {
    return overview.domains.firstWhere(
      (DomainProgressEntity domain) => domain.domainId == id,
    );
  }

  group('GetPathOverviewUseCase', () {
    test('lists every domain, in the order of the app, unstarted', () async {
      // Act
      final PathOverviewEntity actual = (await buildUseCase()(
        params: 'p1',
      )).requireData;
      // Assert
      expect(
        actual.domains.map((DomainProgressEntity domain) => domain.domainId),
        <String>[
          'multiplication',
          'numbers',
          'addition',
          'division',
          'math_words',
          'problems',
        ],
      );
      expect(
        actual.domains.every((DomainProgressEntity domain) {
          return !domain.isStarted &&
              domain.doneUnitCount == 0 &&
              domain.unitCount > 0;
        }),
        isTrue,
      );
      expect(actual.recommendedDomainId, isNull);
    });

    test('counts the units done and the crowns of a domain', () async {
      // Arrange
      final GetPathOverviewUseCase useCase = buildUseCase(
        progress: <StageProgressEntity>[
          ..._done('multiplication', <String>['mul:1', 'mul:2']),
          _stars('multiplication', 'mul:1', StageKind.boss),
          _stars('multiplication', 'mul:10', StageKind.discovery),
        ],
      );
      // Act
      final DomainProgressEntity actual = progressOf(
        (await useCase(params: 'p1')).requireData,
        'multiplication',
      );
      // Assert
      expect(actual.isStarted, isTrue);
      expect(actual.doneUnitCount, 2);
      expect(actual.unitCount, 12);
      expect(actual.crownCount, 1);
      expect(actual.isFinished, isFalse);
    });

    test('a domain with every unit done is finished', () async {
      // Arrange
      final GetPathOverviewUseCase useCase = buildUseCase(
        progress: _done('numbers', _numberUnits),
      );
      // Act
      final DomainProgressEntity actual = progressOf(
        (await useCase(params: 'p1')).requireData,
        'numbers',
      );
      // Assert
      expect(actual.doneUnitCount, 7);
      expect(actual.unitCount, 7);
      expect(actual.isFinished, isTrue);
      expect(actual.doneFraction, 1);
    });

    test('recommends the domain of the latest placement test', () async {
      // Arrange
      final GetPathOverviewUseCase useCase = buildUseCase(
        history: <PlacementResultEntity>[
          _recommending('division', 'div:2'),
          _recommending('numbers', 'num:count10'),
        ],
      );
      // Act
      final PathOverviewEntity actual = (await useCase(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actual.recommendedDomainId, 'division');
    });

    test('no longer recommends a domain once it is finished', () async {
      // Arrange
      final GetPathOverviewUseCase useCase = buildUseCase(
        progress: _done('numbers', _numberUnits),
        history: <PlacementResultEntity>[
          _recommending('numbers', 'num:count10'),
        ],
      );
      // Act
      final PathOverviewEntity actual = (await useCase(
        params: 'p1',
      )).requireData;
      // Assert
      expect(actual.recommendedDomainId, isNull);
    });
  });
}
